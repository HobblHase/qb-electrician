local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local isLoggedIn = false
CompleteRepairs = 0
JobsinSession = {}

local blips = {}

local function handleBlip()
    for i = 1, #blips do
        if DoesBlipExist(blips[i]) then
            RemoveBlip(blips[i])
        end
    end

    blips = {}

    if not Config.UseJob or PlayerData.job.name == 'electrician' then
        for _, jobpoint in pairs(Config.Locations['blip']) do
            local blip = AddBlipForCoord(jobpoint.x, jobpoint.y, jobpoint.z)
            SetBlipSprite(blip, 365)
            SetBlipAsShortRange(blip, true)
            SetBlipScale(blip, 1.0)
            SetBlipColour(blip, 46)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(Lang:t('main.label'))
            EndTextCommandSetBlipName(blip)
            blips[#blips+1] = blip
        end
    end
end


RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerData = QBCore.Functions.GetPlayerData()
    handleBlip()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    PlayerData = {}
    if DoesBlipExist(blip) then RemoveBlip(blip) blip = nil end
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(val)
    PlayerData = val
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerData.job = JobInfo
    handleBlip()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName and LocalPlayer.isLoggedIn then return end
    PlayerData = QBCore.Functions.GetPlayerData()
    handleBlip()
    print(PlayerData.job.name)
end)

-- Job Blip Function
local function SetWorkBlip(d)
    for k, v in pairs(Config.Locations["jobset" ..d]) do
        WorkBlip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
        SetBlipSprite(WorkBlip, 143)
        SetBlipDisplay(WorkBlip, 4)
        SetBlipScale(WorkBlip, 0.5)
        SetBlipAsShortRange(WorkBlip, true)
        SetBlipColour(WorkBlip, 26)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(v.name)
        EndTextCommandSetBlipName(WorkBlip)
        table.insert(JobsinSession, {id = k, x = v.coords.x, y = v.coords.y, z = v.coords.z, BlipId = WorkBlip})
    end
    TriggerEvent('qb-electrician:client:JobMarkers')
end

local function VehicleCheck(vehicle)
    local retval = false
    for k, v in pairs(Config.JobVehicles) do
        if Config.Debug then
            print(v)
        end
        if GetEntityModel(vehicle) == GetHashKey(v) then
            retval = true
        end
    end
    return retval
end

