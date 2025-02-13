local screenW, screenH = guiGetScreenSize()
local map_w = 6000
local game_w = 6000
local radar_w = 350
local zoom_factor = 2
local position_offset_y = 20
local position_offset_x = 20
local rt = dxCreateRenderTarget(radar_w, radar_w, true)

local radarShader = dxCreateShader("radar_shader.fx")
dxSetShaderValue(radarShader, "gTexture", rt)

local markers_on_map = {}
local last_x_game, last_y_game = -99999, -99999

addEventHandler("onClientResourceStart", resourceRoot, function()
    for _, marker in ipairs(getElementsByType("marker")) do
        if getMarkerType(marker) == "cylinder" then
            local r, g, b, _ = getMarkerColor(marker)
            local mx, my, _ = getElementPosition(marker)
            
            local blip_type
            if r == 255 then
                blip_type = "blip.png"  -- Markery o kolorze 255
            elseif r == 254 then
                blip_type = "blip2.png" -- Markery o kolorze 254
            end

            if blip_type then
                table.insert(markers_on_map, {mx, my, blip_type})
            end
        end
    end
end)

local function updateRadarRender(x_game, y_game)
    local target_x_map = (((x_game + 3000) / game_w) * map_w)
    local target_y_map = (((-y_game + 3000) / game_w) * map_w)

    dxSetRenderTarget(rt, true)
    dxDrawImageSection(0, 0, radar_w, radar_w, target_x_map - (radar_w / 2) * zoom_factor, target_y_map - (radar_w / 2) * zoom_factor, radar_w * zoom_factor, radar_w * zoom_factor, "map.png")
    dxDrawImage(radar_w / 2 - 8, radar_w / 2 - 8, 16, 16, "player_icon.png")

    for _, marker in ipairs(markers_on_map) do
        local marker_x = (((marker[1] + 3000) / game_w) * map_w)
        local marker_y = (((-marker[2] + 3000) / game_w) * map_w)
        local radar_marker_x = (marker_x - target_x_map) / zoom_factor + radar_w / 2
        local radar_marker_y = (marker_y - target_y_map) / zoom_factor + radar_w / 2
        
        dxDrawImage(radar_marker_x - 8, radar_marker_y - 8, 16, 16, marker[3]) -- Rysujemy blipa odpowiedniego typu
    end

    dxSetRenderTarget()
end

addEventHandler("onClientRender", root, function()
    setPlayerHudComponentVisible("radar", false)
    local x_game, y_game = getElementPosition(localPlayer)

    if math.abs(x_game - last_x_game) > 1 or math.abs(y_game - last_y_game) > 1 then
        updateRadarRender(x_game, y_game)
        last_x_game, last_y_game = x_game, y_game
    end

    local radar_x = position_offset_x
    local radar_y = screenH - radar_w - position_offset_y

    dxDrawImage(radar_x, radar_y, radar_w, radar_w, radarShader)

    dxDrawImage(radar_x, radar_y, radar_w, radar_w, "ring.png")
end)
