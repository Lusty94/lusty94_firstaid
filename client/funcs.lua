local QBCore = exports['qb-core']:GetCoreObject()
local NotifyType = Config.CoreSettings.Notify.Type or 'qb'
local TargetType = Config.CoreSettings.Target.Type or 'qb'
local InvType = Config.CoreSettings.Inventory.Type or 'qb'
local CashSymbol = Config.CoreSettings.Misc.CashSymbol or '$'
local spawnedPeds = {}
local pedBlips = {}
local pedZones = {}
local inReviveZone = false
local busy = false


--sends a client debug print
function CLDebug(msg)
    if not Config.CoreSettings.Debug.Prints then return end
    print(msg)
end


--sends a client notification
function CLNotify(msg, type, time, title)
    if NotifyType == nil then print('^1| Lusty94_FirstAid | DEBUG | ERROR | NotifyType is nil') return end
    if not msg then msg = 'Notification sent with no message' end
    if not type then type = 'success' end
    if not time then time = 5000 end
    if not title then title = 'Notification' end
    if NotifyType == 'qb' then
        QBCore.Functions.Notify(msg,type,time)
    elseif NotifyType == 'qs' then
        exports['qs-interface']:AddNotify(msg, title, time, 'fa-solid fa-clipboard')
    elseif NotifyType == 'okok' then
        exports['okokNotify']:Alert(title, msg, time, type, true)
    elseif NotifyType == 'mythic' then
        exports['mythic_notify']:DoHudText(type, msg)
    elseif NotifyType == 'ox' then
        lib.notify({ title = title, description = msg, position = 'top', type = type, duration = time})
    elseif NotifyType == 'custom' then
        --insert your custom notification function here
    else
        print('^1| Lusty94_FirstAid | DEBUG | ERROR | Unknown Notify Type Set In Config.CoreSettings.Notify.Type | '..tostring(NotifyType))
    end
end


--set busy status
function setBusy(toggle)
    busy = toggle
    CLDebug(('^3| Lusty94_FirstAid | DEBUG | Info | Busy Status %s'):format(tostring(busy)))
end


--lock inventory to prevent exploits
function LockInventory(toggle)
	if toggle then
        LocalPlayer.state:set('inv_busy', true, true)
    else 
        LocalPlayer.state:set('inv_busy', false, true)
    end
    CLDebug(('^3| Lusty94_FirstAid | DEBUG | Info | Inventory Lock %s'):format(tostring(toggle)))
end


---get an item image
function ItemImage(img)
	if InvType == 'ox' then
        if not tostring(img) then CLDebug('^1| Lusty94_FirstAid | DEBUG | ERROR | Item: '.. tostring(img)..' is missing from ox_inventory/data/items.lua!^7') return 'https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png'  end 
		return 'nui://ox_inventory/web/images/'..img..'.png'
	elseif InvType == 'qb' or InvType == 'qs' then
		if not QBCore.Shared.Items[img] then CLDebug('^1| Lusty94_FirstAid | DEBUG | ERROR | Item: '.. tostring(img)..' is missing from qb-core/shared/items.lua!^7') return 'https://files.fivemerr.com/images/54e9ebe7-df76-480c-bbcb-05b1559e2317.png'  end
		return 'nui://qb-inventory/html/images/'..QBCore.Shared.Items[img].image
	elseif InvType == 'custom' then
        -- Insert your own methods for obtaining item images here
	else
        print('| Lusty94_FirstAid | DEBUG | ERROR | Unknown inventory type set in Config.CoreSettings.Inventory.Type | '..tostring(InvType))
	end
end


--get an item label
function ItemLabel(label)
	if InvType == 'ox' then
		local Items = exports['ox_inventory']:Items()
		if not Items[label] then CLDebug('^1| Lusty94_FirstAid | DEBUG | ERROR | Item: '.. tostring(label)..' is missing from ox_inventory/data/items.lua!^7') return '❌ The item: '..tostring(label)..' is missing from your items.lua! ' end
		return Items[label]['label']
    elseif InvType == 'qb' or InvType == 'qs' then
		if not QBCore.Shared.Items[label] then CLDebug('^1| Lusty94_FirstAid | DEBUG | ERROR | Item: '.. tostring(label)..' is missing from qb-core/shared/items.lua!^7') return '❌ The item: '..tostring(label)..' is missing from your items.lua! ' end
		return QBCore.Shared.Items[label]['label']
	elseif InvType == 'custom' then
        -- Insert your own methods for obtaining item labels here
	else
        print('| Lusty94_FirstAid | DEBUG | ERROR | Unknown inventory type set in Config.CoreSettings.Inventory.Type | '..tostring(InvType))
	end
end