-- Randomly selects a Vehicle from the Config List
RegisterNetEvent('qb-electrician:client:VehPick', function()
    local choice = math.random(1, #Config.JobVehicles)
    ElecVeh = Config.JobVehicles[choice]
    TriggerEvent('qb-electrician:client:SpawnVehicle', ElecVeh)
    --Wait(1500)
end)

-- Markers for Job Vehicle
CreateThread(function()
    local inRange = false
    while true do
        Wait(0)
        local pos = GetEntityCoords(PlayerPedId())
        if Config.UseJob == true then
            if PlayerData.job and PlayerData.job.name == "electrician" then -- you can change the job on this line :D -- if in the config.lua 'UseJob = true' then you have to be in the job 'electrician' else you can do it w every job
                if #(pos - vector3(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z)) < 20 then
                    inRange = true
                    -- DrawMarker(2, Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                    if #(pos - vector3(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z)) < 4.5 then
                        if IsPedInAnyVehicle(PlayerPedId(), false) then
                            QBCore.Functions.DrawText3D(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z, Lang:t("main.park_in"))
                        else
                            QBCore.Functions.DrawText3D(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z, Lang:t("main.park_out"))
                        end
                        if IsControlJustReleased(0, 38) then
                            if IsPedInAnyVehicle(PlayerPedId(), false) then
                                if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1) == PlayerPedId() then
                                    if VehicleCheck(GetVehiclePedIsIn(PlayerPedId(), false)) then
                                        DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                        for k,v in ipairs(JobsinSession) do
                                            RemoveBlip(v.BlipId)
                                        end
                                    else
                                        QBCore.Functions.Notify(Lang:t("error.no_elec_veh"), 'error')
                                    end
                                else
                                    QBCore.Functions.Notify(Lang:t("error.not_driver"), 'error')
                                end
                            else
                                TriggerEvent('qb-electrician:client:VehPick')
                                Wait(1500) -- to prevent spamming
                            end
                        end
                    end
                end
                if not inRange then
                    Wait(1000)
                end
            end
        else
            if #(pos - vector3(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z)) < 10 then
                inRange = true
                -- DrawMarker(2, Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                if #(pos - vector3(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z)) < 1.5 then
                    if IsPedInAnyVehicle(PlayerPedId(), false) then
                        QBCore.Functions.DrawText3D(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z, Lang:t("main.park_in"))
                    else
                        QBCore.Functions.DrawText3D(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z, Lang:t("main.park_out"))
                    end
                    if IsControlJustReleased(0, 38) then
                        if IsPedInAnyVehicle(PlayerPedId(), false) then
                            if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1) == PlayerPedId() then
                                if VehicleCheck(GetVehiclePedIsIn(PlayerPedId(), false)) then
                                    DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                    for k,v in ipairs(JobsinSession) do
                                        RemoveBlip(v.BlipId)
                                    end
                                else
                                    QBCore.Functions.Notify(Lang:t("error.no_elec_veh"), 'error')
                                end
                            else
                                QBCore.Functions.Notify(Lang:t("error.not_driver"), 'error')
                            end
                        else
                            TriggerEvent('qb-electrician:client:VehPick')
                            Wait(1500) -- to prevent spamming
                        end
                    end
                end
            end
            if not inRange then
                Wait(1000)
            end
        end
    end
end)

-- Spawns Electrician Vehicle
RegisterNetEvent('qb-electrician:client:SpawnVehicle', function(vehicleInfo)
    local coords = Config.Locations["vehicle"].coords
    QBCore.Functions.SpawnVehicle(vehicleInfo, function(veh)
        SetVehicleNumberPlateText(veh, Lang:t("main.plate") ..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, coords.w)
        exports['LegacyFuel']:SetFuel(veh, 100.0) -- if u r using LegacyFuel dont edit, if not you have to replace this export :D
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetEntityAsMissionEntity(veh, true, true)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
        SetVehicleEngineOn(veh, true, true)
        CurrentPlate = QBCore.Functions.GetPlate(veh)
        StartJobLocations()
    end, coords, true)
end)

function StartJobLocations()
    jobchoice = math.random(1,5)
    SetWorkBlip(jobchoice)
    QBCore.Functions.Notify(Lang:t("main.job_start"), 'primary')
end

-- Individual Job Site Interactions
RegisterNetEvent('qb-electrician:client:JobMarkers', function(k, v)
    local inRange = false
    CompleteRepairs = 0
    while true do
        Wait(0)
        for k, v in ipairs(JobsinSession) do
            local pos = GetEntityCoords(PlayerPedId())
            local Player = QBCore.Functions.GetPlayerData()
            if Config.UseJob == true then
                if PlayerData.job and PlayerData.job.name == "electrician" then -- you can change the job on this line :D -- if in the config.lua 'UseJob = true' then you have to be in the job 'electrician' else you can do it w every job
                    if CompleteRepairs < 5 then
                        if #(pos - vector3(v.x, v.y, v.z)) < 10 then
                            inRange = true
                            -- DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                            if #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
                                QBCore.Functions.DrawText3D(v.x, v.y, v.z, Lang:t("main.repair"))
                                if IsControlJustReleased(0, 38) then
                                    QBCore.Functions.Progressbar("repair_work", Lang:t("progress.repair"), math.random(Config.RepairTimeMin, Config.RepairTimeMax), false, true, {
                                        disableMovement = true,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                    }, {
                                        animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                                        anim = "machinic_loop_mechandplayer",
                                        flags = 49,
                                    }, {}, {}, function()
                                        CompleteRepairs = CompleteRepairs + 1
                                        if Config.Debug then
                                            print(CompleteRepairs)
                                        end
                                        if CompleteRepairs <= 4 then
                                            QBCore.Functions.Notify(Lang:t("success.repaired"))
                                        else
                                            QBCore.Functions.Notify(Lang:t("success.repaired_all"))
                                        end
                                        RemoveBlip(v.BlipId)
                                        table.remove(JobsinSession, k)
                                    end, function() -- Cancel
                                        StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                                        QBCore.Functions.Notify(Lang:t("error.canceled"), "error")
                                    end)
                                end
                            end
                        end
                        if not inRange then
                            Wait(1000)
                        end
                    end
                end
            else
                if CompleteRepairs < 5 then
                    if #(pos - vector3(v.x, v.y, v.z)) < 10 then
                        inRange = true
                        -- DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                        if #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
                            QBCore.Functions.DrawText3D(v.x, v.y, v.z, Lang:t("main.repair"))
                            if IsControlJustReleased(0, 38) then
                                QBCore.Functions.Progressbar("repair_work", Lang:t("progress.repair"), math.random(Config.RepairTimeMin, Config.RepairTimeMax), false, true, {
                                    disableMovement = true,
                                    disableCarMovement = true,
                                    disableMouse = false,
                                    disableCombat = true,
                                }, {
                                    animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                                    anim = "machinic_loop_mechandplayer",
                                    flags = 49,
                                }, {}, {}, function() -- Done
                                    CompleteRepairs = CompleteRepairs + 1
                                    if Config.Debug then
                                        print(CompleteRepairs)
                                    end
                                    if CompleteRepairs <= 4 then
                                        QBCore.Functions.Notify(Lang:t("success.repaired"))
                                    else
                                        QBCore.Functions.Notify(Lang:t("success.repaired_all"))
                                    end
                                    RemoveBlip(v.BlipId)
                                    table.remove(JobsinSession, k)
                                end, function() -- Cancel
                                    StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
                                    QBCore.Functions.Notify(Lang:t("error.canceled"), "error")
                                end)
                            end
                        end
                    end
                    if not inRange then
                        Wait(1000)
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    local pos = GetEntityCoords(PlayerPedId())
    local inRange = false
    while true do
        Wait(0)
        local pos = GetEntityCoords(PlayerPedId())
        if Config.UseJob == true then -- you can change the job on this line :D -- if in the config.lua 'UseJob = true' then you have to be in the job 'electrician' else you can do it w every job
            if PlayerData.job and PlayerData.job.name == "electrician" then
                if #(pos - vector3(Config.Locations["payslip"].coords.x, Config.Locations["payslip"].coords.y, Config.Locations["payslip"].coords.z)) < 10 then
                    inRange = true
                    -- DrawMarker(2, Config.Locations["payslip"].coords.x, Config.Locations["payslip"].coords.y, Config.Locations["payslip"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                    if #(pos - vector3(Config.Locations["payslip"].coords.x, Config.Locations["payslip"].coords.y, Config.Locations["payslip"].coords.z)) < 2.5 then
                        QBCore.Functions.DrawText3D(Config.Locations["payslip"].coords.x, Config.Locations["payslip"].coords.y, Config.Locations["payslip"].coords.z, Lang:t("main.payslip"))
                        if IsControlJustReleased(0, 38) then
                            if CompleteRepairs ~= 0 then
                                TriggerServerEvent('qb-electrician:server:Payslip', CompleteRepairs)
                                CompleteRepairs = 0
                                for k,v in ipairs(JobsinSession) do
                                    RemoveBlip(v.BlipId)
                                end
                            else
                                QBCore.Functions.Notify(Lang:t("error.not_worked"), "error")
                            end
                        end
                    end
                end
                if not inRange then
                    Wait(1000)
                end
            end
        else
            if #(pos - vector3(Config.Locations["payslip"].coords.x, Config.Locations["payslip"].coords.y, Config.Locations["payslip"].coords.z)) < 10 then
                inRange = true
                -- DrawMarker(2, Config.Locations["payslip"].coords.x, Config.Locations["payslip"].coords.y, Config.Locations["payslip"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                if #(pos - vector3(Config.Locations["payslip"].coords.x, Config.Locations["payslip"].coords.y, Config.Locations["payslip"].coords.z)) < 1.5 then
                    QBCore.Functions.DrawText3D(Config.Locations["payslip"].coords.x, Config.Locations["payslip"].coords.y, Config.Locations["payslip"].coords.z, Lang:t("main.payslip"))
                    if IsControlJustReleased(0, 38) then
                        if CompleteRepairs ~= 0 then
                            TriggerServerEvent('qb-electrician:server:Payslip', CompleteRepairs)
                            CompleteRepairs = 0
                            for k,v in ipairs(JobsinSession) do
                                RemoveBlip(v.BlipId)
                            end
                        else
                            QBCore.Functions.Notify(Lang:t("error.not_worked"), "error")
                        end
                    end
                end
            end
            if not inRange then
                Wait(1000)
            end
        end
    end
end)
