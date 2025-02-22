local alertTypes = {
    { name = "info", color = tocolor(123, 154, 255) },
    { name = "success", color = tocolor(23, 235, 55) },
    { name = "warning", color = tocolor(217, 235, 23) },
    { name = "error", color = tocolor(235, 44, 23) }
}

local alert_bar_capacity = 3

-- GUI Setup
local screenW, screenH = guiGetScreenSize()
local alert_width = screenH * 0.35
local alert_height = screenH * 0.1
local alert_margin = 20
local alert_bar_x = screenW / 2 - alert_width / 2
local alert_bar_y = screenH
local alert_line_width = 4
local alert_padding = 5

local alert_queue = {}
local last_tick = getTickCount()

function decrease_time()
    if #alert_queue == 0 then return end

    local now = getTickCount()
    
    local alert = alert_queue[1]
    alert.time = alert.time - (now - last_tick)
    if alert.time <= 0 then
        table.remove(alert_queue, 1)
    end

    last_tick = getTickCount()
end

function add_alert_to_queue(type, title, text, time)
    local alert = {
        type = type,
        title = title,
        text = text,
        time = time,
        initialTime = time
    }

    if #alert_queue == 0 then last_tick = getTickCount() end
    table.insert(alert_queue, alert)
end

local alert_title_font = exports.fonts:getFont("RobotoCondensed-Black", 9)
local alert_text_font = exports.fonts:getFont("RobotoCondensed-Bold", 9)

-- Rysuje alerty
function onClientRender()
    for i, alert in ipairs(alert_queue) do
        if i > alert_bar_capacity then break end

        local alert_color = alertTypes[alert.type].color
        if not alert_color then
            outputDebugString("Invalid alert type", 2)
            return
        end
        local alertY = alert_bar_y - (alert_height + alert_margin) * i

        -- Background
        dxDrawRectangle(alert_bar_x, alertY, alert_width, alert_height, tocolor(80, 80, 80, 200))
        
        -- Time
        dxDrawLine(alert_bar_x, alertY + alert_line_width / 2, alert_bar_x + alert_width * (alert.time / alert.initialTime), alertY + alert_line_width / 2, alert_color, alert_line_width)
        
        -- Title
        dxDrawText(alert.title, 
            alert_bar_x + alert_padding, 
            alertY + alert_line_width + alert_padding, 
            alert_bar_x + alert_width - alert_padding, 
            alertY + alert_line_width + alert_padding + 15, tocolor(255, 255, 255), 1, alert_title_font, "left", "top", false, false, false)
        
        -- Text / body
        dxDrawText(alert.text, 
        alert_bar_x + alert_padding, 
        alertY + alert_line_width + alert_padding * 2 + 15, 
        alert_bar_x + alert_width - alert_padding, 
        alertY + alert_height - alert_padding, tocolor(200, 200, 200), 1, alert_text_font, "left", "top", true, true, false)

        -- Outline
        dxDrawLine(alert_bar_x, alertY, alert_bar_x + alert_width, alertY, alert_color, 1) -- Top
        dxDrawLine(alert_bar_x, alertY + alert_height, alert_bar_x + alert_width, alertY + alert_height, alert_color, 1) -- Bottom
        dxDrawLine(alert_bar_x, alertY, alert_bar_x, alertY + alert_height, alert_color, 1) -- Left
        dxDrawLine(alert_bar_x + alert_width, alertY, alert_bar_x + alert_width, alertY + alert_height, alert_color, 1) -- Right
    end

    decrease_time()
end

-- Event handler odbieranie alertów z serwera
function receive_alert(alert)
    if not alert then return end
    if not alert.type or 
       not alert.title or 
       not alert.text or 
       not alert.time then
        outputDebugString("Invalid or missing alert data", 2)
    end

    add_alert_to_queue(alert.type, alert.title, alert.text, alert.time)
end
addEvent("alert", true)

addEventHandler("alert", root, receive_alert)
addEventHandler("onClientRender", root, onClientRender, true, "low-5")
