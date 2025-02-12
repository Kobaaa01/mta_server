local markerFloorTexture = dxCreateTexture("marker_floor.png") 
local arrowTexture = dxCreateTexture("arrow.png") 

customMarkers = {} -- Lista przechowująca markery

function createCustomMarker(x, y, z, name)
    outputDebugString("Tworzenie markera: " .. tostring(name) .. " (" .. x .. ", " .. y .. ", " .. z .. ")")
    
    -- Sprawdzenie, czy nazwa jest poprawna
    if not name or type(name) ~= "string" then
        outputDebugString("Błąd: Niepoprawna nazwa markera!")
        return false
    end

    -- Sprawdzenie, czy marker o tej nazwie już istnieje
    if customMarkers[name] then
        outputDebugString("Błąd: Marker o nazwie " .. name .. " już istnieje!")
        return false
    end

    local marker = createMarker(x, y, z, "cylinder", 1.5, 255, 255, 255, 255)  
    if not marker then
        outputDebugString("Błąd: Nie udało się utworzyć markera dla " .. name)
        return false
    end

    -- Dodanie markera do listy
    customMarkers[name] = {marker = marker, x = x, y = y, z = z}

    return marker
end

-- Funkcja do renderowania markerów
function renderCustomMarkers()
    local time = getTickCount() / 500
    local scale = 1 + math.sin(time) * 0.2
    local arrowHeight = -1

    for name, markerData in pairs(customMarkers) do
        local x, y, z = markerData.x, markerData.y, markerData.z - 0.95
        local arrowZ = z + 2.0 + arrowHeight

        if not markerFloorTexture then
            outputDebugString("Nie udało się wczytać marker_floor.png!")
        end
        if not arrowTexture then
            outputDebugString("Nie udało się wczytać arrow.png!")
        end

        -- Rysowanie tekstury podłogi
        local success1 = dxDrawMaterialLine3D(
            x - scale, y, z,   
            x + scale, y, z,   
            markerFloorTexture, scale * 2, tocolor(255, 255, 255, 255))
        
        -- Rysowanie strzałki
        local success2 = dxDrawMaterialLine3D(
            x, y, arrowZ + 0.5, 
            x, y, arrowZ - 0.5, 
            arrowTexture, 1, tocolor(255, 255, 255, 255))

        if not success1 or not success2 then
            outputDebugString("Błąd rysowania markera na pozycji (" .. x .. ", " .. y .. ", " .. z .. ")")
        end
    end
end
addEventHandler("onClientPreRender", root, renderCustomMarkers)