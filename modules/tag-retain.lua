-- modules/tag-retain.lua
--
-- Integrates the external "awesome-retain" module for per-user tag
-- persistence (names + layouts) across reboots and awesome restarts.
--
-- Design notes
-- ------------
-- * No theme file is modified. Every theme in this fork creates tags via
--   `awful.tag(awful.util.tagnames, s, layout)` inside its own
--   `beautiful.at_screen_connect(s)`. We wrap that function so the theme
--   sees the per-screen retained names at call time, then we restore the
--   static fallback afterwards.
-- * Per-tag saved layouts are applied AFTER the theme creates the tags
--   (via `tag.layout = ...`). Themes that create all tags with one layout
--   get their per-tag layouts restored this way.
-- * Save triggers: retain's own `connect_signals()` (exit + screen-removed),
--   plus `awesome::restart`, plus a 15s periodic timer for crash safety
--   (same pattern as session-manager).
-- * The session-manager is NOT touched. This module only persists the tag
--   list; window/app restore stays in session-manager.
-- * Save file lives in the per-user XDG config dir so it survives system
--   updates and never tries to write into root-owned /etc/xdg/awesome/.

local awful     = require("awful")
local gears     = require("gears")
local beautiful = require("beautiful")
local naughty   = require("naughty")

local M = {}

-- Static fallback used when no saved data exists (fresh user, new monitor)
-- or when the saved list has been emptied (user deleted every tag). Matches
-- the original _G.tagnames in rc.lua so behaviour is unchanged pre-retain.
local DEFAULT_TAGNAMES = { "1", "2", "3", "4", "5" }

function M.setup()
    -- Load the external module. If its dependency (lua-json) is missing,
    -- fail gracefully and keep the pre-retain behaviour.
    local ok, retain = pcall(require, "retain")
    if not ok then
        naughty.notify({
            preset = naughty.config.presets.critical,
            title  = "awesome-retain",
            text   = "Could not load the 'retain' module:\n" .. tostring(retain)
                     .. "\n\nTag persistence is DISABLED.\n"
                     .. "Install 'lua-json' (pacman -S lua-json) to enable it.",
        })
        return
    end

    -- Per-user save location. The system config lives in /etc/xdg/awesome/
    -- (root-owned), so retain's default
    -- (get_configuration_dir() .. 'retain.json') would fail to write.
    local xdg_cfg = gears.filesystem.get_xdg_config_home()  -- ends with '/'
    retain.tags.savefile = xdg_cfg .. "awesome/tags.save"

    -- Ensure the parent directory exists (should already, but be safe).
    os.execute("mkdir -p '" .. xdg_cfg .. "awesome'")

    -- Pre-create an empty JSON object so retain's load() does not pop a
    -- "critical: No save file found" notification on the very first boot.
    -- {} decodes to an empty table -> clean no-op -> falls back to defaults.
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

    -- Defaults for screens that have never been saved.
    -- Names: same as the pre-retain hardcoded fallback.
    -- Layouts: deliberately NOT overridden — fresh screens keep whatever
    -- layout the active theme chose. We only *apply* saved layouts.
    retain.tags.defaults.names = DEFAULT_TAGNAMES

    -- Load saved state into retain.tags._mytags / _loaded.
    retain.tags.load()

    -- Connect retain's own signals (exit + screen::removed).
    retain.connect_signals()

    -- Also save on awesome restart (Mod4+Ctrl+r). Redundant with 'exit'
    -- for restart specifically, but harmless and explicit.
    awesome.connect_signal("restart", retain.tags.save_all)

    -- Periodic save for crash safety (same pattern as session-manager).
    -- 15s is plenty for a tiny JSON file; a hard crash loses at most 15s.
    M._timer = gears.timer {
        timeout   = 15,
        autostart = true,
        callback  = function() retain.tags.save_all() end,
    }

    -- Stop the periodic timer as soon as awesome is about to exit so it
    -- can never fire mid-teardown and overwrite the last good save.
    -- (connect_signals' 'exit' handler runs first — registration order —
    -- so save_all has already written the good data before we stop.)
    awesome.connect_signal("exit", function()
        if M._timer then M._timer:stop() end
    end)

    -- ------------------------------------------------------------------
    -- Wrap beautiful.at_screen_connect so the theme sees per-screen names.
    --
    -- The theme body does `awful.tag(awful.util.tagnames, s, layout)`.
    -- Both `_G.tagnames` and `awful.util.tagnames` are plain table refs,
    -- so swapping them right before the theme runs is enough. After the
    -- theme returns we:
    --   1. apply any saved per-tag layouts (only if this screen has data)
    --   2. restore the static fallback so other consumers see consistent
    --      values (taglist widgets read s.tags directly, not tagnames)
    -- ------------------------------------------------------------------
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

        -- Apply saved per-tag layouts. Only if we actually have saved data
        -- for this screen — a fresh screen keeps the theme's own layout.
        local saved = retain.tags._mytags[s.sid]
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