local screenW, screenH = guiGetScreenSize()
local map_w = 6000
local game_w = 6000
local radar_w = screenH * 0.3
local zoom_factor = 2
local position_offset_x = screenH * 0.02
local position_offset_y = position_offset_x
local full_map_size = screenH * 0.95 -- rozmiar mapy w trybie pełnoekranowym (F11)
local rt = dxCreateRenderTarget(radar_w, radar_w, true)
local iconSize = 30

local radarShader = dxCreateShader("radar_shader.fx")
dxSetShaderValue(radarShader, "gTexture", rt)

local markers_on_map = {}
local last_x_game, last_y_game = -99999, -99999
local last_rotation = 0
local isMapVisible = false
local fullMapZoom = 1.0

-- Funkcja do konwersji współrzędnych świata na współrzędne mapy
local function convertWorldToMap(x, y)
    local map_x = (x + 3000) / game_w * map_w
    local map_y = (-y + 3000) / game_w * map_w
    return map_x, map_y
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    bindKey("f11", "down", function()
        cancelEvent()
        isMapVisible = not isMapVisible
    end)

    -- Dodaj markery do mapy
    for _, marker in ipairs(getElementsByType("marker")) do
        if getMarkerType(marker) == "cylinder" then
            local r, g, b, _ = getMarkerColor(marker)
            local mx, my, _ = getElementPosition(marker)

            local blip_type
            if r == 255 then -- PRACE
                blip_type = "prace.png"
            elseif r == 254 then -- PRAWO JAZDY
                blip_type = "prawko.png"
            elseif r == 253 then -- BANKOMATY
                blip_type = "bankomat.png"
            elseif r == 252 then -- URZĘDY
                blip_type = "urzad.png"
            elseif r == 251 then -- PRZECHOWYWALNIE
                blip_type = "przechowywalnia.png"
            elseif r == 250 then -- SALONY AUT
                blip_type = "salon.png"
            elseif r == 249 then -- CYGAN
                blip_type = "cygan.png"
            end

            if blip_type then
                table.insert(markers_on_map, {mx, my, blip_type})
            end
        end
    end
end)

addEventHandler("onClientKey", root, function(button, press)
    if press and isMapVisible then
        if button == "mouse_wheel_up" then
            fullMapZoom = math.max(0.5, fullMapZoom - 0.1)
        elseif button == "mouse_wheel_down" then
            fullMapZoom = math.min(2.0, fullMapZoom + 0.1)
        end
    end
end)

local function getCameraRotation()
    local camX, camY, _, lookX, lookY, _ = getCameraMatrix()
    return -math.deg(math.atan2(lookX - camX, lookY - camY))
end

-- ... (istniejący kod pozostaje bez zmian)

addEventHandler("onClientRender", root, function()
    if isMapVisible then
        -- Tryb pełnoekranowy (F11)
        local map_x = (screenW - full_map_size) / 2
        local map_y = (screenH - full_map_size) / 2
        dxDrawImage(map_x, map_y, full_map_size, full_map_size, "mapa.png")

        -- Rysuj markery na mapie
        for _, marker in ipairs(markers_on_map) do
            local marker_x, marker_y = convertWorldToMap(marker[1], marker[2])
            local radar_marker_x = map_x + (marker_x / map_w) * full_map_size
            local radar_marker_y = map_y + (marker_y / map_w) * full_map_size
            dxDrawImage(radar_marker_x - iconSize / 2, radar_marker_y - iconSize / 2, iconSize, iconSize, marker[3])
        end

        -- Rysuj ikonę lokalnego gracza
        local x_game, y_game, _ = getElementPosition(localPlayer)
        local player_x, player_y = convertWorldToMap(x_game, y_game)
        dxDrawImage(map_x + (player_x / map_w) * full_map_size - iconSize / 2, map_y + (player_y / map_w) * full_map_size - iconSize / 2, iconSize, iconSize, "player_icon.png")

        -- Rysuj ikony innych graczy
        for _, player in ipairs(getElementsByType("player")) do
            if player ~= localPlayer then
                local px, py, pz = getElementPosition(player)
                local map_px, map_py = convertWorldToMap(px, py)
                local draw_x = map_x + (map_px / map_w) * full_map_size - iconSize / 2
                local draw_y = map_y + (map_py / map_w) * full_map_size - iconSize / 2
                dxDrawImage(draw_x, draw_y, iconSize, iconSize, "other_player.png")
            end
        end
    else
        -- Tryb radaru (mała mapa w rogu ekranu)
        local x_game, y_game, _ = getElementPosition(localPlayer)
        local rotation = getCameraRotation()

        dxSetRenderTarget(rt, true)
        dxDrawRectangle(0, 0, radar_w, radar_w, tocolor(0, 0, 0, 0))

        -- Rysuj widoczny obszar mapy
        local section_x = (x_game + 3000) / game_w * map_w - (radar_w / 2) * zoom_factor
        local section_y = (-y_game + 3000) / game_w * map_w - (radar_w / 2) * zoom_factor
        dxDrawImageSection(0, 0, radar_w, radar_w, section_x, section_y, radar_w * zoom_factor, radar_w * zoom_factor, "mapa.png")

        -- Rysuj markery na radarze
        for _, marker in ipairs(markers_on_map) do
            local marker_x, marker_y = convertWorldToMap(marker[1], marker[2])
            local radar_marker_x = (marker_x - section_x) / zoom_factor
            local radar_marker_y = (marker_y - section_y) / zoom_factor
            dxDrawImage(radar_marker_x - iconSize / 2, radar_marker_y - iconSize / 2, iconSize, iconSize, marker[3], -rotation)
        end

        -- Rysuj ikony innych graczy na radarze
        for _, player in ipairs(getElementsByType("player")) do
            if player ~= localPlayer then
                local px, py, pz = getElementPosition(player)
                local marker_x, marker_y = convertWorldToMap(px, py)
                local radar_marker_x = (marker_x - section_x) / zoom_factor
                local radar_marker_y = (marker_y - section_y) / zoom_factor
                dxDrawImage(radar_marker_x - iconSize / 2, radar_marker_y - iconSize / 2, iconSize, iconSize, "other_player.png", -rotation)
            end
        end

        -- Rysuj ikonę lokalnego gracza na radarze
        dxDrawImage(radar_w / 2 - iconSize / 2, radar_w / 2 - iconSize / 2, iconSize, iconSize, "player_icon.png", -rotation)

        dxSetRenderTarget()
        dxSetShaderValue(radarShader, "rotation", math.rad(-rotation))
        dxDrawImage(position_offset_x, screenH - radar_w - position_offset_y, radar_w, radar_w, radarShader)
    end
end)