-- HUD Setup
local screenW, screenH = guiGetScreenSize()
local hudW = screenH * 0.3
local padding = screenH * 0.02
local speed_bar_width = 10
local nos_charge_bar_width = hudW / 3
local nos_charge_bar_height = 10

local accent1 = tocolor(0, 31, 63, 255)
local accent2 = tocolor(0, 58, 92, 255)
local accent3 = tocolor(0, 91, 131, 255)
local accent4 = tocolor(0, 123, 154, 255)
local accent5 = tocolor(0, 154, 159, 255)

local speedometer_scale_font = exports.fonts:getFont("RobotoCondensed-Regular", 9, false, "antialiased")
local gear_selector_font = exports.fonts:getFont("RobotoCondensed-Black", 20, false, "antialiased")
local digital_speed_display_font = exports.fonts:getFont("RobotoCondensed-Black", 50, false, "antialiased")
local nos_count_font = exports.fonts:getFont("RobotoCondensed-Black", 10, false, "antialiased")
local nos_ready_font = exports.fonts:getFont("RobotoCondensed-Black", 8, false, "antialiased")

local max_speed = 0
local handling = {}
local speedPerLine = 10

local vehicles = {
    Airplanes = {592, 577, 511, 512, 593, 520, 553, 476, 519, 460, 513},
    Helicopters = {548, 425, 417, 487, 488, 497, 563, 447, 469},
    Boats = {472, 473, 493, 595, 484, 430, 453, 452, 446, 454},
    Bikes = {581, 509, 481, 462, 521, 463, 510, 522, 461, 448, 468, 586},
    Cars_2Door_Compact = {602, 496, 401, 518, 527, 589, 419, 587, 533, 526, 474, 545, 517, 410, 600, 436, 439, 549, 491},
    Cars_4Door_Luxury = {445, 604, 507, 585, 466, 492, 546, 551, 516, 467, 426, 547, 405, 580, 409, 550, 566, 540, 421, 529},
    Civil_Service = {485, 431, 438, 437, 574, 420, 525, 408, 552},
    Government_Vehicles = {416, 433, 427, 490, 528, 407, 544, 523, 470, 596, 598, 599, 597, 432, 601, 428},
    Heavy_Utility_Trucks = {499, 609, 498, 524, 532, 578, 486, 406, 573, 455, 588, 403, 423, 414, 443, 515, 514, 531, 456},
    Light_Trucks_Vans = {459, 422, 482, 605, 530, 418, 572, 582, 413, 440, 543, 583, 478, 554},
    SUVs_Wagons = {579, 400, 404, 489, 505, 479, 442, 458},
    Lowriders = {536, 575, 534, 567, 535, 576, 412},
    Muscle_Cars = {402, 542, 603, 475},
    Street_Racers = {429, 541, 415, 480, 562, 565, 434, 494, 502, 503, 411, 559, 561, 560, 506, 451, 558, 555, 477},
    RC_Vehicles = {441, 464, 594, 501, 465, 564},
    Trailers = {606, 607, 610, 584, 611, 608, 435, 450, 591},
    Trains_Railroad = {590, 538, 570, 569, 537, 449},
    Recreational = {568, 424, 504, 457, 483, 508, 571, 500, 444, 556, 557, 471, 495, 539}
}

function get_vehicle_speed(vehicle)
    local dx, dy, dz = getElementVelocity(vehicle)
    return math.sqrt(dx^2 + dy^2 + dz^2) * 180
end

function is_vehicle_reversing(theVehicle)
    local get_matrix = getElementMatrix (theVehicle)
    local get_velocity = Vector3 (getElementVelocity(theVehicle))
    local get_vector_direction = (get_velocity.x * get_matrix[2][1]) + (get_velocity.y * get_matrix[2][2]) + (get_velocity.z * get_matrix[2][3])
    if (get_vector_direction < 0) then
        return true
    end
    return false
end

function draw_current_gear(vehicle)
    local gearText = is_vehicle_reversing(vehicle) and "R" or getVehicleCurrentGear(vehicle) == 0 and "N" or "D" .. tostring(getVehicleCurrentGear(vehicle))
    local gearColor = gearText == "R" and tocolor(255, 0, 0, 255) or gearText == "N" and accent3 or accent4

    dxDrawText(gearText,
               screenW - hudW / 2 - padding, 
               screenH - hudW / 2 - padding - 50, 
               screenW - hudW / 2 - padding, 
               screenH - hudW / 2 - padding - 50, 
               gearColor, 1, gear_selector_font, "center", "center")
end

