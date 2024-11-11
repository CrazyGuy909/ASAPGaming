local lan = GetConVar("sv_lan")
local MYSQL_HOST = "172.0.0.2"
local MYSQL_USERNAME = "u5720_W3dOI1dTLP"
local MYSQL_PASSWORD = "h.eeKkOWOuBBcvhebwu=25FP"
local MYSQL_DATABASE = "s5720_players"
local MYSQL_PORT = 3306
util.AddNetworkString("ASAPGGOBBLEGUMS:Gobblegums")
util.AddNetworkString("ASAPGGOBBLEGUMS:Slots")
util.AddNetworkString("ASAPGGOBBLEGUMS:Cooldown")
util.AddNetworkString("ASAPGGOBBLEGUMS:Equip")
util.AddNetworkString("ASAPGGOBBLEGUMS:Activate")
util.AddNetworkString("ASAPGGOBBLEGUMS:Buy")
util.AddNetworkString("ASAPGGOBBLEGUMS:RefreshTab")
util.AddNetworkString("ASAPGGOBBLEGUMS:NetworkXPLevel")
util.AddNetworkString("ASAPGGOBBLEGUMS:Credits")
util.AddNetworkString("ASAPGGOBBLEGUMS:Abilities")
util.AddNetworkString("ASAPGGOBBLEGUMS:BuyAbility")
util.AddNetworkString("ASAPGGOBBLEGUMS:Prestige")
util.AddNetworkString("ASAP:SpentOnSlots")
--Slots
util.AddNetworkString("ASAPGGOBBLEGUMS:SlotSpin")
util.AddNetworkString("ASAPGGOBBLEGUMS:StopReel")
util.AddNetworkString("ASAPGGOBBLEGUMS:DisplayReward")
local MySQLDB = nil

local function CreateMySQLTables()
    --Create the table for the users info
	local query = MySQLDB:query([[
		CREATE TABLE IF NOT EXISTS asap_gobblegums (
			steamid VARCHAR(22),
			accountinfo TEXT,
			PRIMARY KEY (steamid)
		);      
	]])

    function query:onSuccess(data)
    end

    --print("[ASAP GOBBLEGUMS] Created mysql personl accounts table.")
    function query:onError(err)
    end

    --print("[ASAP GOBBLEGUMS] Failed to create the sql tables, If the following error says that the table already exists then this is fine. Ignore it. ERROR:"..err)
    query:start()
end

local function InitializeMySQL()
    --Load MySQL
    require("mysqloo")

    --Login to the database and set up the tables
    if mysqloo == nil then
        print("[ASAP GOBBLEGUMS] Failed to load MySQLoo, are you sure you have it installed?")
    end

    --Now try to connect to the database
    MySQLDB = mysqloo.connect(MYSQL_HOST, MYSQL_USERNAME, MYSQL_PASSWORD, MYSQL_DATABASE, MYSQL_PORT)

    function MySQLDB:onConnected()
        print("[ASAP GOBBLEGUMS] Connected to MySQL database!'")
        --Now that we connected, lets try to create the tables
        CreateMySQLTables()
    end

    local error = "ERROR"

    function MySQLDB:onConnectionFailed(err)
        print("[ASAP GOBBLEGUMS] Connection to database failed! : " .. tostring(err))
    end

    --Keep connection alive
    MySQLDB:setAutoReconnect(true)
    MySQLDB:connect()

    --[[
	 17/02/2019 - bambo 
		Moved the saving data to mysql to a timer every 1 minute.
	]]
    timer.Create("ASAPGOBBLEGUMS:SaveTimer", 300, 0, function()
        -- saving players gobblegum settings.
        for k, v in pairs(player.GetAll()) do
            v:ASAPSaveAllData()
        end
    end)
end

ASAP_GOBBLEGUMS = ASAP_GOBBLEGUMS or {}

GobblegumAdd("PlayerInitialSpawn", "ASAPGOBBLEGUMS:SetupPlayer", function(ply)
    ply.gobblegumsslotcount = 2
    ply.gobblegumabilties = {}
    ply.gobblegumsslots = {}
    ply.gobblegumspentonslots = 0
end)

