-- Połączenie z bazą danych
local db = dbConnect("mysql", "dbname=db_109517;host=sql.25.svpj.link;charset=utf8", "db_109517", "YODK7m8uXc0XWty8")

-- Funkcja ładowania pieniędzy po zalogowaniu na podstawie serialu
function onPlayerJoinOrLogin()
    local player = source
    local playerSerial = getPlayerSerial(player)  -- Pobranie serialu gracza
    
    -- Pobranie pieniędzy z bazy na podstawie serialu
    local query = dbQuery(db, "SELECT money_pocket FROM Users WHERE serial = ?", playerSerial)
    local result = dbPoll(query, -1)

    if result and result[1] then
        local money = result[1].money_pocket
        -- Wysyłamy pieniądze do klienta
        triggerClientEvent(player, "onReceiveMoney", player, money)
        setElementData(player, "money_pocket", money)  -- Opcjonalnie zapisanie danych po stronie serwera
    else
        -- Jeśli nie znaleziono gracza w bazie, ustaw 0
        triggerClientEvent(player, "onReceiveMoney", player, 0)
        setElementData(player, "money_pocket", 0)
    end
end
addEventHandler("onPlayerLogin", root, onPlayerJoinOrLogin)

-- Funkcja do aktualizacji pieniędzy w bazie danych na podstawie serialu
function updatePlayerMoney(player, amount)
    local currentMoney = getElementData(player, "money_pocket") or 0
    local newMoney = currentMoney + amount
    local playerSerial = getPlayerSerial(player)

    if newMoney < 0 then
        outputChatBox("Nie masz wystarczająco pieniędzy!", player, 255, 0, 0)
        return
    end

    -- Aktualizacja w bazie danych
    dbExec(db, "UPDATE Users SET money_pocket = ? WHERE serial = ?", newMoney, playerSerial)

    -- Aktualizacja na kliencie
    triggerClientEvent(player, "onReceiveMoney", player, newMoney)
    setElementData(player, "money_pocket", newMoney)
end
