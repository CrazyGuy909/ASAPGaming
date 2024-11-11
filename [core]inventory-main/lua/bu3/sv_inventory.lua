util.AddNetworkString("BU3.SetPerma")
util.AddNetworkString("BU3.Trade:DeleteBulk")
--[[-------------------------------------------------------------------------
This file handles the players inventory, loading, saving, networking etc
---------------------------------------------------------------------------]]
local PLAYER = FindMetaTable("Player")

--All functions in here that are part of the player meta
--Must be prefixed with UB3
--Attempts to load, if it fails then it create the empty inventory
function PLAYER:UB3InitializeInventory()
    self._ub3inv = {} --Inventory
    --self:UB3LoadInventory()
    --print("[UNBOXING 3] Set up inventory for player '" .. self:Name() .. "'")
end

if not file.Exists("unbox_grabbing.txt", "DATA") then
    file.Write("unbox_grabbing.txt", "")
end

--Adds items to a players inventory
function PLAYER:UB3AddItem(itemID, amount)
    if not amount then
        amount = 1
    end

    if not self.loadedInventory then
        if self._waitingItem then
            ErrorNoHalt("Database is still not loading for this player!")

            return
        end

        self._waitingItem = {itemID, amount}

        http.Fetch(asapMarket.API .. "/user?id=" .. self:SteamID64(), function(body)
            local data = util.JSONToTable(body)
            LoadPlayerData(self, data)

            if self._waitingItem then
                self:UB3AddItem(self._waitingItem[1], self._waitingItem[2])
                self.loadedInventory = true
                self._waitingItem = nil
            end
        end)

        return
    end

    if self._ub3inv[itemID] == nil then
        self._ub3inv[itemID] = amount
    else
        self._ub3inv[itemID] = self._ub3inv[itemID] + amount
    end

    local tag = self:SteamID64() .. "_stack"
    self.gatherItems = self.gatherItems or {}
    table.insert(self.gatherItems, BU3.Items.Items[itemID].name .. " (" .. itemID .. ")" .. "x" .. amount)

    timer.Create(tag, 5, 1, function()
        MsgC(Color(50, 100, 255), "[Inventory] ", color_white, self:Nick(), ":" .. self:SteamID64() .. " got: ", Color(255, 255, 0), table.concat(self.gatherItems, ", "), "\n")
        self.gatherItems = {}
    end)

    hook.Run("onBU3AddItem", self, itemID, amount)
    net.Start("UB3.Sync")
    net.WriteInt(itemID, 16)
    net.WriteInt(self._ub3inv[itemID] or 0, 16)
    net.Send(self)
    self:UB3SaveInventory()

    return true
end

--Tried to remove an item, if it fails to remove that ammount it will return false
function PLAYER:UB3RemoveItem(itemID, amount, spawn, ignoreSave)
    if self._ub3inv[itemID] == nil then
        return false
    else
        if not amount then
            amount = 1
        end

        if amount == -1 then
            amount = self._ub3inv[itemID]
        end

        if self._ub3inv[itemID] >= amount then
            self._ub3inv[itemID] = self._ub3inv[itemID] - amount

            if self._ub3inv[itemID] == 0 then
                self._ub3inv[itemID] = nil --Remove it from the inventory if there are none left
            end

            net.Start("UB3.Sync")
            net.WriteInt(itemID, 16)
            net.WriteInt(self._ub3inv[itemID] or 0, 16)
            net.Send(self)

            if not ignoreSave then
                self:UB3SaveInventory()
            end

            if spawn then
                self.droppedItems = self.droppedItems or {}
                local class = BU3.Items.Items[itemID].className
                local oldent = self.droppedItems[BU3.Items.Items[itemID].type]
                if (IsValid(oldent)) then
                    self:ChatPrint("<color=red>Removing old spawn " .. BU3.Items.Items[itemID].name .. "</color>")
                    SafeRemoveEntity(oldent)
                end
                local isArmor = string.StartWith(class, "armor_")
                local ent = ents.Create(isArmor and class or "spawned_weapon")
                ent.ItemID = itemID

                if not isArmor then
                    ent:Setamount(amount)
                    ent:SetWeaponClass(class)
                end

                local tr = util.TraceLine({
                    start = self:GetShootPos(),
                    endpos = self:GetShootPos() + self:GetAimVector() * 64,
                    filter = self
                })

                ent:SetPos(tr.HitPos)
                ent:Spawn()
                ent.nodupe = true
                self.droppedItems[BU3.Items.Items[itemID].type] = ent
            end

            return true
        end
    end
