function send_player_rank(player)
    local players_table = exports.players:getPlayersTable()
    local rank = nil

    for _, p in ipairs(players_table) do 
        if p.serial == getPlayerSerial(player) then
            rank = p.rank
        end
    end

    triggerClientEvent(player, "receive_player_rank", player, rank)
end
addEvent("send_player_rank", true)
addEventHandler("send_player_rank", root, send_player_rank)

function send_server_data(player)
    -- TODO Check permission
    local players_table = exports.players:getPlayersTable()
    local data = {}

    local players = {}
    for _, p in ipairs(players_table) do
        table.insert(players, {id = p.id, name = p.nickname, rank = p.rank})
    end
    data["players"] = players
    
    triggerClientEvent(player, "receive_server_data", player, data)
end
addEvent("send_server_data", true)
addEventHandler("send_server_data", root, send_server_data)

function handle_weather(params)
    local weather = params.weather
    local player = params.player
    -- TODO Check permission

    exports.admin_commands:changeWeatherCommand(player, "", weather)
end

function handle_announce(params)
    local title = params.title
    local text = params.text
    local time = params.time * 1000
    -- TODO Check permission

    exports.alerts:globalAlert({
        type = 1,
        title = title,
        text = text,
        time = time
    })
end
 
function handle_vehicle(params)
    local player = params.player
    local id = params.id
    -- TODO Check permission

    exports.admin_commands:spawnAdminVehicle(player, "", id)
end

function handle_alert(params)
    local player = params.player
    local title = params.title
    local text = params.text
    local target = tonumber(params.target)
    local time = params.time * 1000 
    -- TODO Check permission

    exports.alerts:sendAlert(exports.players:getPlayerByID(target).player, {
        type = 1,
        title = title,
        text = text,
        time = time
    })
end

function handle_fix(params)
    local player = params.player
    local target = tonumber(params.target)
    -- TODO Check permission

    exports.admin_commands:fixVehicleCommand(exports.players:getPlayerByID(target).player)
end

function handle_flip(params)
    local player = params.player
    local target = tonumber(params.target)
    -- TODO Check permission

    exports.admin_commands:flipVehicleCommand(exports.players:getPlayerByID(target).player)
end

local action_handlers = {
    weather = handle_weather,
    announce = handle_announce,
    vehicle = handle_vehicle,
    alert = handle_alert,
    fix = handle_fix,
    flip = handle_flip
}
  
function action(data)
    local action = data.action

    table.remove(data, 1)
    action_handlers[action](data)
end
addEvent("action", true)
addEventHandler("action", root, action)

