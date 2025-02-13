local arrowTexture = dxCreateTexture("arrow.png") 

customMarkers = {} -- Lista przechowująca markery

function createCustomMarker(x, y, z, name)
    outputDebugString("Tworzenie markera: " .. tostring(name) .. " (" .. x .. ", " .. y .. ", " .. z .. ")")
    
    if not name or type(name) ~= "string" then
        outputDebugString("Błąd: Niepoprawna nazwa markera!")
        return false
    end

    if customMarkers[name] then
        outputDebugString("Błąd: Marker o nazwie " .. name .. " już istnieje!")
        return false
    end

    local marker = createMarker(x, y, z, "cylinder", 1.5, 255, 255, 255, 255)  
    if not marker then
        outputDebugString("Błąd: Nie udało się utworzyć markera dla " .. name)
        return false
    end

	-- trzeba znalezc id nieuzywanego modelu w gta i podmienic go na nasz model i dac tutaj jego id gdzie jest teraz 675   
    local floorObject = createObject(675, x, y, z - 0.95)
    if not floorObject then
        outputDebugString("Błąd: Nie udało się utworzyć obiektu podłogi dla " .. name)
        destroyElement(marker)
        return false
    end

    setObjectScale(floorObject, 3.0)

    -- Dodanie markera do listy
    customMarkers[name] = {marker = marker, object = floorObject, x = x, y = y, z = z}

    return marker
end

function renderCustomMarkers()
    local time = getTickCount() / 500
    local arrowHeight = -1

    for name, markerData in pairs(customMarkers) do
        local x, y, z = markerData.x, markerData.y, markerData.z
        local arrowZ = z + 2.0 + arrowHeight

        if not arrowTexture then
            outputDebugString("Nie udało się wczytać arrow.png!")
        end

        -- Rysowanie strzałki
        local success = dxDrawMaterialLine3D(
            x, y, arrowZ + 0.5, 
            x, y, arrowZ - 0.5, 
            arrowTexture, 1, tocolor(255, 255, 255, 255))

        if not success then
            outputDebugString("Błąd rysowania strzałki na pozycji (" .. x .. ", " .. y .. ", " .. z .. ")")
        end
    end
end
addEventHandler("onClientPreRender", root, renderCustomMarkers)

function removeCustomMarker(name)
    if not name or type(name) ~= "string" then
        outputDebugString("Błąd: Niepoprawna nazwa markera!")
        return false
    end

    if not customMarkers[name] then
        outputDebugString("Błąd: Marker o nazwie " .. name .. " nie istnieje!")
        return false
    end

    local markerData = customMarkers[name]
    
    if isElement(markerData.marker) then
        destroyElement(markerData.marker)
    end

    if isElement(markerData.object) then
        destroyElement(markerData.object)
    end

    customMarkers[name] = nil
    outputDebugString("Usunięto marker: " .. name)

    return true
end

function handleDeleteMarkerCommand(cmd, name)
    if not name then
        outputChatBox("Użycie: /deletemarker <nazwa>", 255, 0, 0)
        return
    end

    if removeCustomMarker(name) then
        outputChatBox("Marker '" .. name .. "' został usunięty.", 0, 255, 0)
    else
        outputChatBox("Nie udało się usunąć markera '" .. name .. "'.", 255, 0, 0)
    end
end
addCommandHandler("deletemarker", handleDeleteMarkerCommand)

