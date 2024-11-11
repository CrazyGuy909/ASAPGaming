local ABILITY = {}

ABILITY.id = 5
ABILITY.name = "EXTRA Deep Pockets"
ABILITY.description = [[This unlocks 4 extra slots giving you a total of 8 slots to equip gobble gums into.  And now you can activate 8 gobble gums in the same time.


You are required to purchase "Prison Pocket" to unlock this ability.
]]
ABILITY.price = 27500
--This table should contain other abilities ID's, this means they are required before purchasing this.
ABILITY.requiredUnlocks = {4}

--Called when ever a player with this ability respawns or spawns in
function ABILITY.OnSpawn(ply)
 	ply.gobblegumsslotcount = 8
	ply:NetworkGobblegumSlots()
end

--[[-------------------------------------------------------------------------
Register the ability
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterAbility(ABILITY)