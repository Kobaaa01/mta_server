function sendAlert(player, alert)
    triggerClientEvent(player, "alert", player, alert)
end

function globalAlert(alert)
    triggerClientEvent(root, "alert", root, alert)
end
addEvent("globalAlert", true)
addEventHandler("globalAlert", root, globalAlert)
