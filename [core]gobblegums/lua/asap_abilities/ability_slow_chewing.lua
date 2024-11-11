local ABILITY = {}

ABILITY.id = 7
ABILITY.name = "Extra Taste"
ABILITY.description = [[This ability will increase the activation time of all gumballs by 10%.]]
ABILITY.price = 7500
--This table should contain other abilities ID's, this means they are required before purchasing this.
ABILITY.requiredUnlocks = {}

--Called when ever a player with this ability respawns or spawns in
function ABILITY.OnSpawn(ply)

end

--[[-------------------------------------------------------------------------
Register the ability
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterAbility(ABILITY)