--[[
    --This stores all the gumballs that the user has equip at the current time
    ply.gEmpty = true
    ply.gobblegumsslots = {}
    --This stores the cooldown for each gobblegum slot
    ply.gobblegumscooldown = {}
    --This is a table indexed by id's, and values contain how many of that gum the player owns
    ply.gobblegums = {}
    --This is the number of slots this player has unlocked
    ply.gobblegumsslotcount = 2
    --Thi is the number of credits the user had
    ply.gobblegumcredits = 2500
    --This is a table that stores the ability id, as well as true if its unlocked
    ply.gobblegumabilties = {}
    ply.gobblegumspentonslots = 0
    ply.asap_level = 1
    ply.asap_xp = 0
    ply.asap_xpToNextLevel = 100
    ply.loadAttemps = 0

    local function forceLoad(ply)
        if not IsValid(ply) then return end
        if (ply.loadAttemps > 3) then return end
        ply.loadAttemps = ply.loadAttemps + 1

        if (ply.gEmpty) then
            ply:ASAPLoadNetworkGobbleGums()

            timer.Simple(3, function()
                forceLoad(ply)
            end)
        end
    end

    --Load and network all there info
    timer.Simple(0.1, function()
        forceLoad(ply)
    end)
    ]]
GobblegumAdd("PlayerDisconnected", "ASAP:BackupGobblegumData", function(ply)
    ply:ASAPSaveAllData()
end)

--Each level is 25% more stats than the previous level
local P = FindMetaTable("Player")

--Loads and networks any data for the user
function P:ASAPLoadNetworkGobbleGums()
    local ply = self
    --MySQL
    local steamid64 = MySQLDB:escape(self:SteamID64())
    local query = MySQLDB:query([[SELECT * FROM asap_gobblegums WHERE steamid = ]] .. steamid64 .. [[;]])

    function query:onSuccess(result)
        if istable(result) and result[1] ~= nil then
            ply.gEmpty = false
            local data = util.JSONToTable(result[1].accountinfo)
            local convertedData = {}
            convertedData.gobblegums = util.JSONToTable(data.owned_gobblegums)
            convertedData.gobblegumabilties = util.JSONToTable(data.owned_abilities)
            convertedData.gobblegumspentonslots = data.spent_on_slots
            convertedData.asap_level = data.asap_level
            convertedData.asap_xp = data.asap_xp
            convertedData.asap_xpToNextLevel = data.asap_xpToNextLevel
            convertedData.gobblegumcredits = data.gobblegumcredits
            ply.gobblegums = convertedData.gobblegums
            --Thi is the number of credits the user had
            ply.gobblegumcredits = tonumber(convertedData.gobblegumcredits)
            --This is a table that stores the ability id, as well as true if its unlocked
            ply.gobblegumabilties = convertedData.gobblegumabilties
            ply.gobblegumspentonslots = tonumber(convertedData.gobblegumspentonslots)
            ply.asap_level = tonumber(convertedData.asap_level)
            ply.asap_xp = tonumber(convertedData.asap_xp)
            ply.asap_xpToNextLevel = tonumber(convertedData.asap_xpToNextLevel)

            --Now loop through each ability they own and load it
            for k, v in pairs(ply.gobblegumabilties) do
                ASAP_GOBBLEGUMS.Abilities[k].OnSpawn(ply)
            end
            --print("[ASAP GOBBLEGUMS] Loaded Data")
        else
            ply.gEmpty = false
            ply.gobblegums = {}
            --Thi is the number of credits the user had
            ply.gobblegumcredits = 1500
            ply.gobblegumabilties = {}
            ply.gobblegumspentonslots = 0
            ply.asap_level = 1
            ply.asap_xp = 0
            ply.asap_xpToNextLevel = 100
        end

        ply:NetworkOwnedGobblegums()
        ply:NetworkGobblegumAbilities()
        ply:NetworkGobblegumSlots()
        ply:SetNW2Int("GB.Level", ply.asap_level or 1)
        --Now network the new XP and the new Level if they changed
        net.Start("ASAPGGOBBLEGUMS:NetworkXPLevel")
        net.WriteUInt(ply.asap_xp, 32)
        net.WriteUInt(ply.asap_level, 32)
        net.WriteUInt(ply.asap_xpToNextLevel, 32)
        net.Send(ply)
        --Network credits
        net.Start("ASAPGGOBBLEGUMS:Credits")
        net.WriteUInt(ply.gobblegumcredits, 32)
        net.Send(ply)
    end

    function query:onError(err)
        --print("[ASAP GOBBLEGUMS] Failed to load data, this will result in data loss. Please read the following error: "..err)
        callback(false)
    end

    query:start()
    query:wait()
    --[[
	--This is a table indexed by id's, and values contain how many of that gum the player owns
	local gums = self:GetPData("owned_gobblegums", -1)
	if gums == -1 then
		gums = {}
	else
		gums = util.JSONToTable(gums)
	end
	self.gobblegums = gums

	--Thi is the number of credits the user had
	self.gobblegumcredits = self:GetPData("gobblegumcredits", 1000)


	--This is a table that stores the ability id, as well as true if its unlocked
	local abbiltities = self:GetPData("owned_abilities", -1)
	if abbiltities == -1 then
		abbiltities = {}
	else
		abbiltities = util.JSONToTable(abbiltities)
	end
	self.gobblegumabilties = abbiltities

	self.gobblegumspentonslots = tonumber(self:GetPData("spent_on_slots", 0))

	self.asap_level = tonumber(self:GetPData("asap_level", 1))
	self.asap_xp = tonumber(self:GetPData("asap_xp", 0))
	self.asap_xpToNextLevel = tonumber(self:GetPData("asap_xpToNextLevel",  100)	)

	--Now loop through each ability they own and load it
	for k, v in pairs(self.gobblegumabilties) do
		ASAP_GOBBLEGUMS.Abilities[k].OnSpawn(self)
	end
	]]
    --
