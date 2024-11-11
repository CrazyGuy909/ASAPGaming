local GUMBALL = {}

GUMBALL.id = 17
GUMBALL.name = "Printer Power"
GUMBALL.description = [[Gives you 2x more money from the printers when you collect them]]
GUMBALL.price = 10
GUMBALL.icon = Material("asap_gumballs/balls/printer_power.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Orange
GUMBALL.activeTime = 60 * 10
GUMBALL.Unobtainable = false

function GUMBALL.OnGumballEquip(ply)

end

function GUMBALL.OnGumballDequip(ply)

end

function GUMBALL.OnGumballExpire(ply)
	ply.doubleprintermoney = false
end

function GUMBALL.OnGumballUse(ply)
	ply.doubleprintermoney = true
end

--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)