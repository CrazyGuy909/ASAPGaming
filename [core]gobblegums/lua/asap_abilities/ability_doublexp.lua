local ABILITY = {}

ABILITY.id = 1
ABILITY.name = "Double XP"
ABILITY.description = [[Receive X2 XP permanently making it easier to reach prestige!]]
ABILITY.price = 10000
--This table should contain other abilities ID's, this means they are required before purchasing this.
ABILITY.requiredUnlocks = {}

--Called when ever a player with this ability respawns or spawns in
function ABILITY.OnSpawn(ply)

end

--[[-------------------------------------------------------------------------
Register the ability
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterAbility(ABILITY)