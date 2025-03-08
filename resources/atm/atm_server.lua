local atmPositions = {
    {x = 8, y = 8, z = 2.7},
}

function createATMs()
    for _, pos in ipairs(atmPositions) do
        local atm = createObject(2942, pos.x, pos.y, pos.z) 
        setElementData(atm, "is_broken", false) 

        local marker = createMarker(pos.x, pos.y + 1, pos.z - 1, "cylinder", 1.5, 255, 255, 0, 150)
        setElementData(marker, "atm", atm)  
    end
end
addEventHandler("onResourceStart", resourceRoot, createATMs)

function onPlayerEnterATMMarker(hitPlayer, matchingDimension)
    if getElementType(hitPlayer) == "player" then
        local atm = getElementData(source, "atm") 
        if atm then
            if getElementData(atm, "is_broken") then
                outputChatBox("Ten bankomat jest zepsuty!", hitPlayer, 255, 0, 0)
            else
                triggerClientEvent(hitPlayer, "openATMInterface", hitPlayer) 
            end
        end
    end
end
addEventHandler("onMarkerHit", root, onPlayerEnterATMMarker)

function onPlayerLeaveATMMarker(leavePlayer, matchingDimension)
    if getElementType(leavePlayer) == "player" then
        triggerClientEvent(leavePlayer, "closeATMInterface", leavePlayer) 
    end
end
addEventHandler("onMarkerLeave", root, onPlayerLeaveATMMarker)

function transferMoney(sourcePlayer, targetNickname, amount)

    local playersTable = exports.players:getPlayersTable()
    local serial = getPlayerSerial(sourcePlayer)
    local sourcePlayer = exports.players:getPlayerBySerial(serial)
    local targetPlayerData = nil

    if tonumber(sourcePlayer.money_bank) < tonumber(amount) then
        --todo
        return
    end

    for _, playerData in pairs(playersTable) do
        if playerData.nickname == targetNickname then
            targetPlayerData = playerData
            break
        end
    end

    if targetPlayerData then
        exports.players:updatePlayerData(targetPlayerData.player, {money_bank = sourcePlayer.money_bank + amount})
    else
        local db = exports.database:get_db()
        dbExec(db, "UPDATE Users SET money_bank = money_bank + ? WHERE nickname = ?", amount, targetNickname)
    end

    exports.players:updatePlayerData(sourcePlayer.player, {money_bank = sourcePlayer.money_bank - amount})
end
addEvent("transferMoney", true)
addEventHandler("transferMoney", root, transferMoney)

function withdrawMoney(sourcePlayer, amount)
    local serial = getPlayerSerial(sourcePlayer)
    local playerData = exports.players:getPlayerBySerial(serial)

    if not playerData then
        return
    end

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        outputChatBox("Nieprawidłowa kwota!", sourcePlayer, 255, 0, 0) -- change to alert
        return
    end

    if playerData.money_bank < amount then
        outputChatBox("Nie masz wystarczająco środków na koncie!", sourcePlayer, 255, 0, 0) -- change to alert
        return
    end

    exports.players:updatePlayerData(sourcePlayer, {money_bank = playerData.money_bank - amount})
    exports.players:updatePlayerData(sourcePlayer, {money_pocket = playerData.money_pocket + amount})
    setPlayerMoney(sourcePlayer, playerData.money_pocket)

end
addEvent("withdrawMoney", true)
addEventHandler("withdrawMoney", root, withdrawMoney)

function depositMoney(sourcePlayer, amount)
    local serial = getPlayerSerial(sourcePlayer)
    local playerData = exports.players:getPlayerBySerial(serial)

    if not playerData then
        return
    end

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        outputChatBox("Nieprawidłowa kwota!", sourcePlayer, 255, 0, 0) -- change to alert
        return
    end

    if playerData.money_pocket < amount then
        outputChatBox("Nie masz wystarczająco środków na koncie!", sourcePlayer, 255, 0, 0) -- change to alert
        return
    end

    exports.players:updatePlayerData(sourcePlayer, {money_bank = playerData.money_bank + amount})
    exports.players:updatePlayerData(sourcePlayer, {money_pocket = playerData.money_pocket - amount})
    setPlayerMoney(sourcePlayer, playerData.money_pocket)

end
addEvent("depositMoney", true)
addEventHandler("depositMoney", root, depositMoney)