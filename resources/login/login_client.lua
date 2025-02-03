-- TESCIKKK
local screenW, screenH = guiGetScreenSize()
local usernameInput, passwordInput, loginButton, registerButton, backgroundImage, backgroundMusic, overlayGif, overlayText, frameImage = nil, nil, nil, nil, nil, nil, nil, nil, nil

local gifFrames = {"frame0.png", "frame1.png", "frame2.png"} -- Tablica z klatkami GIF-a
local currentFrame = 1 -- Aktualna klatka
local frameChangeTime = 300 -- Czas zmiany klatki w milisekundach
local lastFrameChange = getTickCount() -- Czas ostatniej zmiany klatki


local cameraAnimationHandler = nil

function startFallingCamera()
    local player = getLocalPlayer()
    if not player then return end

    -- Konfiguracja animacji
    local startTime = getTickCount()
    local duration = 5000  -- 5 sekund animacji
    local startHeight = 30  -- Początkowa wysokość
    local endHeight = 1  -- Wysokość standardowego widoku plus minus xd

    -- Wyłącz automatyczne śledzenie
    setCameraTarget(player, false)

    -- Pobierz początkową rotację gracza
    local _, _, startRot = getElementRotation(player)
    
    -- Funkcja aktualizacji kamery
    local function updateCamera()
        local currentTime = getTickCount()
        local progress = (currentTime - startTime) / duration
        local easedProgress = getEasingValue(progress, "OutQuad")

        if progress >= 1 then
            removeEventHandler("onClientPreRender", root, updateCamera)
            setCameraTarget(player)  -- Przywróć normalną kamerę
            return
        end

        -- Aktualna pozycja i rotacja gracza
        local px, py, pz = getElementPosition(player)
        local _, _, currentRot = getElementRotation(player)
        
        -- Interpolacja rotacji
        local camRot = startRot + (currentRot - startRot) * easedProgress
        
        -- Oblicz pozycję kamery z uwzględnieniem rotacji
        local angle = math.rad(camRot)  -- 180 stopni za graczem
        local camOffsetX = math.sin(angle) * 3  -- 3 metry za graczem
        local camOffsetY = math.cos(angle) * 3
        
        -- Interpolacja wysokości
        local currentHeight = startHeight - (startHeight - endHeight) * easedProgress
        
        -- Pozycja kamery
        local camX = px + camOffsetX
        local camY = py + camOffsetY
        local camZ = pz + currentHeight
        
        -- Cel kamery (głowa gracza)
        local targetZ = pz + 0.6  -- Wysokość głowy
        
        setCameraMatrix(camX, camY, camZ, px, py, targetZ)
    end

    addEventHandler("onClientPreRender", root, updateCamera)
    
    -- Zabezpieczenie
    setTimer(function()
        removeEventHandler("onClientPreRender", root, updateCamera)
        setCameraTarget(player)
    end, duration + 1000, 1)
end

function updateCameraPosition()
    local player = getLocalPlayer()
    if not isElement(player) then return end
    
    local px, py, pz = getElementPosition(player)
    local _, _, rz = getElementRotation(player)
    
    -- Oblicz pozycję z offsetem uwzględniającym rotację
    local distance = 3 -- odległość od gracza
    local angle = math.rad(rz + 90) -- 90 stopni w prawo
    local camX = px - math.sin(angle) * distance
    local camY = py + math.cos(angle) * distance
    local camZ = pz + 0.5
    
    -- Płynne śledzenie gracza
    setCameraMatrix(camX, camY, camZ, px, py, pz)
end


