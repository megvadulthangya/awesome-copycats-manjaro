--[[

     Steamburn-Nord Awesome WM theme
     last modified by: github.com/megvadulthangya
     Based on Steamburn by lcpz, modified with Nord color scheme elements

--]]

local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi   = require("beautiful.xresources").apply_dpi
local beautiful = require("beautiful") -- Szükséges a weather és a global wallpaper eléréséhez

local os = os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme                                     = {}
theme.zenburn_dir                               = require("awful.util").get_themes_dir() .. "zenburn"
theme.dir                                       = os.getenv("HOME") .. "/.config/awesome/themes/steamburn"

-- ============================================================================
-- ALAPÉRTELMEZETT HÁTTÉRKÉP (VISSZAKAPCSOLVA)
-- ============================================================================
theme.wallpaper                                 = theme.dir .. "/wall.png"
-- ============================================================================

theme.font                                      = "Terminus 12"
-- Nord color scheme base colors
theme.nord0  = "#2E3440"  -- darkest
theme.nord1  = "#3B4252"
theme.nord2  = "#434C5E"
theme.nord3  = "#4C566A"  -- bright
theme.nord4  = "#D8DEE9"  -- snow
theme.nord5  = "#E5E9F0"
theme.nord6  = "#ECEFF4"
theme.nord7  = "#8FBCBB"  -- frost
theme.nord8  = "#88C0D0"
theme.nord9  = "#81A1C1"
theme.nord10 = "#5E81AC"
theme.nord11 = "#BF616A"  -- aurora red
theme.nord12 = "#D08770"  -- aurora orange
theme.nord13 = "#EBCB8B"  -- aurora yellow
theme.nord14 = "#A3BE8C"  -- aurora green
theme.nord15 = "#B48EAD"  -- aurora purple

-- Updated theme colors with Nord influence
theme.fg_normal                                 = theme.nord4  -- light text
theme.fg_focus                                  = theme.nord12 -- orange focus
theme.fg_urgent                                 = theme.nord11 -- red urgent
theme.bg_normal                                 = theme.nord0  -- dark background
theme.bg_focus                                  = theme.nord1  -- slightly lighter for focus
theme.bg_urgent                                 = theme.nord1
theme.border_width                              = dpi(1)
theme.border_normal                             = theme.nord2  -- darker border
theme.border_focus                              = theme.nord12 -- orange border focus
theme.border_marked                             = theme.nord11 -- red marked
theme.taglist_fg_focus                          = theme.nord12
theme.tasklist_bg_focus                         = theme.nord1
theme.tasklist_fg_focus                         = theme.nord12
theme.taglist_squares_sel                       = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel                     = theme.dir .. "/icons/square_unsel.png"
theme.menu_height                               = dpi(20)
theme.menu_width                                = dpi(250)
theme.awesome_icon                              = theme.dir .."/icons/awesome.png"
theme.menu_submenu_icon                         = theme.dir .. "/icons/submenu.png"
theme.layout_txt_tile                           = "[t]"
theme.layout_txt_tileleft                       = "[l]"
theme.layout_txt_tilebottom                     = "[b]"
theme.layout_txt_tiletop                        = "[tt]"
theme.layout_txt_fairv                          = "[fv]"
theme.layout_txt_fairh                          = "[fh]"
theme.layout_txt_spiral                         = "[s]"
theme.layout_txt_dwindle                        = "[d]"
theme.layout_txt_max                            = "[m]"
theme.layout_txt_fullscreen                     = "[F]"
theme.layout_txt_magnifier                      = "[M]"
theme.layout_txt_floating                       = "[|]"
theme.tasklist_plain_task_name                  = true
theme.tasklist_disable_icon                     = true
theme.useless_gap                               = 0 -- RÉS NÉLKÜL
theme.titlebar_close_button_normal              = theme.zenburn_dir.."/titlebar/close_normal.png"
theme.titlebar_close_button_focus               = theme.zenburn_dir.."/titlebar/close_focus.png"
theme.titlebar_minimize_button_normal           = theme.zenburn_dir.."/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus            = theme.zenburn_dir.."/titlebar/minimize_focus.png"
theme.titlebar_ontop_button_normal_inactive     = theme.zenburn_dir.."/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive      = theme.zenburn_dir.."/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active       = theme.zenburn_dir.."/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active        = theme.zenburn_dir.."/titlebar/ontop_focus_active.png"
theme.titlebar_sticky_button_normal_inactive    = theme.zenburn_dir.."/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive     = theme.zenburn_dir.."/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active      = theme.zenburn_dir.."/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active       = theme.zenburn_dir.."/titlebar/sticky_focus_active.png"
theme.titlebar_floating_button_normal_inactive  = theme.zenburn_dir.."/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive   = theme.zenburn_dir.."/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active    = theme.zenburn_dir.."/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active     = theme.zenburn_dir.."/titlebar/floating_focus_active.png"
theme.titlebar_maximized_button_normal_inactive = theme.zenburn_dir.."/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = theme.zenburn_dir.."/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active   = theme.zenburn_dir.."/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active    = theme.zenburn_dir.."/titlebar/maximized_focus_active.png"

-- lain related
theme.layout_txt_termfair                       = "[termfair]"
theme.layout_txt_centerfair                     = "[centerfair]"

