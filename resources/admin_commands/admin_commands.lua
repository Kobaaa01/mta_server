local spawnedVehicles = {}

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
        outputChatBox("✔ Pojazd ID " .. vehicleID .. " został zrespiony!", player, 0, 255, 0)

        -- Automatyczne usunięcie pojazdu po opuszczeniu
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
        outputChatBox("❌ Użycie: /pogoda <nazwa lub ID>", player, 255, 0, 0)
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
addCommandHandler("pogoda", changeWeatherCommand)

-- Funkcja do zmiany pory dnia
function changeTimeCommand(player, _, hour, minute)
    hour = tonumber(hour)
    minute = tonumber(minute) or 0

    if not hour or hour < 0 or hour > 23 then
        outputChatBox("❌ Użycie: /pora <godzina> <minuta>", player, 255, 0, 0)
        return
    end

    setTime(hour, minute)
    outputChatBox("✔ Ustawiono porę na: " .. hour .. ":" .. string.format("%02d", minute), player, 0, 255, 0)
end
addCommandHandler("pora", changeTimeCommand)
