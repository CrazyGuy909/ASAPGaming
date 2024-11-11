local ABILITY = {}

ABILITY.id = 6
ABILITY.name = "Shake The Machine"
ABILITY.description = [[This will grant you with double the amount of gumballs from the slot machine! This means if you got 3 rares from the slot machine you would instead get 6 gumballs!]]
ABILITY.price = 12500
--This table should contain other abilities ID's, this means they are required before purchasing this.
ABILITY.requiredUnlocks = {}

--Called when ever a player with this ability respawns or spawns in
function ABILITY.OnSpawn(ply)
	ply.doubleslots = true
end

--[[-------------------------------------------------------------------------
Register the ability
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterAbility(ABILITY)