local GUMBALL = {}

GUMBALL.id = 11
GUMBALL.name = "Double Down"
GUMBALL.description = [[Gain 2x More XP.
]]
GUMBALL.price = 10
GUMBALL.icon = Material("asap_gumballs/balls/double_down.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Purple
GUMBALL.activeTime = 60 * 30

function GUMBALL.OnGumballEquip(ply)

end

function GUMBALL.OnGumballDequip(ply)

end

function GUMBALL.OnGumballExpire(ply)
	ply.doublexp = false
end


function GUMBALL.OnGumballUse(ply)
	ply.doublexp = true
end

--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)