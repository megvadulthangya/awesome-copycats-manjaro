--[[

     Powerarrow Awesome WM theme - Nord color scheme
     last modified by: github.com/megvadulthangya
     Based on: github.com/lcpz

--]]

local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi   = require("beautiful.xresources").apply_dpi

local math, string, os = math, string, os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme                                     = {}
theme.dir                                       = os.getenv("HOME") .. "/.config/awesome/themes/powerarrow"
theme.wallpaper                                 = theme.dir .. "/wall.png"
theme.font                                      = "Terminus 12"
-- Nord color scheme - sötétebb háttérszínekkel
theme.fg_normal                                 = "#D8DEE9"  -- nord4 - világos szöveg
theme.fg_focus                                  = "#88C0D0"  -- nord8 - világos kék
theme.fg_urgent                                 = "#BF616A"  -- nord11 - piros
theme.bg_normal                                 = "#3B4252"  -- nord1 - sötétebb háttér
theme.bg_focus                                  = "#434C5E"  -- nord2 - kicsit világosabb
theme.bg_urgent                                 = "#4C566A"  -- nord3 - közepes
theme.taglist_fg_focus                          = "#88C0D0"  -- nord8 - világos kék
theme.tasklist_bg_focus                         = "#3B4252"  -- nord1
theme.tasklist_fg_focus                         = "#88C0D0"  -- nord8
theme.border_width                              = dpi(2)
theme.border_normal                             = "#4C566A"  -- nord3
theme.border_focus                              = "#81A1C1"  -- nord9 - kék
theme.border_marked                             = "#BF616A"  -- nord11 - piros
theme.titlebar_bg_focus                         = "#434C5E"  -- nord2
theme.titlebar_bg_normal                        = "#434C5E"  -- nord2
theme.titlebar_bg_focus                         = theme.bg_focus
theme.titlebar_bg_normal                        = theme.bg_normal
theme.titlebar_fg_focus                         = theme.fg_focus
theme.menu_height                               = dpi(20)
theme.menu_width                                = dpi(250)
theme.menu_submenu_icon                         = theme.dir .. "/icons/submenu.png"
theme.awesome_icon                              = theme.dir .. "/icons/awesome.png"
theme.taglist_squares_sel                       = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel                     = theme.dir .. "/icons/square_unsel.png"
theme.layout_tile                               = theme.dir .. "/icons/tile.png"
theme.layout_tileleft                           = theme.dir .. "/icons/tileleft.png"
theme.layout_tilebottom                         = theme.dir .. "/icons/tilebottom.png"
theme.layout_tiletop                            = theme.dir .. "/icons/tiletop.png"
theme.layout_fairv                              = theme.dir .. "/icons/fairv.png"
theme.layout_fairh                              = theme.dir .. "/icons/fairh.png"
theme.layout_spiral                             = theme.dir .. "/icons/spiral.png"
theme.layout_dwindle                            = theme.dir .. "/icons/dwindle.png"
theme.layout_max                                = theme.dir .. "/icons/max.png"
theme.layout_fullscreen                         = theme.dir .. "/icons/fullscreen.png"
theme.layout_magnifier                          = theme.dir .. "/icons/magnifier.png"
theme.layout_floating                           = theme.dir .. "/icons/floating.png"
theme.widget_ac                                 = theme.dir .. "/icons/ac.png"
theme.widget_battery                            = theme.dir .. "/icons/battery.png"
theme.widget_battery_low                        = theme.dir .. "/icons/battery_low.png"
theme.widget_battery_empty                      = theme.dir .. "/icons/battery_empty.png"
theme.widget_brightness                         = theme.dir .. "/icons/brightness.png"
theme.widget_mem                                = theme.dir .. "/icons/mem.png"
theme.widget_cpu                                = theme.dir .. "/icons/cpu.png"
theme.widget_temp                               = theme.dir .. "/icons/temp.png"
theme.widget_net                                = theme.dir .. "/icons/net.png"
theme.widget_hdd                                = theme.dir .. "/icons/hdd.png"
theme.widget_music                              = theme.dir .. "/icons/note.png"
theme.widget_music_on                           = theme.dir .. "/icons/note_on.png"
theme.widget_music_pause                        = theme.dir .. "/icons/pause.png"
theme.widget_music_stop                         = theme.dir .. "/icons/stop.png"
theme.widget_vol                                = theme.dir .. "/icons/vol.png"
theme.widget_vol_low                            = theme.dir .. "/icons/vol_low.png"
theme.widget_vol_no                             = theme.dir .. "/icons/vol_no.png"
theme.widget_vol_mute                           = theme.dir .. "/icons/vol_mute.png"
theme.widget_mail                               = theme.dir .. "/icons/mail.png"
theme.widget_mail_on                            = theme.dir .. "/icons/mail_on.png"
theme.widget_task                               = theme.dir .. "/icons/task.png"
theme.widget_scissors                           = theme.dir .. "/icons/scissors.png"
theme.widget_clock                              = theme.dir .. "/icons/clock.png"
theme.tasklist_plain_task_name                  = true
theme.tasklist_disable_icon                     = true
theme.useless_gap                               = 4
theme.titlebar_close_button_focus               = theme.dir .. "/icons/titlebar/close_focus.png"
theme.titlebar_close_button_normal              = theme.dir .. "/icons/titlebar/close_normal.png"
theme.titlebar_ontop_button_focus_active        = theme.dir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active       = theme.dir .. "/icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive      = theme.dir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive     = theme.dir .. "/icons/titlebar/ontop_normal_inactive.png"
theme.titlebar_sticky_button_focus_active       = theme.dir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active      = theme.dir .. "/icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive     = theme.dir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive    = theme.dir .. "/icons/titlebar/sticky_normal_inactive.png"
theme.titlebar_floating_button_focus_active     = theme.dir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active    = theme.dir .. "/icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive   = theme.dir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive  = theme.dir .. "/icons/titlebar/floating_normal_inactive.png"
theme.titlebar_maximized_button_focus_active    = theme.dir .. "/icons/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active   = theme.dir .. "/icons/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = theme.dir .. "/icons/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = theme.dir .. "/icons/titlebar/maximized_normal_inactive.png"

