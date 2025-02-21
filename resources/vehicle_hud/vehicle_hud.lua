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

function onClientRender()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return end

    max_speed = math.floor((getVehicleHandling(vehicle)["maxVelocity"] + 0.5) / 10) * 10 + 30
    local currentSpeed = get_vehicle_speed(vehicle)

    draw_speedometer(currentSpeed)
    draw_speedometer_labels(currentSpeed)    
    draw_digital_current_speed(currentSpeed)
    draw_current_gear(vehicle)

    draw_nos_level(vehicle)
end
addEventHandler("onClientRender", root, onClientRender)
