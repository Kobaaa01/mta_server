
addEventHandler("onClientResourceStart", resourceRoot, function()
    createCustomMarker(5, 5, 10, "Testowy Marker")
end)

addEventHandler("onCustomMarkerHit", root, function(player, name)
    if name == "Testowy Marker" then
        outputChatBox("✅ Wszedłeś w testowy marker!", player, 0, 255, 0)
    end
end)
