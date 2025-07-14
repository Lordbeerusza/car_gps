local trackedPlates = {}

RegisterNetEvent("tracker:notify", function(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, true)
end)

RegisterNetEvent("tracker:updatePlates")
AddEventHandler("tracker:updatePlates", function(plates)
    trackedPlates = {}
    for _, plate in pairs(plates) do
        table.insert(trackedPlates, string.upper(string.gsub(plate, "%s+", "")))
    end

    if #trackedPlates == 0 then
        SetNuiFocus(false, false)
        SendNUIMessage({ action = "close" })
        TriggerEvent("tracker:notify", "❌ You have no vehicles with a Tracker installed.")
    end
end)

RegisterNetEvent("tracker:installed", function(plate)
    TriggerEvent("tracker:notify", "✅ Tracker installed on vehicle [" .. plate .. "]")
end)

RegisterCommand("installgps", function(_, args)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    local isPermanent = args[1] == "perm"
    if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
        local plate = GetVehicleNumberPlateText(veh)
        TriggerServerEvent("tracker:install", plate, isPermanent)
    else
        TriggerEvent("tracker:notify", "❌ You must be in the driver seat to install the tracker.")
    end
end)

RegisterCommand("gps", function()
    if #trackedPlates == 0 then
        TriggerEvent("tracker:notify", "❌ You have no vehicles with a tracker installed.")
        SetNuiFocus(false, false)
        SendNUIMessage({ action = "close" })
    else
        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "open",
            plates = trackedPlates
        })
    end
end)

RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
    cb("ok")
end)

RegisterNUICallback("trackVehicle", function(data, cb)
    local plate = string.upper(string.gsub(data.plate, "%s+", ""))
    TriggerServerEvent("tracker:findVehicle", plate)
    cb("ok")
end)

RegisterNetEvent("tracker:setWaypoint")
AddEventHandler("tracker:setWaypoint", function(coords)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 161)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 0.9)
    SetBlipColour(blip, 3)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Tracked Vehicle")
    EndTextCommandSetBlipName(blip)
    TriggerEvent("tracker:notify", "📍 Tracker: Blip added on your map.")

    SetTimeout(30000, function()
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end)
end)

function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, veh = FindFirstVehicle()
        if not handle or handle == -1 then return end
        local success
        repeat
            coroutine.yield(veh)
            success, veh = FindNextVehicle(handle)
        until not success
        EndFindVehicle(handle)
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)

        local PlayerPed = PlayerPedId()
        if not DoesEntityExist(PlayerPed) then
            Citizen.Wait(1000)
            goto continue
        end

        local vehiclesToReport = {}

        for vehicle in EnumerateVehicles() do
            if DoesEntityExist(vehicle) and IsVehicleDriveable(vehicle, false) then
                local plate = string.upper(string.gsub(GetVehicleNumberPlateText(vehicle), "%s+", ""))
                for _, p in pairs(trackedPlates) do
                    if p == plate then
                        local coords = GetEntityCoords(vehicle)
                        table.insert(vehiclesToReport, { plate = plate, coords = coords })
                    end
                end
            end
        end

        if #vehiclesToReport > 0 then
            TriggerServerEvent("tracker:updateVehiclePositions", vehiclesToReport)
        end

        ::continue::
    end
end)

CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do Wait(500) end
    Wait(3000)
    TriggerServerEvent("tracker:playerJoined")
end)
