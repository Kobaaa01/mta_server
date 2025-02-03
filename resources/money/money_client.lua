local screenW, screenH = guiGetScreenSize()
local backgroundImage = dxCreateTexture("background.png")
local playerMoney = 0  -- Domyślna wartość pieniędzy

-- Funkcja odbierająca pieniądze z serwera
addEvent("onReceiveMoney", true)
addEventHandler("onReceiveMoney", root, function(money)
    playerMoney = money
end)

-- Funkcja rysująca HUD z grafiką i pieniędzmi
function drawMoneyHUD()
    local imageWidth, imageHeight = 300, 100  -- Rozmiar grafiki
    local imageX, imageY = screenW - imageWidth - 20, 20  -- Pozycja w prawym górnym rogu

    -- Rysowanie tła (grafiki)
    dxDrawImage(imageX, imageY, imageWidth, imageHeight, backgroundImage)

    -- Rysowanie tekstu na tle grafiki
    dxDrawText("Pieniądze: $" .. tostring(playerMoney), imageX + 20, imageY + 35, imageX + imageWidth, imageY + imageHeight,
               tocolor(255, 255, 255, 255), 1.5, "default-bold", "left", "top", false, false, false)
end
addEventHandler("onClientRender", root, drawMoneyHUD)
