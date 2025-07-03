local QBCore = exports['qb-core']:GetCoreObject()
local InvType = Config.CoreSettings.Inventory.Type or 'qb'
local TargetType = Config.CoreSettings.Target.Type or 'qb'
local NotifyType = Config.CoreSettings.Notify.Type or 'qb'
local CashSymbol = Config.CoreSettings.Misc.CashSymbol or '$'
local cooldowns = {}




--server debug function
function SVDebug(msg)
    if not Config.CoreSettings.Debug.Prints then return end
    print(msg)
end


--get character name
function getCharacterName(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player and Player.PlayerData and Player.PlayerData.charinfo then
        local info = Player.PlayerData.charinfo
        return (info.firstname or 'Unknown')..' '..(info.lastname or 'Unknown')
    end
    return 'Unknown'
end


--send logs
function sendLog(source, logType, message, level)
    local src = source
    local name = getCharacterName(src)
    local logsEnabled = Config.CoreSettings.Security.Logs.Enabled
    if not logsEnabled then return end
    local logging = Config.CoreSettings.Security.Logs.Type
    if logging == 'discord' then
        local webhookURL = '' -- set your discord webhook URL here
        if webhookURL == '' then print('^1| Lusty94_FirstAid | DEBUG | ERROR | Logging method is set to Discord but WebhookURL is missing!') return end
        PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({
            username = "Lusty94_FirstAid Logs",
            avatar_url = "https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png",
            embeds = {{
                title = "**"..(logType or "First Aid Log").."**",
                description = message or ("Log triggered by **%s** (ID: %s)"):format(name, source),
                color = level == "warning" and 16776960 or level == "error" and 16711680 or 65280,
                footer = {
                    text = "Lusty94_FirstAid Logs • "..os.date("%Y-%m-%d %H:%M:%S"),
                    icon_url = "https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png"
                },
                thumbnail = {
                    url = "https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png"
                },
                author = {
                    name = 'Lusty94_FirstAid Logs'
                }
            }}
        }), { ['Content-Type'] = 'application/json' })
    elseif logging == 'fm-logs' then
        if not GetResourceState('fm-logs') or GetResourceState('fm-logs') ~= 'started' then
            print('^1| Lusty94_FirstAid | DEBUG | ERROR | Unable to send log | fm-logs is not started!')
            return
        end
        exports['fm-logs']:createLog({
            LogType = logType or "Player",
            Message = message or 'Check Resource',
            Level = level or "info",
            Resource = GetCurrentResourceName(),
            Source = source,
        }, { Screenshot = false })
    end
end


--server notification
function SVNotify(src, msg, type, time, title)
    if NotifyType == nil then print('^1| Lusty94_FirstAid | DEBUG | ERROR | NotifyType is nil!') return end
    if not msg then msg = 'Notification sent with no message!' end
    if not type then type = 'success' end
    if not time then time = 5000 end
    if not title then title = 'Notification' end
    if NotifyType == 'qb' then
        TriggerClientEvent('QBCore:Notify', src, msg, type, time)
    elseif NotifyType == 'qs' then
        TriggerClientEvent('lusty_firstaid:client:notify', src, msg, type, time)
    elseif NotifyType == 'okok' then
        TriggerClientEvent('okokNotify:Alert', src, title, msg, time, type, Config.CoreSettings.Notify.Sound)
    elseif NotifyType == 'mythic' then
        TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = type, text = msg, style = { ['background-color'] = '#00FF00', ['color'] = '#FFFFFF' } })
    elseif NotifyType == 'ox' then 
        TriggerClientEvent('ox_lib:notify', src, ({ title = title, description = msg, position = 'top', length = time, type = type, style = 'default'}))
    elseif NotifyType == 'custom' then
        -- Insert your own notify function here
    else
        print('^1| Lusty94_FirstAid | DEBUG | ERROR | Unknown notify type: ' .. tostring(NotifyType))
    end
end


