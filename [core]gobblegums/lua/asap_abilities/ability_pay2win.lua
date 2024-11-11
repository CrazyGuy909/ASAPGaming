local ABILITY = {}

ABILITY.id = 3
ABILITY.name = "Head Start"
ABILITY.description = [[This will always make you start at level 15 after prestiging.]]
ABILITY.price = 5600
--This table should contain other abilities ID's, this means they are required before purchasing this.
ABILITY.requiredUnlocks = {}

--Called when ever a player with this ability respawns or spawns in
function ABILITY.OnSpawn(ply)
	ply.paytowin = true
end

--[[-------------------------------------------------------------------------
Register the ability
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterAbility(ABILITY)