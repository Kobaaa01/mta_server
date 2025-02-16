function handleCarAction(action)
    local vehicle = getPedOccupiedVehicle(client)
    if not vehicle then return end

    if action == "toggleEngine" then
        local state = not getVehicleEngineState(vehicle)
        setVehicleEngineState(vehicle, state)

    elseif action == "toggleHandbrake" then
        local vx, vy, vz = getElementVelocity(vehicle)
        local speed = math.sqrt(vx^2 + vy^2 + vz^2) * 180

        if speed > 0.5 then
        else
            setElementFrozen(vehicle, not isElementFrozen(vehicle))
        end

    elseif action == "toggleLights" then
        local currentState = getVehicleOverrideLights(vehicle)
        local newState = (currentState == 2) and 1 or 2  
        setVehicleOverrideLights(vehicle, newState)

    elseif action == "toggleTrunk" then
        local state = getVehicleDoorOpenRatio(vehicle, 1) == 0 and 1 or 0
        setVehicleDoorOpenRatio(vehicle, 1, state, 500)

    elseif action == "toggleHood" then
        local state = getVehicleDoorOpenRatio(vehicle, 0) == 0 and 1 or 0
        setVehicleDoorOpenRatio(vehicle, 0, state, 500)
    end

    -- Powiadom klienta, aby odświeżył stan ikon
    triggerClientEvent(client, "updateCarPanelIcons", resourceRoot)
end
addEvent("handleCarAction", true)
addEventHandler("handleCarAction", root, handleCarAction)
