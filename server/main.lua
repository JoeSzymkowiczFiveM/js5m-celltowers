local QBCore = exports['qb-core']:GetCoreObject()

lib.callback.register('js5m-radiotowers:server:getPhoneCoords', function(source, number, tower)
    -- if not Config.towers[tower]['pwners'][source] then
    --     Config.towers[tower]['pwners'][source] = true
    -- end
    local Player = QBCore.Functions.GetPlayerByPhone(number)
    local source = Player.PlayerData.source
    local pos = GetEntityCoords(GetPlayerPed(source))
    local towerCoords = Config.towers[tower]['coords'].xyz
    if #(pos - towerCoords) < 600 then
        return pos
    else
        return nil
    end
end)

lib.callback.register('js5m-radiotowers:server:checkPwners', function(source, tower)
    return Config.towers[tower]['pwners'][source]
end)

lib.callback.register('js5m-radiotowers:server:setPwner', function(source, tower)
    if not Config.towers[tower]['pwners'][source] then
        Config.towers[tower]['pwners'][source] = true
        return true
    else
        return false
    end
end)