function draw_digital_current_speed(currentSpeed)
    dxDrawText(math.floor(currentSpeed),
               screenW - hudW / 2 - padding, 
               screenH - hudW / 2 - padding, 
               screenW - hudW / 2 - padding, 
               screenH - hudW / 2 - padding, 
               accent5, 1, digital_speed_display_font, "center", "center")
end

function draw_speedometer(currentSpeed)
    local currentAngle = 270 * (currentSpeed / max_speed)
    if currentAngle > 270 then currentAngle = 270 end

    dxDrawCircle(screenW - hudW / 2 - padding, screenH - hudW / 2 - padding, hudW / 2, 0, 360, accent2, accent2, 64)
    dxDrawCircle(screenW - hudW / 2 - padding, screenH - hudW / 2 - padding, hudW / 2, 135, 405, accent1, accent1, 64)
    dxDrawCircle(screenW - hudW / 2 - padding, screenH - hudW / 2 - padding, hudW / 2, 135, 135 + currentAngle, accent4, accent4, 64)
    dxDrawCircle(screenW - hudW / 2 - padding, screenH - hudW / 2 - padding, hudW / 2 - speed_bar_width, 0, 360, accent2, accent2, 64)
end

function draw_speedometer_labels(currentSpeed)
    local lineCount = max_speed / speedPerLine
    for i = 0, lineCount do
        local angle = 135 + 270 * (i / lineCount)
        local color = currentSpeed > i * speedPerLine and accent4 or accent1
        local x = screenW - hudW / 2 - padding + math.cos(math.rad(angle)) * (hudW / 2 - speed_bar_width * 2.5)
        local y = screenH - hudW / 2 - padding + math.sin(math.rad(angle)) * (hudW / 2 - speed_bar_width * 2.5)
        dxDrawText(i * speedPerLine, x, y, x, y, color, 1, speedometer_scale_font, "center", "center")
    end
end

function draw_nos_level(vehicle)
    local nitro_count = getVehicleNitroCount(vehicle)
    local nitro_level = getVehicleNitroLevel(vehicle)
    local nitro_activated = isVehicleNitroActivated(vehicle)
    local nitro_recharging = isVehicleNitroRecharging(vehicle)

    if not nitro_level then return end

    if nitro_count == 0 and not nitro_activated then
        nitro_level = 0
    end
    
    local dx =screenW - hudW / 2 - padding - nos_charge_bar_width / 2
    local dy = screenH - hudW / 2 - padding + 50

    local bar_color = nitro_recharging and accent3 or accent5

    dxDrawRectangle(
        dx, 
        dy, 
        nos_charge_bar_width,
        nos_charge_bar_height,
        accent1
    )
    dxDrawRectangle(
        dx, 
        dy, 
        nos_charge_bar_width * nitro_level,
        nos_charge_bar_height,
        bar_color
    )
    if nitro_count > 1 and nitro_level == 1 then
        dxDrawText(
            nitro_count,
            dx - 5, 
            dy +  nos_charge_bar_height / 2 + 1, 
            dx - 5, 
            dy + nos_charge_bar_height / 2 + 1, 
            bar_color, 1, nos_count_font, "center", "center"
        )
    end
    if nitro_level == 1 then
        dxDrawText(
            "NOS Ready",
            dx, 
            dy - 12, 
            dx + nos_charge_bar_width, 
            dy + nos_charge_bar_height - 12, 
            accent5, 1, nos_ready_font, "center", "center"
        )
    end
    if nitro_count == 0 and nitro_level == 0 then
        dxDrawText(
            "NOS Empty",
            dx, 
            dy - 12, 
            dx + nos_charge_bar_width, 
            dy + nos_charge_bar_height - 12, 
            accent1, 1, nos_ready_font, "center", "center"
        )
    end
end

function get_vehicle_category(id)
    for category, ids in pairs(vehicles) do
        for _, vehicleID in ipairs(ids) do
            if vehicleID == id then
                return category
            end
        end
    end
    return nil
end

function is_vehicle_aircraft(category)
    return category == "Airplanes" or category == "Helicopters"
end

local air_color = tocolor(98, 187, 213, 255)
local ground_color = tocolor(154, 85, 17, 255)
local attitude_indicator_target = dxCreateRenderTarget(hudW, hudW, true)
local attitude_indicator_shader = dxCreateShader("attitude_indicator_shader.fx")
local attitude_indicator_size = 1000
dxSetShaderValue(attitude_indicator_shader, "gTexture", attitude_indicator_target)

