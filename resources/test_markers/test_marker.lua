-- testowa / przyklad uzycia
local marker = exports.markers:createCustomMarker(0, 0, 3, "testowy", 255)

if marker then
    outputDebugString("Marker został pomyślnie utworzony!")
else
    outputDebugString("Błąd podczas tworzenia markera!")
end

local marker = exports.markers:createCustomMarker(0, 25, 3, "testowy2", 254)

if marker then
    outputDebugString("Marker został pomyślnie utworzony!")
else
    outputDebugString("Błąd podczas tworzenia markera!")
end

local marker = exports.markers:createCustomMarker(30, 0, 3, "testowy3", 253)

if marker then
    outputDebugString("Marker został pomyślnie utworzony!")
else
    outputDebugString("Błąd podczas tworzenia markera!")
end

local marker = exports.markers:createCustomMarker(50, 35, 3, "testowy4", 252)

if marker then
    outputDebugString("Marker został pomyślnie utworzony!")
else
    outputDebugString("Błąd podczas tworzenia markera!")
end

local marker = exports.markers:createCustomMarker(25, 25, 3, "testowy5", 251)

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