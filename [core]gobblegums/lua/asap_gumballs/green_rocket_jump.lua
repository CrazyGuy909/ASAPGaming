local GUMBALL = {}
GUMBALL.id = 1
GUMBALL.name = "Rocket Jump"
GUMBALL.description = [[Jump up to 20%* higher that what you normally could.

*Green Gobble Gums are permanent
*May be less if user is overweight ;)
]]
GUMBALL.price = 1000
GUMBALL.icon = Material("asap_gumballs/balls/rocket_jump.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Green
GUMBALL.activeTime = 60 * 5 --5 minutes
GUMBALL.Unobtainable = true

function GUMBALL.OnGumballEquip(ply)
end

function GUMBALL.OnGumballDequip(ply)
end

function GUMBALL.OnGumballExpire(ply)
    ply.jumpBoost = false
    ply.SetJumpPower = ply._SetJumpPower
    ply._SetJumpPower = nil
    --Subtract 20% from current jump height
    --local boost = ply:GetJumpPower()
    --boost = boost - (boost * 0.2) --Minus 20%
    ply:SetJumpPower(200)
end

local meta = FindMetaTable("Player")

meta._SJP = meta._SJP or meta.SetJumpPower
function meta:SetJumpPower(pow)
	if (self.jumpBoost) then
		pow = pow + pow * .2
	end
	self:_SJP(pow)
end

function GUMBALL.OnGumballUse(ply)
    ply.jumpBoost = true
    ply:SetJumpPower(ply:GetJumpPower())
end

--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)