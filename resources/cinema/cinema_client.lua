local browser = nil
local shader = nil
local screen = nil
local videoStartTime = 0

addEvent("client:playVideo", true)
addEventHandler("client:playVideo", resourceRoot, function(videoName, startTime, x, y, z)
    -- Czyść poprzednie elementy
    destroyElements()

    videoStartTime = startTime

    -- Stwórz obiekt ekranu
    screen = createObject(2332, x, y, z)
    setElementDimension(screen, getElementDimension(localPlayer))
    setElementInterior(screen, getElementInterior(localPlayer))

    -- Inicjalizacja przeglądarki
    browser = createBrowser(800, 600, true)
    addEventHandler("onClientBrowserCreated", browser, function()
        loadBrowserURL(browser, "http://mta/local/player.html?video=" .. videoName)
    end)

    -- Stwórz i aplikuj shader
    shader = dxCreateShader("texreplace.fx")
    engineApplyShaderToWorldTexture(shader, "tvscrn", screen) -- Poprawna nazwa tekstury
end)

function destroyElements()
    if isElement(browser) then destroyElement(browser) end
    if isElement(shader) then destroyElement(shader) end
    if isElement(screen) then destroyElement(screen) end
end

addEventHandler("onClientBrowserDocumentReady", root, function(url)
    if source ~= browser then return end
    dxSetShaderValue(shader, "gTexture", browser)
    
    -- Synchronizacja czasu
    local currentTime = (getTickCount() - videoStartTime) / 1000
    executeJavaScript(browser, "document.getElementById('videoPlayer').currentTime = " .. currentTime .. ";")
end)

-- Automatyczne czyszczenie
setTimer(function()
    if screen and isElement(screen) then
        local dist = getDistanceBetweenPoints3D(getElementPosition(localPlayer), getElementPosition(screen))
        if dist > 50 then
            destroyElements()
        end
    end
end, 5000, 0)