end

--Tries to gift a player an item
function PLAYER:BU3GiftItem(itemID, target, amount)
    if amount ~= math.Round(amount) then return end
    if amount < 1 then return end
    if self:InArena() then return end
    local hasOne, am = self:UB3HasItem(itemID)
    local item = BU3.Items.Items[itemID]

    if item.perm and self:HasWeapon(item.className) then
        DarkRP.notify(self, 1, 5, "You cannot gift a permanent item you already has equipped")

        return false
    end

    if item.rankRestricted then
        DarkRP.notify(self, 1, 5, "You cannot gift this item")

        return false
    end

    if am >= amount and self:UB3RemoveItem(itemID, amount) then
        --Add it to the other persons inventory
        target:UB3AddItem(itemID, amount)
        hook.Run("OnItemGift", self, target, itemID)
        net.Start("BU3:AddEventHistory")
        net.WriteString("'" .. self:Name() .. "' gifted '" .. target:Name() .. "' a '" .. BU3.Items.Items[itemID].name .. "'")
        net.Broadcast()
        MsgC(Color(255, 255, 9), "[Inventory] ", color_white, self:Nick(), ":" .. self:SteamID64() .. " gifted ", BU3.Items.Items[itemID].name, " (" .. itemID .. ")", " to ", Color(255, 100, 0), target:Nick() .. ":" .. target:SteamID64(), "\n")
        self:BU3AddStat("gift", amount)
        hook.Run("onUnboxGift", self, target, itemID, BU3.Items.Items[itemID])
    end
end

--Returns true if yes, false if not (also returns a number of how many they have)
function PLAYER:UB3HasItem(itemID)
    if self._ub3inv[itemID] == nil then return false end
    if self._ub3inv[itemID] > 0 then return true, self._ub3inv[itemID] end
end

--Saves the players inventory
function PLAYER:UB3SaveInventory()
    --TODO
    local sid = self:SteamID64()
    self.pendingSave = true

    timer.Create(self:SteamID64() .. "_quotaSave", 5, 1, function()
        if not IsValid(self) then return end
        self.pendingSave = nil
        BU3.SQL.SaveInventory(sid, self._ub3inv)
    end)
end

--Returns true if the inventory loaded, false it if failed
function PLAYER:UB3LoadInventory()
    --TODO
    BU3.SQL.LoadInventory(self:SteamID64(), function(inv)
        if inv == false then
            self._ub3inv = {}
        else
            self._ub3inv = inv
        end

        self._permaWeapons = util.JSONToTable(self:GetPData("Unbox.PermaWeapons", "[]"))

        timer.Simple(5, function()
            if not IsValid(self) then return end

            for k, v in pairs(self._permaWeapons or {}) do
                if not self._ub3inv[k] then
                    self._permaWeapons[k] = nil
                else
                    self:BU3UseItem(k)
                end
            end
        end)

        net.Start("BU3:EquipPerma")
        net.WriteTable(self._permaWeapons)
        net.Send(self)
        self.loadedInventory = true
    end)

    --Load there stats too
    self:BU3LoadStats()

    return false
end

function PLAYER:UB3SendInventory()
    net.Start("BU3:PrepareInventory")
    net.WriteBool(false)
    net.Send(self)
    local iterations = math.ceil(table.Count(self._ub3inv) / 16)
    local groups = {}
    local i = 1
    local now = {}

    for k, v in pairs(self._ub3inv) do
        table.insert(now, {k, v})

        if i == 16 then
            table.insert(groups, now)
            now = {}
            i = 1
        end

        i = i + 1
    end

    if table.Count(now) ~= 0 then
        table.insert(groups, now)
    end

    for k = 1, iterations + 1 do
        if not groups[k] then continue end

        timer.Simple(.05 * (k - 1), function()
            net.Start("BU3:UpdateInventory")
            net.WriteTable(groups[k])
            net.Send(self)
        end)
    end

    timer.Simple((iterations + 1) * .05, function()
        net.Start("BU3:FinishInventory")
        net.Send(self)
    end)
end

