local screenW, screenH = guiGetScreenSize()
local map_w = 1536 		-- Rozdzielczość tekstury mapy
local game_w = 6000		-- Wielkość świata GTA
local radar_w = 200 	-- Wielkość radaru na ekranie
local player_icon_size = 15  -- Rozmiar ikony gracza

local rt = dxCreateRenderTarget(map_w , map_w) -- Render Target dla radaru

function renderCustomRadar()
    local px, py, pz = getElementPosition(localPlayer) -- Pozycja gracza
    local _, _, pr = getElementRotation(localPlayer) -- Kąt obrotu gracza

    -- Przeskalowanie pozycji na mapę
    local x_map = (map_w * (px + 3000)) / game_w 
    local y_map = -(map_w * (py + 3000)) / game_w 

    dxSetRenderTarget(rt, true)
        -- Rysowanie wycinka mapy
        dxDrawImageSection(0, 0, map_w, map_w, x_map - (radar_w / 2), y_map - (radar_w / 2), radar_w, radar_w, "map.jpg", -pr) 
        -- Rysowanie okręgu symbolizującego gracza
        dxDrawImage(map_w / 2 - player_icon_size / 2, map_w / 2 - player_icon_size / 2, player_icon_size, player_icon_size, "player_icon.png", 0, 0, 0, tocolor(255, 255, 255, 255))

        -- Rysowanie innych graczy na radarze
        for _, player in ipairs(getElementsByType("player")) do
            if player ~= localPlayer then
                local tx, ty, tz = getElementPosition(player)
                local dx = (map_w * (tx + 3000)) / game_w - x_map
                local dy = -(map_w * (ty + 3000)) / game_w - y_map
                
                -- Przekształcenie pozycji do obrotu kamery
                local angle = math.rad(-pr)
                local cosA, sinA = math.cos(angle), math.sin(angle)
                local rotated_x = dx * cosA - dy * sinA
                local rotated_y = dx * sinA + dy * cosA

                -- Rysowanie punktu dla innego gracza na radarze
                dxDrawImage(map_w / 2 + rotated_x - 5, map_w / 2 + rotated_y - 5, 10, 10, "blip.png", 0, 0, 0, tocolor(255, 0, 0, 255))
            end
        end
    dxSetRenderTarget()

    -- Rysowanie radaru na ekranie
    local radar_x, radar_y = screenW - radar_w - 20, screenH - radar_w - 20 -- Pozycja radaru (prawy dolny róg)
    dxDrawImage(radar_x, radar_y, radar_w, radar_w, rt)

    -- Rysowanie obwódki (opcjonalne)
    dxDrawCircle(radar_x + radar_w / 2, radar_y + radar_w / 2, radar_w / 2, tocolor(0, 0, 0, 150))
end
addEventHandler("onClientRender", root, renderCustomRadar)
