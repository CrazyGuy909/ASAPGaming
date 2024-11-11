local GUMBALL = {}

GUMBALL.id = 2
GUMBALL.name = "Stock Option"
GUMBALL.description = [[Uses ammo from your reserve instead of from your clip.

*Green Gobble Gums are permanent
]]
GUMBALL.price = 1000
GUMBALL.icon = Material("asap_gumballs/balls/stock_option.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Green
GUMBALL.activeTime = 60 * 5 --5 minutes
GUMBALL.Unobtainable = true
function GUMBALL.OnGumballEquip(ply)

end

function GUMBALL.OnGumballDequip(ply)

end

function GUMBALL.OnGumballExpire(ply)
	ply.stock_option = false
end

function GUMBALL.OnGumballUse(ply)
	ply.stock_option = true
end

--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)