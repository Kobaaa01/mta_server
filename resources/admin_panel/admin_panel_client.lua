local is_panel_open = false
local can_access_panel = false
local is_browser_ready = false

local allowed_ranks = {
    "Wlasciciel",
    "Admin",
    "SuperModerator",
    "Moderator",
    "JuniorModerator"
}

function is_rank_allowed(rank)
    for _, r in ipairs(allowed_ranks) do
        if r == rank then
            return true
        end
    end
    return false
end

--[[
Param types:
                  Input type                  Default values
 - text         - string                    - ""
 - long-text    - string                    - ""
 - number       - dowolna liczba            - nil
 - number-range - range liczb               - min z zakresu
 - player       - list graczy online        - localPlayer
 - dropdown     - lista                     - pierwsza opcja
--]]

function receive_player_rank(rank)
    if is_rank_allowed(rank) then
        can_access_panel = true
    end
end
addEvent("receive_player_rank", true)
addEventHandler("receive_player_rank", root, receive_player_rank)

function action(data)
    data = fromJSON(data)
    data["player"] = getLocalPlayer()
    triggerServerEvent("action", root, data)
end
addEvent("action", true)
addEventHandler("action", root, action)

local screen_w, screen_h = guiGetScreenSize()
local browser_w = screen_w * 0.8
local browser_h = screen_h * 0.8
local browser_x = (screen_w - browser_w) / 2
local browser_y = (screen_h - browser_h) / 2
local browser = guiCreateBrowser(0.1, 0.1, 0.8, 0.8, true, true, true)
local theBrowser = guiGetBrowser(browser)
guiSetVisible(browser, false)

function onClientBrowserCreated()
    loadBrowserURL(theBrowser, "http://mta/local/index.html")
    is_browser_ready = true
end
addEventHandler("onClientBrowserCreated", theBrowser, onClientBrowserCreated)

function onClientResourceStart()
    triggerServerEvent("send_player_rank", root, getLocalPlayer())
end
addEventHandler("onClientResourceStart", root, onClientResourceStart)

function toggle_panel_opened_state()
    if not can_access_panel then return end

    is_panel_open = not is_panel_open
    guiSetVisible(browser, is_panel_open)
    showChat(not is_panel_open)
    showCursor(is_panel_open)
    setCursorPosition(screen_w / 2, screen_h / 2)
end
bindKey("f2", "down", toggle_panel_opened_state)

function onClientRender()
    if not is_browser_ready or not can_access_panel or not is_panel_open then return end

    dxDrawRectangle(0, 0, screen_w, screen_h, tocolor(0, 0, 0, 150))
end
addEventHandler("onClientRender", root, onClientRender)
