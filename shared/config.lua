Config = {}

--
--██╗░░░░░██╗░░░██╗░██████╗████████╗██╗░░░██╗░█████╗░░░██╗██╗
--██║░░░░░██║░░░██║██╔════╝╚══██╔══╝╚██╗░██╔╝██╔══██╗░██╔╝██║
--██║░░░░░██║░░░██║╚█████╗░░░░██║░░░░╚████╔╝░╚██████║██╔╝░██║
--██║░░░░░██║░░░██║░╚═══██╗░░░██║░░░░░╚██╔╝░░░╚═══██║███████║
--███████╗╚██████╔╝██████╔╝░░░██║░░░░░░██║░░░░█████╔╝╚════██║
--╚══════╝░╚═════╝░╚═════╝░░░░╚═╝░░░░░░╚═╝░░░░╚════╝░░░░░░╚═╝


--Thank you for downloading this script!

--Below you can change multiple options to suit your server needs.

--If you do not want to use any of the pre-configured locations then remove all the necessary logic for them throughout this config file

--Extensive documentation detailing this script and how to confiure it correclty can be found here: https://lusty94-scripts.gitbook.io/documentation/free/first-aid


Config.CoreSettings = {
    Debug = {
        Prints = true, -- sends debug prints to f8 console and txadmin server console
    },
     Security = {
        MaxDistance = 15.0, -- max distance permitted for security checks
        KickPlayer = true, -- set to true to kick players for failed security checks
        Logs = {
            Enabled = false, -- enable logs for events with detailed information
            Type = 'fm-logs', -- type of logging, support for fm-logs(preferred) or discord webhook (not recommended)
            --use 'fm-logs' for fm-logs (if using this ensure you have setup the resource correctly and it is started before this script)
            --use 'discord' for discord webhooks (if using this make sure to set your webhook URL in the sendLog function in vehicleshop_server.lua)
        },
    },
    Misc = {
        CashSymbol = '£', -- cash symbol used in your server
    },
    Notify = { -- notification type - support for qb-core notify okokNotify, mythic_notify, ox_lib notify and qs-notify (experimental not tested)
        --EDIT CLIENT.LUA & SERVER.LUA TO ADD YOUR OWN NOTIFY SUPPORT
        Type = 'ox',
        --use 'qb' for default qb-core notify
        --use 'okok' for okokNotify
        --use 'mythic' for mythic_notify
        --use 'ox' for ox_lib notify
        --use 'qs' for qs-notify (experimental not tested) (qs-interface)  -- some logic might need adjusting
        --use 'custom' for custom notifications
    },
    Target = {
        Type = 'qb', -- target script name support for qb-target and ox_target        
        -- EDIT CLIENT/FUNCS.LUA TO ADD YOUR OWN TARGET SUPPORT
        -- use 'qb' for qb-target
        -- use 'ox' for ox_target
        -- use 'custom' for custom target
    },
    Inventory = { -- inventory type - support for qb-inventory ox_inventory
        --EDIT CLIENT.LUA & SERVER.LUA TO ADD YOUR OWN INVENTORY SUPPORT
        Type = 'qb',
        --use 'qb' for qb-inventory
        --use 'ox' for ox_inventory
        --use 'custom' for custom inventory
    },
}



