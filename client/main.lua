-- client/main.lua
local QBCore = exports['qb-core']:GetCoreObject()

-- Function to open the shop menu
local function openShop()
    local playerData = QBCore.Functions.GetPlayerData()
    local coins = playerData.metadata.coins or 0
    local menuItems = {}

    -- Add coin balance to the menu header
    table.insert(menuItems, {
        header = 'Your Coins: ' .. coins,
        isMenuHeader = true
    })

    -- Add items to the shop menu
    for _, item in ipairs(Config.ShopItems) do
        table.insert(menuItems, {
            header = item.name .. ' - ' .. item.price .. ' coins',
            txt = '',
            params = {
                event = 'shop:client:buyItem',
                args = {
                    item = item.item
                }
            }
        })
    end

    -- Add a close option
    table.insert(menuItems, {
        header = 'Close',
        params = {
            event = 'qb-menu:client:closeMenu'
        }
    })

    -- Open the qb-menu
    exports['qb-menu']:openMenu(menuItems)
end

-- Register command to open the shop
RegisterCommand('openShop', function()
    openShop()
end, false)

-- Event to handle item purchase
RegisterNetEvent('shop:client:buyItem')
AddEventHandler('shop:client:buyItem', function(data)
    TriggerServerEvent('shop:buyItem', data.item)
end)
