-- HUD Setup
local screenW, screenH = guiGetScreenSize()
local hudW = screenH * 0.3
local padding = screenH * 0.02
local speedBarWidth = 10

local accent1 = tocolor(0, 31, 63, 255)
local accent2 = tocolor(0, 58, 92, 255)
local accent3 = tocolor(0, 91, 131, 255)
local accent4 = tocolor(0, 123, 154, 255)
local accent5 = tocolor(0, 154, 159, 255)

local displayHUD = false
local maxSpeed = 0
local handling = {}
local speedPerLine = 10

function getVehicleSpeed(vehicle)
    local dx, dy, dz = getElementVelocity(vehicle)
    return math.sqrt(dx^2 + dy^2 + dz^2) * 180
end

function isVehicleReversing(theVehicle)
    local getMatrix = getElementMatrix (theVehicle)
    local getVelocity = Vector3 (getElementVelocity(theVehicle))
    local getVectorDirection = (getVelocity.x * getMatrix[2][1]) + (getVelocity.y * getMatrix[2][2]) + (getVelocity.z * getMatrix[2][3])
    if (getVectorDirection < 0) then
        return true
    end
    return false
end

function drawHUD()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if not vehicle then return end

    maxSpeed = math.floor((getVehicleHandling(vehicle)["maxVelocity"] + 0.5) / 10) * 10 + 30
    local currentSpeed = getVehicleSpeed(vehicle)

    local currentAngle = 270 * (currentSpeed / maxSpeed)
    if currentAngle > 270 then currentAngle = 270 end

    -- Draw background and speed bar
    dxDrawCircle(screenW - hudW / 2 - padding, screenH - hudW / 2 - padding, hudW / 2, 0, 360, accent2, accent2, 64)
    dxDrawCircle(screenW - hudW / 2 - padding, screenH - hudW / 2 - padding, hudW / 2, 135, 405, accent1, accent1, 64)
    dxDrawCircle(screenW - hudW / 2 - padding, screenH - hudW / 2 - padding, hudW / 2, 135, 135 + currentAngle, accent4, accent4, 64)
    dxDrawCircle(screenW - hudW / 2 - padding, screenH - hudW / 2 - padding, hudW / 2 - speedBarWidth, 0, 360, accent2, accent2, 64)

    -- Draw speed lines
    local lineCount = maxSpeed / speedPerLine
    for i = 0, lineCount do
        local angle = 135 + 270 * (i / lineCount)
        local color = currentSpeed > i * speedPerLine and accent4 or accent1
        
        local x1 = screenW - hudW / 2 - padding + math.cos(math.rad(angle)) * (hudW / 2 - speedBarWidth * 2)
        local y1 = screenH - hudW / 2 - padding + math.sin(math.rad(angle)) * (hudW / 2 - speedBarWidth * 2)
        local x2 = screenW - hudW / 2 - padding + math.cos(math.rad(angle)) * (hudW / 2 - speedBarWidth)
        local y2 = screenH - hudW / 2 - padding + math.sin(math.rad(angle)) * (hudW / 2 - speedBarWidth)
        
        -- dxDrawLine(x1, y1, x2, y2, color, 2)

        local x = screenW - hudW / 2 - padding + math.cos(math.rad(angle)) * (hudW / 2 - speedBarWidth * 2.5)
        local y = screenH - hudW / 2 - padding + math.sin(math.rad(angle)) * (hudW / 2 - speedBarWidth * 2.5)

        dxDrawText(i * speedPerLine, x, y, x, y, color, 1, "clear-normal", "center", "center")

    end
    dxDrawText(math.floor(currentSpeed),
               screenW - hudW / 2 - padding, 
               screenH - hudW / 2 - padding, 
               screenW - hudW / 2 - padding, 
               screenH - hudW / 2 - padding, 
               accent5, 5, "default-bold", "center", "center")

    local gearText = isVehicleReversing(vehicle) and "R" or getVehicleCurrentGear(vehicle) == 0 and "N" or "D" .. tostring(getVehicleCurrentGear(vehicle))
    local gearColor = gearText == "R" and tocolor(255, 0, 0, 255) or gearText == "N" and accent3 or accent4

    dxDrawText(gearText,
               screenW - hudW / 2 - padding, 
               screenH - hudW / 2 - padding - 50, 
               screenW - hudW / 2 - padding, 
               screenH - hudW / 2 - padding - 50, 
               gearColor, 2, "default-bold", "center", "center")
end

addEventHandler("onClientRender", root, drawHUD)
