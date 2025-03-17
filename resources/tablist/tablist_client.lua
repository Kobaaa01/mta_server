local screenW, screenH = guiGetScreenSize()
local panelWidth, panelHeight = screenW * 0.35, screenH * 0.7  -- Powiększona tablica
local rowHeight = 45
local playerHeight = screenH * 0.06
local maxRows = math.floor((panelHeight - 120) / rowHeight)
local panelX, panelY = (screenW - panelWidth) / 2, (screenH - panelHeight) / 2
local isVisible = false
local players = {}
local scrollY = 0
local scrollSpeed = 40
local textSize = 1.5

local backgroundColor = tocolor(30, 30, 30, 220)
local headerColor = tocolor(50, 50, 50, 255)
local rowColor = tocolor(40, 40, 40, 200)
local scrollbarColor = tocolor(100, 100, 100, 200)
local textColor = tocolor(255, 255, 255, 255)

local rankColors = {
    ["Wlasciciel"] = {255, 0, 0},
    ["Admin"] = {255, 69, 0},
    ["SuperModerator"] = {0, 191, 255},
    ["Moderator"] = {34, 139, 34},
    ["JuniorModerator"] = {138, 43, 226},
    ["Gold"] = {255, 215, 0},
    ["Premium"] = {255, 140, 0}
}


function drawPlayerList()
    if not isVisible then return end

    dxDrawRectangle(panelX, panelY, panelWidth, panelHeight, backgroundColor, false)
    dxDrawRectangle(panelX, panelY, panelWidth, screenH * 0.06, headerColor, false)
    dxDrawText("" .. #players, panelX, panelY, panelX+panelWidth*1.85, panelY + screenH * 0.05, textColor, 1.5, "default-bold", "center", "center")
    dxDrawText("graczy", panelX, panelY, panelX+panelWidth*1.85, panelY + screenH * 0.09, textColor, 1.5, "default-bold", "center", "center")
    local legendY = panelY + screenH * 0.06
    dxDrawRectangle(panelX, legendY, panelWidth, rowHeight, headerColor, false)
    
    local colWidth = panelWidth / 3
    local offsetX = colWidth / 1.5
    local col1X = panelX
    local col2X = panelX + colWidth 
    local col3X = panelX + colWidth * 2
    local col4X = panelX + colWidth * 2.5
    local col5X = panelX + colWidth * 3
    
    dxDrawText("ID", col1X, legendY, col1X + colWidth - offsetX, legendY + rowHeight, textColor, textSize, "default-bold", "center", "center")
    dxDrawText("Nick", col2X, legendY, col2X - 1.5*offsetX, legendY + rowHeight, textColor, textSize, "default-bold", "center", "center")
    dxDrawText("Organizacja", col3X, legendY, col3X-2.5*offsetX, legendY + rowHeight, textColor, textSize, "default-bold", "center", "center")
    dxDrawText("Frakcja", col4X, legendY, col3X-0.7*offsetX, legendY+rowHeight, textColor, textSize, "default-bold", "center", "center")
    dxDrawText("Ping", col5X, legendY, col5X-0.5*offsetX, legendY + rowHeight, textColor, textSize, "default-bold", "center", "center")
    
    local startY = legendY + rowHeight
    
    for i = 1, maxRows do
        local index = i + math.floor(scrollY / playerHeight)
        local playerData = players[index]
        if playerData then
            local posY = startY + (i - 1) * playerHeight
            dxDrawRectangle(panelX, posY, panelWidth, playerHeight, rowColor, false)
            
            local rank = playerData.rank or "Gracz"
            local nickColor = rankColors[rank] or {255, 255, 255}
            
            dxDrawText(playerData.id, col1X, posY, col1X + colWidth-offsetX, posY + playerHeight, textColor, textSize, "default-bold", "center", "center")
            dxDrawText(playerData.nickname, col2X, posY, col2X - 1.5*offsetX, posY + playerHeight, tocolor(nickColor[1], nickColor[2], nickColor[3], 255), textSize, "default-bold", "center", "center")
            dxDrawText(playerData.group_id or "-", col3X, posY, col3X-2.5*offsetX, posY + playerHeight, textColor, textSize, "default-bold", "center", "center")
            dxDrawText(playerData.fraction_id or "-", col4X, posY, col3X-0.7*offsetX, posY + playerHeight, textColor, textSize, "default-bold", "center", "center")
            dxDrawText(playerData.ping .. " ms", col5X, posY, col5X-0.5*offsetX, posY + playerHeight, textColor, textSize, "default-bold", "center", "center")
        end
    end
    
    if #players > maxRows then
        local scrollbarHeight = (maxRows / #players) * (panelHeight - 120)
        local scrollbarY = panelY + 70 + (scrollY / (#players * rowHeight)) * (panelHeight - 120 - scrollbarHeight)
        dxDrawRectangle(panelX + panelWidth - 15, scrollbarY, 10, scrollbarHeight, scrollbarColor, false)
    end
end
addEventHandler("onClientRender", root, drawPlayerList)

function updatePlayerData(data)
    players = data
    table.sort(players, function(a, b) return a.nickname < b.nickname end)
end
addEvent("updateClientPlayerData", true)
addEventHandler("updateClientPlayerData", root, updatePlayerData)

function scrollPlayerList(key, state)
    if isVisible then
        if key == "mouse_wheel_up" then
            scrollY = math.max(scrollY - scrollSpeed, 0)
        elseif key == "mouse_wheel_down" then
            local maxScroll = math.max(0, (#players * rowHeight) - (panelHeight - 120))
            scrollY = math.min(scrollY + scrollSpeed, maxScroll)
        end
    end
end
bindKey("mouse_wheel_up", "down", scrollPlayerList)
bindKey("mouse_wheel_down", "down", scrollPlayerList)

local lastUpdateTime = 0
local updateCooldown = 15000 -- 15 sekund

function togglePlayerList()
    isVisible = not isVisible
    if isVisible then
        local currentTime = getTickCount()
        if currentTime - lastUpdateTime > updateCooldown then
            triggerServerEvent("requestPlayerData", localPlayer) -- Żądanie danych od serwera
            lastUpdateTime = currentTime
        end
    end
end
bindKey("tab", "both", function(_, state)
    if state == "down" then
        togglePlayerList()
    else
        isVisible = false
    end
end)

-- Funkcja do aktualizacji danych graczy
function updatePlayerData(data)
    players = data
    table.sort(players, function(a, b) return a.nickname < b.nickname end) -- Sortowanie graczy po nicku
end
addEvent("updateClientPlayerData", true)
addEventHandler("updateClientPlayerData", root, updatePlayerData)
