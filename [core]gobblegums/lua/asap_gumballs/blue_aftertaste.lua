local GUMBALL = {}

GUMBALL.id = 5
GUMBALL.name = "Aftertaste"
GUMBALL.description = [[Keep all perks after dying. (Active until you die)
]]
GUMBALL.price = 10
GUMBALL.icon = Material("asap_gumballs/balls/aftertaste.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Blue
GUMBALL.activeTime = -1 -- -1 means active until death

function GUMBALL.OnGumballEquip(ply)

end

function GUMBALL.OnGumballDequip(ply)

end

function GUMBALL.OnGumballUse(ply)
	
end

--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)