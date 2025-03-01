addEventHandler("onClientVehicleDamage", root, function()
    local hp = getElementHealth(source)
    if hp < 270 then
        setElementHealth(source, 270)
        setVehicleDamageProof(source, true)
    end
end)

local currentSpeedLimit = nil
function onClientSpeedLimitChange(vehicle)
    if vehicle == getPedOccupiedVehicle(localPlayer) then
        currentSpeedLimit = getElementData(vehicle, "speedLimit")
    end
end

function checkVehicleSpeed()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if vehicle and currentSpeedLimit then
        local speedX, speedY, speedZ = getElementVelocity(vehicle)
        local actualSpeed = (speedX^2 + speedY^2 + speedZ^2)^(0.5) * 180 -- to km/h

        if actualSpeed > currentSpeedLimit then
            local reductionFactor = currentSpeedLimit / actualSpeed
            setElementVelocity(vehicle, speedX * reductionFactor, speedY * reductionFactor, speedZ * reductionFactor)
        end
    end
end

function onRightClick()
    local vehicle = getPedOccupiedVehicle(localPlayer)
    if vehicle then
        triggerServerEvent("onPlayerRequestSpeedLimitChange", localPlayer)
    end
end

function onPlayerExitVehicle()
    currentSpeedLimit = nil
end

addEventHandler("onClientElementDataChange", root, function(dataName)
    if dataName == "speedLimit" and source == getPedOccupiedVehicle(localPlayer) then
        onClientSpeedLimitChange(source)
    end
end)

bindKey("mouse2", "down", onRightClick)
addEventHandler("onClientRender", root, checkVehicleSpeed)
addEventHandler("onClientPlayerVehicleExit", localPlayer, onPlayerExitVehicle)