--check status
function checkStatus()
    local info = QBCore.Functions.GetPlayerData()
    return info.metadata.inlaststand or info.metadata.isdead
end


--main menu
function reviveMenu(zoneName)
    CLDebug(('^3| Lusty94_FirstAid | DEBUG | INFO | Opening revive menu for zone %s'):format(zoneName))
    local ped = spawnedPeds[zoneName]
    if not ped or not DoesEntityExist(ped) then return end
    local pedCoords = GetEntityCoords(spawnedPeds[zoneName])
    local playerCoords = GetEntityCoords(cache.ped)
    local options = {}
    if checkStatus() then
        options [#options+1] = {
            title = 'Get Revived',
            description = 'Receive treatment from the medic',
            icon = 'fa-solid fa-heart-pulse',
            arrow = true,
            canInteract = function()
                return inReviveZone and not busy
            end,
            onSelect = function()
                local playerID = GetPlayerServerId(PlayerId())
                local isDowned = lib.callback.await('lusty_firstaid:server:IsPlayerDowned', false, playerID)
                if not isDowned then CLNotify(Config.Language.Notifications.NotDownOrDead, 'error') return end
                setBusy(true)
                LockInventory(true)
                TriggerServerEvent('lusty_firstaid:server:revivePlayer', cache.serverId, zoneName, pedCoords, playerCoords)
            end,
        }
    end
    if not checkStatus() then
        options [#options+1] = {
        title = 'Buy Medical Contraband',
            description = 'Purchase stolen medical items',
            icon = 'fa-solid fa-kit-medical',
            arrow = true,
            canInteract = function()
                return inReviveZone and not busy
            end,
            onSelect = function()
                CLDebug(('^3| Lusty94_FirstAid | DEBUG | INFO | Opening shop for zone %s'):format(zoneName))
                TriggerEvent('lusty_firstaid:client:OpenShopMenu', zoneName, pedCoords, playerCoords)
            end,
        }
    end
    lib.registerContext({
        id = 'lusty_firstaid_main_menu',
        title = zoneName,
        options = options
    })
    lib.showContext('lusty_firstaid_main_menu')
end


