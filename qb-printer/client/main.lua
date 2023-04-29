local QBCore = exports['qb-core']:GetCoreObject()
local PlayerJob = {}
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        QBCore.Functions.GetPlayerData(function(PlayerData)
            PlayerJob = PlayerData.job
        end)
    end
end)
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.GetPlayerData(function(PlayerData)
        PlayerJob = PlayerData.job
    end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
end)

RegisterNetEvent('qb-printer:client:UseDocument', function(ItemData)
    local DocumentUrl = ItemData.info.url ~= nil and ItemData.info.url or false
    SendNUIMessage({
        action = "open",
        url = DocumentUrl
    })
    SetNuiFocus(true, false)
end)

RegisterNetEvent('qb-printer:client:SpawnPrinter', function()
    local playerPed = PlayerPedId()
    local coords    = GetEntityCoords(playerPed)
    local forward   = GetEntityForwardVector(playerPed)
    local x, y, z   = table.unpack(coords + forward * 1.0)

    local model = `prop_printer_01`
    RequestModel(model)
    while (not HasModelLoaded(model)) do
        Wait(1)
    end
    local obj = CreateObject(model, x, y, z, true, false, true)
    PlaceObjectOnGroundProperly(obj)
    SetModelAsNoLongerNeeded(model)
    SetEntityAsMissionEntity(obj)
end)

-- NUI

RegisterNUICallback('SaveDocument', function(data, cb)
    if data.url then
        TriggerServerEvent('qb-printer:server:SaveDocument', data.url)
    end
    cb('ok')
end)

RegisterNUICallback('CloseDocument', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNetEvent('qb-printer:printer',function()
    SendNUIMessage({
        action = "start"
    })
    SetNuiFocus(true, true)
end)

if Config.UseTarget then
    CreateThread(function()
        exports['qb-target']:AddTargetModel(Config.printers, {
            options = {
                {
                    event = 'qb-printer:printer',
                    type = 'client',
                    icon = "fa fa-print	",
                    label = Lang:t('info.use_printer'),
                    canInteract = function()
                        if PlayerJob.name == "police" or PlayerJob.name == "ambulance" or PlayerJob.name == "judge" then  
                            return true
                        else return false
                        end
                    end
                },
            },
            distance = 1.5,
        })
    end)
end
