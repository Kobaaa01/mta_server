local screenW, screenH = guiGetScreenSize()
local panelWidth, panelHeight = 400, 500
local panelX, panelY = (screenW - panelWidth) / 2, (screenH - panelHeight) / 2
local isVisible = false
local players = {}
local scrollY = 0
local scrollSpeed = 30

local background = dxCreateTexture("background.png")
local scrollbar = dxCreateTexture("scroll.png")

-- Cache dla ikon skór
local skinIcons = {}

-- Funkcja do przełączania widoczności listy graczy
function togglePlayerList()
    isVisible = not isVisible
    if isVisible then
        triggerServerEvent("requestPlayerData", localPlayer)
    end
end
bindKey("tab", "both", function(_, state)
    if state == "down" then
        togglePlayerList()
    else
        isVisible = false
    end
end)

-- Funkcja do rysowania listy graczy
function drawPlayerList()
    if not isVisible then return end

    -- Tło panelu
    dxDrawImage(panelX, panelY, panelWidth, panelHeight, background)

    -- Nagłówek
    dxDrawText("Lista graczy", panelX, panelY + 10, panelX + panelWidth, panelY + 30, tocolor(255, 255, 255, 255), 1.2, "default-bold", "center")

    -- Lista graczy
    local startY = panelY + 50
    local rowHeight = 40
    local maxRows = math.floor((panelHeight - 100) / rowHeight)

    for i = 1, maxRows do
        local index = i + math.floor(scrollY / rowHeight)
        local playerData = players[index]
        if playerData then
            local posY = startY + (i - 1) * rowHeight

            -- Ładowanie ikony skina
            if not skinIcons[playerData.skin_id] then
                skinIcons[playerData.skin_id] = dxCreateTexture("skins/" .. playerData.skin_id .. ".png", "argb", true, "clamp")
            end

            -- Rysowanie ikony skina
            if skinIcons[playerData.skin_id] then
                dxDrawImage(panelX + 10, posY + 4, 32, 32, skinIcons[playerData.skin_id])
            else
                dxDrawText("🚫", panelX + 10, posY + 4, panelX + 42, posY + 36, tocolor(255, 0, 0, 255), 1, "default-bold", "center", "center")
            end

            -- ID i Nick gracza
            dxDrawText(
                "#" .. playerData.id .. " | " .. playerData.nickname,
                panelX + 50, posY,
                panelX + panelWidth - 20, posY + rowHeight,
                tocolor(255, 255, 255, 255), 1, "default-bold", "left", "center"
            )
        end
    end

    -- Scrollbar
    local totalRows = #players
    if totalRows > maxRows then
        local scrollbarHeight = (maxRows / totalRows) * (panelHeight - 100)
        local scrollbarY = panelY + 50 + (scrollY / (totalRows * rowHeight)) * (panelHeight - 100 - scrollbarHeight)
        dxDrawImage(panelX + panelWidth - 20, scrollbarY, 10, scrollbarHeight, scrollbar)
    end
end
addEventHandler("onClientRender", root, drawPlayerList)

-- Funkcja do aktualizacji danych graczy
function updatePlayerData(data)
    players = data
    table.sort(players, function(a, b) return a.nickname < b.nickname end)
end
addEvent("updateClientPlayerData", true)
addEventHandler("updateClientPlayerData", root, updatePlayerData)

-- Funkcja do przewijania listy
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