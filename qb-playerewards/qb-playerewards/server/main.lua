-- server/main.lua
QBCore = exports['qb-core']:GetCoreObject()
local rewardTimer = Config.RewardInterval
local reminderTimer = Config.ReminderInterval

-- Reward players with coins over time
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check every second
        rewardTimer = rewardTimer - 1000
        reminderTimer = reminderTimer - 1000

        if rewardTimer <= 0 then
            rewardTimer = Config.RewardInterval
            for _, playerId in ipairs(GetPlayers()) do
                local xPlayer = QBCore.Functions.GetPlayer(tonumber(playerId))
                if xPlayer then
                    local coins = xPlayer.PlayerData.metadata['coins'] or 0
                    xPlayer.Functions.SetMetaData('coins', coins + Config.CoinsPerInterval)
                    TriggerClientEvent('QBCore:Notify', xPlayer.PlayerData.source, 'You received ' .. Config.CoinsPerInterval .. ' coins!', 'success')

                    -- Log to Discord
                    sendDiscordLog(
                        "Player Earned Coins",
                        xPlayer.PlayerData.name .. " earned " .. Config.CoinsPerInterval .. " coins. New balance: " .. (coins + Config.CoinsPerInterval),
                        65280 -- Green color
                    )
                end
            end
        end

        if reminderTimer <= 0 then
            reminderTimer = Config.ReminderInterval
            local timeRemaining = math.ceil(rewardTimer / 60000)
            for _, playerId in ipairs(GetPlayers()) do
                local xPlayer = QBCore.Functions.GetPlayer(tonumber(playerId))
                if xPlayer then
                    TriggerClientEvent('QBCore:Notify', xPlayer.PlayerData.source, 'Next reward in ' .. timeRemaining .. ' minutes.', 'info')
                end
            end
            -- Send reminder to Discord
            sendDiscordLog(
                "Reward Reminder",
                "Next reward in " .. timeRemaining .. " minutes.",
                3447003 -- Blue color
            )
        end
    end
end)

-- Shop item purchase event
RegisterServerEvent('shop:buyItem')
AddEventHandler('shop:buyItem', function(item)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local coins = xPlayer.PlayerData.metadata['coins'] or 0

    -- Debugging: Print current coin balance
    print('Current Coins:', coins)

    for _, shopItem in ipairs(Config.ShopItems) do
        if shopItem.item == item then
            if coins >= shopItem.price then
                xPlayer.Functions.SetMetaData('coins', coins - shopItem.price)
                xPlayer.Functions.AddItem(shopItem.item, 1)
                TriggerClientEvent('QBCore:Notify', src, 'You bought ' .. shopItem.name, 'success')

                -- Log to Discord
                sendDiscordLog(
                    "Player Purchased Item",
                    xPlayer.PlayerData.name .. " bought " .. shopItem.name .. " for " .. shopItem.price .. " coins. New balance: " .. (coins - shopItem.price),
                    15158332 -- Red color
                )
            else
                TriggerClientEvent('QBCore:Notify', src, 'Not enough coins!', 'error')
            end
            return
        end
    end
end)

-- Function to get player identifiers
local function getPlayerIdentifiers(playerId)
    local identifiers = GetPlayerIdentifiers(playerId)
    for _, id in ipairs(identifiers) do
        if string.find(id, "license:") then
            return id
        end
    end
    return nil
end

-- Function to check if a license is in the admin list
local function isAdmin(playerLicense)
    for _, license in ipairs(Config.AdminLicenses) do
        if license == playerLicense then
            return true
        end
    end
    return false
end

-- Admin command to give coins
QBCore.Commands.Add('givecoins', 'Give coins to a player (Admin Only)', {{name = 'id', help = 'Player ID'}, {name = 'amount', help = 'Amount of coins'}}, true, function(source, args)
    local src = source
    local playerLicense = getPlayerIdentifiers(src)

    if playerLicense and isAdmin(playerLicense) then
        local targetId = tonumber(args[1])
        local amount = tonumber(args[2])
        if targetId and amount then
            local targetPlayer = QBCore.Functions.GetPlayer(targetId)
            if targetPlayer then
                local currentCoins = targetPlayer.PlayerData.metadata['coins'] or 0
                targetPlayer.Functions.SetMetaData('coins', currentCoins + amount)
                TriggerClientEvent('QBCore:Notify', targetId, 'You received ' .. amount .. ' coins from an admin!', 'success')
                TriggerClientEvent('QBCore:Notify', src, 'You gave ' .. amount .. ' coins to ' .. targetPlayer.PlayerData.name, 'success')
                
                -- Debugging: Print new coin balance
                print('New Coins for Player:', targetId, targetPlayer.PlayerData.metadata['coins'])

                -- Log to Discord
                sendDiscordLog(
                    "Admin Gave Coins",
                    targetPlayer.PlayerData.name .. " received " .. amount .. " coins from an admin. New balance: " .. (currentCoins + amount),
                    16776960 -- Yellow color
                )
            else
                TriggerClientEvent('QBCore:Notify', src, 'Player not found', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'Invalid arguments', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'You do not have permission to use this command', 'error')
    end
end, 'admin')

-- Function to send logs to Discord
function sendDiscordLog(title, description, color)
    local embed = {
        {
            ["title"] = title,
            ["description"] = description,
            ["color"] = color,
            ["footer"] = {
                ["text"] = os.date("%Y-%m-%d %H:%M:%S")
            }
        }
    }

    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({embeds = embed}), { ['Content-Type'] = 'application/json' })
end
