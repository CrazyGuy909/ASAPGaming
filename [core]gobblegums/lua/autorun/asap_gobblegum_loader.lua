if SERVER then
    local files, _ = file.Find("asap_gobblegums_scenes/*", "LUA")

    for k, v in pairs(files) do
        AddCSLuaFile("asap_gobblegums_scenes/" .. v)
    end
end

ASAP_GOBBLEGUMS = ASAP_GOBBLEGUMS or {}
--[[-------------------------------------------------------------------------
*DEBUG*
---------------------------------------------------------------------------]]
ASAP_GOBBLEGUMS.Debug = true
--The default cooldown is 10 minutes for all gobblegums
ASAP_GOBBLEGUMS.GlobalCooldown = 10 * 60

--Gumball types
ASAP_GOBBLEGUMS.GUM_TYPE = {
    Green = 0, --Default
    Gray = 1, --Common
    Blue = 2, --Rare
    Purple = 3, --Legendary
    Orange = 4 --Epic
    
}

--Index this with a gum type to get the color for it
ASAP_GOBBLEGUMS.TYPE_TO_COLOR = {
    [ASAP_GOBBLEGUMS.GUM_TYPE.Green] = Color(56, 208, 71),
    [ASAP_GOBBLEGUMS.GUM_TYPE.Gray] = Color(114, 114, 114),
    [ASAP_GOBBLEGUMS.GUM_TYPE.Blue] = Color(44, 128, 171),
    [ASAP_GOBBLEGUMS.GUM_TYPE.Purple] = Color(161, 81, 209),
    [ASAP_GOBBLEGUMS.GUM_TYPE.Orange] = Color(254, 154, 46)
}

--A list of all the gumballs indexed by ID
ASAP_GOBBLEGUMS.Gumballs = {}
--A list of all the abilities indexed by ID
ASAP_GOBBLEGUMS.Abilities = {}

--data
--[[
	int id 						A Unique ID to identify that ball.
	string name 						Print Name
	string description 					Print Description
	int price 							Price
	IMaterial icon 						Gumball Icon
	ASAP_GOBBLEGUMS.GUM_TYPE type 		Rarity Type
	Func OnGumballEquip
	Func OnGumballDequip
	Func OnGumballUse
	float activeTime 					Time the perk is "active" for
]]
ASAP_GOBBLEGUMS.MaxGum = 0
function ASAP_GOBBLEGUMS:RegisterGobbleGum(data)
    local id = data.id
    --Sanity check
    if ASAP_GOBBLEGUMS.Gumballs[id] ~= nil then
        //Error("A Gumball with the same ID already exists. Please set a unique ID for '" .. data.name .. "' so it does not conflict with '" .. data.name .. "'")

        //return false
    end

    --Register the gumball
    ASAP_GOBBLEGUMS.Gumballs[id] = table.Copy(data)
    --MsgN(ASAP_GOBBLEGUMS.Gumballs[id].id, " ", ASAP_GOBBLEGUMS.Gumballs[id].name)
    --Print out
    if (id > self.MaxGum) then
        self.MaxGum = id
    end
    if ASAP_GOBBLEGUMS.Debug then end --print("Registered gumball! '"..data.name.."'!")
end

--data
--[[
	int id 						A Unique ID to identify that ball.
	string name 						Print Name
	string description 					Print Description
	int price 							Price
	IMaterial icon 						Gumball Icon
	ASAP_GOBBLEGUMS.GUM_TYPE type 		Rarity Type
	Func OnGumballEquip
	Func OnGumballDequip
	Func OnGumballUse
	float activeTime 					Time the perk is "active" for
]]
function ASAP_GOBBLEGUMS:RegisterAbility(data)
    local id = data.id

    --Sanity check
    if ASAP_GOBBLEGUMS.Abilities[id] ~= nil then
        Error("An ability with the same ID already exists. Please set a unique ID for '" .. data.name .. "' so it does not conflict with '" .. data.name .. "'")

        return false
    end

    --Register the gumball
    ASAP_GOBBLEGUMS.Abilities[id] = data
    --Print out
    if ASAP_GOBBLEGUMS.Debug then end --print("Registered ability! '"..data.name.."'!")
end

--[[-------------------------------------------------------------------------
Loops through all lua files in the directory lua/asap_gumballs/
and will load them up 
---------------------------------------------------------------------------]]
function ASAP_GOBBLEGUMS:LoadGobbleGumBalls()
    local files, directories = file.Find("asap_gumballs/*", "LUA")

    for k, v in pairs(files) do
        if SERVER then
            AddCSLuaFile("asap_gumballs/" .. v)
        end

        include("asap_gumballs/" .. v)
    end

    files, directories = file.Find("asap_abilities/*", "LUA")

    for k, v in pairs(files) do
        if SERVER then
            AddCSLuaFile("asap_abilities/" .. v)
        end

        include("asap_abilities/" .. v)
    end
end

function GobblegumAdd(type, id, call)
    if (not ASAP_GOBBLEGUMS.Hooks) then
        ASAP_GOBBLEGUMS.Hooks = {}
    end

    ASAP_GOBBLEGUMS.Hooks[type] = {id, call}

    hook.Add(type, id, call)
end

ASAP_GOBBLEGUMS:LoadGobbleGumBalls()

--After loading all the gumballs then sort the table by type
table.sort(ASAP_GOBBLEGUMS.Gumballs, function(a, b)
    if (a.id > 18 or b.id > 18) then
        return a.id < b.id
    end
    if a == nil then return true end
    if b == nil then return false end
    local id1 = id
    local id2 = id

    return a.type < b.type
end)

--Update id's
for k, v in pairs(ASAP_GOBBLEGUMS.Gumballs) do
    if (k < 19) then
        ASAP_GOBBLEGUMS.Gumballs[k].id = k
    end
end
