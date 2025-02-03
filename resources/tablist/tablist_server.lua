-- Tablica przechowująca graczy online
local onlinePlayers = {}

-- Funkcja wysyłająca listę graczy do wszystkich graczy online
function updatePlayerListForAll()
    local playerList = {}
    for user_id, data in pairs(onlinePlayers) do
        table.insert(playerList, {user_id = user_id, nickname = data.nickname})
    end

    -- Wysyłanie aktualizacji do wszystkich graczy
    for _, player in ipairs(getElementsByType("player")) do
        triggerClientEvent(player, "receivePlayerList", player, playerList)
    end
end

-- Dodawanie gracza do listy online przy dołączeniu
addEventHandler("onPlayerJoin", root, function()
    local playerID = getElementData(source, "user_id") or getPlayerSerial(source)  -- Fallback na serial jeśli brak user_id
    local nickname = getPlayerName(source)

    -- Dodaj gracza do listy
    onlinePlayers[playerID] = {nickname = nickname}

    -- Aktualizuj listę dla wszystkich
    updatePlayerListForAll()
end)

-- Usuwanie gracza z listy online przy wyjściu
addEventHandler("onPlayerQuit", root, function()
    local playerID = getElementData(source, "user_id") or getPlayerSerial(source)

    -- Usuń gracza z listy
    onlinePlayers[playerID] = nil

    -- Aktualizuj listę dla wszystkich
    updatePlayerListForAll()
end)

-- Komenda ręcznego odświeżenia listy
addCommandHandler("refreshTab", function(player)
    updatePlayerListForAll()
end)

-- Wysyłanie listy po starcie zasobu (na wypadek restartu)
addEventHandler("onResourceStart", resourceRoot, function()
    updatePlayerListForAll()
end)
