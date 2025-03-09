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

function spawnAdminVehicle(player, _, vehicleID)
    if not vehicleID or not tonumber(vehicleID) then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Użycie: /auto <ID pojazdu> (400-611)",
            time = 5000
        })
        return
    end

    vehicleID = tonumber(vehicleID)
    if vehicleID < 400 or vehicleID > 611 then
        exports.alerts:sendAlert(player, {
            type = 4, 
            title = "Błąd",
            text = "ID pojazdu musi być między 400 a 611!",
            time = 5000
        })
        return
    end

    local x, y, z = getElementPosition(player)
    local rotX, rotY, rotZ = getElementRotation(player)

    if spawnedVehicles[player] and isElement(spawnedVehicles[player]) then
        destroyElement(spawnedVehicles[player])
    end

    local vehicle = createVehicle(vehicleID, x + 2, y, z, rotX, rotY, rotZ)
    if not vehicle then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Nie udało się stworzyć pojazdu!",
            time = 5000
        })
        return
    end
    warpPedIntoVehicle(player, vehicle)
    spawnedVehicles[player] = vehicle
    upgradeVehicleToMax(vehicle)

    addEventHandler("onVehicleExit", vehicle, function(_, seat)
        if seat == 0 then 
            destroyElement(vehicle)
            spawnedVehicles[player] = nil
        end
    end)

    exports.alerts:sendAlert(player, {
        type = 2,
        title = "Sukces",
        text = "Pojazd ID " .. vehicleID .. " został zrespiony!",
        time = 5000
    })
end
addCommandHandler("auto", spawnAdminVehicle)

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
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Użycie: /weather <nazwa lub ID>",
            time = 5000
        })
        return
    end

    local weatherID = tonumber(weather) or weatherIDs[string.lower(weather)]
    if not weatherID or weatherID < 0 or weatherID > 45 then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Niepoprawne ID pogody! (0-45)",
            time = 5000
        })
        return
    end

    setWeather(weatherID)
    exports.alerts:sendAlert(player, {
        type = 2,
        title = "Sukces",
        text = "Pogoda została zmieniona na ID: " .. weatherID,
        time = 5000
    })
end
addCommandHandler("weather", changeWeatherCommand)

function fixVehicleCommand(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        exports.alerts:sendAlert(player, {
            type = 4, 
            title = "Błąd",
            text = "Musisz być w pojeździe, aby go naprawić!",
            time = 5000
        })
        return
    end

    fixVehicle(vehicle)
    exports.alerts:sendAlert(player, {
        type = 2, 
        title = "Sukces",
        text = "Twój pojazd został naprawiony!",
        time = 5000
    })
end
addCommandHandler("fix", fixVehicleCommand)

function giveJetpackCommand(player)
    if not isPedWearingJetpack(player) then
        setPedWearingJetpack(player, true)
        exports.alerts:sendAlert(player, {
            type = 2, 
            title = "Sukces",
            text = "Otrzymałeś Jetpack!",
            time = 5000
        })
        return
    end

    setPedWearingJetpack(player, false)
    exports.alerts:sendAlert(player, {
        type = 4,
        title = "Informacja",
        text = "Jetpack został usunięty!",
        time = 5000
    })
end
addCommandHandler("jetpack", giveJetpackCommand)

function flipVehicleCommand(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        exports.alerts:sendAlert(player, {
            type = 4, 
            title = "Błąd",
            text = "Musisz być w pojeździe, aby go obrócić!",
            time = 5000
        })
        return
    end

    local x, y, z = getElementPosition(vehicle)
    local _, _, rz = getElementRotation(vehicle)

    setElementRotation(vehicle, 0, 0, rz) 
    setElementPosition(vehicle, x, y, z + 1) 
    exports.alerts:sendAlert(player, {
        type = 2,
        title = "Sukces",
        text = "Pojazd został obrócony na koła!",
        time = 5000
    })
end
addCommandHandler("flip", flipVehicleCommand)

function teleportCommand(player, _, target)
    if not target or not tonumber(target) then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Użycie: /tp <ID gracza>",
            time = 5000
        })
        return
    end

    local target_id = tonumber(target)
    local target_player = exports.players:getPlayerByID(target_id)
    if not target_player then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Nie znaleziono takiego gracza!",
            time = 5000
        })
        return
    end
    
    local target_x, target_y, target_z = getElementPosition(target_player.player)
    setElementPosition(player, target_x + 1.5, target_y, target_z)
    exports.alerts:sendAlert(player, {
        type = 2, 
        title = "Sukces",
        text = "Przeteleportowano!",
        time = 5000
    })
end
addCommandHandler("tp", teleportCommand)

local adminAlertTime = 7000

function announce(player, _, ...)
    local message = table.concat({...}, " ")
    if message == "" then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Użycie: /oglos <treść>",
            time = 5000
        })
        return
    end

    exports.alerts:globalAlert({
        type = 1, 
        title = "Ogłoszenie",
        text = message,
        time = adminAlertTime
    })
end
addCommandHandler("oglos", announce)

function sendAlert(player, _, target, ...)
    local message = table.concat({...}, " ")
    if not target or not tonumber(target) or message == "" then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Użycie: /alert <ID gracza> <treść>",
            time = 5000
        })
        return
    end

    local target_id = tonumber(target)
    local target_player = exports.players:getPlayerByID(target_id)
    if not target_player then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Nie znaleziono takiego gracza!",
            time = 5000
        })
        return
    end

    exports.alerts:sendAlert(target_player.player, {
        type = 1,
        title = "Powiadomienie",
        text = message,
        time = adminAlertTime
    })
end
addCommandHandler("alert", sendAlert)

-- Teleportacja gracza do administratora
function teleportHereCommand(player, _, target)
    if not target or not tonumber(target) then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Użycie: /tph <ID gracza>",
            time = 5000
        })
        return
    end

    local target_id = tonumber(target)
    local target_player = exports.players:getPlayerByID(target_id) -- Pobranie gracza docelowego
    if not target_player then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Nie znaleziono takiego gracza!",
            time = 5000
        })
        return
    end

    local admin_x, admin_y, admin_z = getElementPosition(player)
    local _, _, admin_rot = getElementRotation(player)

    -- Teleportation
    setElementPosition(target_player.player, admin_x + 1.5, admin_y, admin_z)
    setElementRotation(target_player.player, 0, 0, admin_rot)

    exports.alerts:sendAlert(player, {
        type = 2,
        title = "Sukces",
        text = "Gracz " .. getPlayerName(target_player.player) .. " został przeteleportowany do Ciebie!",
        time = 5000
    })

    exports.alerts:sendAlert(target_player.player, {
        type = 1,
        title = "Teleportacja",
        text = "Zostałeś przeteleportowany do administratora " .. getPlayerName(player),
        time = 5000
    })
end
addCommandHandler("tph", teleportHereCommand)

function printPlayerCoords(player)
    local x, y, z = getElementPosition(player)
    local rotX, rotY, rotZ = getElementRotation(player)
    
    outputDebugString("X: " .. x .. ", Y: " .. y .. ", Z: " .. z)
    
    exports.alerts:sendAlert(player, {
        type = 2,
        title = "Koordynaty",
        text = "Twoje koordynaty zostały wyświetlone w konsoli serwera.",
        time = 5000
    })
end
addCommandHandler("cords", printPlayerCoords)