local markup = lain.util.markup
local gray   = theme.nord3 

-- Textclock
local mytextclock = wibox.widget.textclock(" %H:%M ")
mytextclock.font = theme.font

-- Calendar
theme.cal = lain.widget.cal({
    attach_to = { mytextclock },
    notification_preset = {
        font = "Terminus 11",
        fg   = theme.fg_normal,
        bg   = theme.bg_normal
    }
})

-- MPD
theme.mpd = lain.widget.mpd({
    settings = function()
        artist = mpd_now.artist .. " "
        title  = mpd_now.title  .. " "

        if mpd_now.state == "pause" then
            artist = "mpd "
            title  = "paused "
        elseif mpd_now.state == "stop" then
            artist = ""
            title  = ""
        end

        widget:set_markup(markup.font(theme.font, markup(gray, artist) .. title))
    end
})

-- CPU
local cpu = lain.widget.sysload({
    settings = function()
        widget:set_markup(markup.font(theme.font, markup(gray, " Cpu ") .. load_1 .. " "))
    end
})

-- MEM
local mem = lain.widget.mem({
    settings = function()
        widget:set_markup(markup.font(theme.font, markup(gray, " Mem ") .. mem_now.used .. " "))
    end
})

-- Battery
local bat = lain.widget.bat({
    settings = function()
        local perc = bat_now.perc
        if bat_now.ac_status == 1 then perc = perc .. " Plug" end
        widget:set_markup(markup.font(theme.font, markup(gray, " Bat ") .. perc .. " "))
    end
})

-- Net checker (MODERN Mbps/Gbps - Steamburn stílus)
local net = lain.widget.net({
    settings = function()
        local function format_speed_bits(speed_kb_per_sec)
            local speed_kbit = (tonumber(speed_kb_per_sec) or 0) * 8
            if speed_kbit >= 1000000 then -- Gbps
                return string.format("%.1f Gb", speed_kbit / 1000000)
            elseif speed_kbit >= 1000 then -- Mbps
                return string.format("%.1f Mb", speed_kbit / 1000)
            else -- Kbps
                return string.format("%.0f Kb", speed_kbit)
            end
        end

        local received = format_speed_bits(net_now.received)
        local sent     = format_speed_bits(net_now.sent)

        widget:set_markup(markup.font(theme.font, markup(gray, " Net ") .. received .. "↓ " .. sent .. "↑ "))
    end
})

-- ALSA volume
theme.volume = lain.widget.alsa({
    settings = function()
        header = " Vol "
        vlevel  = volume_now.level

        if volume_now.status == "off" then
            vlevel = vlevel .. "M "
        else
            vlevel = vlevel .. " "
        end

        widget:set_markup(markup.font(theme.font, markup(gray, header) .. vlevel))
    end
})

-- Separators
local first = wibox.widget.textbox(markup.font("Terminus 4", " "))
local spr   = wibox.widget.textbox(' ')

local function update_txt_layoutbox(s)
    local txt_l = theme["layout_txt_" .. awful.layout.getname(awful.layout.get(s))] or ""
    s.mytxtlayoutbox:set_text(txt_l)
end

function theme.at_screen_connect(s)
    s.quake = lain.util.quake({ app = awful.util.terminal })

    -- OKOS HÁTTÉRKÉP BEÁLLÍTÁS
    local wallpaper = beautiful.wallpaper 
    if wallpaper then
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end

    -- ====================================================================
    -- MINDEN MARGÓ ÉS HÉZAG NULLÁZÁSA (SZELLEM SÁV ELLEN)
    -- ====================================================================
    -- Késleltetve, hogy biztosan működjön
    gears.timer.delayed_call(function()
        s.padding = { left = 0, right = 0, top = 0, bottom = 0 }
    end)
    -- ====================================================================

    -- Tags
    awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])

    s.mypromptbox = awful.widget.prompt()

    s.mytxtlayoutbox = wibox.widget.textbox(theme["layout_txt_" .. awful.layout.getname(awful.layout.get(s))])
    awful.tag.attached_connect_signal(s, "property::selected", function () update_txt_layoutbox(s) end)
    awful.tag.attached_connect_signal(s, "property::layout", function () update_txt_layoutbox(s) end)
    s.mytxtlayoutbox:buttons(my_table.join(
                           awful.button({}, 1, function() awful.layout.inc(1) end),
                           awful.button({}, 2, function () awful.layout.set( awful.layout.layouts[1] ) end),
                           awful.button({}, 3, function() awful.layout.inc(-1) end),
                           awful.button({}, 4, function() awful.layout.inc(1) end),
                           awful.button({}, 5, function() awful.layout.inc(-1) end)))

    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

    -- Create the wibox with Nord background
    s.mywibox = awful.wibar({ 
        position = "top", 
        screen = s, 
        height = dpi(18),
        bg = theme.nord0
    })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            first,
            s.mytaglist,
            spr,
            s.mytxtlayoutbox,
            s.mypromptbox,
            spr,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            spr,
            theme.mpd.widget,
            cpu.widget,
            mem.widget,
            bat.widget,
            net.widget, -- Hálózat (Új)
            theme.volume.widget,
            beautiful.weather_widget, -- Időjárás (Új)
            mytextclock
        },
    }
    -- ALSÓ SÁV KÓDJA TELJESEN TÖRÖLVE!
end

return theme
