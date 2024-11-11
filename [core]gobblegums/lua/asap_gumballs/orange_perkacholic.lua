local GUMBALL = {}

GUMBALL.id = 16
GUMBALL.name = "Perkacholic"
GUMBALL.description = [[Gives you all the perks on the map
]]
GUMBALL.price = 10
GUMBALL.icon = Material("asap_gumballs/balls/perkacholic.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Orange
GUMBALL.activeTime = 0

function GUMBALL.OnGumballEquip(ply)

end

function GUMBALL.OnGumballDequip(ply)

end

function GUMBALL.OnGumballUse(caller)
	--Stamin up
	if caller.asap_perks == nil then
		caller.asap_perks = {}
	end

	--local curRunSpeed = caller:GetRunSpeed()
	--caller:SetRunSpeed(curRunSpeed * ASAP_PERK_CONFIG.StaminUp.Multiplier) -- + 50% run speed
	--caller.asap_perks.staminup  = true

	--Speed coal
	caller.asap_perks.speedcola = true
	for k, v in pairs(caller:GetWeapons()) do
		if v.Primary ~= nil and v.Primary.RPM ~= nil then
			v.Primary.RPM = v.Primary.RPM * ASAP_PERK_CONFIG.SpeedCola.Multiplier
		end
	end

	--PHDFlopper
	caller.asap_perks.phdflopper  = true

	--Juggernog
	if (not ChrismasEvents.PlayersIn or not ChrismasEvents.PlayersIn[caller]) then
		caller:SetMaxHealth(caller:GetMaxHealth() + ASAP_PERK_CONFIG.Juggernog.Amount)
		caller:SetHealth(caller:GetMaxHealth())
	end

	caller.asap_perks.juggernog  = true


	--Double tap
	--caller.asap_perks.doubletap  = true


	--Deadshot
	--caller.asap_perks.deadshot  = true


	--Network the perks
	caller:NetworkASAPPerks()
end

--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)