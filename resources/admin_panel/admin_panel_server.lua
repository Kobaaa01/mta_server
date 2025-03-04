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

function handle_weather(params)
    local weather = params.weather
    local player = params.player

    exports.admin_commands:changeWeatherCommand(player, "", weather)
end

function handle_announce(params)
    local title = params.title
    local text = params.text
    local time = params.time * 1000

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

    exports.admin_commands:spawnAdminVehicle(player, "", id)
end

local action_handlers = {
    weather = handle_weather,
    announce = handle_announce,
    vehicle = handle_vehicle
}
  
function action(data)
    local action = data.action

    table.remove(data, 1)
    action_handlers[action](data)
end
addEvent("action", true)
addEventHandler("action", root, action)

