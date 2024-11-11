local GUMBALL = {}

if SERVER then
	util.AddNetworkString("ASAP_FIRE_SALE")
end

GUMBALL.id = 6
GUMBALL.name = "Firesale"
GUMBALL.description = [[Everything in the F4 menu costs 50% less.
]]
GUMBALL.price = 10
GUMBALL.icon = Material("asap_gumballs/balls/firesale.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Blue
GUMBALL.activeTime = 50

function GUMBALL.OnGumballEquip(ply)

end

function GUMBALL.OnGumballDequip(ply)

end

function GUMBALL.OnGumballExpire(ply)
	ply.firesale = false
	net.Start("ASAP_FIRE_SALE")
	net.WriteBool(false)
	net.Send(ply)
end

function GUMBALL.OnGumballUse(ply)
	ply.firesale = true
	net.Start("ASAP_FIRE_SALE")
	net.WriteBool(true)
	net.Send(ply)
end

if CLIENT then
	net.Receive("ASAP_FIRE_SALE", function()
		LocalPlayer().firesale = net.ReadBool()
	end)
end

--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)