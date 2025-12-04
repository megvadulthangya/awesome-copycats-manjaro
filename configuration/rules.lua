-- configuration/rules.lua
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")

local rules = {}

-- Rules to apply to new clients (through the "manage" signal).
rules.create = function(clientkeys, clientbuttons)
    return {
        -- All clients will match this rule.
        { rule = { },
          properties = { border_width = beautiful.border_width,
                         border_color = beautiful.border_normal,
                         callback = awful.client.setslave,
                         focus = awful.client.focus.filter,
                         raise = true,
                         keys = clientkeys,
                         buttons = clientbuttons,
                         screen = awful.screen.preferred,
                         placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                         size_hints_honor = false
          }
        },

        -- Floating clients.
        { rule_any = {
            instance = {
              "DTA",  -- Firefox addon DownThemAll.
              "copyq",  -- Includes session name in class.
              "pinentry"
            },
            class = {
              "Arandr",
              "Blueman-manager",
              "Gpick",
              "Kruler",
              "MessageWin",  -- kalarm.
              "Sxiv",
              "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
              "Wpa_gui",
              "veromix",
              "xtightvncviewer"},

            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
              "Event Tester",  -- xev.
            },
            role = {
              "AlarmWindow",  -- Thunderbird's calendar.
              "ConfigManager",  -- Thunderbird's about:config.
              "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
            }
          }, properties = { floating = true }},
        -- Add titlebars to normal clients and dialogs
        { rule_any = {type = { "normal", "dialog" }
          }, properties = { titlebars_enabled = true }
        },

        -- Set Firefox to always map on the tag named "2" on screen 1.
        -- { rule = { class = "Firefox" },
        --   properties = { screen = 1, tag = "2" } },
        -- ==========================================================
        -- 1. JAVÍTÁS: NORMÁL URXVT FIX (Hogy ne legyen 2 centis csík)
        -- ==========================================================
        { rule = { class = "URxvt" },
          properties = { 
              size_hints_honor = false,
              titlebars_enabled = false
          }
        }, 

        -- ==========================================================
        -- 2. JAVÍTÁS: SCRATCHPAD (Quake Style + Fix első indítás)
        -- ==========================================================
        { rule = { instance = "scratchpad" },
          properties = { 
              floating = true,
              sticky = true,       -- Minden asztalon ott legyen
              ontop = true,        -- Mindig legfelül
              minimizable = true,
              border_width = 0,    -- Nincs keret (mert 100% széles)
              size_hints_honor = false,
              titlebars_enabled = false
          }, 
            
          -- Ez a logika fut le, amikor ELŐSZÖR jön létre az ablak
          callback = function (c)
              -- A gears.timer.delayed_call biztosítja, hogy ez fusson le UTOLJÁRA
              -- Így biztosan felülírja az alapértelmezett méretet.
              gears.timer.delayed_call(function()
              local s_geo = c.screen.geometry
              c:geometry({
                  x = s_geo.x,
                  y = s_geo.y,
                  width = s_geo.width,
                  height = s_geo.height * 0.5 -- 50% magasság
              })
          end)
      end
        } 
    }
end

return rules