local markup = lain.util.markup
local separators = lain.util.separators

-- Normális óra widget
local clockicon = wibox.widget.imagebox(theme.widget_clock)
local mytextclock = wibox.widget.textclock(markup.fontfg(theme.font, "#D8DEE9", " %H:%M "))
mytextclock:buttons(gears.table.join(
    awful.button({}, 1, function() awful.spawn.with_shell("gnome-calendar") end)
))

-- Calendar
theme.cal = lain.widget.cal({
    attach_to = { mytextclock },
    notification_preset = {
        font = "Terminus 10",
        fg   = theme.fg_normal,
        bg   = theme.bg_normal
    }
})

-- Taskwarrior
local task = wibox.widget.imagebox(theme.widget_task)
lain.widget.contrib.task.attach(task, {
    show_cmd = "task | sed -r 's/\\x1B\\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g'"
})
task:buttons(my_table.join(awful.button({}, 1, lain.widget.contrib.task.prompt)))

-- Scissors (xsel copy and paste)
local scissors = wibox.widget.imagebox(theme.widget_scissors)
scissors:buttons(my_table.join(awful.button({}, 1, function() awful.spawn.with_shell("xsel | xsel -i -b") end)))

-- ALSA volume
theme.volume = lain.widget.alsabar({
    notification_preset = { 
        font = "Terminus 10", 
        fg = theme.fg_normal, 
        bg = theme.bg_normal 
    },
})