--This function network an update of the inventory to the client
function PLAYER:UB3UpdateClient()
    --First lets make sure we have all the items that exist
    for k, v in pairs(self._ub3inv) do
        if BU3.Items.Items[k] == nil and (istable(k) or BU3:FetchItem(k) == nil) then
            self._ub3inv[k] = nil
        end
    end

    http.Fetch(asapMarket.API .. "/ping", function()
        net.Start("BU3:PrepareInventory")
        net.WriteBool(true)
        net.Send(self)
    end)

    --Also send them an update of there stats
    self:BU3UpdateClientStats()
end

function BU3.FixSuits()
    local weird = {}

    for k, v in pairs(BU3.Items.Items) do
        if (v.type == "entity" or v.type == "weapon") and string.find(v.className or "", "armor", 1, true) then
            v.type = "suit"
            weird[k] = v
        end
    end

    for k, v in pairs(weird) do
    end
    --BU3.SQL.SaveItem(k)
end

function PLAYER:UB3UseArmor(id, cancelRemove)
    if self.armorSuit then
        self:SendLua("Derma_Message('You cannot equip an armor while you have one active', 'error')")
        return
    end

    local item = BU3.Items.Items[id]

    if not item or not BU3:FetchItem(item.className) then
        DarkRP.notify(self, 1, 5, "This armor does not exist #" .. id .. ", notify management")
        return
    end
	
    local name = BU3:FetchItem(item.className).name
    self:giveArmorSuit(name)

    if cancelRemove == nil then
        self.armorEquipped = self.armorSuit
    else
        self.demoArmor = true
    end

    http.Post(asapMarket.API .. "/eq/push", {
        key = "gonzo_made_it",
        id = self:SteamID64(),
        armor = name,
    })

    hook.Run("OnItemUsed", self, id, 1)
end

