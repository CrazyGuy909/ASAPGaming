local GUMBALL = {}

GUMBALL.id = 9
GUMBALL.name = "Shields Up"
GUMBALL.description = [[Gives you 150 Armor.
]]
GUMBALL.price = 10
GUMBALL.icon = Material("asap_gumballs/balls/shields_up.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Blue
GUMBALL.activeTime = 0 -- -2 has no active time, it gets used instantly and goes on cooldown

function GUMBALL.OnGumballEquip(ply)

end

function GUMBALL.OnGumballDequip(ply)

end

function GUMBALL.OnGumballUse(ply)
	ply:SetArmor(150)
end

--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)