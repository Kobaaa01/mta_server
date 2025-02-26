Players = {}

function getPlayersTable()
    return Players
end

function addPlayer(player)
    local serial = getPlayerSerial(player)
    local playerID = findFirstFreeID() -- Znajdź pierwsze wolne ID

    Players[playerID] = {
        id = playerID,
        serial = serial,
        player = player,
        nickname = getPlayerName(player),
        money_pocket = 0,
        money_bank = 0,
        skin_id = 0,
        rank = "Gracz",
        ban_status = "NOT_BANNED",
        mute_status = "NOT_MUTED",
        driving_license = false,
        fraction_id = 0,
        group_id = 0
    }

    Players[serial] = Players[playerID]
    outputDebugString("Dodano gracza: " .. getPlayerName(player) .. " z ID: " .. playerID)
end

function findFirstFreeID()
    for i = 1, 1000 do -- Zakładamy maksymalnie 1000 graczy
        if not Players[i] then
            return i
        end
    end
    return #Players + 1 -- Jeśli nie ma wolnych ID, dodaj na końcu
end

function removePlayer(player)
    local serial = getPlayerSerial(player)
    local playerID = nil

    for id, data in pairs(Players) do
        if type(id) == "number" and data.serial == serial then
            playerID = id
            break
        end
    end

    if playerID then
        Players[serial] = nil
        Players[playerID] = nil
        outputDebugString("Usunięto gracza o serialu: " .. serial)
    else
        outputDebugString("Błąd: Nie można usunąć gracza z tabeli Players.")
    end
end

function getPlayerByID(playerID)
    return Players[playerID]
end

function getPlayerBySerial(serial)
    return Players[serial]
end

function updatePlayerData(player, data)
    local serial = getPlayerSerial(player)
    local playerData = Players[serial]

    if playerData then
        for key, value in pairs(data) do
            playerData[key] = value
        end
    end
end

addEventHandler("onPlayerQuit", root, function()
    removePlayer(source)
end)

    function printPlayersTable()
        for playerID, playerData in pairs(Players) do
            if type(playerID) == "number" then
                outputDebugString("Gracz ID: " .. playerID)
                for key, value in pairs(playerData) do
                    outputDebugString("  " .. key .. ": " .. tostring(value))
                end
                outputDebugString("-----------------------------")
            end
        end
    end
    
    addCommandHandler("printplayers", function(player)
        if getElementType(player) == "player" then 
            printPlayersTable()
            outputChatBox("Zawartość tabeli Players została wyświetlona w konsoli debugowania.", player)
        else
            printPlayersTable() 
        end
    end)