end

--Will save everything, this should be called when a player leaves
function P:ASAPSaveAllData()
    --[[
	self:SetPData("owned_gobblegums", util.TableToJSON(self.gobblegums))
	self:SetPData("owned_abilities", util.TableToJSON(self.gobblegumabilties))
	self:SetPData("spent_on_slots", self.gobblegumspentonslots)
	self:SetPData("asap_level", self.asap_level)
	self:SetPData("asap_xp", self.asap_xp)
	self:SetPData("asap_xpToNextLevel", self.asap_xpToNextLevel)
	self:SetPData("gobblegumcredits", self.gobblegumcredits)
	]]
    --
    --MySQL
    if not self.CanSave then return end
    local data = {}
    data.owned_gobblegums = self.gobblegums
    data.owned_abilities = self.gobblegumabilties
    data.spent_on_slots = self.gobblegumspentonslots
    data.asap_level = self.asap_level
    data.asap_xp = self.asap_xp
    data.asap_xpToNextLevel = self.asap_xpToNextLevel
    data.prestiges = self:GetNW2Int("Prestiges", 0)
    data.gobblegumcredits = self.gobblegumcredits
    asapArena.query("INSERT INTO asap_gobblegums (steamid, accountinfo) VALUES ('" .. self:SteamID64() .. "', '" .. util.TableToJSON(data) .. "') ON DUPLICATE KEY UPDATE accountinfo = '" .. util.TableToJSON(data) .. "'", function() end)
end

--[[ 17/02/2019 - bambo ]]
function P:ASAPSaveXPAndCredits()
end

--[[
	self:SetPData("asap_level", self.asap_level)
	self:SetPData("asap_xp", self.asap_xp)
	self:SetPData("asap_xpToNextLevel", self.asap_xpToNextLevel)
	self:SetPData("gobblegumcredits", self.gobblegumcredits)
	--]]
--self:ASAPSaveAllData()
--[[ 17/02/2019 - bambo ]]
function P:ASAPSAveGobbleGumsAndAbilities()
end

--[[
	self:SetPData("owned_gobblegums", util.TableToJSON(self.gobblegums))
	self:SetPData("owned_abilities", util.TableToJSON(self.gobblegumabilties))
	--]]
--self:ASAPSaveAllData()
--[[ 17/02/2019 - bambo ]]
function P:ASAPSaveSpentOnSlots()
end

--[[
	self:SetPData("spent_on_slots", self.gobblegumspentonslots)
	]]
