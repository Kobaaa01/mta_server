function syncTimeFromServer()
    local timeData = getRealTime() 
    local hour = timeData.hour
    local minute = timeData.minute

    setTime(hour, minute)
    setMinuteDuration(99999999)

end

setTimer(syncTimeFromServer, 60000, 0)

addEventHandler("onResourceStart", resourceRoot, syncTimeFromServer)
