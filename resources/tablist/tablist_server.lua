addEvent("requestPlayerData", true)
addEventHandler("requestPlayerData", root, function()
    local playersData = {}
    for _, player in ipairs(getElementsByType("player")) do
        table.insert(playersData, {
            id = getElementData(player, "playerid") or 0, -- Pobierz ID gracza
            nickname = getPlayerName(player), -- Pobierz nick gracza
            skin_id = getElementModel(player) -- Pobierz ID skina gracza
        })
    end
    triggerClientEvent(client, "updateClientPlayerData", client, playersData)
end)