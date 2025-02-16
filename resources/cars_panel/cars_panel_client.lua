local panelVisible = false
local screenW, screenH = guiGetScreenSize()
local centerX, centerY = screenW / 2, screenH / 2 + 100 -- Środek ekranu dla okręgu
local radius = 100 -- Promień okręgu

local buttons = {
    {icon = "silnik.png", action = "toggleEngine"},
    {icon = "reczny.png", action = "toggleHandbrake"},
    {icon = "swiatla.png", action = "toggleLights"},
    {icon = "bagaznik.png", action = "toggleTrunk"},
    {icon = "maska.png", action = "toggleHood"}
}

function drawCarControlPanel()
    if not panelVisible then return end

    local numButtons = #buttons
    for i, btn in ipairs(buttons) do
        local angle = math.rad((360 / numButtons) * (i - 1))
        local btnX = centerX + math.cos(angle) * radius - 32
        local btnY = centerY + math.sin(angle) * radius - 32
        dxDrawImage(btnX, btnY, 64, 64, btn.icon)
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
        local btnX = centerX + math.cos(angle) * radius - 32
        local btnY = centerY + math.sin(angle) * radius - 32

        if x >= btnX and x <= btnX + 64 and y >= btnY and y <= btnY + 64 then
            triggerServerEvent("handleCarAction", resourceRoot, btn.action)
            break
        end
    end
end
addEventHandler("onClientClick", root, clickCarControlPanel)
