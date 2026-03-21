local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")   -- for optional debug notifications

local session = {}

local session_file = gears.filesystem.get_cache_dir() .. "awesome-session.lua"
local session_data = nil

-- Mapping from WM_CLASS to actual command for applications where the
-- executable name differs from the class/instance.
-- Add entries here for any application that doesn't start correctly.
local command_map = {
    ["Com.gexperts.Tilix"] = "tilix",
    ["Brave-browser"]      = "brave",
    ["Geany"]              = "geany",
    ["XnViewMP"]           = "xnviewmp",
    -- Example for Grayjay (once you know its WM_CLASS):
    -- ["Grayjay"]         = "grayjay",
}

-- Set to true to see notifications when a client is skipped during save
local debug_notify = false

-- Simple Lua table serializer (adapted from original)
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

-- Save current session
function session.save()
    local clients = {}

    for _, c in ipairs(client.get()) do
        -- Only save clients that have a class and are attached to a tag
        if c.class and c.first_tag then
            -- Determine the command to spawn later
            local cmd = command_map[c.class]
            if not cmd then
                cmd = (c.instance and c.instance ~= "") and c.instance or c.class
            end

            table.insert(clients, {
                class    = c.class,
                instance = c.instance or "",
                screen   = c.screen.index,
                tag      = c.first_tag.index,
                layout   = c.first_tag.layout.name,
                cmd      = cmd,   -- store the command for spawning
            })
        elseif debug_notify then
            naughty.notify {
                title   = "Session Manager",
                text    = "Skipped client: no class or tag\n" ..
                          (c.name or "unknown"),
                timeout = 3
            }
        end
    end

    local file = io.open(session_file, "w")
    if file then
        file:write("return " .. serialize(clients))
        file:close()
    end
end

-- Load and restore session
function session.load()
    local ok, data = pcall(dofile, session_file)
    if not ok or not data then
        return
    end

    session_data = data

    -- Spawn all saved applications using the stored cmd field
    for _, entry in ipairs(session_data) do
        if entry.cmd then
            awful.spawn(entry.cmd)
        else
            -- Fallback (should never happen with new saves)
            awful.spawn(entry.class)
        end
    end

    -- Connect a one‑time signal handler to place clients as they appear
    client.connect_signal("manage", function(c)
        if not session_data then return end

        for i = #session_data, 1, -1 do   -- iterate backwards to allow safe removal
            local entry = session_data[i]

            -- Match both class and instance to uniquely identify the client
            if c.class == entry.class and c.instance == entry.instance then
                -- Move to the saved screen if it still exists
                local target_screen = screen[entry.screen]
                if target_screen then
                    local target_tag = target_screen.tags[entry.tag]
                    if target_tag then
                        c:move_to_tag(target_tag)
                        
                        -- Restore the tag’s layout safely
                        if target_tag.layout.name ~= entry.layout then
                            -- Meg kell keresni a stringhez tartozó layout objektumot
                            local actual_layout = nil
                            for _, l in ipairs(awful.layout.layouts) do
                                if l.name == entry.layout then
                                    actual_layout = l
                                    break
                                end
                            end
                            
                            -- Ha megtaláltuk az objektumot, beállítjuk
                            if actual_layout then
                                awful.layout.set(actual_layout, target_tag)
                            end
                        end
                        target_tag:view_only()
                    end
                end
                -- Remove this entry so it isn’t used again
                table.remove(session_data, i)
                break
            end
        end
    end)
end

return session
