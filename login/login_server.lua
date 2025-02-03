local db = dbConnect("mysql", "dbname=db_109517;host=sql.25.svpj.link;charset=utf8", "db_109517", "YODK7m8uXc0XWty8")

function hashPassword(password)
    return hash("sha256", password) -- Hashowanie hasła
end

-- Pobranie danych online do klienta
function fetchOnlineUserData()
    local query = dbQuery(db, "SELECT user_id, nickname FROM Users WHERE online = 1")
    local result = dbPoll(query, -1)
    return result or {}
end

function sendUserDataToClient(player)
    local userData = fetchOnlineUserData()
    triggerClientEvent(player, "updateUserData", resourceRoot, userData)
end

function loginPlayer(username, password, player)
    if not username or not password then
        triggerClientEvent(player, "onLoginResponse", resourceRoot, false, "Brak danych")
        return
    end

    local result = dbPoll(dbQuery(db, "SELECT user_id, password_hash, ban_status FROM Users WHERE nickname = ?", username), -1)
    
    if result and #result > 0 then
        local user = result[1]

        if user.ban_status == "BANNED" then
            triggerClientEvent(player, "onLoginResponse", resourceRoot, false, "Użytkownik jest zbanowany")
            return
        end

        if user.password_hash == hashPassword(password) then
            -- Sprawdzanie czy nick nie jest już używany przez innego gracza
            local existingPlayer = getPlayerFromName(username)
            if existingPlayer then
                triggerClientEvent(player, "onLoginResponse", resourceRoot, false, "Ktoś już jest zalogowany na to konto!")
                return
            end

            -- Zmiana nicku gracza na zalogowany
            setPlayerName(player, username)

            -- Aktualizacja statusu online w bazie danych
            dbExec(db, "UPDATE Users SET online = 1 WHERE nickname = ?", username)
            
            -- Wysyłanie zaktualizowanych danych do wszystkich graczy
            sendUserDataToClient(root)

            -- Informacja o sukcesie logowania
            triggerClientEvent(player, "onLoginResponse", resourceRoot, true, "Zalogowano pomyślnie!")
            
            -- Respi gracza na mapie
            spawnPlayer(player, 0, 0, 3, 90, 0)
            fadeCamera(player, true)
            setCameraTarget(player, player)
        else
            triggerClientEvent(player, "onLoginResponse", resourceRoot, false, "Nieprawidłowe hasło")
        end
    else
        triggerClientEvent(player, "onLoginResponse", resourceRoot, false, "Użytkownik nie istnieje")
    end
end

function registerPlayer(username, password, player)
    if not username or not password then
        triggerClientEvent(player, "onRegisterResponse", resourceRoot, false, "Brak danych")
        return
    end

    if #username < 3 then
        triggerClientEvent(player, "onRegisterResponse", resourceRoot, false, "Nazwa użytkownika musi mieć co najmniej 3 znaki")
        return
    end

    if #password < 8 then
        triggerClientEvent(player, "onRegisterResponse", resourceRoot, false, "Hasło musi mieć co najmniej 8 znaków")
        return
    end

    local playerSerial = getPlayerSerial(player)
    local serialExists = dbPoll(dbQuery(db, "SELECT user_id FROM Users WHERE serial = ?", playerSerial), -1)

    if serialExists and #serialExists > 0 then
        triggerClientEvent(player, "onRegisterResponse", resourceRoot, false, "Nie możesz tworzyć wielu kont z tego samego komputera")
        return
    end

    local exists = dbPoll(dbQuery(db, "SELECT user_id FROM Users WHERE nickname = ?", username), -1)

    if exists and #exists > 0 then
        triggerClientEvent(player, "onRegisterResponse", resourceRoot, false, "Użytkownik już istnieje")
        return
    end

    local success = dbExec(db, "INSERT INTO Users (nickname, password_hash, skin_id, money_pocket, money_bank, warns, ban_status, mute_status, driving_license, serial, online) VALUES (?, ?, 0, 500.00, 0.00, 0, 'NOT_BANNED', 'NOT_MUTED', FALSE, ?, 0)",
        username, hashPassword(password), playerSerial)

    if success then
        triggerClientEvent(player, "onRegisterResponse", resourceRoot, true, "Rejestracja zakończona sukcesem")
    else
        triggerClientEvent(player, "onRegisterResponse", resourceRoot, false, "Błąd rejestracji")
    end
end

-- Ustawienie statusu offline przy wyjściu z gry
addEventHandler("onPlayerQuit", root, function()
    local accountName = getPlayerName(source)
    if accountName then
        dbExec(db, "UPDATE Users SET online = 0 WHERE nickname = ?", accountName)
        sendUserDataToClient(root)
    end
end)

-- Wysłanie danych o użytkownikach online przy starcie zasobu
addEventHandler("onResourceStart", resourceRoot, function()
    sendUserDataToClient(root)
end)

-- Obsługa zdarzeń logowania i rejestracji
addEvent("onPlayerLoginRequest", true)
addEventHandler("onPlayerLoginRequest", root, loginPlayer)

addEvent("onPlayerRegisterRequest", true)
addEventHandler("onPlayerRegisterRequest", root, registerPlayer)
