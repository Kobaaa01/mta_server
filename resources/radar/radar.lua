local screen_w, screen_h = guiGetScreenSize()
local map_w = 6000
local game_w = 6000
local radar_w = screen_h * 0.3
local zoom_factor = 2
local position_offset_x = screen_h * 0.02
local position_offset_y = position_offset_x
local full_map_size = screen_h * 0.95 -- rozmiar mapy w trybie pełnoekranowym (F11)
local rt = dxCreateRenderTarget(radar_w, radar_w, true)
local iconSize = 30

local radarShader = dxCreateShader("radar_shader.fx")
dxSetShaderValue(radarShader, "gTexture", rt)

local markers_on_map = {}
local is_map_visible = false

local full_map_zoom = 1.0 -- Początkowy zoom
local min_zoom = 1.0 -- Minimalny zoom (nie można oddalić bardziej niż stan początkowy)
local max_zoom = 3.0 -- Maksymalny zoom
local zoom_speed = 0.1 -- Szybkość zoomowania

local map_offset_x = 0
local map_offset_y = 0

local is_dragging = false
local drag_start_x, drag_start_y = 0, 0
local drag_offset_x, drag_offset_y = 0, 0

local path_advance_progress_proximity = 15 -- Advance path if player is closer than this
local path_recalculate_proximity = 50 -- Recalculate path if player is futher than this
local path_end_proximity = 100 -- End path if player is closer to destination than this

-- Funkcja do konwersji współrzędnych świata na współrzędne mapy
local function convert_world_map(x, y)
    local map_x = (x + 3000) / game_w * map_w
    local map_y = (-y + 3000) / game_w * map_w
    return map_x, map_y
end

local current_path = nil
local current_destination_x = nil
local current_destination_y = nil
local current_destination_bearing = nil

function path_found(path)
    current_path = path
end
addEvent("pathFound", true)
addEventHandler("pathFound", localPlayer, path_found)

