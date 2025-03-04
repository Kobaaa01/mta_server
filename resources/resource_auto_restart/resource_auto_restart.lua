local resources_to_monitor = {}
local file_hashes = {}

local function init_file_hashes()
    for _, res in ipairs(getResources()) do
        if getResourceState(res) == "running" then
            local res_name = getResourceName(res)
            resources_to_monitor[res_name] = {}
            file_hashes[res_name] = {}

            local meta = xmlLoadFile(":" .. res_name .. "/meta.xml")
            if meta then
                local child_nodes = xmlNodeGetChildren(meta)
                if child_nodes then
                    for _, node in ipairs(child_nodes) do
                        local file_path = xmlNodeGetAttribute(node, "src")
                        if file_path then
                            table.insert(resources_to_monitor[res_name], file_path)
                        end
                    end
                end
                xmlUnloadFile(meta)
            end

            if #resources_to_monitor[res_name] > 0 then
                for _, file_path in ipairs(resources_to_monitor[res_name]) do
                    local file_path_full = ":" .. res_name .. "/" .. file_path
                    if fileExists(file_path_full) then
                        local success, file = pcall(fileOpen, file_path_full, true)
                        if success and file then
                            local size = fileGetSize(file) or 0
                            local data = fileRead(file, size) or ""
                            fileClose(file)
                            if data and #data > 0 then
                                file_hashes[res_name][file_path] = md5(data)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function check_for_changes()
    for res_name, files_table in pairs(file_hashes) do
        local res = getResourceFromName(res_name)
        if res and getResourceState(res) == "running" then
            for file_path, old_hash in pairs(files_table) do
                local file = fileOpen(":" .. res_name .. "/" .. file_path, true)
                if file then
                    local size = fileGetSize(file) or 0
                    local data = fileRead(file, size) or ""
                    fileClose(file)
                    local new_hash = md5(data or "")
                    if new_hash and old_hash and new_hash ~= old_hash then
                        outputServerLog("Resource '" .. res_name .. "' file changed: " .. file_path .. " (restarting resource)")
                        restartResource(res)
                        file_hashes[res_name][file_path] = new_hash
                        exports.alerts:globalAlert({
                            type = 1,
                            title = "Resource restarter",
                            text = "Resource " .. res_name .. " restarted",
                            time = 3000
                        })
                    end
                else
                    outputDebugString("File " .. file_path .. " in resource " .. res_name .. " is inaccessible.")
                    file_hashes[res_name][file_path] = nil
                end
            end
        end
    end
end

addEventHandler("onResourceStart", resourceRoot, function()
    init_file_hashes()
    setTimer(check_for_changes, 2000, 0)
    local function table_length(T)
        local count = 0
        for _ in pairs(T) do count = count + 1 end
        return count
    end
    outputDebugString("File change monitor initialized. Monitoring " .. tostring(table_length(file_hashes)) .. " resources.")
end)
