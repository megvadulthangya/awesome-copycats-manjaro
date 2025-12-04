-- signals/init.lua
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")

-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- Custom
    if beautiful.titlebar_fun then
        beautiful.titlebar_fun(c)
        return
    end

    -- Default
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, { size = 16 }) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = _G.vi_focus})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- switch to parent after closing child window
local function backham()
    local s = awful.screen.focused()
    local c = awful.client.focus.history.get(s, 0)
    if c then
        client.focus = c
        c:raise()
    end
end

-- attach to minimized state
client.connect_signal("property::minimized", backham)
-- attach to closed state
client.connect_signal("unmanage", backham)
-- ensure there is always a selected client during tag switching or logins
tag.connect_signal("property::selected", backham)

-- HOZZÁADVA: Univerzális Geometria a Quake Terminálhoz
-- Ez biztosítja, hogy felbontástól függetlenül mindig középen legyen
client.connect_signal("manage", function(c)
    if c.instance == "scratchpad" then
        
        -- Kiszámoljuk az aktuális képernyő méreteit
        local screen_geom = awful.screen.focused().geometry
        
        -- BEÁLLÍTÁSOK (Itt módosíthatod az arányokat)
        local width_ratio = 0.95  -- A képernyő szélességének 95%-a
        local height_ratio = 0.50 -- A képernyő magasságának 50%-a
        
        -- Matek: Kiszámoljuk a pixel méreteket
        local w = screen_geom.width * width_ratio
        local h = screen_geom.height * height_ratio
        
        -- Matek: Kiszámoljuk az X pozíciót, hogy Középen legyen
        -- (Képernyő szélessége - Ablak szélessége) / 2 + Képernyő eltolása
        local x = (screen_geom.width - w) / 2 + screen_geom.x
        
        -- Beállítjuk az ablakot
        c:geometry({
            x = x,
            y = screen_geom.y + 10, -- Kicsi margó fentről
            width = w,
            height = h
        })

        -- Ez kikapcsolja a terminál rács-igazítását
        c.size_hints_honor = false 
        
        -- Levesszük a keretet
        c.border_width = 0
    end
end)
