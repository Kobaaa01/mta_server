-- Funkcja do hashowania hasła
function hashPassword(password)
    return hash("sha256", password)
end

function createUserObject(player)
    local serial = getPlayerSerial(player)
    local query = "SELECT * FROM Users WHERE serial = ?"
    local db = exports.database:get_db();

    dbQuery(function(queryHandle)
        local result, numRows, errorMsg = dbPoll(queryHandle, -1)

        if result and numRows > 0 then
            local userData = result[1]

            local user = {
                user_id = userData.user_id,
                nickname = userData.nickname,
                serial = userData.serial,
                rank = userData.ranga,
                password_hash = userData.password_hash,
                skin_id = tonumber(userData.skin_id),
                money_pocket = tonumber(userData.money_pocket),
                money_bank = tonumber(userData.money_bank),
                warns = tonumber(userData.warns),
                ban_status = userData.ban_status,
                mute_status = userData.mute_status,
                driving_license = tonumber(userData.driving_license),
                fraction_id = tonumber(userData.fraction_id),
                group_id = tonumber(userData.group_id)
            }

            -- Dodaj gracza do tabeli Players
            exports.players:addPlayer(player)
            exports.players:updatePlayerData(player, user)

            -- Powiadom klienta o pomyślnym logowaniu
            triggerClientEvent(player, "onLoginResponse", resourceRoot, true, "Zalogowano pomyślnie!", user)
            triggerClientEvent(player, "disableHUD", resourceRoot)
            spawnPlayer(player, 0, 0, 3, 90, user.skin_id)
            fadeCamera(player, true)
            setCameraTarget(player, player)
            setPlayerMoney(player, user.money_pocket)
        else
            triggerClientEvent(player, "onLoginResponse", resourceRoot, false, "Nie znaleziono danych użytkownika.")
        end
    end, db, query, serial)
end

function loginPlayer(username, password, player)
    outputDebugString("Próba logowania gracza: " .. username)
    if not username or not password then
        triggerClientEvent(player, "onLoginResponse", resourceRoot, false, "Brak danych")
        return
    end

    local db = exports.database:get_db();
    local result = dbPoll(
        dbQuery(db, "SELECT user_id, password_hash, ban_status, serial FROM Users WHERE nickname = ?", username), -1)

    if result and #result > 0 then
        local user = result[1]

        if user.ban_status == "BANNED" then
            triggerClientEvent(player, "onLoginResponse", resourceRoot, false, "Użytkownik jest zbanowany")
            return
        end

        if user.password_hash == hashPassword(password) then
            -- Sprawdź, czy gracz jest już zalogowany
            local existingPlayer = exports.players:getPlayerBySerial(user.serial)
            if existingPlayer then
                triggerClientEvent(player, "onLoginResponse", resourceRoot, false,
                    "Ktoś już jest zalogowany na to konto!")
                return
            end

            -- Ustaw nazwę gracza i dodaj go do tabeli Players
            setPlayerName(player, username)
            createUserObject(player)
        else
            triggerClientEvent(player, "onLoginResponse", resourceRoot, false, "Nieprawidłowe hasło")
        end
    else
        triggerClientEvent(player, "onLoginResponse", resourceRoot, false, "Użytkownik nie istnieje")
    end
end

-- Zdarzenie do obsługi logowania
addEvent("onPlayerLoginRequest", true)
addEventHandler("onPlayerLoginRequest", root, function(username, password)
    -- Upewnij się, że źródło zdarzenia (gracz) jest poprawne
    if source then
        loginPlayer(username, password, source)
    else
        outputDebugString("Błąd: źródło zdarzenia (source) jest nil.")
    end
end)

function savePlayerData(player)
    local serial = getPlayerSerial(player)
    local playerData = exports.players:getPlayerBySerial(serial)

    if playerData then
        outputDebugString("Zapisywanie danych gracza: " .. playerData.nickname)
        outputDebugString("Dane gracza: money_pocket=" .. playerData.money_pocket .. ", money_bank=" ..
                              playerData.money_bank .. ", skin_id=" .. playerData.skin_id)

        local db = exports.database:get_db();
        local query = dbExec(db, "UPDATE Users SET money_pocket = ?, money_bank = ?, skin_id = ? WHERE nickname = ?",
            playerData.money_pocket, playerData.money_bank, playerData.skin_id, playerData.nickname)

        if query then
            outputDebugString("Dane gracza zostały zapisane.")
        else
            outputDebugString("Błąd: Nie udało się wykonać zapytania SQL.")
        end

        exports.players:removePlayer(player)
    else
        outputDebugString("Błąd: Nie znaleziono danych gracza dla serialu: " .. serial)
    end
end

addEventHandler("onPlayerQuit", root, function()
    outputDebugString("Gracz " .. getPlayerName(source) .. " opuszcza serwer.")
    savePlayerData(source)
end)

function registerPlayer(username, password, player)
    outputDebugString("Próba rejestracji gracza: " .. username)

    if not username or not password then
        triggerClientEvent(player, "onRegisterResponse", resourceRoot, false, "Brak danych")
        return
    end

    -- Sprawdzenie, czy użytkownik już istnieje
    local result = dbPoll(dbQuery(db, "SELECT user_id FROM Users WHERE nickname = ?", username), -1)

    if result and #result > 0 then
        triggerClientEvent(player, "onRegisterResponse", resourceRoot, false, "Użytkownik już istnieje")
        return
    end

    -- Pobranie serialu gracza
    local serial = getPlayerSerial(player)

    -- Sprawdzenie, czy serial już istnieje (żeby uniknąć multi-kont)
    local serialCheck = dbPoll(dbQuery(db, "SELECT user_id FROM Users WHERE serial = ?", serial), -1)

    if serialCheck and #serialCheck > 0 then
        triggerClientEvent(player, "onRegisterResponse", resourceRoot, false,
            "To konto już istnieje na tym komputerze.")
        return
    end

    local passwordHash = hashPassword(password)
    local defaultSkinID = 0

    local db = exports.database:get_db();
    local query = dbExec(db, [[
            INSERT INTO Users (nickname, serial, password_hash, skin_id, money_pocket, money_bank, warns, ban_status, mute_status, driving_license, fraction_id, group_id)
            VALUES (?, ?, ?, ?, 0.00, 0.00, 0, 'NOT_BANNED', 'NOT_MUTED', FALSE, NULL, NULL)
        ]], username, serial, passwordHash, defaultSkinID)

    if query then
        triggerClientEvent(player, "onRegisterResponse", resourceRoot, true,
            "Rejestracja zakończona sukcesem! Możesz się teraz zalogować.")
    else
        triggerClientEvent(player, "onRegisterResponse", resourceRoot, false,
            "Błąd podczas rejestracji. Spróbuj ponownie.")
    end
end

addEvent("onPlayerRegisterRequest", true)
addEventHandler("onPlayerRegisterRequest", root, registerPlayer)
