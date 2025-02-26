addEvent("requestPlayerData", true)
addEventHandler("requestPlayerData", root, function()
    local playersData = {}
    for _, player in ipairs(getElementsByType("player")) do
        local serial = getPlayerSerial(player)
        player_data = exports.players:getPlayerBySerial(serial)

        table.insert(playersData, {
            id = player_data.id, -- Pobierz ID gracza
            nickname = player_data.nickname, -- Pobierz nick gracza
            skin_id = player_data.skin_id -- Pobierz ID skina gracza
        })
    end
    triggerClientEvent(client, "updateClientPlayerData", client, playersData)
end)