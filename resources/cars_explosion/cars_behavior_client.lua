addEventHandler("onClientVehicleDamage", root, function()
    local hp = getElementHealth(source)
    if hp < 270 then
        setElementHealth(source, 270)
        setVehicleDamageProof(source, true)
    end
end)