--self:ASAPSaveAllData()
function P:GobbleAddXP(amount, reason)
    amount = hook.Run("onXPEarned", self, amount, reason) or amount
    local startLevel = self.asap_level

    if isstring(self.gobblegumabilties) then
        self.gobblegumabilties = util.JSONToTable(self.gobblegumabilties) or {}
    end

    if self.gobblegumabilties[1] then
        amount = amount * 2
    end

    self.asap_xp = (self.asap_xp or 0) + amount

    while true do
        if (self.asap_xp or 0) >= (self.asap_xpToNextLevel or 1000) then
            self.asap_xp = (self.asap_xp or 0) - (self.asap_xpToNextLevel or 1000)
            --Level them up
            self.asap_level = (self.asap_level or 0) + 1
            self.asap_xpToNextLevel = ((self.asap_level or 0) / 4) * 100
            --Give them credits
            self:GiveCredits(75)
        end

        if (self.asap_xp or 0) < (self.asap_xpToNextLevel or 1000) then break end
    end

    --Now network the new XP and the new Level if they changed
    net.Start("ASAPGGOBBLEGUMS:NetworkXPLevel")
    net.WriteUInt(self.asap_xp or 0, 32)
    net.WriteUInt(self.asap_level or 1, 32)
    net.WriteUInt(self.asap_xpToNextLevel or 1000, 32)
    net.Send(self)
    self:ChatPrint("<color=orange>[Galaxium]</color> You received '" .. amount .. "' xp for '" .. reason .. "'!")

    if startLevel ~= self.asap_level then
        self:SetNW2Int("GB.Level", self.asap_level or 1)
        self:ChatPrint("<color=orange>[Galaxium]</color> You leveled up, you are now level '" .. self.asap_level .. "'! You received 20 Galaxium points as a reward.")
    end
end

function P:GiveCredits(amount)
    self.gobblegumcredits = (self.gobblegumcredits or 0) + amount
    net.Start("ASAPGGOBBLEGUMS:Credits")
    net.WriteUInt(self.gobblegumcredits, 32)
    net.Send(self)
end

function P:TakeCredits(amount)
    if self.gobblegumcredits - amount < 0 then return false end
    self.gobblegumcredits = self.gobblegumcredits - amount
    net.Start("ASAPGGOBBLEGUMS:Credits")
    net.WriteUInt(self.gobblegumcredits, 32)
    net.Send(self)
end

function P:CanAffordCredits(amount)
    return self.gobblegumcredits - amount >= 0
end

--Tries to pretige this player
function P:ASAPPretige()
    --Check they are above level 50
    if self.asap_level < 50 then return end
    --Check they have 1 mil
    if not self:canAfford(1000000) then return end
    self:addMoney(-1000000)

    if self.paytowin then
        self.asap_level = 15
        self.asap_xp = 0
        self.asap_xpToNextLevel = 1500
    else
        self.asap_level = 1
        self.asap_xp = 0
        self.asap_xpToNextLevel = 2273
    end

    self:SetNW2Int("Prestiges", self:GetNW2Int("Prestiges", 0) + 1)
    self:SetNW2Int("GB.Level", self.asap_level or 1)
    self:GiveCredits(1000)
    net.Start("ASAPGGOBBLEGUMS:NetworkXPLevel")
    net.WriteUInt(self.asap_xp, 32)
    net.WriteUInt(self.asap_level, 32)
    net.WriteUInt(self.asap_xpToNextLevel, 32)
    net.Send(self)
    net.Start("ASAPGGOBBLEGUMS:RefreshTab")
    net.Send(self)
    self:ChatPrint("[Galaxium] You prestige for $1,000,000 and 50 levels. You received 1000 Galaxium points!")
    self:ASAPSaveAllData()
end

function P:GetXP()
    return self.asap_xp
end

function P:GetLevel()
    return self.asap_level
end

function P:NetworkOwnedGobblegums()
    net.Start("ASAPGGOBBLEGUMS:Gobblegums")
    net.WriteTable(self.gobblegums)
    net.Send(self)
end

function P:NetworkGobblegumSlots()
    net.Start("ASAPGGOBBLEGUMS:Slots")
    net.WriteTable(self.gobblegumsslots)
    net.WriteInt(self.gobblegumsslotcount, 16)
    net.Send(self)
end

function P:NetworkGobblegumCooldowns()
    net.Start("ASAPGGOBBLEGUMS:Cooldown")
    net.WriteTable(self.gobblegumscooldown or {})
    net.Send(self)
end

function P:NetworkGobblegumAbilities()
    net.Start("ASAPGGOBBLEGUMS:Abilities")
    net.WriteTable(self.gobblegumabilties)
    net.Send(self)
end

--Lets see if the player owns that ID gumball and has some left
function P:EquipGobblegum(id, slot)
    if self.gobblegums[id] == true then
        if self.gobblegumsslots[slot] == nil then
            if slot < 1 or slot > self.gobblegumsslotcount then return false end
            self.gobblegumsslots[slot] = id
        end

        self:ASAPSaveAllData()
    end
end

