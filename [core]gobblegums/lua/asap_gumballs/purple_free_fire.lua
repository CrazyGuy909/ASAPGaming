local GUMBALL = {}
GUMBALL.id = 13
GUMBALL.name = "Free Fire"
GUMBALL.description = [[Fire Weapon without using bullets.
]]
GUMBALL.price = 2000
GUMBALL.icon = Material("asap_gumballs/balls/free_fire.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Purple
GUMBALL.purchasable = true
GUMBALL.activeTime = -1
GUMBALL.Unobtainable = true

function GUMBALL.OnGumballEquip(ply)
end

function GUMBALL.OnGumballDequip(ply)
    ply.free_fire = false
end

function GUMBALL.OnGumballUse(ply)
    ply.free_fire = true
end

if SERVER then
    
end

--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)