local spawnedVehicles = {}

function spawnAdminVehicle(player, _, vehicleID)
    if not vehicleID then
        outputChatBox("Użycie: /auto <ID pojazdu>", player, 255, 0, 0)
        return
    end

    vehicleID = tonumber(vehicleID)
    if not vehicleID or vehicleID < 400 or vehicleID > 611 then
        outputChatBox("Błąd: Niepoprawne ID pojazdu (musi być między 400 a 611)", player, 255, 0, 0)
        return
    end

    local x, y, z = getElementPosition(player)
    local rotX, rotY, rotZ = getElementRotation(player)

    if spawnedVehicles[player] and isElement(spawnedVehicles[player]) then
        destroyElement(spawnedVehicles[player]) -- Usunięcie poprzedniego pojazdu
    end

    local vehicle = createVehicle(vehicleID, x + 2, y, z, rotX, rotY, rotZ)
    if vehicle then
        warpPedIntoVehicle(player, vehicle)
        spawnedVehicles[player] = vehicle
        outputChatBox("✔ Pojazd ID " .. vehicleID .. " został zrespiony.", player, 0, 255, 0)

        addEventHandler("onVehicleExit", vehicle, function()
            if isElement(vehicle) then
                destroyElement(vehicle)
                spawnedVehicles[player] = nil
                outputChatBox("❌ Twój admin pojazd został usunięty!", player, 255, 0, 0)
            end
        end)
    else
        outputChatBox("❌ Błąd: Nie udało się stworzyć pojazdu!", player, 255, 0, 0)
    end
end
addCommandHandler("auto", spawnAdminVehicle)

function fixAdminVehicle(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Błąd: Nie jesteś w pojeździe!", player, 255, 0, 0)
        return
    end

    fixVehicle(vehicle)
    outputChatBox("✔ Twój pojazd został naprawiony!", player, 0, 255, 0)
end
addCommandHandler("fix", fixAdminVehicle)
