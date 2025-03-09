local screenW, screenH = guiGetScreenSize()
local panelWidth, panelHeight = screenH * 0.4, screenH * 0.5
local rowHeight = 40
local maxRows = math.floor((panelHeight - 100) / rowHeight)
local panelX, panelY = (screenW - panelWidth) / 2, (screenH - panelHeight) / 2
local isVisible = false
local players = {}
local scrollY = 0
local scrollSpeed = 30

local backgroundColor = tocolor(30, 30, 30, 220)
local headerColor = tocolor(50, 50, 50, 255)
local rowColor = tocolor(40, 40, 40, 200)
local scrollbarColor = tocolor(100, 100, 100, 200)
local textColor = tocolor(255, 255, 255, 255)

local rankColors = {
    ["Wlasciciel"] = {255, 0, 0},       -- Czerwony
    ["Admin"] = {255, 69, 0},           -- Pomarańczowy
    ["SuperModerator"] = {0, 191, 255}, -- Niebieski
    ["Moderator"] = {34, 139, 34},      -- Zielony
    ["JuniorModerator"] = {138, 43, 226}, -- Fioletowy
    ["Gold"] = {255, 215, 0},           -- Złoty
    ["Premium"] = {255, 140, 0}         -- Ciemnopomarańczowy
}

local lastUpdateTime = 0 
local updateCooldown = 15000

function togglePlayerList()
    isVisible = not isVisible
    if isVisible then
        local currentTime = getTickCount()
        if currentTime - lastUpdateTime > updateCooldown then
            triggerServerEvent("requestPlayerData", localPlayer)
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

function drawPlayerList()
    if not isVisible then return end

    -- Tło panelu
    dxDrawRectangle(panelX, panelY, panelWidth, panelHeight, backgroundColor, false)

    -- Nagłówek
    dxDrawRectangle(panelX, panelY, panelWidth, 40, headerColor, false)
    dxDrawText("Gracze online: " .. #players, panelX, panelY + 10, panelX + panelWidth, panelY + 30, textColor, 1.2, "default-bold", "center", "center")

    local legendY = panelY + 40
    dxDrawRectangle(panelX + 10, legendY, panelWidth - 20, rowHeight, headerColor, false) 
    dxDrawText("ID", panelX + 20, legendY, panelX + 100, legendY + rowHeight, textColor, 1, "default-bold", "left", "center") 
    dxDrawText("Nick", panelX + 120, legendY, panelX + panelWidth - 100, legendY + rowHeight, textColor, 1, "default-bold", "left", "center") 
    dxDrawText("Ping", panelX + panelWidth - 90, legendY, panelX + panelWidth - 20, legendY + rowHeight, textColor, 1, "default-bold", "right", "center") 
    local startY = panelY + 90 

    for i = 1, maxRows do
        local index = i + math.floor(scrollY / rowHeight)
        local playerData = players[index]
        if playerData then
            local posY = startY + (i - 1) * rowHeight

            -- Tło wiersza
            dxDrawRectangle(panelX + 10, posY, panelWidth - 20, rowHeight, rowColor, false)
            
            -- ID, Nick i Ping gracza
            dxDrawText(
                playerData.id,
                panelX + 20, posY,
                panelX + 100, posY + rowHeight,
                textColor, 1, "default-bold", "left", "center"
            )
            local rank = playerData.rank or "Gracz" -- Domyślna ranga to "Gracz"
            local nickColor = rankColors[rank] or {255, 255, 255} -- Domyślny kolor to biały
            dxDrawText(
                playerData.nickname,
                panelX + 120, posY,
                panelX + panelWidth - 100, posY + rowHeight,
                tocolor(nickColor[1], nickColor[2], nickColor[3], 255), 1, "default-bold", "left", "center"
            )
            dxDrawText(
                playerData.ping .. " ms",
                panelX + panelWidth - 90, posY,
                panelX + panelWidth - 20, posY + rowHeight,
                textColor, 1, "default-bold", "right", "center"
            )
        end
    end

    -- Scrollbar
    local totalRows = #players
    if totalRows > maxRows then
        local scrollbarHeight = (maxRows / totalRows) * (panelHeight - 100)
        local scrollbarY = panelY + 50 + (scrollY / (totalRows * rowHeight)) * (panelHeight - 100 - scrollbarHeight)
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
            local maxScroll = math.max(0, (#players * rowHeight) - (panelHeight - 100))
            scrollY = math.min(scrollY + scrollSpeed, maxScroll)
        end
    end
end
bindKey("mouse_wheel_up", "down", scrollPlayerList)
bindKey("mouse_wheel_down", "down", scrollPlayerList)