--Gives the user a gumball and saves it.
function P:GiveGumball(gumball)
    if not self.gobblegums then
        self.gobblegums = {}
    end

    if self.gobblegums[gumball] == nil then
        self.gobblegums[gumball] = 1
    else
        if self.gobblegums[gumball] == true then
            self.gobblegums[gumball] = 1
        end

        self.gobblegums[gumball] = self.gobblegums[gumball] + 1
        self:ASAPSaveAllData()
    end
end

local function selectGobble()
    local win = math.random(1, ASAP_GOBBLEGUMS.MaxGum)

    while ASAP_GOBBLEGUMS.Gumballs[win].Unobtainable do
        win = math.random(1, ASAP_GOBBLEGUMS.MaxGum)
    end

    return win
end

function P:SpinSlot(quick)
    if self.slotCooldown ~= nil and self.slotCooldown > CurTime() then
        DarkRP.notify(self, 1, 5, "You must wait " .. math.Round(self.slotCooldown - CurTime()) .. " seconds before spinning again!")

        return
    end

    local credits = self.gobblegumcredits or 0

    if quick and quick <= 20 then
        self.slotCooldown = CurTime() + quick / 4
        local spent = 0
        local b = false

        for k = 1, quick do
            credits = self.gobblegumcredits or 0
            if credits < 500 then break end
            spent = spent + 500
            self:TakeCredits(500)

            for i = 1, 3 do
                local win = selectGobble()
                self:GiveGumball(win)

                if self.doubleslots then
                    self:GiveGumball(win)
                end

                if not b then
                    net.Start("ASAPGGOBBLEGUMS:StopReel")
                    net.WriteUInt(i, 4)
                    net.WriteInt(win, 32)
                    net.Send(self)
                end

                net.Start("ASAPGGOBBLEGUMS:DisplayReward")
                net.WriteInt(win, 32)
                net.Send(self)
            end

            b = true
        end

        self.gobblegumspentonslots = self.gobblegumspentonslots + spent
        net.Start("ASAP:SpentOnSlots")
        net.WriteInt(self.gobblegumspentonslots, 32)
        net.Send(self)
        self:ASAPSaveAllData()

        return
    end

    if credits - 500 >= 0 then
        self:TakeCredits(500)
    else
        self:ChatPrint("[Galaxium] You cannot afford that!")

        return
    end

    self.slotCooldown = CurTime() + 2.5
    net.Start("ASAPGGOBBLEGUMS:SlotSpin")
    net.Send(self)
    local win = selectGobble()
    self.gobblegumspentonslots = self.gobblegumspentonslots + 500
    self:ASAPSaveSpentOnSlots()
    net.Start("ASAP:SpentOnSlots")
    net.WriteInt(self.gobblegumspentonslots, 32)
    net.Send(self)

    --Reel 1
    timer.Simple(1, function()
        net.Start("ASAPGGOBBLEGUMS:StopReel")
        net.WriteUInt(1, 4)
        net.WriteInt(win, 32)
        net.Send(self)
        self:GiveGumball(win)

        if self.doubleslots then
            self:GiveGumball(win)
        end

        net.Start("ASAPGGOBBLEGUMS:DisplayReward")
        net.WriteInt(win, 32)
        net.Send(self)

        timer.Simple(.6, function()
            win = selectGobble()
            net.Start("ASAPGGOBBLEGUMS:StopReel")
            net.WriteUInt(2, 4)
            net.WriteInt(win, 32)
            net.Send(self)
            self:GiveGumball(win)

            if self.doubleslots then
                self:GiveGumball(win)
            end

            net.Start("ASAPGGOBBLEGUMS:DisplayReward")
            net.WriteInt(win, 32)
            net.Send(self)

            timer.Simple(.6, function()
                win = selectGobble()
                net.Start("ASAPGGOBBLEGUMS:StopReel")
                net.WriteUInt(3, 4)
                net.WriteInt(win, 32)
                net.Send(self)
                self:GiveGumball(win)

                if self.doubleslots then
                    self:GiveGumball(win)
                end

                net.Start("ASAPGGOBBLEGUMS:DisplayReward")
                net.WriteInt(win, 32)
                net.Send(self)
                --Network it
                self:NetworkOwnedGobblegums()
            end)
        end)
    end)
end

net.Receive("ASAPGGOBBLEGUMS:SlotSpin", function(len, ply)
    --Todo implement price checks
    local quick = net.ReadUInt(5)
    ply:SpinSlot(quick > 0 and quick or nil)
end)

