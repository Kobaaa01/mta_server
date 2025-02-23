local rankColors = {
    ["Wlasciciel"] = {255, 0, 0},       -- Czerwony
    ["Admin"] = {255, 69, 0},           -- Pomarańczowy
    ["SuperModerator"] = {0, 191, 255}, -- Niebieski
    ["Moderator"] = {34, 139, 34},      -- Zielony
    ["JuniorModerator"] = {138, 43, 226}, -- Fioletowy
    ["Gold"] = {255, 215, 0},           -- Złoty
    ["Premium"] = {255, 140, 0}         -- Ciemnopomarańczowy
}

addEvent("onChatMessage", true)
addEventHandler("onChatMessage", root, function(player, playerID, nickname, rank, message, isOwner)
    if not isElement(player) then return end

    local r, g, b = 255, 255, 255 
    if rankColors[rank] then
        r, g, b = unpack(rankColors[rank])
    end

    if not isOwner then
        message = string.gsub(message, "#%x%x%x%x%x%x", "") 
    end

    outputChatBox(
        "#AAAAAA[" .. playerID .. "] " .. 
        "#" .. string.format("%02X%02X%02X", r, g, b) .. nickname .. 
        ": #FFFFFF" .. message, 
        255, 255, 255, true
    )
end)