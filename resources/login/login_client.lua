local browser = nil

function openLoginBrowser()
    if not browser then

        browser = guiCreateBrowser(0, 0, 1, 1, true, true, true)
        local theBrowser = guiGetBrowser(browser)

        guiSetVisible(guiGetScreenSize(), false)

        addEventHandler("onClientBrowserCreated", theBrowser, function()
            loadBrowserURL(theBrowser, "http://mta/local/login.html")
            outputDebugString("Przeglądarka otwarta i strona załadowana.")
            showCursor(true)
        end)
    else
        closeLoginBrowser()
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
    openLoginBrowser()
end)

function closeLoginBrowser()
    if browser then
        destroyElement(browser)
        browser = nil
        showCursor(false)
        local playerX, playerY, playerZ = getElementPosition(localPlayer)
        setCameraMatrix(playerX, playerY, playerZ + 2, playerX, playerY, playerZ)
    end
end

addEvent("onLoginResponse", true)
addEventHandler("onLoginResponse", root, function(success, message, userData)
    if success then
        outputChatBox("Zalogowano pomyślnie!", 0, 255, 0)
        closeLoginBrowser()
    else
        outputChatBox(message, 255, 0, 0)
    end
end)

addEvent("onRegisterResponse", true)
addEventHandler("onRegisterResponse", root, function(success, message)
    if success then
        outputChatBox(message, 0, 255, 0)
    else
        outputChatBox(message, 255, 0, 0)
    end
end)

function loginPlayer(username, password)
    triggerServerEvent("onPlayerLoginRequest", localPlayer, username, password)
end

addEvent("loginPlayer", true)
addEventHandler("loginPlayer", root, function(username, password)
    loginPlayer(username, password)
end)