--Equip a gumball
net.Receive("ASAPGGOBBLEGUMS:Equip", function(len, ply)
    if ASAP_GOBBLEGUMS.Disabled then
        DarkRP.notify(ply, 0, 5, "Gobblegums has been disabled temporally...")

        return
    end

    local slot = net.ReadUInt(4)
    local gumball = net.ReadInt(32)

    if ply.gobblegums[gumball] ~= nil and slot > 0 and slot <= ply.gobblegumsslotcount then
        --lets check if any cooldowns match what we have in that slot
        local canPlace = true

        for k, v in pairs(ply.gobblegumscooldown or {}) do
            if v.cooldown > CurTime() and k == ply.gobblegumsslots[slot] then
                canPlace = false
                break
            end
        end

        --Check if we already have this gumball equip
        for k, v in pairs(ply.gobblegumsslots) do
            if v == gumball then
                --Unequip from that slot and move it into this slot
                ply.gobblegumsslots[k] = nil
                break
            end
        end

        if canPlace then
            ply.gobblegumsslots[slot] = gumball
            ply:NetworkGobblegumSlots()
        else
            ply:ChatPrint("[Galaxium] Can't equipt into this slot! There is already a gumball active or on cooldown in this slot.")
        end
    end
end)

net.Receive("ASAPGGOBBLEGUMS:Prestige", function(len, ply)
    ply:ASAPPretige()
end)

net.Receive("ASAPGGOBBLEGUMS:Buy", function(len, ply)
    if ASAP_GOBBLEGUMS.Disabled then
        DarkRP.notify(ply, 0, 5, "Gobblegums has been disabled temporally...")

        return
    end

    local gbID = net.ReadInt(32)
    local gumball = ASAP_GOBBLEGUMS.Gumballs[gbID]

    if gumball ~= nil then
        if gumball.type == ASAP_GOBBLEGUMS.GUM_TYPE.Green then
            if ply.gobblegums[gbID] ~= true then
                --Check they can afford it
                if ply.gobblegumcredits - gumball.price >= 0 then
                    ply:TakeCredits(gumball.price)
                    ply.gobblegums[gbID] = true
                    ply:NetworkOwnedGobblegums()
                    net.Start("ASAPGGOBBLEGUMS:RefreshTab")
                    net.Send(ply)
                    hook.Run("gobblegum.Buy", ply, gumball)
                    ply:ASAPSaveAllData()
                else
                    ply:ChatPrint("[Galaxium] You cannot afford that!")
                end
            end
        elseif gumball.purchasable and ply.gobblegumcredits - gumball.price >= 0 then
            ply:TakeCredits(gumball.price)
            ply:GiveGumball(gumball.id)
            ply:NetworkOwnedGobblegums()
            net.Start("ASAPGGOBBLEGUMS:RefreshTab")
            net.Send(ply)
            hook.Run("gobblegum.Buy", ply, gumball)
        end
        --net.Start("ASAPGGOBBLEGUMS:RefreshTab")
        --net.Send(ply)
    end
end)

net.Receive("ASAPGGOBBLEGUMS:BuyAbility", function(len, ply)
    if ASAP_GOBBLEGUMS.Disabled then
        DarkRP.notify(ply, 0, 5, "Gobblegums has been disabled temporally...")

        return
    end

    local abilityID = net.ReadInt(32)
    local ability = ASAP_GOBBLEGUMS.Abilities[abilityID]

    if ability ~= nil then
        --CHecl if they own all the other abilities
        local unlocked = true

        for k, v in pairs(ability.requiredUnlocks) do
            if ply.gobblegumabilties[v] ~= true then
                unlocked = false
            end
        end

        if unlocked then
            --See if they can afford it
            if ply.gobblegumcredits - ability.price >= 0 then
                ply:TakeCredits(ability.price)
                --Unlock it
                ply.gobblegumabilties[abilityID] = true
                --Network it
                ply:NetworkGobblegumAbilities()
                --Refresh the tab if they are on one
                net.Start("ASAPGGOBBLEGUMS:RefreshTab")
                net.Send(ply)
                --Active it
                ability.OnSpawn(ply)
                hook.Run("gobblegum.BuyAbility", ply, ability)
            else
                ply:ChatPrint("[Galaxium] You cannot afford that!")
            end
        end

        ply:ASAPSaveAllData()
    end
end)

