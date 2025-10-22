--[[
     Nord Multicolor Awesome WM theme 2.0
     Based on multicolor theme by github.com/lcpz
     last modified by: github.com/megvadulthangya
     Adapted with Nord color scheme
--]]

local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi   = require("beautiful.xresources").apply_dpi

local os = os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme = {}

-- Nord Color Scheme
theme.nord0  = "#2E3440"  -- darkest gray
theme.nord1  = "#3B4252"  -- dark gray
theme.nord2  = "#434C5E"  -- medium gray
theme.nord3  = "#4C566A"  -- light gray
theme.nord4  = "#D8DEE9"  -- lightest gray
theme.nord5  = "#E5E9F0"  -- off white
theme.nord6  = "#ECEFF4"  -- white
theme.nord7  = "#8FBCBB"  -- teal
theme.nord8  = "#88C0D0"  -- light blue
theme.nord9  = "#81A1C1"  -- blue
theme.nord10 = "#5E81AC"  -- dark blue
theme.nord11 = "#BF616A"  -- red
theme.nord12 = "#D08770"  -- orange
theme.nord13 = "#EBCB8B"  -- yellow
theme.nord14 = "#A3BE8C"  -- green
theme.nord15 = "#B48EAD"  -- purple

theme.confdir = os.getenv("HOME") .. "/.config/awesome/themes/multicolor"
theme.wallpaper = theme.confdir .. "/wall.png"
theme.font = "Terminus 12"

-- Main colors
theme.menu_bg_normal = theme.nord0
theme.menu_bg_focus = theme.nord1
theme.bg_normal = theme.nord0
theme.bg_focus = theme.nord1
theme.bg_urgent = theme.nord11
theme.fg_normal = theme.nord4
theme.fg_focus = theme.nord8
theme.fg_urgent = theme.nord6
theme.fg_minimize = theme.nord3

-- Borders
theme.border_width = dpi(1)
theme.border_normal = theme.nord1
theme.border_focus = theme.nord8
theme.border_marked = theme.nord12

-- Menu
theme.menu_border_width = 0
theme.menu_width = dpi(250)
theme.menu_submenu_icon = theme.confdir .. "/icons/submenu.png"
theme.menu_fg_normal = theme.nord4
theme.menu_fg_focus = theme.nord8
theme.menu_bg_normal = theme.nord0 .. "dd"
theme.menu_bg_focus = theme.nord1 .. "dd"

-- Widget icons (paths remain the same)
theme.widget_temp = theme.confdir .. "/icons/temp.png"
theme.widget_uptime = theme.confdir .. "/icons/ac.png"
theme.widget_cpu = theme.confdir .. "/icons/cpu.png"
theme.widget_weather = theme.confdir .. "/icons/dish.png"
theme.widget_fs = theme.confdir .. "/icons/fs.png"
theme.widget_mem = theme.confdir .. "/icons/mem.png"
theme.widget_note = theme.confdir .. "/icons/note.png"
theme.widget_note_on = theme.confdir .. "/icons/note_on.png"
theme.widget_netdown = theme.confdir .. "/icons/net_down.png"
theme.widget_netup = theme.confdir .. "/icons/net_up.png"
theme.widget_mail = theme.confdir .. "/icons/mail.png"
theme.widget_batt = theme.confdir .. "/icons/bat.png"
theme.widget_clock = theme.confdir .. "/icons/clock.png"
theme.widget_vol = theme.confdir .. "/icons/spkr.png"

-- Taglist
theme.taglist_squares_sel = theme.confdir .. "/icons/square_a.png"
theme.taglist_squares_unsel = theme.confdir .. "/icons/square_b.png"

-- Tasklist
theme.tasklist_plain_task_name = true
theme.tasklist_disable_icon = true
theme.useless_gap = 0

-- Layout icons (paths remain the same)
theme.layout_tile = theme.confdir .. "/icons/tile.png"
theme.layout_tilegaps = theme.confdir .. "/icons/tilegaps.png"
theme.layout_tileleft = theme.confdir .. "/icons/tileleft.png"
theme.layout_tilebottom = theme.confdir .. "/icons/tilebottom.png"
theme.layout_tiletop = theme.confdir .. "/icons/tiletop.png"
theme.layout_fairv = theme.confdir .. "/icons/fairv.png"
theme.layout_fairh = theme.confdir .. "/icons/fairh.png"
theme.layout_spiral = theme.confdir .. "/icons/spiral.png"
theme.layout_dwindle = theme.confdir .. "/icons/dwindle.png"
theme.layout_max = theme.confdir .. "/icons/max.png"
theme.layout_fullscreen = theme.confdir .. "/icons/fullscreen.png"
theme.layout_magnifier = theme.confdir .. "/icons/magnifier.png"
theme.layout_floating = theme.confdir .. "/icons/floating.png"

-- Titlebar icons (paths remain the same)
theme.titlebar_close_button_normal = theme.confdir .. "/icons/titlebar/close_normal.png"
theme.titlebar_close_button_focus = theme.confdir .. "/icons/titlebar/close_focus.png"
theme.titlebar_minimize_button_normal = theme.confdir .. "/icons/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus = theme.confdir .. "/icons/titlebar/minimize_focus.png"
theme.titlebar_ontop_button_normal_inactive = theme.confdir .. "/icons/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive = theme.confdir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = theme.confdir .. "/icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active = theme.confdir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_sticky_button_normal_inactive = theme.confdir .. "/icons/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive = theme.confdir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = theme.confdir .. "/icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active = theme.confdir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_floating_button_normal_inactive = theme.confdir .. "/icons/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive = theme.confdir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = theme.confdir .. "/icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active = theme.confdir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_maximized_button_normal_inactive = theme.confdir .. "/icons/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive = theme.confdir .. "/icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = theme.confdir .. "/icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active = theme.confdir .. "/icons/titlebar/maximized_focus_active.png"

