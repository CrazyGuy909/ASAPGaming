local GUMBALL = {}

if SERVER then
	util.AddNetworkString("ASAP_PERK_PURCHASE")
end

GUMBALL.id = 8
GUMBALL.name = "Perk Purchase"
GUMBALL.description = [[All the perks cost 35% less.
]]
GUMBALL.price = 10
GUMBALL.icon = Material("asap_gumballs/balls/perk_pruchase.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Blue
GUMBALL.activeTime = 60 * 6

function GUMBALL.OnGumballEquip(ply)

end

function GUMBALL.OnGumballDequip(ply)

end

function GUMBALL.OnGumballExpire(ply)
	ply.perk_purchase = true
	net.Start("ASAP_PERK_PURCHASE")
	net.WriteBool(false)
	net.Send(ply)
end

function GUMBALL.OnGumballUse(ply)
	ply.perk_purchase = true
	net.Start("ASAP_PERK_PURCHASE")
	net.WriteBool(true)
	net.Send(ply)
end

if CLIENT then
	net.Receive("ASAP_PERK_PURCHASE", function()
		LocalPlayer().perk_purchase = net.ReadBool()
	end)
end

--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)