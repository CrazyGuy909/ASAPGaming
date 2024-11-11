local GUMBALL = {}

GUMBALL.id = 15
GUMBALL.name = "On The House"
GUMBALL.description = [[Gives you a random perk.
]]
GUMBALL.price = 10
GUMBALL.icon = Material("asap_gumballs/balls/onthehouse.png", "noclamp smooth")
GUMBALL.type = ASAP_GOBBLEGUMS.GUM_TYPE.Purple
GUMBALL.activeTime = -2

function GUMBALL.OnGumballEquip(ply)

end

function GUMBALL.OnGumballDequip(ply)

end

function GUMBALL.OnGumballUse(ply)

	caller = ply

	local num = math.random(1, 6)

	--Stamin up
	if caller.asap_perks == nil then
		caller.asap_perks = {}
	end
 
	if num == 1 then
		if caller.asap_perks.staminup ~= true then
			local curRunSpeed = caller:GetRunSpeed()
			caller:SetRunSpeed(curRunSpeed * ASAP_PERK_CONFIG.StaminUp.Multiplier) -- + 50% run speed
			caller.asap_perks.staminup  = true

			--Play the animation and give reset the timer
			local wep = caller:Give("perk_animation")
			if not IsValid(wep) then
				wep = caller:GetActiveWeapon()
			end

			wep:SetMaterialOverride("models/hoff/animations/perks/juggernog/_-gmtl_t6_zmb_perk_bottle_mara_col")
		end
	elseif num == 2 then
		--Speed coal
		if caller.asap_perks.speedcola ~= true then
			caller.asap_perks.speedcola = true
			for k, v in pairs(caller:GetWeapons()) do
				if v.Primary ~= nil and v.Primary.RPM ~= nil then
					v.Primary.RPM = v.Primary.RPM * ASAP_PERK_CONFIG.SpeedCola.Multiplier
				end
			end

			--Play the animation and give reset the timer
			local wep = caller:Give("perk_animation")
			if not IsValid(wep) then
				wep = caller:GetActiveWeapon()
			end

			wep:SetMaterialOverride("models/hoff/animations/perks/juggernog/speedcola")
		end
	elseif num == 3 then
		--PHDFlopper
		caller.asap_perks.phdflopper  = true

		--Play the animation and give reset the timer
		local wep = caller:Give("perk_animation")
		if not IsValid(wep) then
			wep = caller:GetActiveWeapon()
		end

		wep:SetMaterialOverride("models/hoff/animations/perks/juggernog/_-gmtl_t6_zmb_perk_bottle_nuke_col")
	elseif num == 4 then
		if caller.asap_perks.juggernog ~= true then
			--Juggernog
			caller:SetMaxHealth(caller:GetMaxHealth() + ASAP_PERK_CONFIG.Juggernog.Amount)
			caller:SetHealth(caller:GetMaxHealth())

			caller.asap_perks.juggernog  = true

			--Play the animation and give reset the timer
			local wep = caller:Give("perk_animation")
			if not IsValid(wep) then
				wep = caller:GetActiveWeapon()
			end

			wep:SetMaterialOverride("models/hoff/animations/perks/juggernog/_-gzombie_perkbottle_jugg_in_c")
		end 
	elseif num == 5 then
		--Double tap
		caller.asap_perks.doubletap  = true

		--Play the animation and give reset the timer
		local wep = caller:Give("perk_animation")
		if not IsValid(wep) then
			wep = caller:GetActiveWeapon()
		end

		wep:SetMaterialOverride("models/hoff/animations/perks/juggernog/doubletap")
	else
		--Deadshot
		caller.asap_perks.deadshot  = true

		--Play the animation and give reset the timer
		local wep = caller:Give("perk_animation")
		if not IsValid(wep) then
			wep = caller:GetActiveWeapon()
		end

		wep:SetMaterialOverride("models/hoff/animations/perks/juggernog/deadshot")
	end

	--Network the perks
	caller:NetworkASAPPerks()
end

--[[-------------------------------------------------------------------------
Register the gumball
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterGobbleGum(GUMBALL)