function spawnTestVehicle(player)
    local x, y, z = getElementPosition(player)
    local vehicle = createVehicle(411, x + 2, y, z)

    warpPedIntoVehicle(player, vehicle)

end

addCommandHandler("testveh", spawnTestVehicle)

-- Blokuj wybuchy wszystkich pojazdów
addEventHandler("onVehicleExplode", root, function()
    cancelEvent()
    setElementHealth(source, 270) -- Przywróć minimalne HP
end)

-- Ustaw pojazdy jako "niezniszczalne" po osiągnięciu 270 HP
addEventHandler("onVehicleDamage", root, function()
    if getElementHealth(source) < 270 then
        setElementHealth(source, 270)
        setVehicleDamageProof(source, true) -- Blokuj dalsze uszkodzenia
    else
        setVehicleDamageProof(source, false) -- Zezwalaj na uszkodzenia powyżej 300 HP
    end
end)

-- returning if car is empty
local function is_car_empty(veh)
    local occupants = getVehicleOccupants(veh)
    local seats = getVehicleMaxPassengers(veh)
    if (not seats) then
        return true
    end
    for i = 0, seats do
        local occupant = occupants[i]
        if occupant and (getElementType(occupant) == "player" or getElementType(occupant) == "ped") then
            return false
        end
    end
    return true
end

-- is vehicle not occupied then its damageproof
addEventHandler("onPlayerVehicleExit", root, function(vehicle, seat)
    if is_car_empty(vehicle) then
        setVehicleDamageProof(vehicle, true)
    end
end)

-- if vehicle occupied then its damageable
addEventHandler("onPlayerVehicleEnter", root, function(vehicle, seat)
    setVehicleDamageProof(vehicle, false)
end)

-- initialization of cars' state after restart
addEventHandler("onResourceStart", resourceRoot, function()
    for i, v in ipairs(getElementsByType("vehicle")) do
        if is_car_empty(v) then
            setVehicleDamageProof(v, true)
        else
            setVehicleDamageProof(v, false)
        end
    end
end)

function setVehicleSpeedLimit(vehicle, speed)
    if isElement(vehicle) and getElementType(vehicle) == "vehicle" then
        setElementData(vehicle, "speedLimit", speed, true)
        local player = getVehicleController(vehicle)
        if player then
            exports.alerts:sendAlert(player, 
            { type = 1, 
            title = "Limit prędkości", 
            text = "Ustawiono limit prędkości na " .. speed .. " km/h.", 
            time = 2000 })
        end
    end
end

function removeVehicleSpeedLimit(vehicle)
    if isElement(vehicle) and getElementType(vehicle) == "vehicle" then
        setElementData(vehicle, "speedLimit", nil, true)
    end
end

addEvent("onPlayerRequestSpeedLimitChange", true)
addEventHandler("onPlayerRequestSpeedLimitChange", root, function()
    local player = client
    local vehicle = getPedOccupiedVehicle(player)

    if vehicle then
        local currentLimit = getElementData(vehicle, "speedLimit")
        local newLimit = nil

        if currentLimit == nil then
            newLimit = 130
        elseif currentLimit == 130 then
            newLimit = 90
        elseif currentLimit == 90 then
            newLimit = 50
        elseif currentLimit == 50 then
            newLimit = 20
        elseif currentLimit == 20 then
            newLimit = nil
        end

        if newLimit then
            setVehicleSpeedLimit(vehicle, newLimit)
        else
            removeVehicleSpeedLimit(vehicle)
        end
    end
end)