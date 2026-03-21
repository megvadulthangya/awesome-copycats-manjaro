--[[
     Nord Awesome WM theme
     last modified by: github.com/megvadulthangya
     Based on Rainbow theme by github.com/lcpz
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
theme.default_dir                               = require("awful.util").get_themes_dir() .. "default"
theme.dir                                       = "/usr/share/awesome/themes/rainbow"

-- ============================================================================
-- ALAPÉRTELMEZETT HÁTTÉRKÉP (VISSZAKAPCSOLVA)
-- ============================================================================
theme.wallpaper                                 = theme.dir .. "/wall.png"
-- ============================================================================

theme.font                                      = "Terminus 12"

-- Nord color palette
theme.nord0  = "#2E3440"  -- darkest gray
theme.nord1  = "#3B4252"  -- dark gray
theme.nord2  = "#434C5E"  -- medium gray
theme.nord3  = "#4C566A"  -- light gray
theme.nord4  = "#D8DEE9"  -- lightest gray
theme.nord5  = "#E5E9F0"  -- off white
theme.nord6  = "#ECEFF4"  -- snow white
theme.nord7  = "#8FBCBB"  -- teal
theme.nord8  = "#88C0D0"  -- light blue
theme.nord9  = "#81A1C1"  -- blue
theme.nord10 = "#5E81AC"  -- dark blue
theme.nord11 = "#BF616A"  -- red
theme.nord12 = "#D08770"  -- orange
theme.nord13 = "#EBCB8B"  -- yellow
theme.nord14 = "#A3BE8C"  -- green
theme.nord15 = "#B48EAD"  -- purple

-- Theme colors
theme.fg_normal                                 = theme.nord3
theme.fg_focus                                  = theme.nord6
theme.fg_minimize                               = theme.nord3
theme.bg_normal                                 = theme.nord0
theme.bg_focus                                  = theme.nord1
theme.fg_urgent                                 = theme.nord0
theme.bg_urgent                                 = theme.nord11
theme.border_width                              = dpi(1)
theme.border_normal                             = theme.nord0
theme.border_focus                              = theme.nord8
theme.taglist_fg_focus                          = theme.nord8
theme.taglist_bg_focus                          = theme.nord1
theme.taglist_fg_occupied                       = theme.nord4
theme.taglist_fg_empty                          = theme.nord3
theme.taglist_fg_urgent                         = theme.nord11

-- Tasklist colors
theme.tasklist_fg_normal                        = theme.nord3
theme.tasklist_fg_focus                         = theme.nord6
theme.tasklist_fg_urgent                        = theme.nord11
theme.tasklist_bg_normal                        = theme.nord0
theme.tasklist_bg_focus                         = theme.nord1

theme.menu_height                               = dpi(20)
theme.menu_width                                = dpi(250)
theme.ocol                                      = "<span color='" .. theme.fg_normal .. "'>"
theme.tasklist_sticky                           = theme.ocol .. "[S]</span>"
theme.tasklist_ontop                            = theme.ocol .. "[T]</span>"
theme.tasklist_floating                         = theme.ocol .. "[F]</span>"
theme.tasklist_maximized_horizontal             = theme.ocol .. "[M] </span>"
theme.tasklist_maximized_vertical               = ""
theme.tasklist_disable_icon                     = true
theme.awesome_icon                              = theme.dir .."/icons/awesome.png"
theme.menu_submenu_icon                         = theme.dir .."/icons/submenu.png"
theme.taglist_squares_sel                       = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel                     = theme.dir .. "/icons/square_unsel.png"
theme.useless_gap                               = dpi(4)
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
theme.layout_txt_floating                       = "[*]"
theme.titlebar_close_button_normal              = theme.default_dir.."/titlebar/close_normal.png"
theme.titlebar_close_button_focus               = theme.default_dir.."/titlebar/close_focus.png"
theme.titlebar_minimize_button_normal           = theme.default_dir.."/titlebar/minimize_normal.png"
theme.titlebar_minimize_button_focus            = theme.default_dir.."/titlebar/minimize_focus.png"
theme.titlebar_ontop_button_normal_inactive     = theme.default_dir.."/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive      = theme.default_dir.."/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active       = theme.default_dir.."/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active        = theme.default_dir.."/titlebar/ontop_focus_active.png"
theme.titlebar_sticky_button_normal_inactive    = theme.default_dir.."/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive     = theme.default_dir.."/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active      = theme.default_dir.."/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active       = theme.default_dir.."/titlebar/sticky_focus_active.png"
theme.titlebar_floating_button_normal_inactive  = theme.default_dir.."/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive   = theme.default_dir.."/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active    = theme.default_dir.."/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active     = theme.default_dir.."/titlebar/floating_focus_active.png"
theme.titlebar_maximized_button_normal_inactive = theme.default_dir.."/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = theme.default_dir.."/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active   = theme.default_dir.."/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active    = theme.default_dir.."/titlebar/maximized_focus_active.png"

-- Titlebar colors
theme.titlebar_bg_normal = theme.nord0
theme.titlebar_bg_focus  = theme.nord1
theme.titlebar_fg_normal = theme.nord4
theme.titlebar_fg_focus  = theme.nord6

-- lain related
theme.layout_txt_cascade                        = "[cascade]"
theme.layout_txt_cascadetile                    = "[cascadetile]"
theme.layout_txt_centerwork                     = "[centerwork]"
theme.layout_txt_termfair                       = "[termfair]"
theme.layout_txt_centerfair                     = "[centerfair]"

local markup = lain.util.markup
local white  = theme.nord6
local gray   = theme.nord4
local blue   = theme.nord8

-- Textclock
local mytextclock = wibox.widget.textclock(markup(blue, " %H:%M "))
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

-- MPD
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

        widget:set_markup(markup.font(theme.font, markup(gray, artist) .. markup(blue, title)))
    end
})

