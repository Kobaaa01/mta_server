function disableHUDOnJoin()
    -- Wysyłanie zdarzenia do klienta, aby ukrył HUD i zablokował strzały
    triggerClientEvent(source, "disableHUD", source)
end

-- Dodanie obsługi eventu onPlayerJoin, aby uruchomić funkcję po wejściu gracza
addEventHandler("onPlayerJoin", root, disableHUDOnJoin)
