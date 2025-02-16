local screenW, screenH = guiGetScreenSize()
local panelWidth, panelHeight = 400, 500
local panelX, panelY = (screenW - panelWidth) / 2, (screenH - panelHeight) / 2
local isVisible = false
local players = {}
local scrollY = 0
local scrollSpeed = 30

local background = dxCreateTexture("background.png")
local scrollbar = dxCreateTexture("scroll.png")

function togglePlayerList()
    isVisible = not isVisible
    if isVisible then
        triggerServerEvent("requestPlayerData", resourceRoot)
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

    dxDrawImage(panelX, panelY, panelWidth, panelHeight, background)
    
    local startY = panelY + 50
    local rowHeight = 40
    local maxRows = math.floor((panelHeight - 100) / rowHeight)

    for i = 1, maxRows do
        local index = i + math.floor(scrollY / rowHeight)
        local playerData = players[index]
        if playerData then
            local posY = startY + (i - 1) * rowHeight
            dxDrawText(
                playerData.id .. " | " .. playerData.nickname,  -- ← Dodajemy ID przed nickiem
                panelX + 20, posY,
                panelX + panelWidth - 40, posY + rowHeight,
                tocolor(255, 255, 255, 255), 1, "default-bold", "left", "center"
            )
        end
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
            local maxScroll = math.max(0, (#players * 40) - (panelHeight - 100))
            scrollY = math.min(scrollY + scrollSpeed, maxScroll)
        end
    end
end
bindKey("mouse_wheel_up", "down", scrollPlayerList)
bindKey("mouse_wheel_down", "down", scrollPlayerList)