--add item
function addItem(src, item, amount, slot, info)
    sendLog(src, "Security", ('Giving %sx%s to %s with info %s'):format(item, amount, getCharacterName(src), json.encode(info) or 'N/A'), "warning")
    if InvType == 'qb' then
        local canCarry = exports['qb-inventory']:CanAddItem(src, item, amount, slot, info)
        if not canCarry then SVNotify(src, Config.Language.Notifications.CantGive, 'error') TriggerClientEvent('lusty_firstaid:client:toggleStatus', src) return end
        exports['qb-inventory']:AddItem(src, item, amount, slot, info)
        TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', amount)
        SVDebug('^3| Lusty94_FirstAid | DEBUG | Adding '..amount..'x '..item..' to '..getCharacterName(src))
    elseif InvType == 'qs' then
        local canCarry = exports['qs-inventory']:CanAddItem(src, item, amount, slot, info)
        if not canCarry then SVNotify(src, Config.Language.Notifications.CantGive, 'error') TriggerClientEvent('lusty_firstaid:client:toggleStatus', src) return end
        exports['qs-inventory']:AddItem(src, item, amount, slot, info)
        TriggerClientEvent('qs-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'add', amount)
        SVDebug('^3| Lusty94_FirstAid | DEBUG | Adding '..amount..'x '..item..' to '..getCharacterName(src))
    elseif InvType == 'ox' then
        local canCarry = exports.ox_inventory:CanCarryItem(src, item, amount, info)
        if not canCarry then SVNotify(src, Config.Language.Notifications.CantGive, 'error') TriggerClientEvent('lusty_firstaid:client:toggleStatus', src) return end
        exports.ox_inventory:AddItem(src, item, amount, info)
        SVDebug('^3| Lusty94_FirstAid | DEBUG | Adding '..amount..'x '..item..' to '..getCharacterName(src))
    elseif InvType == 'custom' then
        --insert your own logic for adding items here
    else
        print('^1| Lusty94_FirstAid | DEBUG | ERROR | Unknown inventory type set in Config.CoreSettings.Inventory.Type | '..tostring(InvType))
    end
end


--remove item
function removeItem(src, item, amount)
    sendLog(src, "Security", ('Removing %sx%s from %s'):format(item, amount, getCharacterName(src)), "warning")
    if InvType == 'qb' then
        if exports['qb-inventory']:RemoveItem(src, item, amount) then
            TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', amount)
            SVDebug('^3| Lusty94_FirstAid | DEBUG | Removing ' .. amount .. 'x ' .. item .. ' from '..getCharacterName(src))
            return true
        else
            TriggerClientEvent('lusty_firstaid:client:toggleStatus', src)
            return false
        end
    elseif InvType == 'qs' then
        if exports['qs-inventory']:RemoveItem(src, item, amount) then
            TriggerClientEvent('qs-inventory:client:ItemBox', src, QBCore.Shared.Items[item], 'remove', amount)
            SVDebug('^3| Lusty94_FirstAid | DEBUG | Removing ' .. amount .. 'x ' .. item .. ' from '..getCharacterName(src))
            return true
        else
            TriggerClientEvent('lusty_firstaid:client:toggleStatus', src)
            return false
        end
    elseif InvType == 'ox' then
        if exports.ox_inventory:RemoveItem(src, item, amount) then
            SVDebug('^3| Lusty94_FirstAid | DEBUG | Removing ' .. amount .. 'x ' .. item .. ' from '..getCharacterName(src))
            return true
        else
            TriggerClientEvent('lusty_firstaid:client:toggleStatus', src)
            return false
        end
    elseif InvType == 'custom' then
        --insert your own logic for removing items here remebering to return the correct boolean
    else
        print('^1| Lusty94_FirstAid | DEBUG | ERROR | Unknown inventory type set in Config.CoreSettings.Inventory.Type | '..tostring(InvType))
    end
end


--remove money
function removeMoney(src, account, amount)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    if amount == 0 then return true end
    sendLog(src, "Security", ('Removing %s%s from %s in %s'):format(CashSymbol, amount, getCharacterName(src), account), "warning")
    if InvType == 'ox' then
        if exports.ox_inventory:Search(src, 'count', 'money') >= amount then
            if not removeItem(src, 'money', amount) then return false end
            SVDebug(('^3| Lusty94_FirstAid | DEBUG | INFO | Removing %s%.2f from %s^7'):format(CashSymbol, amount, getCharacterName(src)))
            return true
        else
            TriggerClientEvent('lusty_firstaid:client:toggleStatus', src)
            SVDebug('^1| Lusty94_FirstAid | DEBUG | INFO | Player: '..getCharacterName(src)..' has insufficient funds')
            return false
        end
    elseif InvType == 'qb' or InvType == 'qs' then
        if Player.Functions.GetMoney(account) >= amount then
            if Player.Functions.RemoveMoney(account, amount) then
                SVDebug(('^3| Lusty94_FirstAid | DEBUG | INFO | Removing %s%.2f from %s^7'):format(CashSymbol, amount, getCharacterName(src)))
                return true
            end
        else
            TriggerClientEvent('lusty_firstaid:client:toggleStatus', src)
            SVDebug('^1| Lusty94_FirstAid | DEBUG | INFO | Player: '..getCharacterName(src)..' has insufficient funds')
            return false
        end
    elseif InvType == 'custom' then
        --insert your own logic here for removing money via account
    else
        print('^1| Lusty94_FirstAid | DEBUG | ERROR | Unknown inventory type set in Config.CoreSettings.Inventory.Type | '..tostring(InvType))
    end
end


--distance check coords
function IsPlayerNearCoords(src, targetCoords, playerCoords, maxDist, checkName)
    local dist = #(vector3(playerCoords.x, playerCoords.y, playerCoords.z) - vector3(targetCoords.x, targetCoords.y, targetCoords.z))
    if dist > maxDist then
        print(('^1| Lusty94_FirstAid | DEBUG | WARNING | %s failed distance check (%s) | Distance: %.2f^7'):format(getCharacterName(src), checkName, dist))
        sendLog(src, "Security", ('%s failed distance check (%s) | Distance: %.2f'):format(getCharacterName(src), checkName, dist), "warning")
        if Config.CoreSettings.Security.KickPlayer then DropPlayer(src, 'Potential Exploiting Detected') end
        return false
    end
    return true
end


--check permission
function hasPerms(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return false end
    local groups = { -- define permission groups
        'god',
        'admin',
        'mod',
        --add more as required
    }
    local allowed = QBCore.Functions.HasPermission(src, groups)
    return allowed
end


--check perm
lib.callback.register('lusty_firstaid:server:checkPerms', function(source)
    return hasPerms(source)
end)


--check status
lib.callback.register('lusty_firstaid:server:IsPlayerDowned', function(_, playerId)
    local Player = QBCore.Functions.GetPlayer(tonumber(playerId))
    if not Player then return false end
    local metadata = Player.PlayerData.metadata or {}
    return metadata['isdead'] or metadata['inlaststand'] or false
end)


--get stock levels
lib.callback.register('lusty_firstaid:server:GetItemStock', function(source, zoneName)
    local result = MySQL.query.await('SELECT item_name, stock FROM firstaid_stock WHERE zone_name = ?', { zoneName })
    local stockData = {}
    for _, row in ipairs(result) do
        stockData[row.item_name] = row.stock
    end
    return stockData
end)


--revive
RegisterNetEvent('lusty_firstaid:server:revivePlayer', function(targetId, zoneName, pedCoords, playerCoords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    local reviveData = Config.FirstAid[zoneName]
    if not reviveData then return end
    if not IsPlayerNearCoords(src, pedCoords, playerCoords, Config.CoreSettings.Security.MaxDistance or 10.0, 'lusty_firstaid:server:revivePlayer') then return end
    local cost = reviveData.revive.cost
    if cooldowns[cid] and os.time() < cooldowns[cid] then
        SVNotify(src, Config.Language.Notifications.Cooldown, 'error')
        return
    end
    if not removeMoney(src, 'cash', cost) then 
        SVNotify(src, (Config.Language.Notifications.CantAfford):format(CashSymbol, cost),'error')
        return
    end
    cooldowns[cid] = os.time() + 600
    TriggerClientEvent('lusty_firstaid:client:revivePlayer', targetId, reviveData.revive, zoneName, pedCoords, playerCoords)
    SVDebug(('^3| Lusty94_FirstAid | DEBUG | INFO | %s Is Being Revived At %s Cost %s%s'):format(getCharacterName(src), zoneName, CashSymbol, cost))
end)


--revive
RegisterNetEvent('lusty_firstaid:server:revive', function(pedCoords, playerCoords)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if not IsPlayerNearCoords(src, pedCoords, playerCoords, Config.CoreSettings.Security.MaxDistance or 10.0, 'lusty_firstaid:server:revivePlayer') then return end
    TriggerClientEvent('hospital:client:Revive', src)
    sendLog(src, 'Revive', ('%s paid $%s to be revived at %s'):format(getCharacterName(src), cost, zoneName), 'info')
end)


--buy items
RegisterNetEvent('lusty_firstaid:server:BuyItem', function(zoneName, itemName, quantity, pedCoords, playerCoords, paymentType)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local reviveData = Config.FirstAid[zoneName]
    if not reviveData or not reviveData.inventory then return end
    if not IsPlayerNearCoords(src, pedCoords, playerCoords, Config.CoreSettings.Security.MaxDistance or 10.0, 'lusty_firstaid:server:BuyItem') then return end
    local itemData
    for _, item in pairs(reviveData.inventory) do
        if item.name == itemName then
            itemData = item
            break
        end
    end
    if not itemData then return end
    quantity = tonumber(quantity)
    if not quantity or quantity < 1 then 
        SVNotify(src, Config.Language.Notifications.InvalidQuantity, 'error')
        return
    end
    local result = MySQL.single.await('SELECT stock FROM firstaid_stock WHERE zone_name = ? AND item_name = ?', { zoneName, itemName })
    local stock = result and tonumber(result.stock) or 0
    if quantity > stock then
        SVNotify(src, Config.Language.Notifications.NotEnoughStock, 'error')
        return
    end
    local totalCost = itemData.price * quantity
    if not removeMoney(src, paymentType, totalCost) then 
        SVNotify(src, (Config.Language.Notifications.CantAfford):format(CashSymbol, totalCost), 'error')
        return
    end
    addItem(src, itemName, quantity)
    MySQL.update('UPDATE firstaid_stock SET stock = stock - ? WHERE zone_name = ? AND item_name = ?', { quantity, zoneName, itemName })
end)


--reset stock level
RegisterNetEvent('lusty_firstaid:server:ResetStock', function(zoneName, itemName, amount)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return end
    if not zoneName then return end
    if not itemName then return end
    if not amount then return end
    if not hasPerms(source) then 
        SVNotify(source, Config.Language.Notifications.NoAccess, 'error')
        SVDebug(('^3| Lusty94_FirstAid | DEBUG | INFO | Checking %s Stock Level For %s Amount Stocked %s'):format(zoneName, item.name, defaultStock ))
        return
    end
    MySQL.update('UPDATE firstaid_stock SET stock = ? WHERE zone_name = ? AND item_name = ?', { amount, zoneName, itemName })
    SVNotify(source, (Config.Language.Notifications.StockUpdated):format(itemName, zoneName, amount), 'success')
end)


--set stock level on start
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        for zoneName, zoneData in pairs(Config.FirstAid) do
            if zoneData.inventory then
                for _, item in pairs(zoneData.inventory) do
                    local defaultStock = item.stock or 0
                    local row = MySQL.single.await('SELECT stock FROM firstaid_stock WHERE zone_name = ? AND item_name = ?',{zoneName, item.name})
                    if not row then
                        SVDebug(('^3| Lusty94_FirstAid | DEBUG | INFO | Adding Stock | Zone %s | Item %s | Stock: %d'):format(zoneName, item.name, defaultStock))
                        MySQL.insert.await('INSERT INTO firstaid_stock (zone_name, item_name, stock) VALUES (?, ?, ?)',{zoneName, item.name, defaultStock})
                    elseif tonumber(row.stock) ~= defaultStock then
                        SVDebug(('^3| Lusty94_FirstAid | DEBUG | INFO | Updating Stock | Zone %s | Item %s | %d → %d'):format(zoneName, item.name, row.stock, defaultStock))
                        MySQL.update.await('UPDATE firstaid_stock SET stock = ? WHERE zone_name = ? AND item_name = ?', {defaultStock, zoneName, item.name})
                    else
                        SVDebug(('^3| Lusty94_FirstAid | DEBUG | INFO | Current Stock | %s | %s | %d'):format(zoneName, item.name, row.stock))
                    end
                end
            end
        end
    end
end)



--admin command
lib.addCommand('adminstock', {
    help = 'Update or reset stock levels for fist aid zones',
    restricted = false,
}, function(source)
    if not hasPerms(source) then
        SVNotify(source, Config.Language.Notifications.NoAccess, 'error')
        return
    end
    TriggerClientEvent('lusty_firstaid:client:openAdminMenu', source)
end)



--version check
local function CheckVersion()
    PerformHttpRequest('https://raw.githubusercontent.com/Lusty94/UpdatedVersions/main/FirstAid/version.txt', function(err, newestVersion, headers)
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
        if not newestVersion then
            print('^1[Lusty94_FirstAid]^7: Unable to fetch the latest version.')
            return
        end
        newestVersion = newestVersion:gsub('%s+', '')
        currentVersion = currentVersion and currentVersion:gsub('%s+', '') or "Unknown"
        if newestVersion == currentVersion then
            print(string.format('^2[Lusty94_FirstAid]^7: ^6You are running the latest version.^7 (^2v%s^7)', currentVersion))
        else
            print(string.format('^2[Lusty94_FirstAid]^7: ^3Your version: ^1v%s^7 | ^2Latest version: ^2v%s^7\n^1Please update to the latest version | Changelogs can be found in the support discord.^7', currentVersion, newestVersion))
        end
    end)
end
CheckVersion()