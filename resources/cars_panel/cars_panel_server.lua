function sendAlertToPlayer(player, alertData)
    if not isElement(player) then
        return
    end
    triggerClientEvent(player, "showAlert", player, alertData)
end

function handleCarAction(action)
    local vehicle = getPedOccupiedVehicle(client)
    if not vehicle then
        return
    end

    if action == "toggleEngine" and not isTimer(engineCooldown) then
        local state = not getVehicleEngineState(vehicle)
        if state == true then
            local health = getElementHealth(vehicle)
            if health < 300 then
                local chance = math.random(1, 10) -- 10% chance
                if chance > 1 then
                    exports.alerts:sendAlert(client, {
                        type = 4,
                        title = "Nie udało się odpalić pojazdu!",
                        text = "Silnik jest zepsuty, spróbuj ponownie i niezwłocznie udaj się do mechanika!",
                        time = 2000
                    })
                    engineCooldown = setTimer(function()
                        engineCooldown = nil
                    end, 2000, 1)
                else
                    setVehicleEngineState(vehicle, state)
                    exports.alerts:sendAlert(client, {
                        type = 2,
                        title = "Sukces!",
                        text = "Udało się odpalić pojazd! Udaj się zatem do mechanika!",
                        time = 2000
                    })
                end
            else
                setVehicleEngineState(vehicle, state)
            end
        end
        if state == false then
            setVehicleEngineState(vehicle, state)
        end
    elseif action == "toggleHandbrake" then
        local vx, vy, vz = getElementVelocity(vehicle)
        local speed = math.sqrt(vx ^ 2 + vy ^ 2 + vz ^ 2) * 180

        if speed > 0.5 then
        else
            setElementFrozen(vehicle, not isElementFrozen(vehicle))
        end

    elseif action == "toggleLights" then
        local current_state = getVehicleOverrideLights(vehicle)
        local new_state = (current_state == 2) and 1 or 2
        setVehicleOverrideLights(vehicle, new_state)

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
