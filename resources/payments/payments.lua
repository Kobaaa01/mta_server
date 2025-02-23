local Players = exports.players:getPlayersTable()
local dbConnection = exports.database:get_db()

function updatePlayerMoneyInDatabase(player, money_pocket, callback)
    local query = "UPDATE Users SET money_pocket = ? WHERE user_id = ?"
    dbExec(dbConnection, query, money_pocket, player.user_id, function(execResult)
        if callback then
            callback(execResult)
        end
    end)
end

local function findPlayer(sender)
    for _, playerData in pairs(Players) do
        if playerData.nickname == sender or tostring(playerData.id) == sender then
            return playerData
        end
    end
    return nil
end

addCommandHandler("przelej", function(player, command, receiver, amount)
    -- Proper number of args
    if not receiver or not amount then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Użycie: /przelej <nick / id> <kwota>",
            time = 5000
        })
        return
    end

    -- Proper number
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Podaj poprawną kwotę.",
            time = 5000
        })
        return
    end

    local sourcePlayer = findPlayer(getPlayerName(player))

    -- Does player have enough money
    if sourcePlayer.money_pocket < amount then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Nie masz wystarczająco pieniędzy w kieszeni.",
            time = 5000
        })
        return
    end

    -- Find receiver
    local targetPlayer = findPlayer(receiver)
    if not targetPlayer then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Nie znaleziono gracza docelowego.",
            time = 5000
        })
        return
    end

    -- Payment itself
    sourcePlayer.money_pocket = sourcePlayer.money_pocket - amount
    targetPlayer.money_pocket = targetPlayer.money_pocket + amount
    setPlayerMoney(sourcePlayer.player, sourcePlayer.money_pocket)
    setPlayerMoney(targetPlayer.player, targetPlayer.money_pocket)

    exports.alerts:sendAlert(sourcePlayer.player, {
        type = 1,
        title = "Przelew",
        text = "Przelano " .. amount .. "$ do gracza " .. targetPlayer.nickname .. ".",
        time = 5000
    })

    exports.alerts:sendAlert(targetPlayer.player, {
        type = 4,
        title = "Przelew",
        text = "Otrzymano " .. amount .. "$ od gracza " .. sourcePlayer.nickname .. ".",
        time = 5000
    })

    -- Database update
    updatePlayerMoneyInDatabase(sourcePlayer, sourcePlayer.money_pocket, function(execResult)
        if not execResult then
            outputDebugString("Błąd podczas aktualizacji stanu konta gracza źródłowego w bazie danych.")
        end
    end)
    updatePlayerMoneyInDatabase(targetPlayer, targetPlayer.money_pocket, function(execResult)
        if not execResult then
            outputDebugString("Błąd podczas aktualizacji stanu konta gracza docelowego w bazie danych.")
        end
    end)
end)

addCommandHandler("take", function(player, command, targetIdentifier, amount)
    -- Proper number of args
    if not targetIdentifier or not amount then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Użycie: /take <nick / id> <kwota>",
            time = 5000
        })
        return
    end

    -- Proper number
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Podaj poprawną kwotę.",
            time = 5000
        })
        return
    end

    local sourcePlayer = findPlayer(getPlayerName(player))

    -- Find target player
    local targetPlayer = findPlayer(targetIdentifier)
    if not targetPlayer then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Nie znaleziono gracza docelowego.",
            time = 5000
        })
        return
    end

    -- Does player have enough money
    if targetPlayer.money_pocket < amount then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Gracz " .. targetPlayer.nickname .. " nie ma wystarczająco pieniędzy.",
            time = 5000
        })
        return
    end

    -- Taking money itself
    targetPlayer.money_pocket = targetPlayer.money_pocket - amount
    setPlayerMoney(targetPlayer.player, targetPlayer.money_pocket)

    exports.alerts:sendAlert(sourcePlayer.player, {
        type = 1,
        title = "Zabrano pieniądze",
        text = "Zabrano " .. amount .. "$ graczowi " .. targetPlayer.nickname .. ".",
        time = 5000
    })

    exports.alerts:sendAlert(targetPlayer.player, {
        type = 4,
        title = "Zabrano pieniądze",
        text = "Zabrano Ci " .. amount .. "$.",
        time = 5000
    })

    -- Database update
    updatePlayerMoneyInDatabase(targetPlayer, targetPlayer.money_pocket, function(execResult)
        if not execResult then
            outputDebugString("Błąd podczas aktualizacji stanu konta gracza docelowego w bazie danych.")
        end
    end)
end)

addCommandHandler("give", function(player, command, targetIdentifier, amount)

    -- Proper number of args
    if not targetIdentifier or not amount then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Użycie: /give <nick / id> <kwota>",
            time = 5000
        })
        return
    end

    -- Proper number
    amount = tonumber(amount)
    if not amount or amount <= 0 then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Podaj poprawną kwotę.",
            time = 5000
        })
        return
    end

    -- Find target player
    local targetPlayer = findPlayer(targetIdentifier)
    if not targetPlayer then
        exports.alerts:sendAlert(player, {
            type = 4,
            title = "Błąd",
            text = "Nie znaleziono gracza docelowego.",
            time = 5000
        })
        return
    end

    -- Give money
    targetPlayer.money_pocket = targetPlayer.money_pocket + amount
    setPlayerMoney(targetPlayer.player, targetPlayer.money_pocket)
    exports.alerts:sendAlert(player, {
        type = 1,
        title = "Dodano pieniądze",
        text = "Dodano " .. amount .. "$ graczowi " .. targetPlayer.nickname .. ".",
        time = 5000
    })

    exports.alerts:sendAlert(targetPlayer.player, {
        type = 2,
        title = "Otrzymano pieniądze",
        text = "Otrzymano " .. amount .. "$ od administratora.",
        time = 5000
    })

    -- Update database
    updatePlayerMoneyInDatabase(targetPlayer, targetPlayer.money_pocket, function(execResult)
        if not execResult then
            outputDebugString("Błąd podczas aktualizacji stanu konta gracza docelowego w bazie danych.")
        end
    end)
end)
