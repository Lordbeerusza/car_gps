local QBCore = exports['qb-core']:GetCoreObject()
local vehiclePositions = {}

RegisterServerEvent("tracker:install")
AddEventHandler("tracker:install", function(plate, isPermanent)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    plate = string.upper(string.gsub(plate, "%s+", ""))

    exports.oxmysql:execute('SELECT * FROM player_vehicles WHERE plate = ?', {plate}, function(result)
        if result[1] and result[1].citizenid == Player.PlayerData.citizenid then
            local gpsColumn = isPermanent and "perm_gps" or "gps_installed"
            if tonumber(result[1][gpsColumn]) == 1 then
                TriggerClientEvent("tracker:notify", src, "✅ This vehicle already has a Tracker.")
                return
            end

            if not isPermanent then
                local gpsItem = Player.Functions.GetItemByName("gps")
                if not gpsItem or gpsItem.amount < 1 then
                    TriggerClientEvent("tracker:notify", src, "❌ You need a Tracker device to install.")
                    return
                end
                Player.Functions.RemoveItem("gps", 1)
                TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items["gps"], "remove")
            end

            exports.oxmysql:execute('UPDATE player_vehicles SET ' .. gpsColumn .. ' = 1 WHERE plate = ?', {plate}, function()
                local veh = GetVehiclePedIsIn(GetPlayerPed(src), false)
                if veh ~= 0 then
                    local coords = GetEntityCoords(veh)
                    vehiclePositions[plate] = coords
                    exports.oxmysql:execute('UPDATE player_vehicles SET gps_last_x = ?, gps_last_y = ?, gps_last_z = ? WHERE plate = ?', {
                        coords.x, coords.y, coords.z, plate
                    })
                end

                TriggerClientEvent("tracker:installed", src, plate)
                TriggerClientEvent("tracker:updatePlates", src, GetPlatesForPlayer(Player.PlayerData.citizenid))
            end)
        else
            TriggerClientEvent("tracker:notify", src, "❌ You do not own this vehicle.")
        end
    end)
end)

RegisterCommand("removegps", function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end

    local ped = GetPlayerPed(source)
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then
        TriggerClientEvent("tracker:notify", source, "❌ You must be in a vehicle.")
        return
    end

    local plate = string.upper(string.gsub(GetVehicleNumberPlateText(veh), "%s+", ""))

    exports.oxmysql:execute('SELECT * FROM player_vehicles WHERE citizenid = ? AND gps_installed = 1', {Player.PlayerData.citizenid}, function(result)
        local found = false
        for _, row in pairs(result) do
            local dbPlate = string.upper(string.gsub(row.plate, "%s+", ""))
            if dbPlate == plate then
                found = true
                exports.oxmysql:execute('UPDATE player_vehicles SET gps_installed = 0 WHERE plate = ?', {row.plate})
                TriggerClientEvent("tracker:notify", source, "🧰 Tracker removed from vehicle [" .. row.plate .. "]")
                TriggerClientEvent("tracker:updatePlates", source, GetPlatesForPlayer(Player.PlayerData.citizenid))
                vehiclePositions[dbPlate] = nil
                break
            end
        end

        if not found then
            TriggerClientEvent("tracker:notify", source, "❌ This vehicle has no GPS installed or is not registered under you.")
        end
    end)
end)

RegisterNetEvent("tracker:updateVehiclePositions")
AddEventHandler("tracker:updateVehiclePositions", function(vehicles)
    for _, v in ipairs(vehicles) do
        local plate = string.upper(string.gsub(v.plate, "%s+", ""))
        vehiclePositions[plate] = v.coords
        exports.oxmysql:execute('UPDATE player_vehicles SET gps_last_x = ?, gps_last_y = ?, gps_last_z = ? WHERE plate = ?', {
            v.coords.x, v.coords.y, v.coords.z, plate
        })
    end
end)

RegisterServerEvent("tracker:findVehicle")
AddEventHandler("tracker:findVehicle", function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cleanPlate = string.upper(string.gsub(plate, "%s+", ""))

    exports.oxmysql:execute('SELECT * FROM player_vehicles WHERE citizenid = ? AND (gps_installed = 1 OR perm_gps = 1)', {
        Player.PlayerData.citizenid
    }, function(result)
        local matched = false

        for _, v in pairs(result) do
            local dbPlate = string.upper(string.gsub(v.plate, "%s+", ""))
            if dbPlate == cleanPlate then
                matched = true

                local coords = vehiclePositions[cleanPlate]
                if not coords and v.gps_last_x and v.gps_last_y and v.gps_last_z then
                    coords = vector3(v.gps_last_x, v.gps_last_y, v.gps_last_z)
                    vehiclePositions[cleanPlate] = coords
                end

                if coords then
                    TriggerClientEvent("tracker:setWaypoint", src, coords)
                    TriggerClientEvent("tracker:notify", src, "📍 Tracker: Vehicle location added to your map.")
                else
                    TriggerClientEvent("tracker:notify", src, "❌ Tracker: No recent location found for this vehicle.")
                end
                break
            end
        end

        if not matched then
            TriggerClientEvent("tracker:notify", src, "❌ This vehicle no longer has GPS installed or isn’t registered under you.")
        end
    end)
end)

function GetPlatesForPlayer(citizenid)
    local plates = {}
    local result = exports.oxmysql:executeSync([[SELECT plate FROM player_vehicles WHERE citizenid = ? AND (gps_installed = 1 OR perm_gps = 1)]], {citizenid})
    for _, v in pairs(result) do
        table.insert(plates, string.upper(string.gsub(v.plate, "%s+", "")))
    end
    return plates
end

RegisterNetEvent("tracker:playerJoined")
AddEventHandler("tracker:playerJoined", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    exports.oxmysql:execute('SELECT plate, gps_last_x, gps_last_y, gps_last_z FROM player_vehicles WHERE citizenid = ? AND (gps_installed = 1 OR perm_gps = 1)', {
        Player.PlayerData.citizenid
    }, function(result)
        for _, row in ipairs(result) do
            local plate = string.upper(string.gsub(row.plate, "%s+", ""))
            if row.gps_last_x and row.gps_last_y and row.gps_last_z then
                vehiclePositions[plate] = vector3(row.gps_last_x, row.gps_last_y, row.gps_last_z)
            else
                vehiclePositions[plate] = nil
            end
        end

        TriggerClientEvent("tracker:updatePlates", src, GetPlatesForPlayer(Player.PlayerData.citizenid))
    end)
end)