--[[-------------------------------------------------------------------------
These are logic functions for attual items, such as equip, use
---------------------------------------------------------------------------]]
--Attempts to use an item
function PLAYER:BU3UseItem(itemID, isSpecial)
    local item = BU3.Items.Items[itemID] or BU3:FetchItem(itemID)
    if self._tradeID then return false end

    --Item is not valid
    if item == nil then
        MsgC(Color(255, 0, 0), "[Inv] Item not valid ", itemID, " : ", self:Nick(), "\n")

        return false
    end

    if self:InArena() then return end

    if not self:UB3HasItem(itemID) then
        MsgC(Color(255, 0, 0), "[Inv] Player doesn't have such item ", itemID, " : ", self:Nick(), "\n")

        return false
    end

    if item.className then
        if not self._itemsSpawned then
            self._itemsSpawned = {}
        end

        if not self._itemsSpawned[item.className] then
            self._itemsSpawned[item.className] = {}
        end

        if item.max and item.max ~= 0 then
            local newVal = {}

            for k, v in pairs(self._itemsSpawned[item.className]) do
                if IsValid(v) then
                    table.insert(newVal, v)
                end
            end

            self._itemsSpawned[item.className] = newVal

            if item.max <= table.Count(self._itemsSpawned[item.className]) then
                self:SendLua([[notification.AddLegacy("You've reached this entity spawn limit!", NOTIFY_ERROR, 5)]])

                return false
            end
        end
    end

    local cancelRemove = hook.Run("BU3.ShouldRemove", self, item)

    --Remove the item if its not permanent
    if cancelRemove == nil then
        if item.perm ~= true then
            self:UB3RemoveItem(itemID, 1)
        end
    elseif item.type ~= "weapon" and item.type ~= "suit" then
        self:UB3RemoveItem(itemID, 1)
    end

    --Perform the action for the item
    if item.type == "weapon" and weapons.GetStored(item.className) then
        --Give them the weapon
        local wep = self:Give(item.className)

        if item.perm then
            wep.isPerm = true
        elseif cancelRemove == nil then
            wep.allowToPickup = true
        end

        if cancelRemove == nil then
            wep.ItemID = itemID
        else
            wep.demoWeapon = true

            if asapArena.BlacklistWeapons[item.className] then
                ply:StripWeapon(item.className)
                ply:ChatPrint("You cannot use this weapon during purge!")
            end
        end

        self:SelectWeapon(item.className)
        net.Start("BU3.SetPerma")
        net.WriteString(item.className)
        net.Send(self)

        if not item.perm then
            http.Post(asapMarket.API .. "/eq/push", {
                id = self:SteamID64(),
                key = "gonzo_made_it",
                cls = item.className
            })

            self._requireUnload = true
        end

        return
    elseif item.type == "weapon" and not weapons.GetStored(item.className) and not item.perm then
        if cancelRemove ~= nil then return end
        self:UB3AddItem(itemID, 1)
        DarkRP.notify(self, 1, 5, "This weapon doesn't exists! Notify management.")

        return
    end

    --Perform the action for the item
    if item.type == "attachment" then
        --Give them the weapon
        if not self.aweapons[item.className] then
            self.aweapons[item.className] = {}
        end

        self.aweapons[item.className].unlocked = true
        net.Start("ASAP.Customs.Permanent")
        net.WriteString(item.className)
        net.Send(self)

        return
    end

    --Perform the action for the item
    if item.type == "accesory" then
        --Give them the weapon
        local ply = self
        local itemID = item.accessoryID
        local acc = SH_ACC:GetAccessory(itemID)

        if not acc then
            MsgN("This accesory doesn't exists! Notify management.")

            return
        end

        if ply:SH_HasAccessory(itemID) then
            print("Unbox: " .. ply:Nick() .. " <" .. ply:SteamID() .. "> already has '" .. item.accessoryID .. "' accessory!")

            return
        end

        if ply:SH_AddAccessory(itemID) then
            print("Unbox: " .. "Successfully given " .. ply:Nick() .. " <" .. ply:SteamID() .. "> the '" .. item.accessoryID .. "' accessory!")
        else
            print("Unbox: " .. "Failed to give " .. ply:Nick() .. " <" .. ply:SteamID() .. "> the '" .. item.accessoryID .. "' accessory!")
        end

        return
    end

    --Spawn the entity
    if item.type == "entity" then
        local trace = self:GetEyeTrace()
        local posToSpawn = Vector(0, 0, 0)
		
		if item.className == "unkown" then
			print("BLAH")
			return
		end
		print("OBLAH")
        if trace.HitPos:Distance(self:GetPos()) > 200 then
            posToSpawn = (self:GetPos() + Vector(0, 0, 50)) + (self:GetAimVector() * 100)
        else
            posToSpawn = trace.HitPos
        end

        local temp = ents.Create(item.className)

        if not item.perm and not IsValid(temp) then
            self:UB3AddItem(itemID, 1)

            return
        end

        temp:SetPos(posToSpawn)
        temp:Spawn()
        temp.ItemID = itemID
        temp.allowToPickup = true

        if temp.Setowning_ent ~= nil then
            temp:Setowning_ent(self)
        end

        local newVal = {}

        for k, v in pairs(self._itemsSpawned[item.className]) do
            if IsValid(v) then
                table.insert(newVal, v)
            end
        end

        self._itemsSpawned[item.className] = newVal
        table.insert(self._itemsSpawned[item.className], temp)
        self:SendLua([[notification.AddLegacy("[UNBOX] Entity Spawned!", NOTIFY_HINT, 5)]])

        return
    end

    if item.type == "suit" or string.find(item.className or "", "armor", 1, true) then
        self:UB3UseArmor(itemID, cancelRemove)

        return
    end

    if item.type == "points1" then
        self:PS_GivePoints(tonumber(item.pointsAmount))
        self:SendLua([[notification.AddLegacy("[UNBOX] Added Points!", NOTIFY_HINT, 5)]])

        return
    end

    if item.type == "points2" then
        if not item.premium then
            self:PS2_AddStandardPoints(tonumber(item.pointsAmount), "Added from Unboxing 3")
            self:SendLua([[notification.AddLegacy("[UNBOX] Added Points!", NOTIFY_HINT, 5)]])
        else
            self:PS2_AddPremiumPoints(tonumber(item.pointsAmount))
            self:SendLua([[notification.AddLegacy("[UNBOX] Added Premium Points!", NOTIFY_HINT, 5)]])
        end

        return
    end

    if item.type == "points1item" then
        print("Giving item class name ", item.className)
        self:PS_GiveItem(item.className)
        self:SendLua([[notification.AddLegacy("[UNBOX] Added Pointshop Item!", NOTIFY_HINT, 5)]])

        return
    end

    if item.type == "points2item" then
        local itemClass = Pointshop2.GetItemClassByPrintName(item.className)

        if not itemClass then
            error("Invalid item " .. tostring(item.className))
        end

        self:PS2_EasyAddItem(itemClass.className)
        self:SendLua([[notification.AddLegacy("[UNBOX] Added Pointshop Item!", NOTIFY_HINT, 5)]])

        return
    end

    if item.type == "money" then
        self:addMoney(tonumber(item.moneyAmount))
        self:SendLua([[notification.AddLegacy("[UNBOX] Added Money!", NOTIFY_HINT, 5)]])

        return
    end

    if item.type == "credits" then
        self:AddStoreCredits(tonumber(item.creditsAmount))
        self:SendLua([[notification.AddLegacy("[UNBOX] Added Credits!", NOTIFY_HINT, 5)]])

        return
    end

    if item.type == "lua" then
        --Lua to execute
        local bootstrap = [[
			local PLY = Player(]] .. self:UserID() .. [[)
		]]
        local func = CompileString(bootstrap .. item.lua, "BU3:ItemExecution" .. math.random(10000, 10000000), true)
        func()
    end
    --If its a custom Lua entity perfom the actions
    --TODO
