local graphID = 0

function onResourceStart()
    if not loadPathGraph then
		outputServerLog("GPS module not loaded. Continuing without...", 2)
		return
	end

    graphID = loadPathGraph("./sa_nodes.json")
    outputServerLog("Graph in use: " .. graphID)

    local node = findNodeAt(graphID, 0, 0, 0)
end
addEventHandler("onResourceStart", root, onResourceStart)

function onResourceStop()
    if unloadPathGraph then
		unloadPathGraph(graphID)
	end
end
addEventHandler("onResourceStop", root, onResourceStop)

function getPath(player, x1, y1, z1, x2, y2, z2)
    if not findShortestPathBetween or not findNodeAt then
		return false
	end

    function onPathFound(path)
        triggerClientEvent(player, "pathFound", player, path)
    end

	return findShortestPathBetween(graphID, x1, y1, z1, x2, y2, z2, onPathFound)
end
addEvent("getPath", true)
addEventHandler("getPath", root, getPath)


