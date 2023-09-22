local QBCore = exports['qb-core']:GetCoreObject()
local blip = nil

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for k, v in pairs(Config.towers) do
            if v["IsRendered"] then
                DeleteObject(v["object"])
                DeleteObject(v["panelObject"])
            end
        end
        if blip ~= nil then
            RemoveBlip(blip)
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        while QBCore == nil do
            Wait(200)
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    if PlayerJob.name == 'job' then
    end
end)

RegisterNetEvent('js5m-radiotowers:client:clientEvent', function()
    local playerCoords = GetEntityCoords(cache.ped)
    for k, v in pairs(Config.towers) do
        local objectCoords = v["coords"]
        local dist = #(playerCoords - vector3(objectCoords["x"], objectCoords["y"], objectCoords["z"]))
        if dist < 6 then
            lib.callback('js5m-radiotowers:server:checkPwners', false, function(pwner)
                if not pwner then
                    Wait(100)
                    local success = lib.skillCheck({'easy', 'easy', 'easy', 'easy'}, {'w', 'a', 's', 'd'})
                    if not success then
                        return
                    else
                        local response = lib.callback.await('js5m-radiotowers:server:setPwner', false, k)
                        if not response then
                            return
                        end
                    end
                end
                local input = lib.inputDialog('Locate Phone Signal', {'Phone Number'})
                if not input then return end
                local number = input[1]
                lib.callback('js5m-radiotowers:server:getPhoneCoords', false, function(coords)
                    local newCoords = coords
                    Wait(1500)
                    if newCoords ~= nil then
                        CreateThread(function()
                            if blip == nil then
                                lib.notify({title = 'Location marked on map'})
                                blip = AddBlipForCoord(newCoords.x, newCoords.y, newCoords.z)
                                SetBlipSprite (blip, 459)
                                SetBlipDisplay(blip, 4)
                                SetBlipScale  (blip, 0.65)
                                SetBlipAsShortRange(blip, true)
                                SetBlipColour(blip, 3)
                        
                                BeginTextCommandSetBlipName("STRING")
                                AddTextComponentSubstringPlayerName(number)
                                EndTextCommandSetBlipName(blip)
                                Wait(30000)
                                RemoveBlip(blip)
                                blip = nil
                            end
                        end)
                    else
                        lib.notify({title = 'Signal not found', type = 'error'})
                    end
                end, input[1], k)
            end, k)
            break
        end
    end
end)

RegisterNetEvent("QBCore:Player:SetPlayerData", function(val)
    if GetInvokingResource() then return end
    PlayerData = val
end)

CreateThread(function()
	while true do
		for k, v in pairs(Config.towers) do
            local data = v["options"]
            local objectCoords = v["coords"]
			local playerCoords = GetEntityCoords(cache.ped)
			local dist = #(playerCoords - vector3(objectCoords["x"], objectCoords["y"], objectCoords["z"]))
			if dist < data["SpawnRange"] and v["IsRendered"] == nil then
                
				local object = CreateObject(v["model"], objectCoords["x"], objectCoords["y"], objectCoords["z"], false, false, false)
                SetEntityHeading(object, objectCoords["w"])
                SetEntityAlpha(object, 0)
                PlaceObjectOnGroundProperly(object)
                FreezeEntityPosition(object, true)
				v["IsRendered"] = true
                v["object"] = object
                local panelCoords = GetEntityCoords(object)

                local panelObject = CreateObject(`v_corp_bk_secpanel`, panelCoords["x"], panelCoords["y"]-0.55, panelCoords["z"]+1, false, false, false)
                v["panelObject"] = panelObject
                SetEntityAlpha(v["panelObject"], 0)
                FreezeEntityPosition(panelObject, true)

                for i = 0, 255, 51 do
                    Wait(50)
                    SetEntityAlpha(v["object"], i, false)
                    SetEntityAlpha(v["panelObject"], i, false)
                end

                local options = {
                    {
                        name = 'ox:option1',
                        event = 'js5m-radiotowers:client:clientEvent',
                        icon = 'fa-solid fa-gears',
                        label = 'Access Panel',
                    },
                }

                exports.ox_target:addLocalEntity({ v["panelObject"] }, options)
			end
			
			if dist >= data["SpawnRange"] and v["IsRendered"] then
                if DoesEntityExist(v["object"]) then
                    exports.ox_target:removeLocalEntity({v["panelObject"]}, {'ox:option1'})

                    for i = 255, 0, -51 do
                        Wait(50)
                        SetEntityAlpha(v["object"], i, false)
                        SetEntityAlpha(v["panelObject"], i, false)
                    end
                    DeleteObject(v["object"])
                    DeleteObject(v["panelObject"])

                    v["object"] = nil
                    v["panelObject"] = nil
                    v["IsRendered"] = nil

                    
                end
			end
		end
        Wait(2000)
	end
end)