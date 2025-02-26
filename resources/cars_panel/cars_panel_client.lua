local panelVisible = false
local showHint = false
local hintShown = ""
local screenW, screenH = guiGetScreenSize()
local centerX, centerY = screenW / 2, screenH / 2 -- Środek ekranu dla okręgu

local radius = screenH * 0.2 -- Promień okręgu
local button_size = screenH * 0.15 -- Rozmiar przycisku
local big_circle_size = radius * 2
local small_circle_size = radius / 2
local lineW = 5

-- Lista przycisków z dynamicznymi ikonami
local buttons = {
    {action = "toggleEngine", icon = "silnik", hint = "SILNIK"},
    {action = "toggleHandbrake", icon = "reczny", hint = "RĘCZNY"},
    {action = "toggleLights", icon = "swiatla", hint = "ŚWIATŁA"},
    {action = "toggleTrunk", icon = "bagaznik", hint = "BAGAŻNIK"},
    {action = "toggleHood", icon = "maska", hint = "MASKA"}
}

local buttonStates = {}

function updateButtonStates()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return end

    buttonStates["toggleEngine"] = getVehicleEngineState(vehicle)
    buttonStates["toggleHandbrake"] = isElementFrozen(vehicle)
    buttonStates["toggleLights"] = getVehicleOverrideLights(vehicle) == 2
    buttonStates["toggleTrunk"] = getVehicleDoorOpenRatio(vehicle, 1) > 0
    buttonStates["toggleHood"] = getVehicleDoorOpenRatio(vehicle, 0) > 0
end

addEvent("updateCarPanelIcons", true)
addEventHandler("updateCarPanelIcons", root, updateButtonStates)

local black = tocolor(0, 0, 0, 255)
local grey = tocolor(50, 50, 50, 255)
local lightGrey = tocolor(100, 100, 100, 200)

local accent1 = tocolor(0, 31, 63, 255)
local accent2 = tocolor(0, 58, 92, 255)
local accent3 = tocolor(0, 91, 131, 255)
local accent4 = tocolor(0, 123, 154, 255)
local accent5 = tocolor(0, 154, 159, 255)

local hint_font = exports.fonts:getFont("RobotoCondensed-Black", 20, false, "antialiased")

function drawCarControlPanel()
    if not panelVisible then return end
    updateButtonStates()

    -- Dim background
    dxDrawRectangle(0, 0, screenW, screenH, tocolor(0, 0, 0, 120))

    -- Circle background
    dxDrawCircle(centerX, centerY, big_circle_size, 0, 360, tocolor(0, 58, 92, 180), tocolor(0, 31, 63, 180), 32)

    -- Segments
    for i, btn in ipairs(buttons) do
        local angle = (360 / #buttons) * i - (360 / #buttons) / 2
        if hintShown == i then
            dxDrawCircle(centerX, centerY, big_circle_size, angle, angle - 360 / #buttons, tocolor(0, 58, 92, 180), tocolor(0, 58, 92, 180), 32)
        end
    end

    -- Lines
    for i, btn in ipairs(buttons) do
        local angle = math.rad((360 / #buttons) * i - (360 / #buttons) / 2)
        dxDrawLine(centerX, centerY, centerX + math.cos(angle) * big_circle_size, centerY + math.sin(angle) * big_circle_size, accent3, lineW)
    end

    -- Middle circle
    dxDrawCircle(centerX, centerY, small_circle_size, 0, 360, accent3, accent3, 64)

    -- Hint
    if showHint then
        dxDrawText(buttons[hintShown].hint, centerX, centerY, centerX, centerY, tocolor(255, 255, 255, 255), 1, hint_font, "center", "center")
    end

    -- Border
    local segments = 100
    for i = 1, segments do
        local angle = math.rad((360 / segments) * (i - 1))
        local next_angle = math.rad((360 / segments) * i)
        dxDrawLine(centerX + math.cos(angle) * big_circle_size,
                   centerY + math.sin(angle) * big_circle_size,
                   centerX + math.cos(next_angle) * big_circle_size,
                   centerY + math.sin(next_angle) * big_circle_size,
                   accent3, lineW)
    end

    for i, btn in ipairs(buttons) do
        local angle = math.rad((360 / #buttons) * (i - 1))
        local btnX = centerX + math.cos(angle) * radius * 1.3 - button_size / 2
        local btnY = centerY + math.sin(angle) * radius * 1.3 - button_size / 2
        
        local state = buttonStates[btn.action] and "_on" or "_off"
        local iconPath = btn.icon .. state .. ".png"

        dxDrawImage(btnX, btnY, button_size, button_size, iconPath)
    end
end
addEventHandler("onClientRender", root, drawCarControlPanel)

function toggle_car_control_panel(state)
    if isPedInVehicle(localPlayer) then
        panelVisible = state
        showCursor(state)
    else
        panelVisible = false
        showCursor(false)
    end
end

bindKey("lshift", "down", function()
    toggle_car_control_panel(true)
end)

bindKey("lshift", "up", function()
    toggle_car_control_panel(false)
end)

function mouse_distance(x, y, cx, cy)
    return math.sqrt((x - cx) ^ 2 + (y - cy) ^ 2)
end

function is_mouse_in_pie(x, y, cx, cy, radius, startAngle, endAngle)
    local angle = math.deg(math.atan2(y - cy, x - cx))
    angle = (angle + 360) % 360

    if startAngle > endAngle then
        return angle >= startAngle or angle <= endAngle
    end

    return angle >= startAngle and angle <= endAngle
end

function normalize_angle(angle)
    return (angle + 360) % 360
end

function onClientClick(button, state, x, y)
    if button ~= "left" or state ~= "up" or not panelVisible then return end

    for i, btn in ipairs(buttons) do
        if mouse_distance(x, y, centerX, centerY) < small_circle_size or mouse_distance(x, y, centerX, centerY) > big_circle_size then return end
        
        local endAngle = normalize_angle((360 / #buttons) * i - (360 / #buttons) / 2)
        local startAngle = normalize_angle(endAngle - 360 / #buttons)

        if is_mouse_in_pie(x, y, centerX, centerY, big_circle_size, startAngle, endAngle) then
            triggerServerEvent("handleCarAction", resourceRoot, btn.action)
            break
        end
    end
end
addEventHandler("onClientClick", root, onClientClick)

function onClientCursorMove(_, _, x, y)
    if not panelVisible then return end

    if mouse_distance(x, y, centerX, centerY) < small_circle_size or mouse_distance(x, y, centerX, centerY) > big_circle_size then
        showHint = false
        hintShown = nil
        return
    end

    showHint = true

    for i, btn in ipairs(buttons) do
        local endAngle = normalize_angle((360 / #buttons) * i - (360 / #buttons) / 2)
        local startAngle = normalize_angle(endAngle - 360 / #buttons)

        if is_mouse_in_pie(x, y, centerX, centerY, big_circle_size, startAngle, endAngle) then
            hintShown = i
            break
        end
    end
end
addEventHandler("onClientCursorMove", root, onClientCursorMove)