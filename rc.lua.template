--[[
      Awesome WM configuration (Modularized & Fixed)
	You can find all of the modules, in /etc/xdg/awesome
--]]

-- {{{ Required libraries
pcall(require, "luarocks.loader")

local gears         = require("gears")
local awful         = require("awful")
                      require("awful.autofocus")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local freedesktop   = require("freedesktop")
local hotkeys_popup = require("awful.hotkeys_popup")
                      require("awful.hotkeys_popup.keys")

-- Betöltjük a widget modulokat (pl. időjárás)
local weather_widget = require("widgets.weather")
-- }}}

-- {{{ Error handling
if awesome.startup_errors then
    naughty.notify {
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    }
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true
        naughty.notify {
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        }
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Témák listája
local themes = {
    "blackburn",       -- 1
    "copland",         -- 2
    "dremora",         -- 3
    "holo",            -- 4
    "multicolor",      -- 5
    "powerarrow",      -- 6
    "powerarrow-dark", -- 7
    "rainbow",         -- 8
    "steamburn",       -- 9
    "vertex"           -- 10
}

local chosen_theme = themes[7] -- Jelenleg: powerarrow-dark

-- Globális változók (_G) - ezeket látják a modulok is
_G.modkey       = "Mod4"
_G.altkey       = "Mod1"
_G.terminal     = "tilix"
_G.vi_focus     = false 
_G.cycle_prev   = true  
_G.editor       = os.getenv("EDITOR") or "nano"
_G.browser      = "brave"

-- ===================================================================
-- FONTOS JAVÍTÁS (A hiba elkerülése végett)
-- ===================================================================
-- A témafájlok az 'awful.util' táblából olvassák a terminált és a gombokat.
-- Ezeket ITT kell definiálni, még mielőtt betöltjük a témát.

awful.util.terminal = _G.terminal
awful.util.tagnames = { "1", "2", "3", "4", "5" }

-- Betöltjük a layout és tag beállításokat a külön fájlból
local tags_config = require("configuration.tags")
awful.layout.layouts = tags_config.layouts

-- Átadjuk a gombokat az awful.util-nak, mert a téma innen veszi
awful.util.taglist_buttons = tags_config.taglist_buttons
awful.util.tasklist_buttons = tags_config.tasklist_buttons

-- ===================================================================
-- TÉMA BETÖLTÉSE
-- ===================================================================
-- Most már biztonságos betölteni, mert a fenti változók léteznek.
beautiful.init(string.format("/usr/share/awesome/themes/%s/theme.lua", chosen_theme))
beautiful.wallpaper = nil

-- Időjárás widget csatlakoztatása a témához
beautiful.weather_widget = weather_widget

-- }}}

-- {{{ Menu
local myawesomemenu = {
   { "Hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "Manual", string.format("%s -e man awesome", _G.terminal) },
   { "Edit config", string.format("%s -e %s %s", _G.terminal, _G.editor, awesome.conffile) },
   { "reload cfg", awesome.restart },
   { "=========", },
   { "=Logout=", function() awesome.quit() end },
   { "=Reboot=", "systemctl reboot" },
   { "=Power Off=", "systemctl poweroff" },
}

awful.util.mymainmenu = freedesktop.menu.build {
    before = {
        { "Awesome", myawesomemenu, beautiful.awesome_icon },
    },
    after = {
        { "Open terminal", _G.terminal },
    }
}
-- }}}

-- {{{ Screen
-- Itt NINCSEN háttérkép állítás (property::geometry),
-- mert azt a téma intézi, mi pedig felülírjuk az autostarttal a végén.

-- Keretek eltüntetése, ha csak egy ablak van
screen.connect_signal("arrange", function (s)
    local only_one = #s.tiled_clients == 1
    for _, c in pairs(s.clients) do
        if only_one and not c.floating or c.maximized or c.fullscreen then
            c.border_width = 0
        else
            c.border_width = beautiful.border_width
        end
    end
end)

-- Képernyők beállítása (Taglist, Tasklist, Wibar - ami a témából jön)
awful.screen.connect_for_each_screen(function(s) 
    -- Ez a függvény (ami a témában van) teszi ki a wibart és a téma hátterét
    beautiful.at_screen_connect(s) 
end)
-- }}}

-- {{{ Key Bindings (Billentyűk betöltése külön fájlból)
local keys = require("configuration.keys")
root.buttons(keys.rootbuttons)
root.keys(keys.globalkeys)
-- }}}

-- {{{ Rules (Szabályok betöltése külön fájlból)
local rules = require("configuration.rules")
awful.rules.rules = rules.create(keys.clientkeys, keys.clientbuttons)
-- }}}

-- {{{ Signals (Eseménykezelők betöltése)
require("signals.init")
-- }}}

-- {{{ Session management
local session = require("modules.session-manager")
awesome.connect_signal("exit", function() session.save() end)
awesome.connect_signal("restart", function() session.save() end)
session.load()
-- }}}

-- {{{ Autostart (INDÍTÁSI PARANCSOK)
-- EZT TESSZÜK A LEGVÉGÉRE!
-- Ez tartalmazza a 'feh' parancsot. Mivel ez fut le utoljára,
-- ez fogja felülírni a téma által beállított háttérképet a sajátodra.
require("configuration.autostart")
-- }}}