GobblegumAdd("PlayerSpawn", "asdasdasdasdasdasdasdads", function(ply)
    if ply:InArena() then return end

    if isstring(ply.gobblegumabilties) then
        ply.gobblegumabilties = util.JSONToTable(ply.gobblegumabilties)
    end

    for k, v in pairs(ply.gobblegumabilties or {}) do
        if v then
            ASAP_GOBBLEGUMS.Abilities[k].OnSpawn(ply)
        end
    end
end)

net.Receive("ASAPGGOBBLEGUMS:Activate", function(len, ply)
    if ASAP_GOBBLEGUMS.Disabled then
        DarkRP.notify(ply, 0, 5, "Gobblegums has been disabled temporally...")

        return
    end

    --First read data
    local slot = net.ReadUInt(8)

    --Check if slot is valid
    if ply.gobblegumsslots[slot] ~= nil then
        --Check if the gumball is in cooldown
        if not ply.gobblegumscooldown then
            ply.gobblegumscooldown = {}
        end

        if ply.gobblegumscooldown[ply.gobblegumsslots[slot]] == nil or ply.gobblegumscooldown[ply.gobblegumsslots[slot]].cooldown <= CurTime() then
            --No cooldown so now we activate the gumball and start the cooldown
            local gumball = ASAP_GOBBLEGUMS.Gumballs[ply.gobblegumsslots[slot]]

            if gumball ~= nil then
                --Activate it on the user and apply the cooldown
                local activeTime = gumball.activeTime
                local globalCooldown = gumball.Cooldown or ASAP_GOBBLEGUMS.GlobalCooldown

                if activeTime ~= -1 then
                    --Ability that increased activation time
                    if ply.gobblegumabilties[7] == true then
                        activeTime = activeTime + (activeTime * 0.1)
                    end

                    --Ability that decreases cooldown
                    if ply.gobblegumabilties[2] then
                        globalCooldown = globalCooldown / 2
                    end

                    local cooldown = CurTime() + globalCooldown + activeTime
                    activeTime = activeTime + CurTime()

                    --Apply cooldown
                    ply.gobblegumscooldown[gumball.id] = {
                        activatedFunc = false,
                        activeTime = activeTime,
                        cooldown = cooldown,
                        startTime = CurTime(),
                    }

                    if ply.gobblegums[gumball.id] ~= true then
                        ply.gobblegums[gumball.id] = ply.gobblegums[gumball.id] - 1
                        ply:NetworkOwnedGobblegums()
                    end

                    --Activate the gum
                    gumball.OnGumballUse(ply)
                    local timerName = ply:SteamID64() .. gumball.id .. "_gumball"

                    if gumball.OnGumballExpire ~= nil then
                        timer.Create(timerName .. "_cooldown", globalCooldown + (activeTime - CurTime()), 1, function()
                            if not IsValid(ply) then return end

                            for d, c in pairs(ply.gobblegumsslots) do
                                if c == gumball.id then
                                    if ply.gobblegums[c] ~= true and ply.gobblegums[c] < 1 then
                                        --Remove it from the slot
                                        ply.gobblegumsslots[d] = nil
                                    end
                                end
                            end

                            ply.gobblegumscooldown[gumball.id] = nil
                            ply:NetworkGobblegumCooldowns()
                            ply:NetworkGobblegumSlots()
                            gumball.OnGumballExpire(ply)
                        end)
                    end

                    timer.Create(timerName, activeTime - CurTime(), 1, function()
                        if not IsValid(ply) then return end
                        gumball.OnGumballDequip(ply)
                    end)

                    ply:NetworkGobblegumCooldowns()
                    hook.Run("gobblegum.Used", ply, gumball)
                else
                    activeTime = -1
                    cooldown = -1

                    --Apply cooldown
                    ply.gobblegumscooldown[gumball.id] = {
                        activatedFunc = false,
                        activeTime = -1,
                        cooldown = -1,
                        startTime = CurTime()
                    }

                    if ply.gobblegums[gumball.id] ~= true then
                        ply.gobblegums[gumball.id] = ply.gobblegums[gumball.id] - 1
                        ply:NetworkOwnedGobblegums()
                    end

                    --Activate the gum
                    hook.Run("gobblegum.Used", ply, gumball)
                    gumball.OnGumballUse(ply)
                    ply:NetworkGobblegumCooldowns()
                    ply:ASAPSaveAllData()
                end
            else
                print("[Gobbles] Failed to find gumball")
            end
        else
            print("[Gobbles] Failed Cooldown Check")
        end
    else
        print("[Gobbles] Failed Slot Check")
    end
end)

