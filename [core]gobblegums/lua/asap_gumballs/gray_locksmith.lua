local GUMBALL = {}

GUMBALL.id = 3
GUMBALL.name = "Locksmith"
GUMBALL.description = [[Picklock doors and fading doors 2x faster.
]]
GUMBALL.price = 10
GUMBALL.icon = Material("asap_gumballs/balls/locksmith.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Gray
GUMBALL.activeTime = 60 * 5 --5 minutes
GUMBALL.Unobtainable = false
function GUMBALL.OnGumballEquip(ply)

end

function GUMBALL.OnGumballDequip(ply)

end

function GUMBALL.OnGumballExpire(ply)
	ply.lockpickSpeed = false
end

function GUMBALL.OnGumballUse(ply)
	ply.lockpickSpeed = true
end

if SERVER then
	--Speed it up if we have the perk active
	GobblegumAdd("lockpickTime", "ASAP:Locksmoth", function(ply, ent)
		if ply.lockpickSpeed then
			return 4
		end
	end)	
end
--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)