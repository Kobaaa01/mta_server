function handleChatMessage(message, messageType)
    local player = source
    if not isElement(player) then return end
    cancelEvent()

    local userData = exports.players:getPlayerBySerial(getPlayerSerial(player))
    if not userData then
        outputDebugString("❌ Błąd: Nie znaleziono danych użytkownika dla: " .. getPlayerName(player), 2)
        return
    end

    local isOwner = (userData.rank == "Wlasciciel")

    triggerClientEvent("onChatMessage", root, player, userData.id, userData.nickname, userData.rank, message, isOwner)
end
addEventHandler("onPlayerChat", root, handleChatMessage)