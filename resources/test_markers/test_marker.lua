-- testowa / przyklad uzycia
local marker = exports.markers:createCustomMarker(0, 0, 3, "testowy")

if marker then
    outputDebugString("Marker został pomyślnie utworzony!")
else
    outputDebugString("Błąd podczas tworzenia markera!")
end

addEventHandler("onClientMarkerHit", marker, function(hitPlayer, matchingDimension)
    if hitPlayer == localPlayer and matchingDimension then
        setElementPosition(hitPlayer, 20, 20, 3)
        outputChatBox("Zostałeś przeteleportowany!", 0, 255, 0)
    end
end)