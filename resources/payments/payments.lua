local db = exports.database:get_db()

function pay(sender, receiver, amount)
    assert(amount > 0)
    assert(sender.money_bank >= amount)

    if not dbExec(db, "BEGIN TRANSACTION") then
        outputChatBox("Zjebalo sie fest cos.")
        return
    end

    local sender_update_result = dbExec(db, "UPDATE Users SET money_bank = money_bank - ? WHERE user_id = ?", amount,
        sender.user_id)
    local receiver_update_result = dbExec(db, "UPDATE Users SET money_bank = money_bank + ? WHERE user_id = ?", amount,
        receiver.user_id)

    if sender_update_result and receiver_update_result then
        if dbExec(db, "COMMIT") then
            sender.money_bank = sender.money_bank - amount
            receiver.money_bank = receiver.money_bank + amount
            outputChatBox("Pomyslnie przeprowadzono transakcje.")
        end
    end

    dbExec(db, "ROLLBACK")
    outputChatBox("Transakcja sie zjebala.")
end

function give(receiver, amount)
    assert(amount > 0)

    local receiver_update_result = dbExec(db, "UPDATE Users SET money_bank = money_bank + ? WHERE user_id = ?", amount,
        receiver.user_id)
    if not receiver_update_result then
        outputChatBox("Zjebalo sie wysylanie kasy!")
        return
    end

    outputChatBox("Pomyslnie wyslano " .. amount .. " do " .. receiver.nickname)
end

function take(receiver, amount)
    assert(amount > 0)

    local receiver_update_result = dbExec(db, "UPDATE Users SET money_bank = money_bank - ? WHERE user_id = ?", amount,
        receiver.user_id)
    if not receiver_update_result then
        outputChatBox("Zjebalo sie odbieranie kasy!")
        return
    end

    outputChatBox("Pomyslnie odebrano " .. amount .. " od " .. receiver.nickname)
end

function pay_command(player, _, target, amount)
    if not target or not amount or not tonumber(target) or not tonumber(amount) then
        outputChatBox("❌ Użycie: /przelej <ID gracza> <kwota>", player, 255, 0, 0)
        return
    end

    local amount_value = tonumber(amount)

    if amount_value <= 0 then
        outputChatBox("❌ Kwota musi być większa od zera.", player, 255, 0, 0)
        return
    end

    local sender_serial = getPlayerSerial(player)
    local sender = exports.players:getPlayerBySerial(sender_serial)

    if amount_value > sender.money_bank then
        outputChatBox("❌ Nie masz wystarczającej ilości środków.", player, 255, 0, 0)
        return
    end

    local target_id = tonumber(target)
    local receiver = exports.players:getPlayerByID(target_id)
    if not receiver then
        outputChatBox("❌ Nie znaleziono takiego gracza!", player, 255, 0, 0)
        return
    end

    if receiver.user_id == sender.user_id then
        outputChatBox("❌ Nie możesz wykonać przelewu do samego siebie.", player, 255, 0, 0)
        return
    end

    pay(sender, receiver, amount)
    outputChatBox("✔ Pomyślnie wykonano przelew na kwotę " .. amount .. " do " .. receiver.nickname .. "!", player, 0, 255, 0)
end
addCommandHandler("przelej", pay_command)
