local is_panel_open = false
local can_access_panel = false
local is_browser_ready = false

local server_data = nil
local user_rank = nil

local screen_w, screen_h = guiGetScreenSize()
local browser_w = screen_w * 0.8
local browser_h = screen_h * 0.8
local browser_x = (screen_w - browser_w) / 2
local browser_y = (screen_h - browser_h) / 2
local browser = guiCreateBrowser(0, 0, 1, 1, true, false, true)
local theBrowser = guiGetBrowser(browser)
guiSetVisible(browser, false)

function receive_player_rank_player(rank)
    if user_rank then return end

    local bool = executeBrowserJavascript(theBrowser, "updateRank(" .. rank .. ");")

    user_rank = rank
    toggle_panel_opened_state()
end
addEvent("receive_player_rank_player", true)
addEventHandler("receive_player_rank_player", root, receive_player_rank_player)

function onClientBrowserCreated()
    loadBrowserURL(theBrowser, "http://mta/local/index.html")
    is_browser_ready = true
end
addEventHandler("onClientBrowserCreated", theBrowser, onClientBrowserCreated)

function toggle_panel_opened_state()
    if not user_rank then
        triggerServerEvent("send_player_rank_player", root, getLocalPlayer())
        return
    end
 
    is_panel_open = not is_panel_open
    guiSetVisible(browser, is_panel_open)
    showChat(not is_panel_open)
    showCursor(is_panel_open)
    setCursorPosition(screen_w / 2, screen_h / 2)
end
bindKey("f1", "down", toggle_panel_opened_state)

 