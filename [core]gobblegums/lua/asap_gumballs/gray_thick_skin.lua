local GUMBALL = {}

GUMBALL.id = 4
GUMBALL.name = "Thick Skin"
GUMBALL.description = [[Gives the consumer a 20% chance to deflect a bullet that is fired at them.
]]
GUMBALL.price = 10
GUMBALL.icon = Material("asap_gumballs/balls/thick_skin.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Gray
GUMBALL.activeTime = 60 * 10 --5 minutes

function GUMBALL.OnGumballEquip(ply)

end

function GUMBALL.OnGumballDequip(ply)

end

--Called when the active time has finished or met its condition
function GUMBALL.OnGumballExpire(ply)
	ply.thickskin = false
end

function GUMBALL.OnGumballUse(ply)
	ply.thickskin = true
end

if SERVER then
	GobblegumAdd("PlayerShouldTakeDamage", "ASAP:ThickSkin", function(ply, attacker)
		if ply.thickskin == true then
			if (ply:InArena()) then return end
			local rand = math.random(1, 10)

			if rand < 4 then
				return false
			end
		end
	end)

end 

--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)