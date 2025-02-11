local markerFloorTexture = dxCreateTexture("marker_floor.png") 
local arrowTexture = dxCreateTexture("arrow.png") 

customMarkers = {} -- markerów

addEvent("onCustomMarkerHit", true)

function createCustomMarker(x, y, z, name)
    -- (obszar kolizji)
    local col = createColSphere(x, y, z, 1.5)

    table.insert(customMarkers, {x = x, y = y, z = z, name = name, col = col})

    addEventHandler("onColShapeHit", col, function(player)
        if getElementType(player) == "player" then
            triggerEvent("onCustomMarkerHit", root, player, name)
        end
    end)
end

function renderCustomMarkers()
    local time = getTickCount() / 500
    local scale = 1.5 + math.sin(time) * 0.2
    local arrowHeight = 1.5 + math.sin(time) * 0.3

    for _, marker in ipairs(customMarkers) do
        local x, y, z = marker.x, marker.y, marker.z - 0.95
        local arrowZ = z + 2.0 + arrowHeight

        dxDrawMaterialLine3D(x - scale, y, z, x + scale, y, z, markerFloorTexture, scale, tocolor(255, 255, 255, 255))

        dxDrawMaterialLine3D(x - 0.5, y, arrowZ, x + 0.5, y, arrowZ, arrowTexture, 1, tocolor(255, 255, 255, 255))
    end
end
addEventHandler("onClientRender", root, renderCustomMarkers)
