Store = Store or {}
Store.Database = Store.Database or {}

STORE_BOOSTER_ID = 0

DonationRoles = DonationRoles or {}
DonationRoles.Database = DonationRoles.Database or {}

CustomJobs = CustomJobs or {}

function Store:CreateFont(name, size, weight)
	surface.CreateFont(name, {
		font = "Montserrat",
		size = size,
		weight = weight or 500
	})
end

function IncludeClient(path)
	if (CLIENT) then
		include(path .. ".lua")
	end

	if (SERVER) then
		AddCSLuaFile(path .. ".lua")
	end
end

function IncludeServer(path)
	if (SERVER) then
		include(path .. ".lua")
	end
end

function IncludeShared(path)
	IncludeServer(path)
	IncludeClient(path)
end

MsgC(Color(0, 136, 255), "Loading Store...\n")

IncludeClient("store/ui/frame")
IncludeClient("store/ui/menu")
IncludeClient("store/ui/tab_packages")
IncludeClient("store/ui/tab_misc")
IncludeClient("store/ui/tab_weapons")
IncludeClient("store/ui/text_effects")
IncludeClient("store/ui/network")
IncludeShared("store/shared/config")
IncludeShared("store/shared/player")
IncludeServer("store/server/network")
IncludeServer("store/server/database")
IncludeServer("store/server/player")
MsgC(Color(179, 255, 0), "Loading Donation...\n")

IncludeShared("donation/shared/player")
IncludeServer("donation/server/player")
IncludeServer("donation/server/network")
IncludeServer("donation/server/database")
IncludeClient("donation/client/network")

MsgC(Color(179, 255, 0), "Loading Printers...\n")

IncludeShared("printers/skins")
IncludeServer("printers/neto")
IncludeClient("printers/menu")

MsgC(Color(0, 255, 0), "Finished!!!\n")