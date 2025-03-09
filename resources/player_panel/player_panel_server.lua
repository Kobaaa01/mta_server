function send_player_rank_player(player)
    local players_table = exports.players:getPlayersTable()
    local rank = nil

    for _, p in ipairs(players_table) do 
        if p.serial == getPlayerSerial(player) then
            rank = p.rank
        end
    end

    triggerClientEvent(player, "receive_player_rank_player", player, rank)
end
addEvent("send_player_rank_player", true)
addEventHandler("send_player_rank_player", root, send_player_rank_player)
