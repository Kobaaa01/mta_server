-- Tabela przechowująca dane o graczach
Players = {}

-- Funkcja zwracająca tabelę Players
function getPlayersTable()
    return Players
end

-- Funkcja dodająca gracza do tabeli Players
function addPlayer(player)
    local serial = getPlayerSerial(player)
    local playerID = #Players + 1

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

    Players[serial] = Players[playerID] -- Dodajemy również referencję przez serial
end

-- Funkcja usuwająca gracza z tabeli Players
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
    end
end

-- Funkcja zwracająca dane gracza po ID
function getPlayerByID(playerID)
    return Players[playerID]
end

-- Funkcja zwracająca dane gracza po serialu
function getPlayerBySerial(serial)
    return Players[serial]
end

-- Funkcja aktualizująca dane gracza
function updatePlayerData(player, data)
    local serial = getPlayerSerial(player)
    local playerData = Players[serial]

    if playerData then
        for key, value in pairs(data) do
            playerData[key] = value
        end
    end
end

-- Dodajemy gracza do tabeli Players po zalogowaniu
addEvent("onPlayerLogin", true)
addEventHandler("onPlayerLogin", root, function(player)
    addPlayer(player)
end)

-- Usuwamy gracza z tabeli Players po wyjściu z gry
addEventHandler("onPlayerQuit", root, function()
    removePlayer(source)
end)