end

hook.Add("PlayerDisconnected", "UB3:CLEANITEMS", function(ply)
    if ply.pendingSave then
        BU3.SQL.SaveInventory(ply:SteamID64(), ply._ub3inv)
    end

    for class, entities in pairs(ply._itemsSpawned or {}) do
        for _, ent in pairs(entities) do
            if IsValid(ent) then
                ent:Remove()
            end
        end
    end
end)

--[[-------------------------------------------------------------------------
Hooks
---------------------------------------------------------------------------]]
hook.Add("PlayerInitialSpawn", "UB3:SETUPINVENTORY", function(ply)
    --BU3.Items.NetworkItems(ply)
    ply:UB3InitializeInventory()
end)

hook.Add("onChatCommand", "BU3.ClearWeapon", function(ply, cmd, args, ret)
    if ply._tradeID then return end

    if cmd == "dropweapon" and ply:GetActiveWeapon().ItemID and not BU3.Items.Items[ply:GetActiveWeapon().ItemID].perm then
        http.Post(asapMarket.API .. "/eq/take", {
            id = ply:SteamID64(),
            cls = ply:GetActiveWeapon():GetClass()
        })
    end
end)

hook.Add("ScalePlayerDamage", "BU3.BattleTag", function(ply)
    ply.battleTag = CurTime() + 10
end)

hook.Add("PlayerDisconnected", "BU3.AvoidSave", function(ply)
    if ply.battleTag and ply.battleTag > CurTime() then
        http.Post(asapMarket.API .. "/eq/clear", {
            id = ply:SteamID64()
        })
    end
end)

--[[-------------------------------------------------------------------------
Networking stuff
---------------------------------------------------------------------------]]
util.AddNetworkString("BU3:UpdateInventory")
util.AddNetworkString("BU3:UseItem")
util.AddNetworkString("BU3:FinishInventory")
util.AddNetworkString("BU3:UseItemWeapon")
util.AddNetworkString("BU3:DeleteItem")
util.AddNetworkString("BU3:DropItem")
util.AddNetworkString("BU3:GiftItem")
util.AddNetworkString("BU3:UseItemArmor")
util.AddNetworkString("BU3:AddEventHistory")
util.AddNetworkString("BU3:AdminOpenInventory")
util.AddNetworkString("BU3:PrepareInventory")
util.AddNetworkString("UB3:AdminDeleteItem")
util.AddNetworkString("BU3:EquipPerma")
util.AddNetworkString("BU3:BulkOpening")
util.AddNetworkString("BU3:BulkDelete")
util.AddNetworkString("UB3.Sync")
util.AddNetworkString("ASAP.CheckConnection")

net.Receive("ASAP.CheckConnection", function(l, ply)
    net.Start("ASAP.CheckConnection")
    net.Send(ply)
end)

net.Receive("BU3:EquipPerma", function(len, ply)
    local itemID = net.ReadInt(32)
    if ply._tradeID then return false end
    local item = BU3.Items.Items[itemID]
    if not item.perm then return end
    if not ply._ub3inv[itemID] then return end

    if not ply._permaWeapons then
        ply._permaWeapons = {}
    end

    if ply._permaWeapons[itemID] then
        ply._permaWeapons[itemID] = nil
    else
        ply._permaWeapons[itemID] = true
    end

    ply:SetPData("Unbox.PermaWeapons", util.TableToJSON(ply._permaWeapons))
end)