function draw_attitude_indicator(pitch, roll)
    local pitch_y_offset = pitch
    if pitch_y_offset > 180 then
        pitch_y_offset = (pitch_y_offset - 360) * 3
    else 
        pitch_y_offset = pitch_y_offset * 3
    end
    
    dxSetRenderTarget(attitude_indicator_target, true)

    dxDrawCircle(hudW / 2, hudW / 2 + pitch_y_offset, attitude_indicator_size, 180 - roll, 360 - roll, air_color, air_color, 64)
    dxDrawCircle(hudW / 2, hudW / 2 + pitch_y_offset, attitude_indicator_size, -roll, 180 - roll, ground_color, ground_color, 64)
    local x2 = hudW / 2 + math.cos(math.rad(roll)) * attitude_indicator_size
    local y1 = hudW / 2 + pitch_y_offset + math.sin(math.rad(roll)) * attitude_indicator_size
    local x1 = hudW / 2 + math.cos(math.rad(roll + 180)) * attitude_indicator_size
    local y2 = hudW / 2 + pitch_y_offset + math.sin(math.rad(roll + 180)) * attitude_indicator_size
    dxDrawLine(x1, y1, x2, y2, tocolor(0, 0, 0, 255), 3)

    dxSetRenderTarget()
    dxDrawImage(screenW - hudW - padding + hudW * 0.0125, screenH - hudW - padding + hudW * 0.0125, hudW * 0.975, hudW * 0.975, attitude_indicator_shader, 0, 0, 0, tocolor(255, 255, 255, 255))
end

function get_airspeed(vehicle)
    local dx, dy, dz = getElementVelocity(vehicle)
    return math.sqrt(dx^2 + dy^2) * 180
end

local speed_tape_width = 75
local speed_tape_target = dxCreateRenderTarget(speed_tape_width, hudW, true)
local speed_tape_current_speed_font = exports.fonts:getFont("RobotoCondensed-Black", 20, false, "antialiased")
local speed_tape_current_speed_rectangle_height = 40
local arrow = dxCreateRenderTarget(speed_tape_current_speed_rectangle_height, speed_tape_current_speed_rectangle_height, false)

function draw_speed_tape(speed)
    dxSetRenderTarget(speed_tape_target, true)

    dxDrawRectangle(0, 0, speed_tape_width, hudW, accent1) -- Background
    -- Current speed display background
    dxDrawRectangle(0, hudW / 2 - speed_tape_current_speed_rectangle_height / 2, speed_tape_width - speed_tape_current_speed_rectangle_height / 2, speed_tape_current_speed_rectangle_height, accent3)
    
    -- Draw arrow pointing to speed tape
    dxSetRenderTarget(arrow, true)
    dxDrawRectangle(0, 0, speed_tape_current_speed_rectangle_height, speed_tape_current_speed_rectangle_height, tocolor(255, 0, 0, 100))
    dxSetRenderTarget(speed_tape_target)
    dxDrawImage(speed_tape_width - speed_tape_current_speed_rectangle_height * math.sqrt(2), hudW / 2, speed_tape_current_speed_rectangle_height, speed_tape_current_speed_rectangle_height, arrow, 45)

    local current_speed_x = speed_tape_width / 2
    local current_speed_y = hudW / 2
    dxDrawText(tostring(math.floor(speed)), current_speed_x, current_speed_y, current_speed_x, current_speed_y, tocolor(255, 255, 255, 255), 1, speed_tape_current_speed_font, "center", "center")

    dxSetRenderTarget()
    dxDrawImage(screenW - hudW - padding - speed_tape_width / 2, screenH - hudW - padding, speed_tape_width, hudW, speed_tape_target)
end

function draw_aircraft_hud(vehicle)
    local pitch, roll, yaw = getElementRotation(vehicle)
    local air_speed = get_airspeed(vehicle)

    dxDrawCircle(screenW - hudW / 2 - padding, screenH - hudW / 2 - padding, hudW / 2, 0, 360, accent2, accent2, 64)

    draw_attitude_indicator(pitch, roll)
    draw_speed_tape(air_speed)
end

function onClientRender()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return end

    if is_vehicle_aircraft(get_vehicle_category(getElementModel(vehicle))) then
        draw_aircraft_hud(vehicle)
        return
    end

    max_speed = math.floor((getVehicleHandling(vehicle)["maxVelocity"] + 0.5) / 10) * 10 + 30
    local currentSpeed = get_vehicle_speed(vehicle)

    draw_speedometer(currentSpeed)
    draw_speedometer_labels(currentSpeed)    
    draw_digital_current_speed(currentSpeed)
    draw_current_gear(vehicle)

    draw_nos_level(vehicle)
end
addEventHandler("onClientRender", root, onClientRender)
