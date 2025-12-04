-- widgets/weather.lua
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")

-- ============================================================================
-- WEATHER WIDGET BEÁLLÍTÁS (Dinamikus Nyelv)
-- ============================================================================
local weather_widget = wibox.widget.textbox()

-- 2. Nyelv érzékelése
local sys_lang = os.getenv("LANG") or "en"
local lang_code = string.sub(sys_lang, 1, 2) 

-- 3. Parancs összeállítása
local weather_cmd = "curl -s 'wttr.in?format=%t+%C&lang=" .. lang_code .. "'"

-- 4. Frissítés óránként
awful.widget.watch(
    weather_cmd,
    3600, 
    function(widget, stdout)
        local weather = stdout:gsub("\n", "")
        widget:set_text(" 🌤 " .. weather .. " ") 
    end,
    weather_widget
)

-- 5. Kattintás
weather_widget:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then 
        awful.spawn("xdg-open https://wttr.in?lang=" .. lang_code) 
    end
end)

return weather_widget
