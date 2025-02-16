addEvent("requestPlayerData", true)
addEventHandler("requestPlayerData", root, function()
    local playersData = {}

    for _, player in ipairs(getElementsByType("player")) do
        local serial = getPlayerSerial(player)
        local data = exports["players"]:getPlayerBySerial(serial)

        if data then
            table.insert(playersData, {
                id = data.id,
                nickname = data.nickname,
            })
        end
    end

    triggerClientEvent(client, "updateClientPlayerData", client, playersData)
end)
