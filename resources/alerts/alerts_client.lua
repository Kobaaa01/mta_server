local alertTypes = {
    { name = "info", color = tocolor(123, 154, 255) },
    { name = "success", color = tocolor(23, 235, 55) },
    { name = "warning", color = tocolor(217, 235, 23) },
    { name = "error", color = tocolor(235, 44, 23) }
}

local alertBarCapacity = 3

-- GUI Setup
local screenW, screenH = guiGetScreenSize()
local alertWidth = screenH * 0.35
local alertHeight = screenH * 0.1
local alertMargin = 20
local alertBarX = screenW / 2 - alertWidth / 2
local alertBarY = screenH
local alertLineWidth = 4
local alertPadding = 5

local alertQueue = {}
local lastTick = getTickCount()

function decreaseTime()
    if #alertQueue == 0 then return end

    local now = getTickCount()
    
    local alert = alertQueue[1]
    alert.time = alert.time - (now - lastTick)
    if alert.time <= 0 then
        table.remove(alertQueue, 1)
    end

    lastTick = getTickCount()
end

function addAlertToQueue(type, title, text, time)
    local alert = {
        type = type,
        title = title,
        text = text,
        time = time,
        initialTime = time
    }

    if #alertQueue == 0 then lastTick = getTickCount() end
    table.insert(alertQueue, alert)
end

local alertTitleFont = exports.fonts:getFont("RobotoCondensed-Black", 9)
local alertTextFont = exports.fonts:getFont("RobotoCondensed-Bold", 9)

-- Rysuje alerty
function drawAlerts()
    for i, alert in ipairs(alertQueue) do
        if i > alertBarCapacity then break end

        local alertColor = alertTypes[alert.type].color
        if not alertColor then
            outputDebugString("Invalid alert type", 2)
            return
        end
        local alertY = alertBarY - (alertHeight + alertMargin) * i

        -- Background
        dxDrawRectangle(alertBarX, alertY, alertWidth, alertHeight, tocolor(80, 80, 80, 200))
        
        -- Time
        dxDrawLine(alertBarX, alertY + alertLineWidth / 2, alertBarX + alertWidth * (alert.time / alert.initialTime), alertY + alertLineWidth / 2, alertColor, alertLineWidth)
        
        -- Title
        dxDrawText(alert.title, 
            alertBarX + alertPadding, 
            alertY + alertLineWidth + alertPadding, 
            alertBarX + alertWidth - alertPadding, 
            alertY + alertLineWidth + alertPadding + 15, tocolor(255, 255, 255), 1, alertTitleFont, "left", "top", false, false, false)
        
        -- Text / body
        dxDrawText(alert.text, 
        alertBarX + alertPadding, 
        alertY + alertLineWidth + alertPadding * 2 + 15, 
        alertBarX + alertWidth - alertPadding, 
        alertY + alertHeight - alertPadding, tocolor(200, 200, 200), 1, alertTextFont, "left", "top", true, true, false)

        -- Outline
        dxDrawLine(alertBarX, alertY, alertBarX + alertWidth, alertY, alertColor, 1) -- Top
        dxDrawLine(alertBarX, alertY + alertHeight, alertBarX + alertWidth, alertY + alertHeight, alertColor, 1) -- Bottom
        dxDrawLine(alertBarX, alertY, alertBarX, alertY + alertHeight, alertColor, 1) -- Left
        dxDrawLine(alertBarX + alertWidth, alertY, alertBarX + alertWidth, alertY + alertHeight, alertColor, 1) -- Right
    end

    decreaseTime()
end

-- Event handler odbieranie alertów z serwera
function receiveAlert(alert)
    if not alert then return end
    if not alert.type or 
       not alert.title or 
       not alert.text or 
       not alert.time then
        outputDebugString("Invalid or missing alert data", 2)
    end

    addAlertToQueue(alert.type, alert.title, alert.text, alert.time)
end
addEvent("alert", true)

addEventHandler("alert", root, receiveAlert)
addEventHandler("onClientRender", root, drawAlerts)
