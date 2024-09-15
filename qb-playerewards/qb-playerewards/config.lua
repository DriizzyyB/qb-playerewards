-- config.lua
Config = {}

Config.RewardInterval = 30 * 60 * 1000 -- 30 minutes (Set intervals for rewards)
Config.CoinsPerInterval = 25 -- (Set coins players get)
Config.ReminderInterval = 5 * 60 * 1000 -- 2 minutes (Set intervals for reminders if Discord Webhook is setup)
Config.ShopItems = {  -- (Sets items available to buy with coins via chat command /openShop. MAKE SURE ONLY THE S IS CAPITAL OR COMMAND WONT WORK)
    {name = 'Walther99', item = 'weapon_pistol', price = 250},
    {name = 'Bandage', item = 'bandage', price = 50},
    {name = 'Joint', item = 'joint', price = 75},
    {name = 'Rolex Watch', item = 'rolex', price = 500},
    {name = 'Glock 17', item = 'weapon_combatpistol', price = 1000}
}

Config.AdminLicenses = { 'license:' } -- Add your FiveM licenses here
Config.DiscordWebhook = '' -- Add your Discord webhook URL here