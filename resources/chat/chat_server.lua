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
    cancelEvent()

    -- Pobieranie danych przez eksportowaną funkcję z loginu
    local userData = exports.players:getPlayerBySerial(getPlayerSerial(player))
    if not userData then
        outputDebugString("❌ Błąd: Nie znaleziono danych użytkownika dla: " .. getPlayerName(player), 2)
        return
    end

    setElementData(player, "rank", userData.rank)
    local prefix = ranks[userData.rank] or ""
    
    triggerClientEvent("onChatMessage", root, player, prefix, userData.nickname, message)
end
addEventHandler("onPlayerChat", root, handleChatMessage)