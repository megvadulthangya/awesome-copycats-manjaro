-- modules/tag-retain.lua
--
-- Integrates the external "awesome-retain" module for per-user tag
-- persistence (names + layouts) across reboots and awesome restarts.
--
-- Dependencies:
--   * "retain"  — the awesome-retain Lua module (EDID fork)
--   * "json"    — the lua-json fork providing json.encode / json.decode
--
-- Design notes
-- ------------
-- * No theme file is modified. Every theme in this fork creates tags via
--   `awful.tag(awful.util.tagnames, s, layout)` inside its own
--   `beautiful.at_screen_connect(s)`. We wrap that function so the theme
--   sees the per-screen retained names at call time, then we restore the
--   static fallback afterwards.
-- * Per-tag saved layouts are applied AFTER the theme creates the tags.
-- * Save triggers: retain's own `connect_signals()` (exit + screen-removed),
--   plus `awesome::restart`, plus a 15s periodic timer for crash safety.

local awful     = require("awful")
local gears     = require("gears")
local beautiful = require("beautiful")
local naughty   = require("naughty")

local M = {}

-- Static fallback used when no saved data exists or retain is missing.
local DEFAULT_TAGNAMES = { "1", "2", "3", "4", "5" }

function M.setup()
    local ok, retain = pcall(require, "retain")
    if not ok then
        naughty.notify({
            preset = naughty.config.presets.critical,
            title  = "awesome-retain",
            text   = "Could not load the 'retain' module:\n"
                     .. tostring(retain)
                     .. "\n\nTag persistence is DISABLED for this session.",
        })
        return
    end

    local xdg_cfg = gears.filesystem.get_xdg_config_home()  -- ends with '/'
    retain.tags.savefile = xdg_cfg .. "awesome/tags.save"

    os.execute("mkdir -p '" .. xdg_cfg .. "awesome'")

    local fh = io.open(retain.tags.savefile, "r")
    if fh then
        fh:close()
    else
        local fw = io.open(retain.tags.savefile, "w")
        if fw then
            fw:write("{}")
            fw:close()
        end
    end

    retain.tags.defaults.names = DEFAULT_TAGNAMES

    local load_ok, load_err = pcall(retain.tags.load)
    if not load_ok then
        naughty.notify({
            preset = naughty.config.presets.critical,
            title  = "awesome-retain",
            text   = "retain.tags.load() failed:\n"
                     .. tostring(load_err)
                     .. "\n\nTag persistence is DISABLED for this session.",
        })
        return
    end

    pcall(retain.connect_signals)

    awesome.connect_signal("restart", function()
        pcall(retain.tags.save_all)
    end)

    M._timer = gears.timer {
        timeout   = 15,
        autostart = true,
        callback  = function() pcall(retain.tags.save_all) end,
    }

    awesome.connect_signal("exit", function()
        if M._timer then M._timer:stop() end
    end)

    local orig_at_screen_connect = beautiful.at_screen_connect
    beautiful.at_screen_connect = function(s)
        local names = retain.tags.getnames(s)
        if not names or #names == 0 then
            names = DEFAULT_TAGNAMES
        end

        local prev_tagnames = _G.tagnames or DEFAULT_TAGNAMES
        _G.tagnames         = names
        awful.util.tagnames = names

        orig_at_screen_connect(s)

        -- Apply saved per-tag layouts if we have saved data for this screen
        local sid = retain.get_screen_id(s)
        local saved = retain.tags._mytags[sid]
        if saved and saved.layouts then
            for i, tag in ipairs(s.tags) do
                if saved.layouts[i] then
                    tag.layout = saved.layouts[i]
                end
            end
        end

        _G.tagnames         = prev_tagnames
        awful.util.tagnames = prev_tagnames
    end

    M._retain = retain
end

return M