function request_path(x, y, z)
    local px, py, pz = getElementPosition(localPlayer)
    triggerServerEvent("getPath", root, localPlayer, px, py, pz, x, y, z)
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    bindKey("f11", "down", function()
        cancelEvent()
        is_map_visible = not is_map_visible
        showCursor(is_map_visible)
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

local function get_camera_rotation()
    local camX, camY, _, lookX, lookY, _ = getCameraMatrix()
    return -math.deg(math.atan2(lookX - camX, lookY - camY))
end

-- ... (istniejący kod pozostaje bez zmian)

local accent1 = tocolor(0, 31, 63, 255)
local accent2 = tocolor(0, 58, 92, 255)
local accent3 = tocolor(0, 91, 131, 255)
local accent4 = tocolor(0, 123, 154, 255)
local accent5 = tocolor(0, 154, 159, 255)

local north_indicator_font = exports.fonts:getFont("RobotoCondensed-Black", 10, false, "antialiased")
local map_texture = dxCreateTexture("mapa.png")
if not map_texture then
    for i = 1, 10 do
        outputDebugString("Failed to load map texture. Retrying...")
        map_texture = dxCreateTexture("mapa.png")
        if map_texture then
            break
        end
    end
end

function distance_to_destination()
    if not current_path then
        return 0
    end
    local dist = 0
    for i = 2, #current_path do
        local x, y = current_path[i - 1][1], current_path[i - 1][2]
        local x1, y1 = current_path[i][1], current_path[i][2]
        dist = dist + getDistanceBetweenPoints2D(x, y, x1, y1)
    end
    return dist
end

function format_distance(distance)
    if distance < 1000 then
        return math.floor(distance / 10) * 10 .. "m"
    else
        return string.format("%.1fkm", distance / 1000)
    end
end

function distance_to_closest_point()
    if not current_path then
        return 0
    end
    local x, y, z = getElementPosition(localPlayer)
    local min_dist = 999999
    for i = 1, #current_path do
        local x1, y1 = current_path[i][1], current_path[i][2]
        local dist = getDistanceBetweenPoints2D(x, y, x1, y1)
        if dist < min_dist then
            min_dist = dist
        end
    end
    return min_dist
end

local last_recalculation = 0

local is_in_aircraft = false

local compass_width = screen_w / 4
local compass_height = screen_h / 20
local compass_padding = 10

-- local accent2 = tocolor(0, 58, 92, 255)
-- local accent3 = tocolor(0, 91, 131, 255)
-- local accent4 = tocolor(0, 123, 154, 255)

local compass_tick_main_color = {0, 123, 154}
local compass_tick_secondary_color = {0, 58, 92}
local compass_tick_spacing = 50
local compass_tick_scale = 20
local compass_tick_font = exports.fonts:getFont("RobotoCondensed-Black", 10, false, "antialiased")

function findRotation(x1, y1, x2, y2)
    local t = -math.deg(math.atan2(x2 - x1, y2 - y1))
    return t < 0 and t + 360 or t
end

addEventHandler("onClientRender", root, function()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if vehicle and not is_map_visible then
        local vehicle_id = getElementModel(vehicle)
        local vehicle_category = exports.vehicle_hud:get_vehicle_category(vehicle_id)
        local is_vehicle_aircraft = exports.vehicle_hud:is_vehicle_aircraft(vehicle_category)
        if is_vehicle_aircraft then
            is_in_aircraft = true
            current_path = nil

            local yaw = get_camera_rotation()

            -- Background
            dxDrawRectangle(screen_w / 2 - compass_width / 2 - 3, compass_padding - 3, compass_width + 6,
                compass_height + 6, accent1)
            dxDrawRectangle(screen_w / 2 - compass_width / 2, compass_padding, compass_width, compass_height, accent2)

            -- Tick marks
            for i = -20, 20 do
                local dx = screen_w / 2 + (yaw / compass_tick_scale * compass_tick_spacing) + i * compass_tick_spacing
                local line_color_scale = (1 - math.abs(dx - screen_w / 2) / (compass_width / 2)) ^ (3 / 2)
                local r = compass_tick_secondary_color[1] +
                              (compass_tick_main_color[1] - compass_tick_secondary_color[1]) * line_color_scale
                local g = compass_tick_secondary_color[2] +
                              (compass_tick_main_color[2] - compass_tick_secondary_color[2]) * line_color_scale
                local b = compass_tick_secondary_color[3] +
                              (compass_tick_main_color[3] - compass_tick_secondary_color[3]) * line_color_scale
                local check_buffer = 20
                local check_l = screen_w / 2 - compass_width / 2 + check_buffer
                local check_r = screen_w / 2 + compass_width / 2 - check_buffer
                if dx > check_l and dx < check_r then
                    local tick_text = i * compass_tick_scale
                    if tick_text < 0 then
                        tick_text = tick_text + 360
                    end
                    if tick_text < 0 then
                        tick_text = tick_text + 360
                    end
                    dxDrawLine(dx, compass_padding, dx, compass_padding + compass_height / 4, tocolor(r, g, b, 255), 3)
                    dxDrawText(tostring(tick_text), dx + 2, compass_padding + 20, dx + 2, compass_padding + 20,
                        tocolor(r, g, b, 255), 1, compass_tick_font, "center", "center")
                end
            end

            -- Navigation destination
            if current_destination_bearing and current_destination_x and current_destination_y then
                yaw = -yaw + 360
                if yaw > 360 then
                    yaw = yaw - 360
                end
                local display_angle = current_destination_bearing - yaw
                if display_angle > 360 then
                    display_angle = display_angle - 360
                end
                if display_angle < 0 then
                    display_angle = display_angle + 360
                end
                local dx = screen_w / 2 + (display_angle / compass_tick_scale * compass_tick_spacing)
                local check_l = screen_w / 2 - compass_width / 2
                local check_r = screen_w / 2 + compass_width / 2
                if dx > check_r then
                    dx = dx - 360 / compass_tick_scale * compass_tick_spacing
                end
                if dx > check_l and dx < check_r then
                    dxDrawLine(dx, compass_padding, dx, compass_padding + compass_height, accent5, 3)
                end

                dxDrawLine3D(current_destination_x, current_destination_y, 0, current_destination_x,
                    current_destination_y, 500, accent5, 100, false)
            end

            -- Facing line
            dxDrawLine(screen_w / 2, compass_padding, screen_w / 2, compass_padding + compass_height, accent1, 3)
        else
            is_in_aircraft = false
        end
    end

    if is_map_visible then

        -- Oblicz pozycję mapy na ekranie (wyśrodkowana)
        local map_x = (screen_w - full_map_size) / 2
        local map_y = (screen_h - full_map_size) / 2

        local mapLeft = map_x
        local mapTop = map_y
        local mapRight = mapLeft + full_map_size
        local mapBottom = mapTop + full_map_size

        local iconLeft
        local iconTop
        local iconRight
        local iconButton

        -- Oblicz widoczny fragment mapy
        local visible_width = map_w / full_map_zoom
        local visible_height = map_w / full_map_zoom

        -- Narysuj widoczny fragment mapy
        dxDrawImageSection(map_x, map_y, full_map_size, full_map_size, map_offset_x, map_offset_y, visible_width,
            visible_height, map_texture, 0, 0, 0, tocolor(255, 255, 255, 255), false)

        -- Draw path
        if current_path then
            for i = 2, #current_path do
                local x1, y1 = convert_world_map(current_path[i - 1][1], current_path[i - 1][2])
                local x2, y2 = convert_world_map(current_path[i][1], current_path[i][2])
                local draw_x1 = map_x + ((x1 - map_offset_x) / visible_width) * full_map_size
                local draw_y1 = map_y + ((y1 - map_offset_y) / visible_height) * full_map_size
                local draw_x2 = map_x + ((x2 - map_offset_x) / visible_width) * full_map_size
                local draw_y2 = map_y + ((y2 - map_offset_y) / visible_height) * full_map_size

                -- Sprawdź czy którykolwiek punkt linii jest widoczny
                local point1In = (draw_x1 >= mapLeft and draw_x1 <= mapRight and draw_y1 >= mapTop and draw_y1 <=
                                     mapBottom)
                local point2In = (draw_x2 >= mapLeft and draw_x2 <= mapRight and draw_y2 >= mapTop and draw_y2 <=
                                     mapBottom)

                if point1In or point2In then
                    dxDrawLine(draw_x1, draw_y1, draw_x2, draw_y2, accent5, 3)
                end
            end
        end

        -- Rysuj markery na mapie
        for _, marker in ipairs(markers_on_map) do
            local marker_x, marker_y = convert_world_map(marker[1], marker[2])
            local radar_marker_x = map_x + ((marker_x - map_offset_x) / visible_width) * full_map_size
            local radar_marker_y = map_y + ((marker_y - map_offset_y) / visible_height) * full_map_size

            -- Sprawdź czy ikona znajduje się w widocznym obszarze
            iconLeft = radar_marker_x
            iconTop = radar_marker_y
            iconRight = iconLeft
            iconBottom = iconTop

            if iconLeft < mapRight and iconRight > mapLeft and iconTop < mapBottom and iconBottom > mapTop then
                dxDrawImage(iconLeft, iconTop, iconSize, iconSize, marker[3])
            end
        end

        -- Rysuj ikonę lokalnego gracza
        local x_game, y_game, _ = getElementPosition(localPlayer)
        local player_x, player_y = convert_world_map(x_game, y_game)

        local radar_player_x = map_x + ((player_x - map_offset_x) / visible_width) * full_map_size
        local radar_player_y = map_y + ((player_y - map_offset_y) / visible_height) * full_map_size

        iconLeft = radar_player_x
        iconTop = radar_player_y
        iconRight = iconLeft
        iconBottom = iconTop

        if iconLeft < mapRight and iconRight > mapLeft and iconTop < mapBottom and iconBottom > mapTop then
            dxDrawImage(iconLeft, iconTop, iconSize, iconSize, "player_icon.png")
        end

        -- Rysuj ikony innych graczy
        for _, player in ipairs(getElementsByType("player")) do
            if player ~= localPlayer then
                local px, py, pz = getElementPosition(player)
                local map_px, map_py = convert_world_map(px, py)

                local draw_x = map_x + ((map_px - map_offset_x) / visible_width) * full_map_size
                local draw_y = map_y + ((map_py - map_offset_y) / visible_height) * full_map_size

                iconLeft = draw_x
                iconTop = draw_y
                iconRight = iconLeft
                iconBottom = iconTop

                if iconLeft < mapRight and iconRight > mapLeft and iconTop < mapBottom and iconBottom > mapTop then
                    dxDrawImage(iconLeft, iconTop, iconSize, iconSize, "other_player.png")
                end
            end
        end

    else
        -- Tryb radaru (mała mapa w rogu ekranu)
        local x_game, y_game, _ = getElementPosition(localPlayer)
        local rotation = get_camera_rotation()

        dxSetRenderTarget(rt, true)
        dxDrawRectangle(0, 0, radar_w, radar_w, tocolor(0, 0, 0, 0))

        -- Rysuj widoczny obszar mapy
        local section_x = (x_game + 3000) / game_w * map_w - (radar_w / 2) * zoom_factor
        local section_y = (-y_game + 3000) / game_w * map_w - (radar_w / 2) * zoom_factor
        dxDrawImageSection(0, 0, radar_w, radar_w, section_x, section_y, radar_w * zoom_factor, radar_w * zoom_factor,
            map_texture)

        -- Draw path
        if current_path then
            for i = 2, #current_path do
                local x1, y1 = convert_world_map(current_path[i - 1][1], current_path[i - 1][2])
                local x2, y2 = convert_world_map(current_path[i][1], current_path[i][2])
                local draw_x1 = (x1 - section_x) / zoom_factor
                local draw_y1 = (y1 - section_y) / zoom_factor
                local draw_x2 = (x2 - section_x) / zoom_factor
                local draw_y2 = (y2 - section_y) / zoom_factor
                dxDrawLine(draw_x1, draw_y1, draw_x2, draw_y2, accent5, 5)
            end
        end

        -- Rysuj markery na radarze
        for _, marker in ipairs(markers_on_map) do
            local marker_x, marker_y = convert_world_map(marker[1], marker[2])
            local radar_marker_x = (marker_x - section_x) / zoom_factor
            local radar_marker_y = (marker_y - section_y) / zoom_factor
            dxDrawImage(radar_marker_x - iconSize / 2, radar_marker_y - iconSize / 2, iconSize, iconSize, marker[3],
                -rotation)
        end

        -- Rysuj ikony innych graczy na radarze
        for _, player in ipairs(getElementsByType("player")) do
            if player ~= localPlayer then
                local px, py, pz = getElementPosition(player)
                local marker_x, marker_y = convert_world_map(px, py)
                local radar_marker_x = (marker_x - section_x) / zoom_factor
                local radar_marker_y = (marker_y - section_y) / zoom_factor
                dxDrawImage(radar_marker_x - iconSize / 2, radar_marker_y - iconSize / 2, iconSize, iconSize,
                    "other_player.png", -rotation)
            end
        end

        -- Aircraft destination
        if is_in_aircraft and current_destination_x and current_destination_y and current_destination_bearing then
            local x, y = convert_world_map(current_destination_x, current_destination_y)
            dxDrawCircle((x - section_x) / zoom_factor, (y - section_y) / zoom_factor, 10, 0, 360, accent5)
        end

        -- Rysuj ikonę lokalnego gracza na radarze
        dxDrawImage(radar_w / 2 - iconSize / 2, radar_w / 2 - iconSize / 2, iconSize, iconSize, "player_icon.png",
            -rotation)

        dxSetRenderTarget()
        dxSetShaderValue(radarShader, "rotation", math.rad(-rotation))
        dxDrawCircle(position_offset_x + radar_w / 2, screen_h - radar_w / 2 - position_offset_y, radar_w / 2, 0, 360,
            accent2) -- Ring
        dxDrawImage(position_offset_x + radar_w * 0.025, screen_h - radar_w - position_offset_y + radar_w * 0.025,
            radar_w * 0.95, radar_w * 0.95, radarShader) -- Radar Shader

        local north_angle = get_camera_rotation() - 90

        local north_x = position_offset_x + radar_w / 2 + math.cos(math.rad(north_angle)) * radar_w / 2 * 0.975
        local north_y = screen_h - radar_w / 2 - position_offset_y + math.sin(math.rad(north_angle)) * radar_w / 2 *
                            0.975

        -- North indicator
        dxDrawCircle(north_x, north_y, 10, 0, 360, accent2)
        dxDrawText("N", north_x + 1, north_y + 1, north_x + 1, north_y + 1, tocolor(255, 255, 255, 255), 1,
            north_indicator_font, "center", "center")

        -- Distance to destination
        if current_path and #current_path > 0 then
            dxDrawText(format_distance(distance_to_destination()), position_offset_x + radar_w / 2,
                screen_h - position_offset_y - 50, position_offset_x + radar_w / 2, screen_h - position_offset_y - 50,
                tocolor(255, 255, 255, 255), 1, north_indicator_font, "center", "center")
        end

        if is_in_aircraft and current_destination_x and current_destination_y then
            local x, y, z = getElementPosition(localPlayer)
            local dist = getDistanceBetweenPoints2D(x, y, current_destination_x, current_destination_y)

            dxDrawText(format_distance(dist), position_offset_x + radar_w / 2, screen_h - position_offset_y - 50,
                position_offset_x + radar_w / 2, screen_h - position_offset_y - 50, tocolor(255, 255, 255, 255), 1,
                north_indicator_font, "center", "center")
        end
    end

    if not is_in_aircraft and current_path and #current_path > 0 then
        local dist = distance_to_closest_point()
        if dist < path_advance_progress_proximity then
            table.remove(current_path, 1)
        end

        if dist > path_recalculate_proximity then
            local now = getTickCount()
            if not last_recalculation or now - last_recalculation > 5000 then
                last_recalculation = now
                request_path(current_destination_x, current_destination_y, 0)
            end
        end

        local x, y, z = getElementPosition(localPlayer)
        if getDistanceBetweenPoints2D(x, y, current_path[#current_path][1], current_path[#current_path][2]) <
            path_end_proximity / 2 then
            current_path = {}
            current_destination_x = nil
            current_destination_y = nil
            current_destination_bearing = nil
        end
    end

    if is_in_aircraft and current_destination_x and current_destination_y then
        local x, y, z = getElementPosition(localPlayer)
        local dist = getDistanceBetweenPoints2D(x, y, current_destination_x, current_destination_y)
        -- outputChatBox(dist)

        current_destination_bearing = 360 - findRotation(x, y, current_destination_x, current_destination_y)

        if dist < path_end_proximity then
            current_destination_x = nil
            current_destination_y = nil
            current_destination_bearing = nil
        end
    end
end)

function clickMap(button, state, x, y)
    if button ~= "left" or state ~= "up" or not is_map_visible then
        return
    end

    local map_x = (screen_w - full_map_size * full_map_zoom) / 2
    local map_y = (screen_h - full_map_size * full_map_zoom) / 2

    if x >= map_x and x <= map_x + full_map_size * full_map_zoom and y >= map_y and y <= map_y + full_map_size *
        full_map_zoom then
        local x_game = (x - map_x) / (full_map_size * full_map_zoom) * map_w - map_w / 2
        local y_game = map_w / 2 - (y - map_y) / (full_map_size * full_map_zoom) * map_w

        current_destination_x = x_game
        current_destination_y = y_game
        if not is_in_aircraft then
            request_path(x_game, y_game, 0)
        end
    end
end
addEventHandler("onClientClick", root, clickMap)

addEventHandler("onClientKey", root, function(button, press)
    if press and is_map_visible then
        if button == "mouse_wheel_down" then
            -- PRZYBLIŻANIE (zoom in) -----------------------------------------
            local old_zoom = full_map_zoom
            full_map_zoom = math.max(min_zoom, full_map_zoom - zoom_speed)

            -- middle of visible map
            local visible_center_x = map_offset_x + (map_w / (2 * old_zoom))
            local visible_center_y = map_offset_y + (map_w / (2 * old_zoom))

            -- new middle bc of zooming 
            map_offset_x = visible_center_x - (map_w / (2 * full_map_zoom))
            map_offset_y = visible_center_y - (map_w / (2 * full_map_zoom))

        elseif button == "mouse_wheel_up" then
            -- ODDALANIE (zoom out) ------------------------------------------
            local old_zoom = full_map_zoom
            full_map_zoom = math.min(max_zoom, full_map_zoom + zoom_speed)

            local visible_center_x = map_offset_x + (map_w / (2 * old_zoom))
            local visible_center_y = map_offset_y + (map_w / (2 * old_zoom))

            map_offset_x = visible_center_x - (map_w / (2 * full_map_zoom))
            map_offset_y = visible_center_y - (map_w / (2 * full_map_zoom))
        end

        local max_offset_x = map_w - (map_w / full_map_zoom)
        local max_offset_y = map_w - (map_w / full_map_zoom)
        map_offset_x = math.max(0, math.min(max_offset_x, map_offset_x))
        map_offset_y = math.max(0, math.min(max_offset_y, map_offset_y))
    end
end)

function startDragging(button, state, x, y)
    if button == "right" and state == "down" and is_map_visible then
        -- is cursor over map
        local map_x = (screen_w - full_map_size) / 2
        local map_y = (screen_h - full_map_size) / 2

        if x >= map_x and x <= map_x + full_map_size and y >= map_y and y <= map_y + full_map_size then
            is_dragging = true
            drag_start_x, drag_start_y = x, y
            drag_offset_x, drag_offset_y = map_offset_x, map_offset_y
            cancelEvent()
        end
    elseif button == "right" and state == "up" then
        is_dragging = false
    end
end
addEventHandler("onClientClick", root, startDragging)

function dragMap()
    if is_dragging then
        local mouse_x, mouse_y = getCursorPosition()
        if not mouse_x or not mouse_y then
            return
        end

        -- cursor to screen 
        mouse_x = mouse_x * screen_w
        mouse_y = mouse_y * screen_h

        local delta_x = mouse_x - drag_start_x
        local delta_y = mouse_y - drag_start_y

        -- move map
        map_offset_x = drag_offset_x - (delta_x / full_map_size) * (map_w / full_map_zoom)
        map_offset_y = drag_offset_y - (delta_y / full_map_size) * (map_w / full_map_zoom)

        local max_offset_x = map_w - (map_w / full_map_zoom)
        local max_offset_y = map_w - (map_w / full_map_zoom)
        map_offset_x = math.max(0, math.min(max_offset_x, map_offset_x))
        map_offset_y = math.max(0, math.min(max_offset_y, map_offset_y))
    end
end
addEventHandler("onClientRender", root, dragMap)

function cleanupResources()
    if map_texture and isElement(map_texture) then
        destroyElement(map_texture)
        map_texture = nil
    end
    if rt and isElement(rt) then
        destroyElement(rt)
        rt = nil
    end
    if radarShader and isElement(radarShader) then
        destroyElement(radarShader)
        radarShader = nil
    end
    outputDebugString("Resources cleaned up!")
end

addEventHandler("onClientResourceStop", resourceRoot, cleanupResources)
