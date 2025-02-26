function disableHUD()
    -- Wyłączenie nazwy obszaru i radaru
    setPlayerHudComponentVisible("area_name", false)
    setPlayerHudComponentVisible("radar", false)
    
    -- Wyłączenie możliwości zadawania obrażeń
    toggleControl("fire", false)
    toggleControl("aim_weapon", false)
    toggleControl("vehicle_fire", false)
    toggleControl("heli_fire", false)
    toggleControl("plane_fire", false)
  	toggleControl("radar", false) 
end

-- Dodanie obsługi zdarzenia
addEvent("disableHUD", true)
addEventHandler("disableHUD", root, disableHUD)
