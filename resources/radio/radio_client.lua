local radioURL = "http://217.74.72.11:8000/rmf_maxxx"
local radioSound = nil

function startRadio()
    -- Sprawdź, czy strumień już nie jest odtwarzany
    if radioSound then
        outputChatBox("Radio is already playing!", 255, 0, 0)
        return
    end

    radioSound = playSound(radioURL, false, true)
    if radioSound then
        outputDebugString("Gra")
    else
        outputChatBox("Failed to start radio stream!", 255, 0, 0)
    end
end

function stopRadio()
    if radioSound then
        stopSound(radioSound)
        radioSound = nil
        outputDebugString("Nie gra")
    else
        outputChatBox("No radio stream is playing!", 255, 0, 0)
    end
end

addCommandHandler("startradio", startRadio)
addCommandHandler("stopradio", stopRadio)