-- MPD
local musicplr = awful.util.terminal .. " -title Music -g 130x34-320+16 -e ncmpcpp"
local mpdicon = wibox.widget.imagebox(theme.widget_music)
mpdicon:buttons(my_table.join(
    awful.button({ modkey }, 1, function () awful.spawn.with_shell(musicplr) end),
    awful.button({ }, 1, function ()
        os.execute("mpc prev")
        theme.mpd.update()
    end),
    awful.button({ }, 2, function ()
        os.execute("mpc toggle")
        theme.mpd.update()
    end),
    awful.button({ }, 3, function ()
        os.execute("mpc next")
        theme.mpd.update()
    end)))
theme.mpd = lain.widget.mpd({
    settings = function()
        if mpd_now.state == "play" then
            artist = " " .. mpd_now.artist .. " "
            title  = mpd_now.title  .. " "
            mpdicon:set_image(theme.widget_music_on)
            widget:set_markup(markup.fontfg(theme.font, "#BF616A", artist) .. markup.fontfg(theme.font, "#D8DEE9", title))
        elseif mpd_now.state == "pause" then
            widget:set_markup(markup.fontfg(theme.font, "#D8DEE9", " mpd paused "))
            mpdicon:set_image(theme.widget_music_pause)
        else
            widget:set_text("")
            mpdicon:set_image(theme.widget_music)
        end
    end
})

-- MEM
local memicon = wibox.widget.imagebox(theme.widget_mem)
local mem = lain.widget.mem({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, "#D8DEE9", " " .. mem_now.used .. "MB "))
    end
})

-- CPU
local cpuicon = wibox.widget.imagebox(theme.widget_cpu)
local cpu = lain.widget.cpu({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, "#D8DEE9", " " .. cpu_now.usage .. "% "))
    end
})

-- Coretemp
local temp = lain.widget.temp({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, "#D8DEE9", " " .. coretemp_now .. "°C "))
    end
})
local tempicon = wibox.widget.imagebox(theme.widget_temp)

-- Battery
local baticon = wibox.widget.imagebox(theme.widget_battery)
local bat = lain.widget.bat({
    settings = function()
        if bat_now.status and bat_now.status ~= "N/A" then
            if bat_now.ac_status == 1 then
                widget:set_markup(markup.fontfg(theme.font, "#D8DEE9", " AC "))
                baticon:set_image(theme.widget_ac)
                return
            elseif not bat_now.perc and tonumber(bat_now.perc) <= 5 then
                baticon:set_image(theme.widget_battery_empty)
            elseif not bat_now.perc and tonumber(bat_now.perc) <= 15 then
                baticon:set_image(theme.widget_battery_low)
            else
                baticon:set_image(theme.widget_battery)
            end
            widget:set_markup(markup.fontfg(theme.font, "#D8DEE9", " " .. bat_now.perc .. "% "))
        else
            widget:set_markup(markup.fontfg(theme.font, "#D8DEE9", " AC "))
            baticon:set_image(theme.widget_ac)
        end
    end
})

-- Net
local neticon = wibox.widget.imagebox(theme.widget_net)
local net = lain.widget.net({
    settings = function()
        widget:set_markup(markup.fontfg(theme.font, "#D8DEE9", 
            " " .. net_now.received .. "↓ " .. net_now.sent .. "↑ "))
    end
})

-- Brightness
local brighticon = wibox.widget.imagebox(theme.widget_brightness)
local brightwidget = awful.widget.watch('light -G', 0.1,
    function(widget, stdout, stderr, exitreason, exitcode)
        local brightness_level = tonumber(string.format("%.0f", stdout))
        widget:set_markup(markup.fontfg(theme.font, "#D8DEE9", " " .. brightness_level .. "%"))
end)

-- Separators
local arrow = separators.arrow_left

function theme.powerline_rl(cr, width, height)
    local arrow_depth, offset = height/2, 0

    if arrow_depth < 0 then
        width  =  width + 2*arrow_depth
        offset = -arrow_depth
    end

    cr:move_to(offset + arrow_depth         , 0        )
    cr:line_to(offset + width               , 0        )
    cr:line_to(offset + width - arrow_depth , height/2 )
    cr:line_to(offset + width               , height   )
    cr:line_to(offset + arrow_depth         , height   )
    cr:line_to(offset                       , height/2 )

    cr:close_path()
