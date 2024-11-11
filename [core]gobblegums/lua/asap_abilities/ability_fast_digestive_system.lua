local ABILITY = {}

ABILITY.id = 2
ABILITY.name = "Metabolism"
ABILITY.description = [[This ability lowers the cooldown of any gumball by a factor of 2!]]
ABILITY.price = 5000
--This table should contain other abilities ID's, this means they are required before purchasing this.
ABILITY.requiredUnlocks = {}

--Called when ever a player with this ability respawns or spawns in
function ABILITY.OnSpawn(ply)

end

--[[-------------------------------------------------------------------------
Register the ability
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterAbility(ABILITY)