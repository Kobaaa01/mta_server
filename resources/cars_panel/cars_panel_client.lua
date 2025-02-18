local panelVisible = false
local screenW, screenH = guiGetScreenSize()
local centerX, centerY = screenW / 2, screenH / 2 -- Środek ekranu dla okręgu
local radius = screenH * 0.1 -- Promień okręgu
local buttonSize = screenH * 0.07 -- Rozmiar przycisku

-- Lista przycisków z dynamicznymi ikonami
local buttons = {
    {action = "toggleEngine", icon = "silnik"},
    {action = "toggleHandbrake", icon = "reczny"},
    {action = "toggleLights", icon = "swiatla"},
    {action = "toggleTrunk", icon = "bagaznik"},
    {action = "toggleHood", icon = "maska"}
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


function drawCarControlPanel()
    if not panelVisible then return end
    updateButtonStates()

    local numButtons = #buttons
    for i, btn in ipairs(buttons) do
        local angle = math.rad((360 / numButtons) * (i - 1))
        local btnX = centerX + math.cos(angle) * radius - buttonSize / 2
        local btnY = centerY + math.sin(angle) * radius - buttonSize / 2
        
        local state = buttonStates[btn.action] and "_on" or "_off"
        local iconPath = btn.icon .. state .. ".png"

        dxDrawImage(btnX, btnY, buttonSize, buttonSize, iconPath)
    end
end
addEventHandler("onClientRender", root, drawCarControlPanel)

function toggleCarControlPanel(state)
    if isPedInVehicle(localPlayer) then
        panelVisible = state
        showCursor(state)
    else
        panelVisible = false
        showCursor(false)
    end
end

bindKey("lshift", "down", function()
    toggleCarControlPanel(true)
end)

bindKey("lshift", "up", function()
    toggleCarControlPanel(false)
end)

function clickCarControlPanel(button, state, x, y)
    if button ~= "left" or state ~= "up" or not panelVisible then return end

    local numButtons = #buttons
    for i, btn in ipairs(buttons) do
        local angle = math.rad((360 / numButtons) * (i - 1))
        local btnX = centerX + math.cos(angle) * radius - buttonSize / 2
        local btnY = centerY + math.sin(angle) * radius - buttonSize / 2

        if x >= btnX and x <= btnX + buttonSize and y >= btnY and y <= btnY + buttonSize then
            triggerServerEvent("handleCarAction", resourceRoot, btn.action)
            break
        end
    end
end
addEventHandler("onClientClick", root, clickCarControlPanel)
