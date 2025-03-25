local radios = {
    {url = "", name = "RADIO OFF"},
    {url = "http://217.74.72.11:8000/rmf_maxxx", name = "RMF MAXXX"},
    {url = "https://playerservices.streamtheworld.com/api/livestream-redirect/RADIO_ZET.mp3", name = "Radio ZET"}
}

local font = exports.fonts:getFont("RobotoCondensed-Black", 10, false, "antialiased")

local currentRadioIndex = 1
local radioSound = nil
local screenW, screenH = guiGetScreenSize()
local isDisplayingText = false

function startRadio(index)
    if radioSound then
        stopSound(radioSound)
        radioSound = nil
    end
    
    currentRadioIndex = index or 1
    if radios[currentRadioIndex].url ~= "" then
        radioSound = playSound(radios[currentRadioIndex].url, false, true)
    end
    displayRadioText(radios[currentRadioIndex].name)
end

function switchRadio(direction)
    if getPedOccupiedVehicle(localPlayer) then
        if radioSound then
            stopSound(radioSound)
            radioSound = nil
        end
        
        currentRadioIndex = (currentRadioIndex + direction - 1) % #radios + 1
        startRadio(currentRadioIndex)
    end
end

function displayRadioText(text)
    isDisplayingText = text
    setTimer(function()
        isDisplayingText = false
    end, 3000, 1)
end

function drawRadioText()
    if isDisplayingText then
        dxDrawText(isDisplayingText, screenW/2, screenH/5, screenW/2, screenH/5, tocolor(255, 255, 255, 255), 1.5, font, "center", "center")
    end
end
addEventHandler("onClientRender", root, drawRadioText)

function onEnterVehicle()
    if source == localPlayer then
        startRadio(1) -- Start with RADIO OFF
    end
end
addEventHandler("onClientVehicleEnter", root, onEnterVehicle)

function onStartExitVehicle(ped, seat, door)
    if ped == localPlayer and radioSound and isElement(radioSound) then
        stopSound(radioSound)
        radioSound = nil
    end
end
addEventHandler("onClientVehicleStartExit", root, onStartExitVehicle)


bindKey("mouse_wheel_up", "down", function() switchRadio(1) end)
bindKey("mouse_wheel_down", "down", function() switchRadio(-1) end)
