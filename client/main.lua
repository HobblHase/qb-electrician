local QBCore = exports['qb-core']:GetCoreObject()
local PlayerJob = {}
CompleteRepairs = 0
JobsinSession = {}

local function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

-- Blip Function
local function SetJobBlip(title)
    local JobBlip = AddBlipForCoord(Config.Locations[title].coords.x, Config.Locations[title].coords.y, Config.Locations[title].coords.z)
    SetBlipSprite(JobBlip, 354)
    SetBlipDisplay(JobBlip, 4)
    SetBlipScale(JobBlip, 0.8)
    SetBlipAsShortRange(JobBlip, true)
    SetBlipColour(JobBlip, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Lang:t("main.label"))
    EndTextCommandSetBlipName(JobBlip)
end

-- Checks if car is a Job Vehicle
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

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

-- Randomly selects a Vehicle from the Config List
RegisterNetEvent('qb-electrician:client:VehPick', function()
    local choice = math.random(1, #Config.JobVehicles)
    ElecVeh = Config.JobVehicles[choice]
    TriggerEvent('qb-electrician:client:SpawnVehicle', ElecVeh)
end)

CreateThread(function()
    local Player = QBCore.Functions.GetPlayerData()
    if Player.job.name == "electrician" then
        for _, jobpoint in pairs(Config.Locations['blip']) do
            local blip = AddBlipForCoord(jobpoint.x, jobpoint.y, jobpoint.z)
            SetBlipSprite(blip, 365)
            SetBlipAsShortRange(blip, true)
            SetBlipScale(blip, 1.0)
            SetBlipColour(blip, 46)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(Lang:t('main.label'))
            EndTextCommandSetBlipName(blip)
        end
    end
end) -- ensures blip for elictricians

-- Markers for Job Vehicle
CreateThread(function()
    local inRange = false
    while true do
        Wait(0)
        local pos = GetEntityCoords(PlayerPedId())
        if Config.UseJob then
            if PlayerJob.name == "electrician" then -- you can change the job on this line :D -- if in the config.lua 'UseJob = true' then you have to be in the job 'electrician' else you can do it w every job
                if #(pos - vector3(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z)) < 10 then
                    inRange = true
                    DrawMarker(2, Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                    if #(pos - vector3(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z)) < 1.5 then
                        if IsPedInAnyVehicle(PlayerPedId(), false) then
                            DrawText3D(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z, Lang:t("main.park_in"))
                        else
                            DrawText3D(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z, Lang:t("main.park_out"))
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
                DrawMarker(2, Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                if #(pos - vector3(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z)) < 1.5 then
                    if IsPedInAnyVehicle(PlayerPedId(), false) then
                        DrawText3D(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z, Lang:t("main.park_in"))
                    else
                        DrawText3D(Config.Locations["vehicle"].coords.x, Config.Locations["vehicle"].coords.y, Config.Locations["vehicle"].coords.z, Lang:t("main.park_out"))
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
            if Config.UseJob and PlayerJob.name == "electrician" then -- you can change the job on this line :D -- if in the config.lua 'UseJob = true' then you have to be in the job 'electrician' else you can do it w every job
                if CompleteRepairs < 5 then
                    if #(pos - vector3(v.x, v.y, v.z)) < 10 then
                        inRange = true
                        DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                        if #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
                            DrawText3D(v.x, v.y, v.z, Lang:t("main.repair"))
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
                                        QBCore.Functions.Notify(Lang:t("succes.repaired"))
                                    else
                                        QBCore.Functions.Notify(Lang:t("succes.repaired_all"))
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
            else
                if CompleteRepairs < 5 then
                    if #(pos - vector3(v.x, v.y, v.z)) < 10 then
                        inRange = true
                        DrawMarker(2, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                        if #(pos - vector3(v.x, v.y, v.z)) < 1.5 then
                            DrawText3D(v.x, v.y, v.z, Lang:t("main.repair"))
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
                                        QBCore.Functions.Notify(Lang:t("succes.repaired"))
                                    else
                                        QBCore.Functions.Notify(Lang:t("succes.repaired_all"))
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
        if Config.UseJob then -- you can change the job on this line :D -- if in the config.lua 'UseJob = true' then you have to be in the job 'electrician' else you can do it w every job
            if PlayerJob.name == "electrician" then
                if #(pos - vector3(Config.Locations["payslip"].coords.x, Config.Locations["payslip"].coords.y, Config.Locations["payslip"].coords.z)) < 10 then
                    inRange = true
                    DrawMarker(2, Config.Locations["payslip"].coords.x, Config.Locations["payslip"].coords.y, Config.Locations["payslip"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                    if #(pos - vector3(Config.Locations["payslip"].coords.x, Config.Locations["payslip"].coords.y, Config.Locations["payslip"].coords.z)) < 1.5 then
                        DrawText3D(Config.Locations["payslip"].coords.x, Config.Locations["payslip"].coords.y, Config.Locations["payslip"].coords.z, Lang:t("main.payslip"))
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
                DrawMarker(2, Config.Locations["payslip"].coords.x, Config.Locations["payslip"].coords.y, Config.Locations["payslip"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                if #(pos - vector3(Config.Locations["payslip"].coords.x, Config.Locations["payslip"].coords.y, Config.Locations["payslip"].coords.z)) < 1.5 then
                    DrawText3D(Config.Locations["payslip"].coords.x, Config.Locations["payslip"].coords.y, Config.Locations["payslip"].coords.z, Lang:t("main.payslip"))
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
