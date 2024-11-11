local GUMBALL = {}

GUMBALL.id = 10
GUMBALL.name = "Skeleton Key"
GUMBALL.description = [[Unlock any door by just shooting at it.
]]
GUMBALL.price = 10
GUMBALL.Unobtainable = true
GUMBALL.icon = Material("asap_gumballs/balls/skeleton_key.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Blue
GUMBALL.activeTime = 60 * 5 -- -1 means active until death

function GUMBALL.OnGumballEquip(ply)

end

function GUMBALL.OnGumballDequip(ply)

end

function GUMBALL.OnGumballExpire(ply)
	ply.skeleton_key = true
end

function GUMBALL.OnGumballUse(ply)
	ply.skeleton_key = true
end

if SERVER then

	GobblegumAdd("EntityTakeDamage", "ASAP:SkeletonKey", function(target, dmg)
		if target:GetClass() == "func_door" or target:GetClass() == "prop_door_rotating" or target:GetClass() == "func_door_rotating"then
			local attacker = dmg:GetAttacker()
	 
			if IsValid(attacker) and attacker:IsPlayer() then
				if attacker.skeleton_key == true then
					target:Fire("unlock","",0)
	                target:Fire("Open","",0)
				end
			end
		end
	end)
end

--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)