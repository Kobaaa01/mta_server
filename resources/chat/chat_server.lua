local function getPlayerData(player)
    if not isElement(player) then
        outputDebugString("❌ Błąd: player nie jest elementem w getPlayerData!", 2)
        return nil
    end

    local serial = getPlayerSerial(player)
    local playersTable = exports.login:getPlayersTable()
    
    return playersTable[serial] or nil
end

local ranks = {
    ["Wlasciciel"] = "[W]",
    ["Admin"] = "[A]",
    ["SuperModerator"] = "[SM]",
    ["Moderator"] = "[M]",
    ["JuniorModerator"] = "[JM]"
}

function handleChatMessage(message, messageType)
    local player = source
    if not isElement(player) then return end

    cancelEvent() -- Blokowanie domyślnego czatu MTA

    local userData = getPlayerData(player)
    if not userData then
        outputDebugString("❌ Błąd: Nie znaleziono danych użytkownika dla: " .. getPlayerSerial(player), 2)
        return
    end

    -- Ustawiamy dane na graczu, aby klient mógł pobrać rangę
    setElementData(player, "rank", userData.rank)

    -- Pobranie prefixu rangi
    local prefix = ranks[userData.rank] or ""

    -- Wysłanie wiadomości do wszystkich graczy
    triggerClientEvent("onChatMessage", root, player, prefix, userData.nickname, message)
end
addEventHandler("onPlayerChat", root, handleChatMessage)
