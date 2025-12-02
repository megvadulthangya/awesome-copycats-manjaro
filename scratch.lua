local client = client
local awful = require("awful")

local scratch = {}
local defaultRule = {instance = "scratch"}

-- Toggle function
function scratch.toggle(cmd, rule)
    local rule = rule or defaultRule
    local screen = awful.screen.focused()
    
    -- Megkeressük a futó klienst a szabály alapján
    local matcher = function(c) return awful.rules.match(c, rule) end
    local c = awful.client.iterate(matcher)()

    if c then
        -- Ha már létezik az ablak:
        if c.first_tag and c.first_tag.selected and client.focus == c and not c.minimized then
            -- Ha látható és fókuszban van -> Rejtsük el
            c.minimized = true
        else
            -- Ha el van rejtve vagy nincs fókuszban -> Mutassuk meg
            c.minimized = false
            
            -- Átrakjuk az aktuális asztalra
            c:move_to_tag(screen.selected_tag)
            
            -- ====================================================
            -- QUAKE STYLE (FULL SCREEN OVERLAY)
            -- ====================================================
            -- A 'workarea' helyett a 'geometry'-t használjuk, 
            -- ami tartalmazza a tálca területét is!
            local s_geo = screen.geometry
            
            c:geometry({
                x = s_geo.x,
                y = s_geo.y,
                width = s_geo.width,
                height = s_geo.height * 0.5 -- A képernyő fele
            })
            
            -- Keret levétele (ha még nem lenne 0)
            c.border_width = 0
            
            -- Előtérbe hozzuk, hogy biztosan a tálca FÖLÖTT legyen
            c.ontop = true 
            c:raise()
            client.focus = c
        end
    else
        -- Ha még nem létezik az ablak -> Indítsuk el
        awful.spawn(cmd)
    end
end

return scratch
