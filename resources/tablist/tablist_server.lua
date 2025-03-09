function getPlayerData()
    local playersData = {}
    for _, player in ipairs(getElementsByType("player")) do
        local serial = getPlayerSerial(player)
        local player_data = exports.players:getPlayerBySerial(serial)
        local ping = getPlayerPing(player) 

        table.insert(playersData, {
            id = player_data.id, 
            nickname = player_data.nickname, 
            rank = player_data.rank,
            ping = ping -- Dodaj ping gracza
        })
    end
    return playersData
end

-- Obsługa żądania danych od gracza
addEvent("requestPlayerData", true)
addEventHandler("requestPlayerData", root, function()
    local playersData = getPlayerData()
    triggerClientEvent(client, "updateClientPlayerData", client, playersData)
end)