local atmPositions = {
    {x = 223.22, y = -187, z = 1.23, type = "bankomat", rx = 0, ry = 0, rz = 90}, 
}

local dbConnection = exports.database:get_db()

function updatePlayerMoneyInDatabase(serial, money_pocket, money_bank, callback)
    local query = "UPDATE Users SET money_pocket = ?, money_bank = ? WHERE serial = ?"
    local db = exports.database:get_db()

    dbExec(db, query, money_pocket, money_bank, serial, function(execResult)
        if callback then
            callback(execResult)
        end
    end)
end

function getATMPositions()
    return atmPositions
end

function createATMs()
    for _, pos in ipairs(atmPositions) do
        local atm = createObject(2942, pos.x, pos.y, pos.z) 

        if pos.rx then
            setObjectRotation(atm, pos.rx, pos.ry or 0, pos.rz or 0)
        end

        setElementData(atm, "is_broken", false) 
        setElementData(atm, "type", pos.type)  

        local offsetX, offsetY = 0, 0
        local rz = pos.rz or 0 

        if rz == 0 then
            offsetY = -1.1
        elseif rz == 90 then
            offsetX = 1.1
        elseif rz == 180 then
            offsetY = 1.1
        elseif rz == 270 then
            offsetX = -1.1
        end

        local marker = createMarker(pos.x + offsetX, pos.y + offsetY, pos.z - 1, "cylinder", 1.5, 255, 255, 0, 150)
        setElementData(marker, "atm", atm)  
        setElementData(marker, "type", pos.type)  
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
        exports.players:updatePlayerData(targetPlayerData.player, {money_bank = targetPlayerData.money_bank + amount})
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
    local newMoneyBank = playerData.money_bank - amount
    local newMoneyPocket = playerData.money_pocket + amount

    exports.players:updatePlayerData(sourcePlayer, {money_bank = newMoneyBank})
    exports.players:updatePlayerData(sourcePlayer, {money_pocket = newMoneyPocket})
    updatePlayerMoneyInDatabase(serial, newMoneyPocket, newMoneyBank)
    setPlayerMoney(sourcePlayer, newMoneyPocket)
end
addEvent("withdrawMoney", true)
addEventHandler("withdrawMoney", root, withdrawMoney)

function depositMoney(sourcePlayer, amount)
    local serial = getPlayerSerial(sourcePlayer)
    local playerData = exports.players:getPlayerBySerial(serial)

    if not playerData then
        outputDebugString("Błąd: Nie znaleziono danych gracza dla serialu: " .. serial)
        return
    end

    amount = tonumber(amount)
    if not amount or amount <= 0 then
        outputChatBox("Nieprawidłowa kwota!", sourcePlayer, 255, 0, 0)
        outputDebugString("Błąd: Nieprawidłowa kwota: " .. tostring(amount))
        return
    end

    if playerData.money_pocket < amount then
        outputChatBox("Nie masz wystarczająco środków w portfelu!", sourcePlayer, 255, 0, 0)
        outputDebugString("Błąd: Gracz nie ma wystarczająco środków w portfelu. Portfel: " .. playerData.money_pocket .. ", Kwota: " .. amount)
        return
    end

    local newMoneyBank = playerData.money_bank + amount
    local newMoneyPocket = playerData.money_pocket - amount

    exports.players:updatePlayerData(sourcePlayer, {money_bank = newMoneyBank})
    exports.players:updatePlayerData(sourcePlayer, {money_pocket = newMoneyPocket})
    updatePlayerMoneyInDatabase(serial, newMoneyPocket, newMoneyBank)
    setPlayerMoney(sourcePlayer, newMoneyPocket)
end
addEvent("depositMoney", true)
addEventHandler("depositMoney", root, depositMoney)