Config.FirstAid = {
    ['Grandma Gladdis'] = { -- the key is the name
        zone = { -- info settings
            coords = vector4(-178.62, 6387.57, 25.72, 142.06), -- spawn coords
            debug = false, -- debug zone
            radius = 3.0, -- zone radius
        },
        blips = { -- blip settings for shop
            enabled = true, -- blip enabled
            id = 51, -- blip id
            colour = 2, -- blip colour
            scale = 0.6, -- bliip scale
            title = 'Revive Point', -- blip title
        },
        target = { -- target settings
            ped = 'a_f_m_eastsa_01', -- ped model
            icon = 'fa-solid fa-hand-point-up', -- target icon
            label = 'Medical Services', -- target label
            distance = 2.0, -- target distance
        },
        revive = { -- operating table settings
            coords = vector4(-178.86, 6386.77, 26.0, 222.55), -- operating table coords to put injured ped
            spawnCoords = vector4(-179.76, 6386.55, 25.72, 219.06),
            duration = 10000, -- duration of revival for progressCircle
            label = 'Receiving treatment',
            cost = 500, -- cost to get revived
            anim = { -- animation settings
                anim = 'fixing_a_ped', -- animation name
                dict = 'mini@repair', -- animation dict
                flag = 49, -- animation flag
            },
        },
        inventory = {
            {name = 'bandage',          price = 100,  stock = 100, },
            {name = 'ifaks',            price = 100,  stock = 100, },
            {name = 'painkillers',      price = 100,  stock = 100, },
            --add more items as required
        },
    },
    ['Grandpa Ron'] = { -- the key is the name
        zone = { -- info settings
            coords = vector4(2436.19, 4966.57, 42.35, 93.53), -- spawn coords
            debug = false, -- debug zone
            radius = 3.0, -- zone radius
        },
        target = { -- target settings
            ped = 'a_m_o_genstreet_01', -- ped model
            icon = 'fa-solid fa-hand-point-up', -- target icon
            label = 'Medical Services', -- target label
            distance = 2.0, -- target distance
        },
        blips = { -- blip settings for shop
            enabled = true, -- blip enabled
            id = 51, -- blip id
            colour = 2, -- blip colour
            scale = 0.6, -- bliip scale
            title = 'Revive Point', -- blip title
        },
        revive = { -- operating table settings
            coords = vector4(2435.33, 4966.51, 41.35, 197.78), -- operating table coords to put injured ped
            spawnCoords = vector4(2435.33, 4966.51, 42.35, 197.78),
            duration = 10000, -- duration of revival for progressCircle
            label = 'Receiving treatment',
            cost = 500, -- cost to get revived
            anim = { -- animation settings
                anim = 'fixing_a_ped', -- animation name
                dict = 'mini@repair', -- animation dict
                flag = 49, -- animation flag
            },
        },
        inventory = {
            {name = 'bandage',          price = 100, stock = 100, },
            {name = 'ifaks',            price = 100, stock = 100, },
            {name = 'painkillers',      price = 100, stock = 100, },
            --add more items as required
        },
    },
    ['Doctor Hernandez'] = { -- the key is the name
        zone = { -- info settings
            coords = vector4(-622.08, 312.57, 83.93, 171.57), -- spawn coords
            debug = false, -- debug zone
            radius = 3.0, -- zone radius
        },
        target = { -- target settings
            ped = 's_m_m_doctor_01', -- ped model
            icon = 'fa-solid fa-hand-point-up', -- target icon
            label = 'Medical Services', -- target label
            distance = 2.0, -- target distance
        },
        blips = { -- blip settings for shop
            enabled = true, -- blip enabled
            id = 51, -- blip id
            colour = 2, -- blip colour
            scale = 0.6, -- bliip scale
            title = 'Revive Point', -- blip title
        },
        revive = { -- operating table settings
            coords = vector4(-622.29, 311.43, 82.93, 266.18), -- operating table coords to put injured ped
            spawnCoords = vector4(-622.29, 311.43, 83.93, 266.18),
            duration = 10000, -- duration of revival for progressCircle
            label = 'Receiving treatment',
            cost = 500, -- cost to get revived
            anim = { -- animation settings
                anim = 'fixing_a_ped', -- animation name
                dict = 'mini@repair', -- animation dict
                flag = 49, -- animation flag
            },
        },
        inventory = {
            {name = 'bandage',          price = 100, stock = 100, },
            {name = 'ifaks',            price = 100, stock = 100, },
            {name = 'painkillers',      price = 100, stock = 100, },
            --add more items as required
        },
    },
}



Config.Language = {
    Notifications = {
        Busy = 'You are already doing something',
        Cancelled = 'Action cancelled',
        CantGive = 'Cant give item',
        NoAccess = 'You dont have access to this',
        NotDownOrDead = 'You are not downed or dead',
        Cooldown = 'You must wait a short while before getting treatment again',
        CantAfford = 'Not enough cash %s%s required',
        InvalidQuantity = 'Invalid quantity selected',
        NotEnoughStock = 'Not enough in stock',
        StockUpdated = '%s stock in %s set to %d',
    },
}