-- ALSA volume bar
theme.volume = lain.widget.alsabar({
    ticks = true, 
    width = dpi(67),
    notification_preset = { font = theme.font },
    colors = {
        background = theme.nord1,
        mute = theme.nord11,
        unmute = theme.nord8
    }
})
theme.volume.tooltip.wibox.fg = theme.fg_focus
theme.volume.tooltip.wibox.font = theme.font
theme.volume.bar:buttons(my_table.join (
          awful.button({}, 1, function()
            awful.spawn(string.format("%s -e alsamixer", "alacritty"))
          end),
          awful.button({}, 2, function()
            os.execute(string.format("%s set %s 100%%", theme.volume.cmd, theme.volume.channel))
            theme.volume.update()
          end),
          awful.button({}, 3, function()
            os.execute(string.format("%s set %s toggle", theme.volume.cmd, theme.volume.togglechannel or theme.volume.channel))
            theme.volume.update()
          end),
          awful.button({}, 4, function()
            os.execute(string.format("%s set %s 1%%+", theme.volume.cmd, theme.volume.channel))
            theme.volume.update()
          end),
          awful.button({}, 5, function()
            os.execute(string.format("%s set %s 1%%-", theme.volume.cmd, theme.volume.channel))
            theme.volume.update()
          end)
))
local volumebg = wibox.container.background(theme.volume.bar, theme.nord1, gears.shape.rectangle)
local volumewidget = wibox.container.margin(volumebg, dpi(7), dpi(7), dpi(5), dpi(5))

-- Net Widget (Speedtest stílus: Mbps/Gbps - SZOLIDABB SZÍNEKKEL)
local net = lain.widget.net({
    settings = function()
        -- Segédfüggvény: BIT alapú sebesség
        local function format_speed_bits(speed_kb_per_sec)
            local speed_kbit = (tonumber(speed_kb_per_sec) or 0) * 8
            
            if speed_kbit >= 1000000 then -- Gigabit
                return string.format("%.1f Gbps", speed_kbit / 1000000)
            elseif speed_kbit >= 1000 then -- Megabit
                return string.format("%.1f Mbps", speed_kbit / 1000)
            else -- Kilobit
                return string.format("%.0f Kbps", speed_kbit)
            end
        end

        local received = format_speed_bits(net_now.received)
        local sent     = format_speed_bits(net_now.sent)

        -- Rainbow stílus: színes nyilak és szöveg
        -- Nord14 (zöld) a letöltés, Nord9 (kék) a feltöltés
        widget:set_markup(markup.font(theme.font, 
            markup(theme.nord14, " ↓" .. received) .. 
            markup(theme.nord9,  " ↑" .. sent) .. " "
        ))
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
    -- Quake application
    s.quake = lain.util.quake({ app = "alacritty" })

    -- OKOS HÁTTÉRKÉP BEÁLLÍTÁS
    -- Figyeli az rc.lua beautiful.wallpaper változóját
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
    -- Ez explicit megmondja, hogy semmi se foglaljon helyet a széleken.
    -- Késleltetve futtatjuk, hogy biztosan felülírja a beragadt beállításokat.
    gears.timer.delayed_call(function()
        s.padding = { left = 0, right = 0, top = 0, bottom = 0 }
    end)
    -- ====================================================================

    -- Tags
    awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()

    -- Textual layoutbox
    s.mytxtlayoutbox = wibox.widget.textbox(theme["layout_txt_" .. awful.layout.getname(awful.layout.get(s))])
    awful.tag.attached_connect_signal(s, "property::selected", function () update_txt_layoutbox(s) end)
    awful.tag.attached_connect_signal(s, "property::layout", function () update_txt_layoutbox(s) end)
    s.mytxtlayoutbox:buttons(my_table.join(
                           awful.button({}, 1, function() awful.layout.inc(1) end),
                           awful.button({}, 2, function () awful.layout.set( awful.layout.layouts[1] ) end),
                           awful.button({}, 3, function() awful.layout.inc(-1) end),
                           awful.button({}, 4, function() awful.layout.inc(1) end),
                           awful.button({}, 5, function() awful.layout.inc(-1) end)))

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({ 
        position = "top", 
        screen = s, 
        height = dpi(22), 
        bg = theme.nord0, 
        fg = theme.nord4 
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
            net.widget, -- Hálózat (Új - szolidabb színekkel)
            volumewidget,
            beautiful.weather_widget, -- Időjárás (Új)
            mytextclock,
        },
    }
    
    -- ALSÓ SÁV TÖRÖLVE!
end

return theme