--create peds
function createPeds()
    for zoneName, data in pairs(Config.FirstAid) do
        local coords = data.zone.coords
        local zone = lib.zones.sphere({
            coords = coords.xyz,
            radius = data.zone.radius,
            debug = data.zone.debug,
            inside = function() inReviveZone = true end,
            onExit = function() inReviveZone = false end
        })
        pedZones[#pedZones+1] = zone
        CLDebug(('^3| Lusty94_FirstAid | DEBUG | INFO | Zone Created | %s |'):format(zoneName))
        local model = data.target.ped
        lib.requestModel(model, 30000)
        local ped = CreatePed(0, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        spawnedPeds[zoneName] = ped
        CLDebug(('^3| Lusty94_FirstAid | DEBUG | INFO | Ped Created | %s | %s |'):format(model, coords))
        if TargetType == 'ox' then
            exports.ox_target:addLocalEntity(ped, {
                {
                    icon = data.target.icon,
                    label = data.target.label,
                    distance = data.target.distance or 2.5,
                    onSelect = function()
                        reviveMenu(zoneName)
                    end,
                    canInteract = function()
                        return inReviveZone and not busy
                    end
                },
            })
        elseif TargetType == 'qb' then
            exports['qb-target']:AddTargetEntity(ped, {
                options = {
                    {
                        icon = data.target.icon,
                        label = data.target.label,
                        distance = data.target.distance or 2.5,
                        action = function()
                            reviveMenu(zoneName)
                        end,
                        canInteract = function()
                            return inReviveZone and not busy
                        end
                    },
                },
                distance = data.target.distance or 2.5
            })
        end
        if data.blips and data.blips.enabled then
            local blip = AddBlipForCoord(coords.xyz)
            SetBlipSprite(blip, data.blips.id)
            SetBlipColour(blip, data.blips.colour)
            SetBlipScale(blip, data.blips.scale)
            SetBlipDisplay(blip, 4)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(data.blips.title)
            EndTextCommandSetBlipName(blip)
            pedBlips[#pedBlips + 1] = blip
            CLDebug(('^3| Lusty94_FirstAid | DEBUG | INFO | Blip Created | %s | %s | %s |'):format(zoneName, coords, data.blips.title ))
        end
    end
end


--open shop stock
function stockShop(zoneName)
    CLDebug(('^3| Lusty94_FirstAid | DEBUG | INFO | Admin Stock Menu Opened | %s'):format(zoneName))
    local data = Config.FirstAid[zoneName]
    if not data or not data.inventory then return end
    local stockData = lib.callback.await('lusty_firstaid:server:GetItemStock', false, zoneName) or {}
    local itemMenu = {}
    for _, item in pairs(data.inventory) do
        local name = item.name
        local label = ItemLabel(name)
        local stock = stockData[name] or 0
        CLDebug(('^3| Lusty94_FirstAid | DEBUG | INFO | Current Stock Levels | %s | %s | %d'):format(zoneName, label, stock))
        table.insert(itemMenu, {
            title = ('%s (%s in stock)'):format(label, stock),
            icon = ItemImage(name),
            arrow = true,
            description = 'Click to update this item\'s stock',
            onSelect = function()
                TriggerEvent('lusty_firstaid:client:resetStockItem', zoneName, name, stock)
            end
        })
    end
    lib.registerContext({
        id = 'revive_admin_items_'..zoneName,
        title = 'Stock: '..zoneName,
        menu = 'revive_admin_shops',
        options = itemMenu
    })
    lib.showContext('revive_admin_items_'..zoneName)
end


--revive player
RegisterNetEvent('lusty_firstaid:client:revivePlayer', function(reviveData, zoneName, pedCoords, playerCoords)
    local playerPed = PlayerPedId()
    local coords = reviveData.coords
    local spawnCoords = reviveData.spawnCoords
    local revivePed = spawnedPeds[zoneName]
    DoScreenFadeOut(1000)
    while not IsScreenFadedOut() do Wait(100) end
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z, false, false, false, true)
    SetEntityHeading(playerPed, coords.w)
    FreezeEntityPosition(playerPed, true)
    Wait(500)
    DoScreenFadeIn(1000)
    Wait(1000)
    if revivePed and DoesEntityExist(revivePed) then
        RequestAnimDict(reviveData.anim.dict)
        while not HasAnimDictLoaded(reviveData.anim.dict) do Wait(1000) end
        TaskPlayAnim(revivePed, reviveData.anim.dict, reviveData.anim.anim, 8.0, -8.0, -1, reviveData.anim.flag or 1, 0, false, false, false)
    end
    lib.progressCircle({
        duration = reviveData.duration or 10000,
        label = reviveData.label or 'Receiving treatment...',
        position = 'bottom',
        useWhileDead = true,
        disable = { move = true, combat = true, car = true },
    })
    DoScreenFadeOut(1000)
    while not IsScreenFadedOut() do Wait(100) end
    if revivePed and DoesEntityExist(revivePed) then
        ClearPedTasks(revivePed)
    end
    FreezeEntityPosition(playerPed, false)
    ClearPedTasks(playerPed)
    SetEntityCoords(playerPed, spawnCoords.x, spawnCoords.y, spawnCoords.z, false, false, false, true)
    Wait(500)
    DoScreenFadeIn(1000)
    local ped = spawnedPeds[zoneName]
    if not ped or not DoesEntityExist(ped) then return end
    local pedCoords = GetEntityCoords(ped)
    local playerCoords = GetEntityCoords(cache.ped)
    TriggerServerEvent('lusty_firstaid:server:revive', pedCoords, playerCoords)
    setBusy(false)
    LockInventory(false)
end)


--open shop menu
RegisterNetEvent('lusty_firstaid:client:OpenShopMenu', function(zoneName, pedCoords, playerCoords)
    CLDebug(('^3| Lusty94_FirstAid | DEBUG | INFO | Opening Shop Menu | %s'):format(zoneName))
    local reviveData = Config.FirstAid[zoneName]
    if not reviveData or not reviveData.inventory then CLDebug(('^1| Lusty94_FirstAid | DEBUG | ERROR | Missing Inventory Config | %s'):format(zoneName)) return end
    local stockData = lib.callback.await('lusty_firstaid:server:GetItemStock', false, zoneName)
    if not stockData then CLDebug(('^1| Lusty94_FirstAid | DEBUG | ERROR | No Stock Data | %s'):format(zoneName)) return end
    local menu = {}
    for _, item in pairs(reviveData.inventory) do
        local itemName = item.name
        local label = ItemLabel(itemName)
        local image = ItemImage(itemName)
        local price = item.price or 0
        local stock = tonumber(stockData[itemName]) or 0
        if stock <= 0 then
            table.insert(menu, {
                title = ('%s (Out of Stock)'):format(label),
                description = 'Item is currently unavailable',
                icon = image,
                disabled = true,
            })
        else
            table.insert(menu, {
                title = ('%s (%s%s)'):format(label, CashSymbol, price),
                description = ('Available: %s'):format(stock),
                icon = image,
                onSelect = function()
                    CLDebug(('^3| Lusty94_FirstAid | DEBUG | INFO | Item Selected | %s | %s'):format(itemName, zoneName))
                    setBusy(true)
                    LockInventory(true)
                    local input = lib.inputDialog('Purchase '..label, {
                        {
                            type = 'slider',
                            label = 'Amount',
                            min = 1,
                            max = stock,
                            default = 1,
                            icon = 'hashtag',
                        },
                        {
                            type = 'select',
                            label = 'Payment Method',
                            icon = 'money-bill-wave',
                            required = true,
                            options = {
                                { label = 'Cash', value = 'cash' },
                                { label = 'Bank', value = 'bank' },
                            }
                        },
                    })
                    if not input then setBusy(false) LockInventory(false) return end
                    local quantity = tonumber(input[1])
                    local paymentType = input[2]
                    local totalCost = price * quantity
                    local confirm = lib.alertDialog({
                        header = 'Confirm Purchase',
                        content = ('%sx %s\nTotal: %s%d\nContinue?'):format(quantity, label, CashSymbol, totalCost),
                        centered = true,
                        cancel = true
                    })
                    if confirm ~= 'confirm' then
                        setBusy(false)
                        LockInventory(false)
                        return
                    end
                    TriggerServerEvent('lusty_firstaid:server:BuyItem', zoneName, itemName, quantity, pedCoords, playerCoords, paymentType)
                    setBusy(false)
                    LockInventory(false)
                end
            })
        end
    end
    lib.registerContext({
        id = 'item_shop_menu',
        title = 'Stolen Medical Supplies',
        options = menu,
        menu = 'lusty_firstaid_main_menu',
    })
    lib.showContext('item_shop_menu')
end)


--admin menu
RegisterNetEvent('lusty_firstaid:client:openAdminMenu', function()
    local hasPerms = lib.callback.await('lusty_firstaid:server:checkPerms', false)
    if not hasPerms then return CLNotify(Config.Language.Notifications.NoAccess, 'error') end
    local shopMenu = {}
    for zoneName, data in pairs(Config.FirstAid) do
        shopMenu[#shopMenu+1] = {
            title = zoneName,
            icon = 'store',
            description = 'View or edit stock for this levels shop',
            arrow = true,
            onSelect = function()
                stockShop(zoneName)
            end
        }
    end
    lib.registerContext({
        id = 'revive_admin_shops',
        title = 'First Aid Admin',
        options = shopMenu
    })
    lib.showContext('revive_admin_shops')
end)


--reset stock level
RegisterNetEvent('lusty_firstaid:client:resetStockItem', function(zoneName, itemName, currentStock)
    local itemLabel = ItemLabel(itemName) 
    local shopData = Config.FirstAid[zoneName]
    local maxStock
    if shopData and shopData.inventory then
        for _, item in pairs(shopData.inventory) do
            if item.name == itemName then
                maxStock = item.stock or 100
                break
            end
        end
    end
    local input = lib.inputDialog('Set Stock Amount', {
        {
            type = 'slider',
            label = ('Set stock for %s'):format(itemLabel),
            icon = 'hashtag',
            min = 0,
            max = maxStock,
            default = currentStock
        }
    })
    if not input then return end
    local amount = tonumber(input[1])
    TriggerServerEvent('lusty_firstaid:server:ResetStock', zoneName, itemName, amount)
    CLDebug(('^3| Lusty94_FirstAid | DEBUG | INFO | Updating Stock Level | %s | %s | %d'):format(itemName, zoneName, amount))
end)


--just because quasar doesnt support server side notifys
RegisterNetEvent('lusty_firstaid:client:notify', function(msg, type, time)
    CLNotify(msg, type, time)
end)


--toggle status
RegisterNetEvent('lusty_firstaid:client:toggleStatus', function()
    setBusy(false)
    LockInventory(false)
end)


--dont touch
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    while not LocalPlayer.state.isLoggedIn do Wait(1000) end
    createPeds()
end)


--dont touch
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        createPeds()
    end
end)


--cleanup
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        setBusy(false)
        LockInventory(false)
        for _, ped in pairs(spawnedPeds) do
            if TargetType == 'ox' then
                exports.ox_target:removeLocalEntity(ped)
            elseif TargetType == 'qb' then
                exports['qb-target']:RemoveTargetEntity(ped)
            end
            if DoesEntityExist(ped) then DeleteEntity(ped) end
            spawnedPeds = {}
        end
        for _, zone in pairs(pedZones) do
            if zone and zone.destroy then zone:destroy() end
            pedZones = {}
        end
        for _, blip in pairs(pedBlips) do
            if DoesBlipExist(blip) then RemoveBlip(blip) end
        end
        print('^2| Lusty94_FirstAid | DEBUG | INFO | Resource stopped')
    end
end)