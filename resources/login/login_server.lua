local db = dbConnect("mysql", "dbname=db_109517;host=sql.25.svpj.link;charset=utf8", "db_109517", "YODK7m8uXc0XWty8")

-- Mapa, kluczem jest serial 
Players = {}

function hashPassword(password)
    return hash("sha256", password)
end

function createUserObject(player)
    local serial = getPlayerSerial(player)
    local query = "SELECT * FROM Users WHERE serial = ?"

    -- Dodaj przekazanie serialu jako parametru do dbQuery
    dbQuery(function(queryHandle)
        local result, numRows, errorMsg = dbPoll(queryHandle, -1)
        
        if result and numRows > 0 then
            local userData = result[1]

            -- Tworzymy obiekt użytkownika
            local user = {
                user_id = userData.user_id,
                nickname = userData.nickname,
                serial = userData.serial,
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

            -- Dodajemy gracza do mapy
            Players[serial] = user

            -- Przekazanie danych na klienta
            triggerClientEvent(player, "onLoginResponse", resourceRoot, true, "Zalogowano pomyślnie!", user)

            -- Ustawienia w grze
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
    if not username or not password then
        triggerClientEvent(player, "onLoginResponse", resourceRoot, false, "Brak danych")
        return
    end

    local result = dbPoll(dbQuery(db, "SELECT user_id, password_hash, ban_status, serial FROM Users WHERE nickname = ?", username), -1)

    if result and #result > 0 then
        local user = result[1]

        if user.ban_status == "BANNED" then
            triggerClientEvent(player, "onLoginResponse", resourceRoot, false, "Użytkownik jest zbanowany")
            return
        end

        if user.password_hash == hashPassword(password) then
            local existingPlayer = Players[user.serial]
            if existingPlayer then
                triggerClientEvent(player, "onLoginResponse", resourceRoot, false, "Ktoś już jest zalogowany na to konto!")
                return
            end

            setPlayerName(player, username)
            dbExec(db, "UPDATE Users SET online = 1 WHERE nickname = ?", username)
            createUserObject(player)
        else
            triggerClientEvent(player, "onLoginResponse", resourceRoot, false, "Nieprawidłowe hasło")
        end
    else
        triggerClientEvent(player, "onLoginResponse", resourceRoot, false, "Użytkownik nie istnieje")
    end
end

addEventHandler("onPlayerQuit", root, function()
    local serial = getPlayerSerial(source)
    if serial then
        local user = Players[serial]
        if user then
            dbExec(db, "UPDATE Users SET online = 0 WHERE nickname = ?", user.nickname)
            Players[serial] = nil  -- Usuwamy gracza z listy zalogowanych
        end
    end
end)

addEvent("onPlayerLoginRequest", true)
addEventHandler("onPlayerLoginRequest", root, loginPlayer)


-- Tajna komenda testowa 
addCommandHandler("kubale", function(player)
    local count = 0
    for serial, userData in pairs(Players) do
        count = count + 1
        outputChatBox("Gracz: " .. tostring(userData.nickname), player)
        outputChatBox("Serial: " .. tostring(userData.serial), player)
        outputChatBox("Pieniądze w kieszeni: " .. tostring(userData.money_pocket), player)
        outputChatBox("Skin ID: " .. tostring(userData.skin_id), player)
        outputChatBox("Pieniądze w banku: " .. tostring(userData.money_bank), player)
        outputChatBox("Zbanowany?: " .. tostring(userData.ban_status), player)
        outputChatBox("--------------------------", player)
    end
    outputChatBox("Rozmiar Players: " .. count, player)
end)