local markup = lain.util.markup

-- Textclock with Nord colors
os.setlocale(os.getenv("LANG"))
local clockicon = wibox.widget.imagebox(theme.widget_clock)
local mytextclock = wibox.widget.textclock(
    markup(theme.nord9, "%A %d %B ") .. 
    markup(theme.nord12, ">") .. 
    markup(theme.nord8, " %H:%M ")
)
mytextclock.font = theme.font

-- Calendar
theme.cal = lain.widget.cal({
    attach_to = { mytextclock },
    notification_preset = {
        font = "Terminus 10",
        fg   = theme.nord4,
        bg   = theme.nord0
    }
})

-- CPU with Nord colors
local cpuicon = wibox.widget.imagebox(theme.widget_cpu)
local cpu = lain.widget.cpu({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, theme.nord11, cpu_now.usage .. "% "))
    end
})

-- Coretemp with Nord colors
local tempicon = wibox.widget.imagebox(theme.widget_temp)
local temp = lain.widget.temp({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, theme.nord12, coretemp_now .. "°C "))
    end
})

-- Battery with Nord colors
local baticon = wibox.widget.imagebox(theme.widget_batt)
local bat = lain.widget.bat({
    settings = function()
        local perc = bat_now.perc ~= "N/A" and bat_now.perc .. "%" or bat_now.perc

        if bat_now.ac_status == 1 then
            perc = perc .. " plug"
        end

        widget:set_markup(markup.fontfg(theme.font, theme.nord14, perc .. " "))
    end
})

-- ALSA volume with Nord colors
local volicon = wibox.widget.imagebox(theme.widget_vol)
theme.volume = lain.widget.alsa({
    settings = function()
        if volume_now.status == "off" then
            volume_now.level = volume_now.level .. "M"
        end

        widget:set_markup(markup.fontfg(theme.font, theme.nord9, volume_now.level .. "% "))
    end
})

-- Net with Nord colors
local netdownicon = wibox.widget.imagebox(theme.widget_netdown)
local netdowninfo = wibox.widget.textbox()
local netupicon = wibox.widget.imagebox(theme.widget_netup)
local netupinfo = lain.widget.net({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, theme.nord11, net_now.sent .. " "))
        netdowninfo:set_markup(markup.fontfg(theme.font, theme.nord14, net_now.received .. " "))
    end
})

-- MEM with Nord colors
local memicon = wibox.widget.imagebox(theme.widget_mem)
local memory = lain.widget.mem({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, theme.nord13, mem_now.used .. "M "))
    end
})

-- MPD with Nord colors
local mpdicon = wibox.widget.imagebox()
theme.mpd = lain.widget.mpd({
    settings = function()
        mpd_notification_preset = {
            text = string.format("%s [%s] - %s\n%s", mpd_now.artist,
                   mpd_now.album, mpd_now.date, mpd_now.title)
        }

        if mpd_now.state == "play" then
            artist = mpd_now.artist .. " > "
            title  = mpd_now.title .. " "
            mpdicon:set_image(theme.widget_note_on)
        elseif mpd_now.state == "pause" then
            artist = "mpd "
            title  = "paused "
        else
            artist = ""
            title  = ""
            mpdicon._private.image = nil
            mpdicon:emit_signal("widget::redraw_needed")
            mpdicon:emit_signal("widget::layout_changed")
        end
        widget:set_markup(
            markup.fontfg(theme.font, theme.nord15, artist) .. 
            markup.fontfg(theme.font, theme.nord4, title)
        )
    end
})

function theme.at_screen_connect(s)
    -- Quake application
    s.quake = lain.util.quake({ app = awful.util.terminal })

    -- If wallpaper is a function, call it with the screen
    local wallpaper = theme.wallpaper
    if type(wallpaper) == "function" then
        wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)

    -- Tags
    awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create layoutbox
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(my_table.join(
        awful.button({}, 1, function () awful.layout.inc( 1) end),
        awful.button({}, 2, function () awful.layout.set( awful.layout.layouts[1] ) end),
        awful.button({}, 3, function () awful.layout.inc(-1) end),
        awful.button({}, 4, function () awful.layout.inc( 1) end),
        awful.button({}, 5, function () awful.layout.inc(-1) end)
    ))

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

    -- Create the top wibox
    s.mywibox = awful.wibar({
        position = "top", 
        screen = s, 
        height = dpi(19), 
        bg = theme.nord0, 
        fg = theme.nord4
    })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
            mpdicon,
            theme.mpd.widget,
        },
        nil, -- Middle widget (empty)
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            netdownicon,
            netdowninfo,
            netupicon,
            netupinfo.widget,
            volicon,
            theme.volume.widget,
            memicon,
            memory.widget,
            cpuicon,
            cpu.widget,
            tempicon,
            temp.widget,
            baticon,
            bat.widget,
            clockicon,
            mytextclock,
        },
    }

    -- Create the bottom wibox
    s.mybottomwibox = awful.wibar({
        position = "bottom", 
        screen = s, 
        border_width = 0, 
        height = dpi(20), 
        bg = theme.nord0, 
        fg = theme.nord4
    })

    -- Add widgets to the bottom wibox
    s.mybottomwibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            s.mylayoutbox,
        },
    }
end

return theme
