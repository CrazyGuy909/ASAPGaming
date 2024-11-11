local ABILITY = {}

ABILITY.id = 4
ABILITY.name = "Deep Pockets"
ABILITY.description = [[This unlocks 2 extra slots giving you a total of 4 slots to equip gobble gums into. And now you can activate 4 gobble gums in the same time.]]
ABILITY.price = 10000
--This table should contain other abilities ID's, this means they are required before purchasing this.
ABILITY.requiredUnlocks = {}

--Called when ever a player with this ability respawns or spawns in
function ABILITY.OnSpawn(ply)
	ply.gobblegumsslotcount = 4
	ply:NetworkGobblegumSlots()
end

--[[-------------------------------------------------------------------------
Register the ability
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS:RegisterAbility(ABILITY)