GobblegumAdd("PlayerDeath", "ASAP:HandleGumbalRemoval", function(ply)
    timer.Simple(0.01, function()
        for k, v in pairs(ply.gobblegumscooldown or {}) do
            if v.activeTime == -1 then
                local cooldown = ASAP_GOBBLEGUMS.Gumballs[k].Cooldown or ASAP_GOBBLEGUMS.GlobalCooldown

                if ply.gobblegumabilties[2] then
                    cooldown = cooldown / 2
                end

                ply.gobblegumscooldown[k] = {
                    activatedFunc = false,
                    activeTime = 0,
                    cooldown = CurTime() + cooldown,
                    startTime = CurTime()
                }
            end

            if ASAP_GOBBLEGUMS.Gumballs[k] and ASAP_GOBBLEGUMS.Gumballs[k].OnGumballExpire then
                ASAP_GOBBLEGUMS.Gumballs[k].OnGumballExpire(ply)
            end
        end

        ply:ASAPSaveAllData()
        ply.gobblegumscooldown = {}
        ply:NetworkGobblegumCooldowns()
    end)
end)

GobblegumAdd("playerBoughtCustomEntity", "ASASP:GobbleAddXPForPuchase", function(ply, _, __, price)
    if price >= 35000 then
        ply:GobbleAddXP(40, "Purchasing from the F4 menu")
    end
end)

GobblegumAdd("onLockpickCompleted", "ASAP:GobbleAddXPForLockpick", function(ply, S_U_C_C)
    if S_U_C_C then
        ply:GobbleAddXP(15, "Successful picklock attempt")
    end
end)

GobblegumAdd("OnNPCKilled", "ASAP:GobbleAddXPForNPCFVE", function(npc, attacker, inflictor)
	attacker:GobbleAddXP(10, "Killed NPC")
end)

concommand.Add("gobblegums_givepoints", function(ply, _, args) -- We use _ for unused variables. - Wookie
    local sid = args[1]
    local amount = tonumber(args[2]) or 1

    if args[1] == nil or args[2] == nil then
        print("[GOBBLE GUMS] To use this command do 'gobblegums_givepoints SteamID amount'")

        return
    end

    local target = player.GetBySteamID(sid)

    if IsValid(target) then
        target:GiveCredits(amount)
        target:ChatPrint("[GOBBLE GUMS] You received " .. amount .. " Galaxium points!")
        print("[GOBBLE GUMS] Points given.")
    else
        print("[GOBBLE GUMS] Failed to find user with that SteamID")
    end
end)

GobblegumAdd("PlayerDeath", "GB.Death", function(ply)
    for k, v in pairs(ply.gobblegums or {}) do
        local data = ASAP_GOBBLEGUMS.Gumballs[k]

        if data and data.OnGumballDequip then
            data.OnGumballDequip(ply)
        end
    end

    ply:NetworkGobblegumCooldowns()
end)

hook.Add("EntityFireBullets", "ASAP:FreeFire2", function(ent, data)
    if not ent:IsPlayer() then return end
    local att = data.Attacker

    if IsValid(att) and att:IsPlayer() then
        if att.free_fire then
            att:GetActiveWeapon():SetClip1(att:GetActiveWeapon():GetMaxClip1())
        end

        if att.stock_option and att:GetAmmoCount(data.AmmoType) >= data.Num then
            att:GetActiveWeapon():SetClip1(att:GetActiveWeapon():GetMaxClip1())
            att:RemoveAmmo(data.Num, data.AmmoType)
        end

        if att.asap_perks ~= nil and att.asap_perks.doubletap == true then
            data.Damage = data.Damage * ASAP_PERK_CONFIG.DoubleTap.Multiplier

            return true
        end
    end
end)

concommand.Add("gobblegums_off", function(ply)
    if IsValid(ply) then return end
    ASAP_GOBBLEGUMS.Disabled = true

    for k, v in pairs(ASAP_GOBBLEGUMS.Hooks) do
        hook.Remove(k, v[1])
    end
end)

concommand.Add("gobblegums_on", function(ply)
    if IsValid(ply) then return end
    ASAP_GOBBLEGUMS.Disabled = nil

    for k, v in pairs(ASAP_GOBBLEGUMS.Hooks) do
        hook.Add(k, v[1], v[2])
    end
end)

--Load up the MySQL
InitializeMySQL()