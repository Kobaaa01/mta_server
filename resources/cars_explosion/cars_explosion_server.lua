function spawnTestVehicle(player)
    local x, y, z = getElementPosition(player)
    local vehicle = createVehicle(411, x + 2, y, z) 
    
    warpPedIntoVehicle(player, vehicle)
    setElementData(vehicle, "deleteOnExit", true)
    
    addEventHandler("onVehicleExit", vehicle, function(player, seat)
        if getElementData(source, "deleteOnExit") then
            destroyElement(source) 
        end
    end)
end

addCommandHandler("testveh", spawnTestVehicle)

-- Blokuj wybuchy wszystkich pojazdów
addEventHandler("onVehicleExplode", root, 
    function()
        cancelEvent()
        setElementHealth(source, 270) -- Przywróć minimalne HP
    end
)

-- Ustaw pojazdy jako "niezniszczalne" po osiągnięciu 270 HP
addEventHandler("onVehicleDamage", root,
    function()
        if getElementHealth(source) < 270 then
            setElementHealth(source, 270)
            setVehicleDamageProof(source, true) -- Blokuj dalsze uszkodzenia
        else
            setVehicleDamageProof(source, false) -- Zezwalaj na uszkodzenia powyżej 300 HP
        end
    end
)