net.Receive("BU3:UseItem", function(len, ply)
    local itemID = net.ReadUInt(32)
    if ply._tradeID then return false end
    ply:BU3UseItem(itemID or -1)
    hook.Run("OnItemUsed", ply, itemID, 1)
end)

net.Receive("BU3:UseItemWeapon", function(len, ply)
    local itemID = net.ReadInt(32)
    if ply._tradeID then return false end
    ply:BU3UseItem(itemID or -1, isSpecial)
    hook.Run("OnItemUsed", ply, itemID, 1)
end)

net.Receive("BU3:GiftItem", function(len, ply)
    local itemID = net.ReadInt(32)
    local target = net.ReadEntity()
    local amount = net.ReadInt(8)
    if ply._tradeID then return false end
    if not BU3.Items.Items[itemID] then return end

    if IsValid(target) and target:IsPlayer() and target ~= ply then
        ply:BU3GiftItem(itemID, target, amount)
    end
end)

local unbox = CreateConVar("asap_unbox_enabled", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Enable ASAP unboxing (1 = enabled, 0 = disabled)")

net.Receive("BU3:BulkOpening", function(len, ply)
    local itemID = net.ReadInt(16)
    local amount = net.ReadInt(16)

    if not unbox:GetBool() then
        ply:ChatPrint("Unboxing is currently disabled.")

        return
    end

    if amount > 5 then return end
    if amount < 1 then return end
    if ply._requestBulk then return end
    ply._requestBulk = true

    timer.Simple(ply:IsDonator(4) and 0.5 or 4, function()
        if not IsValid(ply) then return end
        ply._requestBulk = false

        if ply._ub3inv[itemID] and ply._ub3inv[itemID] >= amount then
            local wonItems = {}
            local didPlay = false

            for k = 1, amount do
                local wonItem, wonAmount = BU3.Chances.GenerateSingle(itemID)
                local item = BU3.Items.Items[wonItem]
                if not wonItem then continue end
                hook.Run("onUnbox", ply, wonItem, item, itemID)
                ply:UB3AddItem(wonItem, wonAmount or 1)
                ply:BU3AddStat("case", 1)
                table.insert(wonItems, wonItem)

                if (item.itemColorCode or 1) >= 6 then
                    net.Start("BU3.AnounceGolden")
                    net.WriteString(item.name)
                    net.WriteUInt(item.itemColorCode, 4)
                    net.WriteEntity(ply)
                    net.Broadcast()

                    if not didPlay then
                        didPlay = true
                        ply:EmitSound("misc/achievement_earned.wav")

                        for i = 1, 6 do
                            ply:Wait(i / 10, function()
                                local effectdata = EffectData()
                                effectdata:SetOrigin(ply:GetPos() + Vector(0, 0, 45) + VectorRand() * 32)
                                util.Effect("balloon_pop", effectdata)
                            end)
                        end
                    end
                end
            end

            net.Start("BU3:BulkOpening")
            net.WriteTable(wonItems)
            net.Send(ply)
            ply:UB3RemoveItem(itemID or -1, amount)
        end
    end)
end)

net.Receive("BU3:BulkDelete", function(len, ply)
    local itemID = net.ReadInt(16)
    local amount = net.ReadInt(16)
    if ply._tradeID then return false end
    if amount < 1 then return end

    if ply._ub3inv[itemID] and ply._ub3inv[itemID] >= amount then
        local b = ply:UB3RemoveItem(itemID or -1, amount)

        if b and BU3.Items.Items[itemID].itemColorCode ~= 15 then
            ply.deleteAmount = (ply.deleteAmount or 0) + amount

            while ply.deleteAmount >= 35 do
                ply:UB3AddItem(1220, 1)
                ply.deleteAmount = ply.deleteAmount - 35
            end

            if ply.deleteAmount > 0 then
                ply:ChatPrint("Scrap " .. (35 - ply.deleteAmount) .. " more to receive a <rainbow=2>Scrap Crate</rainbow>")
            end

            ply:SendLua("BU3.ScrapLeft = " .. ply.deleteAmount)
        end

        hook.Run("OnItemRemoved", ply, itemID, amount)
    end
end)

net.Receive("BU3:UseItemArmor", function(len, ply)
    local armorClass = net.ReadString()
    local id = net.ReadUInt(16)
    if ply._tradeID then return false end
    local cancelRemove = hook.Run("BU3.ShouldRemove", ply, BU3.Items.Items[id])
    local b = true

    if cancelRemove == nil then
        b = ply:UB3RemoveItem(id, 1)
    end

    if b then
        ply:UB3UseArmor(id, cancelRemove)
    end
end)

net.Receive("BU3:DeleteItem", function(len, ply)
    local itemID = net.ReadInt(32)
    if ply._tradeID then return false end
    local b = ply:UB3RemoveItem(itemID or -1, 1)

    if b and BU3.Items.Items[itemID].itemColorCode ~= 11 then
        ply.deleteAmount = (ply.deleteAmount or 0) + 1

        if ply.deleteAmount >= 35 then
            ply:UB3AddItem(1220, 1)
            ply.deleteAmount = 0
        else
            ply:ChatPrint("Scrap " .. (35 - ply.deleteAmount) .. " more to receive a <rainbow=2>Scrap Crate</rainbow>")
        end

        ply:SendLua("BU3.ScrapLeft = " .. ply.deleteAmount)
    end

    hook.Run("OnItemRemoved", ply, itemID, 1)
end)

net.Receive("BU3:DropItem", function(len, ply)
    local class = net.ReadString()
    if ply._tradeID then return false end
    local id = net.ReadInt(32)
    ply:UB3RemoveItem(id, 1, true)
end)

net.Receive("UB3:AdminDeleteItem", function(len, ply)
    if table.HasValue(BU3.Config.AdminRanks, ply:GetUserGroup()) then
        local target = net.ReadEntity()
        local itemID = net.ReadInt(32)

        if target ~= nil and IsValid(target) then
            --Attempt to delete that item 
            target:UB3RemoveItem(itemID or -1, 1)
            --Compress the targets inventory
            local inv = util.TableToJSON(target._ub3inv)
            inv = util.Compress(inv)
            local size = string.len(inv)
            net.Start("BU3:AdminOpenInventory")
            net.WriteDouble(size)
            net.WriteData(inv, size)
            net.WriteEntity(target)
            net.Send(ply)
        end
    end
end)

net.Receive("BU3:AdminOpenInventory", function(len, ply)
    if table.HasValue(BU3.Config.AdminRanks, ply:GetUserGroup()) then
        local target = net.ReadEntity()

        if target ~= nil and IsValid(target) then
            --Compress the targets inventory
            local inv = util.TableToJSON(target._ub3inv)
            inv = util.Compress(inv)
            local size = string.len(inv)
            net.Start("BU3:AdminOpenInventory")
            net.WriteDouble(size)
            net.WriteData(inv, size)
            net.WriteEntity(target)
            net.Send(ply)
        end
    end
end)

concommand.Add("bu3_forcereload", function(ply)
    if ply.loadedInventory then return end
    if ply.invDelay and ply.invDelay > CurTime() then return end
end)

--ply.invDelay = CurTime() + 5
--ply:UB3InitializeInventory()
net.Receive("BU3.Trade:DeleteBulk", function(l, ply)
    local amount = net.ReadUInt(8)

    if (ply.deleteAmount or 0) + amount >= 35 then
        ply:ChatPrint(math.floor(ply.deleteAmount / 35) .. " <rainbow=2>Scrap Crate</rainbow> received!")
    end

    for k = 1, amount do
        local id = net.ReadUInt(16)
        local a = ply._ub3inv[id] or 1
        local b = ply:UB3RemoveItem(id, a, false, true)

        if b and BU3.Items.Items[id].itemColorCode ~= 11 then
            ply.deleteAmount = (ply.deleteAmount or 0) + a

            while ply.deleteAmount >= 35 do
                ply:UB3AddItem(1220, 1)
                ply.deleteAmount = ply.deleteAmount - 35
            end
        end
    end

    if ply.deleteAmount > 0 then
        ply:ChatPrint("Scrap " .. (35 - ply.deleteAmount) .. " more to receive a <rainbow=2>Scrap Crate</rainbow>")
    end

    ply:SendLua("BU3.ScrapLeft = " .. ply.deleteAmount)
    ply:UB3SaveInventory()
end)

hook.Add("onDarkRPWeaponDropped", "RetrieveDropAvailibility", function(ply, ent, weapon)
    if weapon.ItemID then
        ent.ItemID = weapon.ItemID
    end
end)