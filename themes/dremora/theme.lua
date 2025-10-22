--[[

     Dremora Awesome WM theme - Nord Color Scheme
     Based on github.com/lcpz's Dremora theme
     last modified by: github.com/megvadulthangya
     Nord colors: https://www.nordtheme.com/

--]]

local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local dpi   = require("beautiful.xresources").apply_dpi

local os = os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme                                     = {}
theme.dir                                       = os.getenv("HOME") .. "/.config/awesome/themes/dremora"
theme.wallpaper                                 = theme.dir .. "/wall.png"
theme.font                                      = "Terminus 12"
theme.taglist_font                              = "Icons 14"

-- Nord Color Scheme
theme.nord0  = "#2E3440"  -- darkest background
theme.nord1  = "#3B4252"  -- lighter background
theme.nord2  = "#434C5E"  -- selection background
theme.nord3  = "#4C566A"  -- comment/inactive
theme.nord4 = "#979797"   -- actually not a nord color,but who cares?
theme.nord5  = "#E5E9F0"  -- light text
theme.nord6  = "#ECEFF4"  -- very light text
theme.nord7  = "#8FBCBB"  -- teal
theme.nord8  = "#88C0D0"  -- light blue
theme.nord9  = "#81A1C1"  -- blue
theme.nord10 = "#5E81AC"  -- dark blue
theme.nord11 = "#BF616A"  -- red
theme.nord12 = "#D08770"  -- orange
theme.nord13 = "#EBCB8B"  -- yellow
theme.nord14 = "#A3BE8C"  -- green
theme.nord15 = "#B48EAD"  -- purple

-- Apply Nord colors
theme.fg_normal                                 = theme.nord4  -- INACTIVE text - lighter gray (nord4)
theme.fg_focus                                  = theme.nord6  -- ACTIVE text - bright white (kept as requested)
theme.fg_urgent                                 = theme.nord11 -- red for urgent
theme.bg_normal                                 = theme.nord0  -- dark background
theme.bg_focus                                  = theme.nord1  -- slightly lighter for focus
theme.bg_urgent                                 = theme.nord0  -- dark background with red text
theme.border_normal                             = theme.nord1  -- lighter border
theme.border_focus                              = theme.nord9  -- blue border for focus
theme.titlebar_bg_focus                         = theme.nord1  -- lighter titlebar
theme.taglist_fg_focus                          = theme.nord6  -- bright white for focused tags
theme.taglist_fg_normal                         = theme.nord4  -- lighter gray for inactive tags (nord4)
theme.taglist_bg_focus                          = theme.nord1  -- lighter background for focused tags
theme.taglist_bg_normal                         = theme.nord0  -- dark background for normal tags

theme.menu_height                               = dpi(20)
theme.menu_width                                = dpi(250)
theme.menu_bg_normal                            = theme.nord1  -- lighter menu background
theme.menu_bg_focus                             = theme.nord2  -- even lighter for focused menu items
theme.menu_fg_normal                            = theme.nord4  -- lighter gray text for menu (inactive)
theme.menu_fg_focus                             = theme.nord6  -- very light text for focus

theme.menu_submenu_icon                         = theme.dir .. "/icons/submenu.png"
theme.awesome_icon                              = theme.dir .."/icons/awesome.png"
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
theme.tasklist_plain_task_name                  = true
theme.tasklist_disable_icon                     = true
theme.useless_gap                               = dpi(10)
theme.border_width                              = dpi(1)  -- Added slight border for better visibility

-- Titlebar buttons with Nord colors
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

awful.util.tagnames   = { "ƀ", "Ƅ", "Ɗ", "ƈ", "ƙ" }

local markup     = lain.util.markup
local separators = lain.util.separators
local white      = theme.nord6  -- Active text (bright white)
local gray       = theme.nord4  -- Inactive text (lighter Nord gray - nord4)
local blue       = theme.nord9  -- Blue for active elements

-- Textclock with Nord colors - inactive parts in lighter gray, active in white
local mytextclock = wibox.widget.textclock(markup(gray, " %a")
.. markup(white, " %d ") .. markup(gray, "%b ") ..  markup(white, "%H:%M "))
mytextclock.font = theme.font

-- Calendar with Nord colors
theme.cal = lain.widget.cal({
    attach_to = { mytextclock },
    notification_preset = {
        font = "Terminus 11",
        fg   = white,
        bg   = theme.nord1
}})

-- MPD with Nord colors
theme.mpd = lain.widget.mpd({
    settings = function()
        mpd_notification_preset.fg = white
        artist = mpd_now.artist .. " "
        title  = mpd_now.title  .. " "

        if mpd_now.state == "pause" then
            artist = "mpd "
            title  = "paused "
        elseif mpd_now.state == "stop" then
            artist = ""
            title  = ""
        end

        widget:set_markup(markup.font(theme.font, markup(gray, artist) .. markup(white, title)))
    end
})

-- Battery with Nord colors
local bat = lain.widget.bat({
    settings = function()
        bat_header = " Bat "
        bat_p      = bat_now.perc .. " "
        if bat_now.status == "Charging" then
            bat_p = bat_p .. "+"
        elseif bat_now.status == "Discharging" then
            bat_p = bat_p .. "-"
        end
        widget:set_markup(markup.font(theme.font, markup(gray, bat_header) .. markup(white, bat_p)))
    end
})

-- ALSA volume with Nord colors
theme.volume = lain.widget.alsa({
    settings = function()
        header = " Vol "
        vlevel  = volume_now.level

        if volume_now.status == "off" then
            vlevel = vlevel .. "M "
        else
            vlevel = vlevel .. " "
        end

        widget:set_markup(markup.font(theme.font, markup(gray, header) .. markup(white, vlevel)))
    end
})

-- Separators with Nord colors
local first     = wibox.widget.textbox('<span font="Terminus 4"> </span>')
local arrl_pre  = separators.arrow_right("alpha", theme.nord1)
local arrl_post = separators.arrow_right(theme.nord1, "alpha")

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

    -- Create the wibox (top bar) - made lighter with nord1
    s.mywibox = awful.wibar({ 
        position = "top", 
        screen = s, 
        height = dpi(18), 
        bg = theme.nord1,  -- Changed to lighter background
        fg = theme.nord4   -- Lighter gray text color for inactive elements
    })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            first,
            s.mytaglist,
            arrl_pre,
            s.mylayoutbox,
            arrl_post,
            s.mypromptbox,
            first,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            first,
            theme.mpd.widget,
            bat.widget,
            theme.volume.widget,
            mytextclock,
        },
    }
end

return theme
