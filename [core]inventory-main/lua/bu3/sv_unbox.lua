--[[-------------------------------------------------------------------------
This file handles networking and checking
when a user tries to unbox.
---------------------------------------------------------------------------]]
util.AddNetworkString("BU3:TriggerUnboxAnimation")
util.AddNetworkString("BU3:AttemptUnbox")
util.AddNetworkString("BU3:UnboxAnounce")
util.AddNetworkString("BU3.AnounceGolden")

local unbox = CreateConVar("asap_unbox_enabled", "1", {FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Enable ASAP unboxing (1 = enabled, 0 = disabled)")

local cache = {}

function BU3.NotifyRip(ply, att, forceSuit)
    if ply:IsBot() then return end
    local suitName = forceSuit or ply.armorSuit
    local armor = Armor:Get(suitName)
    local item = cache[armor.Entitie]

    if not item then
        for k, v in pairs(BU3.Items.Items) do
            if v.className == armor.Entitie then
                item = v
                cache[suitName] = v
                break
            end
        end
    end

    http.Post("https://kat-1.bil.al:3030/hooks/asap/suits", {
        name = ply:Nick(),
        steamId = ply:SteamID64(),
        itemName = item.name,
        itemIcon = item.iconID,
        itemColor = "#FF5500",
        killerName = att:IsPlayer() and att:Nick() or att:GetClass()
    }, function()
        MsgN("[INV] Suit RIP sent to API.")
    end, function() end, {
        ["Content-Type"] = "application/json",
        ["authorization"] = "53CrT96HTMsnxRd"
    })
end

function BU3.DiscordLog(ply, item, case)
    http.Post("https://kat-1.bil.al:3030/hooks/asap/unbox", {
        name = ply:Nick(),
        steamId = ply:SteamID64(),
        itemName = item.name,
        itemIcon = item.iconID,
        itemColor = "#FF5500",
        crateName = case.name
    }, function(res)
        MsgN("[INV] Unbox sent to API.", res)
    end, function() end, {
        ["authorization"] = "53CrT96HTMsnxRd",
        ["Authorization"] = "53CrT96HTMsnxRd",
    })
end

--This will attempt to unbox an item for the user, add it to there inventory then do the animation
function BU3.UnboxCase(ply, caseID)
    if not unbox:GetBool() then
        DarkRP.notify(ply, 1, 5, "Unbox has been disabled temporally.")

        return
    end

    if ply.isUnboxing then return end --Don't let them unbox yet
    --First check case ID is valid
    local case = BU3.Items.Items[caseID]
    --Check case is valid
    if case == nil or case.type ~= "case" then return false end
    --Check the user has the case
    if not ply:UB3HasItem(caseID) then return end
    --Find the keys that opens this case
    local keyIDs = {}
    --Check if user has key
    local hasAKey = false
    local usedKey = -1

    if case.requiresKey ~= false then
        for k, v in pairs(BU3.Items.Items) do
            if v.type == "key" then
                for a, b in pairs(v.items) do
                    if b == case.itemID then
                        table.insert(keyIDs, v.itemID)
                    end
                end
            end
        end

        --Failed to find key
        if table.Count(keyIDs) < 1 then
            ply:SendLua([[notification.AddLegacy("No key can open this crate.", NOTIFY_ERROR, 5)]])

            return
        end

        for k, v in pairs(keyIDs) do
            if ply:UB3HasItem(v) then
                usedKey = v
                break
            end
        end

        if not ply:UB3HasItem(usedKey) then
            ply:SendLua([[notification.AddLegacy("You don't have the key required.", NOTIFY_ERROR, 5)]])

            return
        end
    end

    --Generate the item to give them
    local wonItem, amount = BU3.Chances.GenerateSingle(case.itemID)
    --Check item is valid
    if wonItem == nil or wonItem == false then return end
    --Take the key
    if case.requiresKey ~= false and not ply:UB3RemoveItem(usedKey, 1) then return end
    if not ply:UB3RemoveItem(caseID, 1) then return end
    --Now tell the client what they are getting and to spin to it.
    net.Start("BU3:TriggerUnboxAnimation")
    net.WriteInt(wonItem, 32)
    net.Send(ply)
    ply.isUnboxing = true

    timer.Simple(8, function()
        local item = BU3.Items.Items[wonItem]
        hook.Run("onUnbox", ply, wonItem, item, caseID)

        if (item.itemColorCode or 0) >= 6 then
            net.Start("BU3.AnounceGolden")
            net.WriteString(item.name)
            net.WriteUInt(item.itemColorCode, 4)
            net.WriteEntity(ply)
            net.Broadcast()
            ply:EmitSound("misc/achievement_earned.wav")

            for k = 1, 6 do
                timer.Simple(k / 10, function()
                    local effectdata = EffectData()
                    effectdata:SetOrigin(ply:GetPos() + Vector(0, 0, 45) + VectorRand() * 32)
                    util.Effect("balloon_pop", effectdata)
                end)
            end

            BU3.DiscordLog(ply, item, case)
        end

        ply.isUnboxing = false

        if BU3.Config.ChatNotifications == true or BU3.Config.ChatNotifications == nil then
            net.Start("BU3:UnboxAnounce")
            net.WriteInt(wonItem, 32)
            net.WriteEntity(ply)
            net.Broadcast()
        end

        net.Start("BU3:AddEventHistory")
        net.WriteString("'" .. ply:Name() .. "' unboxed a '" .. BU3.Items.Items[wonItem].name .. "'")
        net.Broadcast()
        --Give the user the item
        ply:UB3AddItem(wonItem, amount or 1)
        ply:BU3AddStat("case", 1)
    end)
end

concommand.Add("unbox_simulate", function(ply, cmd, args)
    if IsValid(ply) then return end

    if args[1] then
        local count = tonumber(args[2]) or 100
        local list = {}
        local max_letters = 0

        for k = 1, count do
            local wonItem = BU3.Chances.GenerateSingle(tonumber(args[1]))
            if wonItem == nil or wonItem == false then return end
            local item = BU3.Items.Items[wonItem]
            local name = "(" .. string.rep("", item.itemColorCode or 0, "*") .. ")\t" .. item.name
            max_letters = math.max(max_letters, string.len(name))
            list[name] = (list[name] or 0) + 1
        end

        table.sort(list, function(a, b) return a < b end)
        MsgN("x" .. count .. " crates opened")

        for k, v in SortedPairsByValue(list, true) do
            MsgN(k, string.rep("", max_letters - #k + 2, " "), v, " (%" .. math.Round((v / count) * 100, 2) .. ")")
        end
    end
end)

local colors = {
    [1] = Color(169, 169, 169, 255), --Gray
    [2] = Color(0, 191, 255, 255), --Light blue
    [3] = Color(200, 0, 128, 255), --Purple
    [4] = Color(255, 0, 255, 255), --Pink
    [5] = Color(255, 0, 0, 255), --Red
    [6] = Color(255, 215, 0, 255), --Gold!
    [7] = Color(223, 223, 223), --Diamond!
    [8] = Color(255, 102, 0), --Fire!
    [9] = Color(0, 255, 221), --Rainbow!
    [10] = Color(5, 141, 0), --Glitched!
    [11] = Color(5, 255, 0), --Glitched!
}

concommand.Add("bu3_chances", function(ply, cmd, args)
    if IsValid(ply) then return end

    if args[1] then
        local item = tonumber(args[1] or -1)
        local data = BU3.Items.Items[item]

        if not data then
            MsgN("Invalid case ID#", item)

            return
        end

        if not data.items then
            MsgN("Item ", data.name, " is not a case!")

            return
        end

        local totalChance = 0
        local items = {}

        for k, v in pairs(data.items) do
            local chance = isnumber(v) and v or v.chance
            totalChance = totalChance + chance
            items[k] = (items[k] or 0) + chance
        end

        for k, v in SortedPairsByValue(items, true) do
            local it = BU3.Items.Items[k]
            if not it then continue end
            MsgC(colors[it.itemColorCode or 1], it.name, color_white, " - ", Color(150, 255, 0), math.Round((v / totalChance) * 100, 2), "%\n")
        end

        MsgN()
    end
end)

net.Receive("BU3:AttemptUnbox", function(len, ply)
    local caseID = net.ReadInt(32)

    if BU3.Items.Items[caseID] ~= nil and BU3.Items.Items[caseID].type == "case" then
        BU3.UnboxCase(ply, caseID)
    end
end)