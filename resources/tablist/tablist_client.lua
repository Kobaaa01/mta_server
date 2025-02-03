-- TEST FTP
local playerList = {}
local font = "bankgothic"
local lineHeight = 25
local screenWidth, screenHeight = guiGetScreenSize()
local width, height = 500, 300
local startX = (screenWidth - width) / 2 - 125
local startY = (screenHeight - height) / 2 - 100
local width, height = 700, 500 
local scrollY = 0
local maxScrollY = 0
local scrollSpeed = 20 
local odstep = 40

local backgroundImage = dxCreateTexture("background.png")
local scrollBarImage = dxCreateTexture("scroll.png")


addEvent("receivePlayerList", true)
addEventHandler("receivePlayerList", root, function(data)
    playerList = data
    scrollY = 0 
    
    maxScrollY = math.max(0, (#playerList * lineHeight) - height)
    
    outputChatBox("Tablista została zaktualizowana! Gracze: " .. #playerList)
end)

bindKey("tab", "down", function()
    addEventHandler("onClientRender", root, drawTabList)
    toggleControl("jump", true)
    toggleControl("forwards", true)
    toggleControl("backwards", true)
    toggleControl("left", true)
    toggleControl("right", true)
    toggleControl("vehicle_left", true)
    toggleControl("vehicle_right", true)
end)

bindKey("tab", "up", function()
    removeEventHandler("onClientRender", root, drawTabList)
end)


addEventHandler("onClientKey", root, function(button, press)
    if press then
        if button == "mouse_wheel_up" then
            scrollY = math.max(0, scrollY - scrollSpeed)
        elseif button == "mouse_wheel_down" then
            scrollY = math.min(maxScrollY, scrollY + scrollSpeed)
        end
    end
end)


function drawTabList()
    -- Rysowanie tła
    dxDrawImage(startX, startY, width, height, backgroundImage)
    
    -- Tytuł
    dxDrawText("Gracze Online", startX, startY - 30, startX + width, startY, tocolor(255, 255, 255, 255), 1.2, font, "center", "top")

    -- Nagłówki kolumn
    dxDrawText("ID", startX + 10, startY, startX + 50, startY + lineHeight, tocolor(200, 200, 200, 255), 1, font, "left", "center")
    dxDrawText("Nickname", startX + 60, startY, startX + width - 100, startY + lineHeight, tocolor(200, 200, 200, 255), 1, font, "left", "center")

    -- Wyświetlanie graczy
    if #playerList == 0 then
        dxDrawText("Brak graczy online.", startX, startY + 10, startX + width, startY + 40, tocolor(255, 255, 255, 255), 1, font, "center", "top")
    else
        for i, player in ipairs(playerList) do
            local y = startY + ((i - 1) * lineHeight) - scrollY  -- Uwzględnienie przewijania
            
            -- Wyświetlanie tylko widocznych wierszy
            if y + lineHeight > startY and y < startY + height then
                dxDrawText(i, startX + 10, y + odstep, startX + 50, y + lineHeight, tocolor(255, 255, 255, 255), 1, font, "left", "center")
                dxDrawText(player.nickname, startX + 60, y + odstep, startX + width - 100, y + lineHeight, tocolor(255, 255, 255, 255), 1, font, "left", "center")
            end
        end
    end

    -- Rysowanie suwaka
    if maxScrollY > 0 then
        local scrollbarHeight = (height / (#playerList * lineHeight)) * height
        local scrollbarY = startY + (scrollY / maxScrollY) * (height - scrollbarHeight)
        dxDrawImage(startX + width - 15, scrollbarY, 10, scrollbarHeight, scrollBarImage)
    end
end
