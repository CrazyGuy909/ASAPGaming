local GUMBALL = {}

GUMBALL.id = 18
GUMBALL.name = "Self Medication"
GUMBALL.description = [[Slowly generates health over a 10 minute period
]] 
GUMBALL.price = 10
GUMBALL.icon = Material("asap_gumballs/balls/self_medication.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Orange
GUMBALL.activeTime = 60 * 10 --5 minutes

function GUMBALL.OnGumballEquip(ply)

end

function GUMBALL.OnGumballDequip(ply)

end


--Called when the active time has finished or met its condition
function GUMBALL.OnGumballExpire(ply)
	local SID = ply:SteamID()
	hook.Remove("Think", "SELFHEALTH:"..SID)
end

function GUMBALL.OnGumballUse(ply)

	local SID = ply:SteamID()

	local t = 0
	GobblegumAdd("Think", "SELFHEALTH:"..SID, function()
		if IsValid(ply) and t < CurTime() then
			t = CurTime() + 2
			if (ply:InArena()) then return end
			if ply:Health() + 1 <= ply:GetMaxHealth() then
				ply:SetHealth(ply:Health() + 1)
			end
		end
	end)

end



--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)