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
addEventHandler("onChatMessage", root, function(player, prefix, nickname, message)
    if not isElement(player) then return end

    local rank = getElementData(player, "rank") or "Gracz"
    local r, g, b = 255, 255, 255 -- Domyślny kolor nicku

    if rankColors[rank] then
        r, g, b = unpack(rankColors[rank])
    end

    outputChatBox(prefix .. " " .. nickname .. ": #FFFFFF" .. message, r, g, b, true)
end)