end

local function pl(widget, bgcolor, padding)
    return wibox.container.background(wibox.container.margin(widget, dpi(16), dpi(16)), bgcolor, theme.powerline_rl)
end

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
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(my_table.join(
                           awful.button({}, 1, function () awful.layout.inc( 1) end),
                           awful.button({}, 2, function () awful.layout.set( awful.layout.layouts[1] ) end),
                           awful.button({}, 3, function () awful.layout.inc(-1) end),
                           awful.button({}, 4, function () awful.layout.inc( 1) end),
                           awful.button({}, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ 
        position = "top", 
        screen = s, 
        height = dpi(24),
        bg = theme.bg_normal, 
        fg = theme.fg_normal 
    })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            wibox.container.margin(scissors, dpi(4), dpi(8)),
            
            -- Balról jobbra sötétedő kék árnyalatok
            -- MPD - legvilágosabb kék
            arrow(theme.bg_normal, "#88C0D0"),  -- nord8
            wibox.container.background(wibox.container.margin(
                wibox.widget { mpdicon, theme.mpd.widget, layout = wibox.layout.align.horizontal }, 
                dpi(3), dpi(6)), "#88C0D0"),
            
            -- Task - közepes kék
            arrow("#88C0D0", "#81A1C1"),  -- nord9
            wibox.container.background(wibox.container.margin(task, dpi(3), dpi(7)), "#81A1C1"),
            
            -- Memory - sötétebb kék
            arrow("#81A1C1", "#5E81AC"),  -- nord10
            wibox.container.background(wibox.container.margin(
                wibox.widget { memicon, mem.widget, layout = wibox.layout.align.horizontal }, 
                dpi(2), dpi(3)), "#5E81AC"),
            
            -- CPU - sötét kékesszürke
            arrow("#5E81AC", "#4C566A"),  -- nord3
            wibox.container.background(wibox.container.margin(
                wibox.widget { cpuicon, cpu.widget, layout = wibox.layout.align.horizontal }, 
                dpi(3), dpi(4)), "#4C566A"),
            
            -- Temperature - sötétebb szürkékék
            arrow("#4C566A", "#434C5E"),  -- nord2
            wibox.container.background(wibox.container.margin(
                wibox.widget { tempicon, temp.widget, layout = wibox.layout.align.horizontal }, 
                dpi(4), dpi(4)), "#434C5E"),
            
            -- Battery - még sötétebb
            arrow("#434C5E", "#3B4252"),  -- nord1
            wibox.container.background(wibox.container.margin(
                wibox.widget { baticon, bat.widget, layout = wibox.layout.align.horizontal }, 
                dpi(3), dpi(3)), "#3B4252"),
            
            -- Network - sötét
            arrow("#3B4252", "#2E3440"),  -- nord0
            wibox.container.background(wibox.container.margin(
                wibox.widget { neticon, net.widget, layout = wibox.layout.align.horizontal }, 
                dpi(3), dpi(3)), "#2E3440"),
            
            -- Brightness - sötét
            arrow("#2E3440", "#2E3440"),  -- nord0
            wibox.container.background(wibox.container.margin(
                wibox.widget { brighticon, brightwidget, layout = wibox.layout.align.horizontal }, 
                dpi(3), dpi(3)), "#2E3440"),
            
            -- Clock - legsötétebb
            arrow("#2E3440", "#2E3440"),  -- nord0
            wibox.container.background(wibox.container.margin(
                wibox.widget { clockicon, mytextclock, layout = wibox.layout.align.horizontal }, 
                dpi(4), dpi(8)), "#2E3440"),
            
            arrow("#2E3440", "alpha"),
            s.mylayoutbox,
        },
    }
end

return theme
