-- TEST POST PUSHA --
local spawnedVehicles = {}

function upgradeVehicleToMax(vehicle)
    if not vehicle or not isElement(vehicle) then return end

    for i = 0, 16 do
        addVehicleUpgrade(vehicle, getVehicleCompatibleUpgrades(vehicle, i)[1] or 0)
    end
    setVehiclePaintjob(vehicle, math.random(0, 3)) 
    setVehicleColor(vehicle, math.random(0, 255), math.random(0, 255), math.random(0, 255)) 
    setElementHealth(vehicle, 1000) 
    setVehicleEngineState(vehicle, true) 
    setVehicleDamageProof(vehicle, true) 
    setVehiclePlateText(vehicle, "RESPIONY") 
end

-- Respienie pojazdu
function spawnAdminVehicle(player, _, vehicleID)
    if not vehicleID or not tonumber(vehicleID) then
        outputChatBox("❌ Użycie: /auto <ID pojazdu> (400-611)", player, 255, 0, 0)
        return
    end

    vehicleID = tonumber(vehicleID)
    if vehicleID < 400 or vehicleID > 611 then
        outputChatBox("❌ Błąd: ID pojazdu musi być między 400 a 611!", player, 255, 0, 0)
        return
    end

    local x, y, z = getElementPosition(player)
    local rotX, rotY, rotZ = getElementRotation(player)

    -- Usunięcie poprzedniego pojazdu, jeśli istnieje
    if spawnedVehicles[player] and isElement(spawnedVehicles[player]) then
        destroyElement(spawnedVehicles[player])
    end

    local vehicle = createVehicle(vehicleID, x + 2, y, z, rotX, rotY, rotZ)
    if vehicle then
        warpPedIntoVehicle(player, vehicle)
        spawnedVehicles[player] = vehicle
        upgradeVehicleToMax(vehicle)

        addEventHandler("onVehicleExit", vehicle, function(_, seat)
            if seat == 0 then 
                destroyElement(vehicle)
                spawnedVehicles[player] = nil
            end
        end)

        outputChatBox("✔ Pojazd ID " .. vehicleID .. " został zrespiony!", player, 0, 255, 0)
    else
        outputChatBox("❌ Błąd: Nie udało się stworzyć pojazdu!", player, 255, 0, 0)
    end
end
addCommandHandler("auto", spawnAdminVehicle)

-- Funkcja do zmiany pogody
function changeWeatherCommand(player, _, weather)
    local weatherIDs = {
        ["sunny"] = 0,
        ["cloudy"] = 3,
        ["foggy"] = 9,
        ["storm"] = 8,
        ["rain"] = 16,
        ["sandstorm"] = 19
    }
    if not weather then
        outputChatBox("❌ Użycie: /weather <nazwa lub ID>", player, 255, 0, 0)
        return
    end

    local weatherID = tonumber(weather) or weatherIDs[string.lower(weather)]
    if not weatherID or weatherID < 0 or weatherID > 45 then
        outputChatBox("❌ Błąd: Niepoprawne ID pogody! (0-45)", player, 255, 0, 0)
        return
    end

    setWeather(weatherID)
    outputChatBox("✔ Pogoda została zmieniona na ID: " .. weatherID, player, 0, 255, 0)
end
addCommandHandler("weather", changeWeatherCommand)

-- Naprawa pojazdu
function fixVehicleCommand(player)
    local vehicle = getPedOccupiedVehicle(player)
    if vehicle then
        fixVehicle(vehicle)
        outputChatBox("✔ Twój pojazd został naprawiony!", player, 0, 255, 0)
    else
        outputChatBox("❌ Musisz być w pojeździe, aby go naprawić!", player, 255, 0, 0)
    end
end
addCommandHandler("fix", fixVehicleCommand)

-- Jetpack
function giveJetpackCommand(player)
    if not doesPedHaveJetPack(player) then
        givePedJetPack(player)
        outputChatBox("✔ Otrzymałeś Jetpack!", player, 0, 255, 0)
    else
        removePedJetPack(player)
        outputChatBox("❌ Jetpack został usunięty!", player, 255, 0, 0)
    end
end
addCommandHandler("jetpack", giveJetpackCommand)

-- Obrót pojazdu na koła
function flipVehicleCommand(player)
    local vehicle = getPedOccupiedVehicle(player)
    if vehicle then
        local x, y, z = getElementPosition(vehicle)
        local _, _, rz = getElementRotation(vehicle)

        setElementRotation(vehicle, 0, 0, rz) 
        setElementPosition(vehicle, x, y, z + 1) 
        outputChatBox("✔ Pojazd został obrócony na koła!", player, 0, 255, 0)
    else
        outputChatBox("❌ Musisz być w pojeździe, aby go obrócić!", player, 255, 0, 0)
    end
end
addCommandHandler("flip", flipVehicleCommand)