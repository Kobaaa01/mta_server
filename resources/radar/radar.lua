local screenW, screenH = guiGetScreenSize()
local map_w = 6000
local game_w = 6000
local radar_w = 350
local zoom_factor = 2
local position_offset_y = 20
local position_offset_x = 20
local full_map_size = 1000 -- f11 rozmiar mapy 
local rt = dxCreateRenderTarget(radar_w, radar_w, true)

local radarShader = dxCreateShader("radar_shader.fx")
dxSetShaderValue(radarShader, "gTexture", rt)

local markers_on_map = {}
local last_x_game, last_y_game = -99999, -99999
local last_rotation = 0
local isMapVisible = false
local fullMapZoom = 1.0

addEventHandler("onClientResourceStart", resourceRoot, function()
    setPlayerHudComponentVisible("radar", false)
    toggleControl("radar", false) 
    bindKey("f11", "down", function()
        cancelEvent()
        isMapVisible = not isMapVisible
    end)
    
    for _, marker in ipairs(getElementsByType("marker")) do
        if getMarkerType(marker) == "cylinder" then
            local r, g, b, _ = getMarkerColor(marker)
            local mx, my, _ = getElementPosition(marker)
            
            local blip_type
            if r == 255 then
                blip_type = "blip.png"
            elseif r == 254 then
                blip_type = "blip2.png"
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

addEventHandler("onClientRender", root, function()
    if isMapVisible then
        local map_x = (screenW - full_map_size) / 2
        local map_y = (screenH - full_map_size) / 2
        dxDrawImage(map_x, map_y, full_map_size, full_map_size, "map.png")
        
        for _, marker in ipairs(markers_on_map) do
            local marker_x = ((marker[1] + 3000) / game_w) * full_map_size
            local marker_y = ((-marker[2] + 3000) / game_w) * full_map_size
            local radar_marker_x = map_x + marker_x
            local radar_marker_y = map_y + marker_y
            
            dxDrawImage(radar_marker_x - 8, radar_marker_y - 8, 16, 16, marker[3])
        end
        
        local x_game, y_game, _ = getElementPosition(localPlayer)
        local player_x = ((x_game + 3000) / game_w) * full_map_size
        local player_y = ((-y_game + 3000) / game_w) * full_map_size
        dxDrawImage(map_x + player_x - 8, map_y + player_y - 8, 16, 16, "player_icon.png")
    else
        local x_game, y_game, _ = getElementPosition(localPlayer)
        local rotation = getCameraRotation()
        
        dxSetRenderTarget(rt, true)
        dxDrawImageSection(0, 0, radar_w, radar_w, ((x_game + 3000) / game_w) * map_w - (radar_w / 2) * zoom_factor, ((-y_game + 3000) / game_w) * map_w - (radar_w / 2) * zoom_factor, radar_w * zoom_factor, radar_w * zoom_factor, "map.png")
        
        for _, marker in ipairs(markers_on_map) do
            local marker_x = (((marker[1] + 3000) / game_w) * map_w)
            local marker_y = (((-marker[2] + 3000) / game_w) * map_w)
            local radar_marker_x = (marker_x - ((x_game + 3000) / game_w) * map_w) / zoom_factor + radar_w / 2
            local radar_marker_y = (marker_y - ((-y_game + 3000) / game_w) * map_w) / zoom_factor + radar_w / 2
            dxDrawImage(radar_marker_x - 8, radar_marker_y - 8, 16, 16, marker[3], -rotation)
        end
        
        dxDrawImage(radar_w / 2 - 8, radar_w / 2 - 8, 16, 16, "player_icon.png", -rotation)
        
        dxSetRenderTarget()
        dxSetShaderValue(radarShader, "rotation", math.rad(-rotation))
        dxDrawImage(position_offset_x, screenH - radar_w - position_offset_y, radar_w, radar_w, radarShader)
    end
end)
