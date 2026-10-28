local awful = require("awful")
local gears = require("gears")

local session = {}

local session_file = gears.filesystem.get_cache_dir() .. "awesome-session.lua"
local debug_log    = gears.filesystem.get_cache_dir() .. "session-debug.log"
local session_data = nil
local skip_save    = false   -- true for 3s after any client unmanages

local function log(msg)
    local f = io.open(debug_log, "a")
    if f then
        f:write(os.date("%Y-%m-%d %H:%M:%S") .. "  " .. msg .. "\n")
        f:close()
    end
end

local function sanitize(s)
    return (s:gsub("[^%w%-_]", "_"))
end

log("========== AWESOME SESSION START ==========")

local function executable_exists(name)
    local h = io.popen("command -v " .. name .. " 2>/dev/null")
    if not h then return false end
    local r = h:read("*l")
    h:close()
    return r ~= nil and r ~= ""
end

local brave_bin = "brave"
if not executable_exists("brave") then
    if executable_exists("brave-browser") then
        brave_bin = "brave-browser"
    else
        log("WARNING: neither 'brave' nor 'brave-browser' found on PATH")
    end
end
local brave_cmd = brave_bin
    .. " --restore-last-session"
    .. " --disable-dev-shm-usage"
    .. " --disable-features=SendToYourDevices"
log("brave command: " .. brave_cmd)

local multi_window_apps = {
    ["Brave-browser"] = true,
    ["brave-browser"] = true,
}

local command_map = {
    ["Com.gexperts.Tilix"] = "tilix",
    ["Brave-browser"]      = brave_cmd,
    ["brave-browser"]      = brave_cmd,
    ["Geany"]              = "geany",
    ["XnViewMP"]           = "xnviewmp",
}

local function serialize(tbl, indent)
    indent = indent or 0
    local towrite = "{\n"
    indent = indent + 2
    for k, v in pairs(tbl) do
        towrite = towrite .. string.rep(" ", indent)
        if type(k) == "number" then
            towrite = towrite .. "[" .. k .. "] = "
        else
            towrite = towrite .. k .. " = "
        end
        if type(v) == "number" then
            towrite = towrite .. v .. ",\n"
        elseif type(v) == "string" then
            towrite = towrite .. string.format("%q", v) .. ",\n"
        elseif type(v) == "table" then
            towrite = towrite .. serialize(v, indent) .. ",\n"
        end
    end
    indent = indent - 2
    towrite = towrite .. string.rep(" ", indent) .. "}"
    return towrite
end

function session.save()
    if skip_save then
        log("save: SKIPPED (client unmanaged in last 3s - likely logout)")
        return
    end
    log("save() called")
    local clients = {}
    
    -- Get retain for screen ID mapping
    local retain = nil
    local ok, r = pcall(require, "retain")
    if ok then retain = r end
    
    for _, c in ipairs(client.get()) do
        if c.class and c.first_tag then
            local cmd = command_map[c.class] or command_map[c.instance]
            if not cmd then
                cmd = (c.instance and c.instance ~= "") and c.instance or c.class
            end
            
            local sid = (retain and retain.get_screen_id) and retain.get_screen_id(c.screen) or tostring(c.screen.index)
            
            table.insert(clients, {
                class    = c.class,
                instance = c.instance or "",
                screen_id= sid,
                tag      = c.first_tag.index,
                layout   = c.first_tag.layout.name,
                cmd      = cmd,
            })
            log(string.format("  save: %s -> %s (screen: %s)", c.class, cmd, sid))
        end
    end
    local file = io.open(session_file, "w")
    if file then
        file:write("return " .. serialize(clients))
        file:close()
        log("save: wrote " .. #clients .. " entries")
    else
        log("save: ERROR cannot write " .. session_file)
    end
end

local function build_spawn_command(cmd, class, delay)
    local safe      = sanitize(class)
    local spawn_log = gears.filesystem.get_cache_dir() .. "spawn-" .. safe .. ".log"
    local clr = io.open(spawn_log, "w")
    if clr then clr:write("") ; clr:close() end
    local cleanup = ""
    if class == "Brave-browser" or class == "brave-browser" then
        cleanup = "rm -rf ~/.config/BraveSoftware/Brave-Browser/Singleton* 2>/dev/null; "
    end
    return string.format(
        "%ssleep %d && %s > %q 2>&1; echo \"EXIT:$?\" >> %q",
        cleanup, delay, cmd, spawn_log, spawn_log
    )
end

function session.load()
    log("load() called")
    local ok, data = pcall(dofile, session_file)
    if not ok or not data then
        log("load: no session file or parse error: " .. tostring(data))
    else
        session_data = data
        log("load: read " .. #session_data .. " entries")
    end

    gears.timer {
        timeout = 15,
        autostart = true,
        callback = function() session.save() end,
    }

    client.connect_signal("unmanage", function(c)
        log("unmanage: " .. (c.class or "?") .. " instance=" .. (c.instance or "?"))
        skip_save = true
        gears.timer.start_new(3, function()
            skip_save = false
            return false
        end)
    end)

    if not session_data then return end

    -- Override cmd from current command_map
    for _, entry in ipairs(session_data) do
        if command_map[entry.class] and entry.cmd ~= command_map[entry.class] then
            entry.cmd = command_map[entry.class]
        end
    end

    local delay = 10
    local spawned = {}

    for _, entry in ipairs(session_data) do
        local cmd = entry.cmd or entry.class
        local class = entry.class
        local should_spawn = true
        if multi_window_apps[class] then
            if spawned[class] then
                should_spawn = false
                log("load: skip duplicate spawn for " .. class)
            else
                spawned[class] = true
            end
        end
        if should_spawn then
            local wrapped = build_spawn_command(cmd, class, delay)
            log("load: spawning -> " .. cmd)
            awful.spawn.with_shell(wrapped)
        end
    end

    client.connect_signal("manage", function(c)
        if not session_data then return end
        
        local retain = nil
        local ok, r = pcall(require, "retain")
        if ok then retain = r end
        
        for i = #session_data, 1, -1 do
            local entry = session_data[i]
            if c.class == entry.class then
                log(string.format("manage: %s -> tag %d", c.class, entry.tag))
                
                local target_screen = nil
                if entry.screen_id and retain and retain.get_screen_id then
                    for s in screen do
                        if retain.get_screen_id(s) == entry.screen_id then
                            target_screen = s
                            break
                        end
                    end
                elseif entry.screen then
                    -- Fallback for old sessions that didn't have screen_id but had screen
                    target_screen = screen[entry.screen]
                end

                if target_screen then
                    local tt = target_screen.tags[entry.tag]
                    if tt then
                        c:move_to_tag(tt)
                        if tt.layout.name ~= entry.layout then
                            for _, l in ipairs(awful.layout.layouts) do
                                if l.name == entry.layout then
                                    awful.layout.set(l, tt)
                                    break
                                end
                            end
                        end
                        tt:view_only()
                    end
                else
                    log("manage: target screen not found for " .. c.class)
                end
                table.remove(session_data, i)
                break
            end
        end
    end)
end

return session