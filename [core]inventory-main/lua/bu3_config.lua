
--[[-------------------------------------------------------------------------
READ ME

Thank you for purchasing my addon, it helps me out so much!
If you are having any issues at all with the addon instead of reaching for the 
script review button instead open a support ticket!

If you enjoy the script then please leave a review, it helps out alot.

!!!!!!!!!!!!!!!
WORKSHOP LINK : https://steamcommunity.com/sharedfiles/filedetails/?id=1369926934
!!!!!!!!!!!!!!!

Below is a list of console commands that come with the addon

"bu3_items"
This console command prints out a list of all registered items and there ID for when you need it

"bu3_give <STEAMID64> <ITEM ID> <AMOUNT>"
This will give an online player the item and the amount.

"bu3_give_all <ITEM ID> <AMOUNT>"
Gives all the online players that item and amount

"bu3_wipe <STEAMID64>"
This will delete a players inventory

To edit the MySQL setting please refer to the other config (bu3_sql_config.lua)

If you need any help please contact me via support ticket or on steam/message.

]]
--[[-------------------------------------------------------------------------
CONFIG
---------------------------------------------------------------------------]]
BU3.Config = {}


--[[-------------------------------------------------------------------------
If true, this will print in everyones chat when someone unboxes, false it will not.
---------------------------------------------------------------------------]]
BU3.Config.ChatNotifications = false

--[[-------------------------------------------------------------------------
This is the currency to use for the store, "ps1", "ps2", "darkrp", "custom"
---------------------------------------------------------------------------]]
BU3.Config.Currency = "darkrp"
if not asapMarket then
    asapMarket = {}
end

asapMarket.API = "http://45.62.160.35:2052"
--[[-------------------------------------------------------------------------
These are the admin ranks, capable of creating, delete and modify items as
well as being able to modify a users inventory, This also bypasses the "rank restriction"
on some times if they have a rank in here
---------------------------------------------------------------------------]]
BU3.Config.AdminRanks = {
	"owner",
	"superadmin",
}

--[[-------------------------------------------------------------------------
This is resposible for random drops of items
Using the item ID in the table below
---------------------------------------------------------------------------]]
BU3.Config.DropItems = {
	293, 1163, 1164, 1165, 1166, 1167, 1168, 1169, 1063, 1065, 1066
}

BU3.Config.RareDropItems = {
	292, 1068, 1072, 1067, 1183, 1173
}

BU3.Config.RareDropChance = 50
BU3.Config.RareDropTime = 20

BU3.Config.DropChance = 50 --This is the chance a user will receive an item
BU3.Config.DropTime = 30 --Drop a crate every 30 minutes
--[[-------------------------------------------------------------------------
These functions are for when you are using a "custom" currency in the config
---------------------------------------------------------------------------]]
BU3.Config.CanAfford = function(ply, amount)
	return false
end

BU3.Config.AddMoney = function(ply, amount)
	return false
end

BU3.Config.TakeMoney = function(ply, amount)
	return false
end