function showLoginWindow()
    showCursor(true)

    -- Tło
    backgroundImage = guiCreateStaticImage(0, 0, 1, 1, "background.png", true)
    guiSetEnabled(backgroundImage, false)

    -- Pole do wprowadzania nazwy użytkownika
    usernameInput = guiCreateEdit(0.4, 0.3, 0.2, 0.05, "", true)
    guiSetAlpha(usernameInput, 0.8)
    guiEditSetCaretIndex(usernameInput, 0)
    guiSetProperty(usernameInput, "PlaceholderText", "Login")

    -- Pole do wprowadzania hasła
    passwordInput = guiCreateEdit(0.4, 0.4, 0.2, 0.05, "", true)
    guiSetAlpha(passwordInput, 0.8)
    guiEditSetMasked(passwordInput, true)
    guiEditSetCaretIndex(passwordInput, 0)
    guiSetProperty(passwordInput, "PlaceholderText", "Hasło")

    -- Przyciski logowania i rejestracji
    loginButton = guiCreateStaticImage(0.4, 0.5, 0.2, 0.05, "login.png", true)
    registerButton = guiCreateStaticImage(0.4, 0.6, 0.2, 0.05, "register.png", true)

    addEventHandler("onClientGUIClick", loginButton, onLoginButtonClick, false)
    addEventHandler("onClientGUIClick", registerButton, onRegisterButtonClick, false)

    -- Muzyka w tle
    backgroundMusic = playSound("background_music.mp3", true)
    setSoundVolume(backgroundMusic, 0.5)

    -- Napis obok GIF-a
    overlayText = guiCreateLabel(0.8, 0.75, 0.18, 0.05, "OneRepublic - All The Right Moves", true)
    guiLabelSetColor(overlayText, 255, 255, 255)
    guiLabelSetHorizontalAlign(overlayText, "center", false)

    -- Dodaj obrazek frame0.png z boku
    frameImage = guiCreateStaticImage(0.84, 0.78, 0.1, 0.2, gifFrames[currentFrame], true)
    guiSetAlpha(frameImage, 0.8)

    -- Dodaj zdarzenie onClientRender do animacji GIF-a
    addEventHandler("onClientRender", root, animateGif)
end
addEventHandler("onClientResourceStart", resourceRoot, showLoginWindow)

function animateGif()
    local now = getTickCount()
    if now - lastFrameChange >= frameChangeTime then -- Sprawdź, czy minął czas zmiany klatki
        currentFrame = currentFrame + 1 -- Przejdź do następnej klatki
        if currentFrame > #gifFrames then -- Jeśli przekroczono liczbę klatek, wróć do pierwszej
            currentFrame = 1
        end
        guiStaticImageLoadImage(frameImage, gifFrames[currentFrame]) -- Załaduj nową klatkę
        lastFrameChange = now -- Zaktualizuj czas ostatniej zmiany klatki
    end
end


function onLoginButtonClick()
    local username = guiGetText(usernameInput)
    local password = guiGetText(passwordInput)
    triggerServerEvent("onPlayerLoginRequest", resourceRoot, username, password, localPlayer)
end

function onRegisterButtonClick()
    local username = guiGetText(usernameInput)
    local password = guiGetText(passwordInput)
    triggerServerEvent("onPlayerRegisterRequest", resourceRoot, username, password, localPlayer)
end

addEvent("onLoginResponse", true)
addEventHandler("onLoginResponse", resourceRoot, function(success, message, userData)
    outputChatBox(message)
    if success then
        destroyElement(usernameInput)
        destroyElement(passwordInput)
        destroyElement(loginButton)
        destroyElement(registerButton)
        destroyElement(backgroundImage)
        destroyElement(frameImage)
        removeEventHandler("onClientRender", root, animateGif)
        destroyElement(overlayText)
        stopSound(backgroundMusic)
        showCursor(false)
        startFallingCamera()

        -- Wyświetlenie danych użytkownika
        if userData then
            outputChatBox("Witaj, " .. userData.nickname .. "!")
            outputChatBox("Masz: $" .. userData.money_pocket .. " w kieszeni.")
        end
    else
        outputChatBox("Logowanie nie powiodło się.")
    end
end)


addEvent("onRegisterResponse", true)
addEventHandler("onRegisterResponse", resourceRoot, function(success, message)
    outputChatBox(message)
end)