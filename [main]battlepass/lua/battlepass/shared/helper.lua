local meta = FindMetaTable("Player")

function meta:getLevel(real)
    return real and self:GetNW2Int("BPLevel", 1) or math.min(self:GetNW2Int("BPLevel", 1), 200)
end

function meta:getPrestige()
    return math.floor(self:getLevel(true) / 200)
end

function meta:addTokens(am)
    self.bpTokens = math.ceil(self.bpTokens + am)
    self:SendLua("LocalPlayer().bpTokens = " .. self.bpTokens)
    ASAPDriver:MySQLQuery("UPDATE battlepass_players SET tokens=" .. self.bpTokens .. " WHERE aid=" .. self:SteamID64())
end

function meta:getXP()
    if not self.BattlePass then return 1 end

    return self.BattlePass.Owned.progress / 10
end

function BATTLEPASS:Replace(str, tbl)
    for i, v in pairs(tbl) do
        str = str:Replace(":" .. i, v)
    end

    return str
end

function BATTLEPASS:SetupPass(ply)
    ply.BattlePass = ply.BattlePass or {}
    ply.BattlePass.ClaimedItems = ply.BattlePass.ClaimedItems or {}

    ply.BattlePass.Owned = ply.BattlePass.Owned or {
        owned = false,
        tier = 0,
        progress = 0
    }
end


function BATTLEPASS:CreateChallengeFromID(id)
    return table.Copy(self.Challenges[id])
end

function BATTLEPASS:AddTier(ply, amt, final)
    self:SetupPass(ply)

    if CLIENT then
        local level = amt

        if (level >= 200) then
            local prestige = math.ceil(level / 200)
            local msg = "Congrats! You've reached prestige <rainbow=3>" .. string.rep("★", prestige) .. " " .. ((level % 200) / 200) .. "%</rainbow>"
            chat.AddText(XeninUI.Theme.Accent, "[BP] ", color_white, msg)
        end

        local msg = "You have leveled up your Battle Pass to level <rainbow=3>" .. level .. "</rainbow>"
        chat.AddText(XeninUI.Theme.Accent, "[BP] ", color_white, msg)
    end

    for k = 1, amt do
        local curTier = ply.BattlePass.Owned.tier
        ply.BattlePass.Owned.tier = curTier + 1

        if ply.BattlePass.Owned.tier % (curTier >= 200 and 10 or 5) == 0 and ply.addMoney and ply.UB3AddItem then
            local money = 1000000
            local item = math.random(1163, 1169)
            hook.Run("onBU3AddItem_Kit", ply, item)
            ply:UB3AddItem(item)
            ply:ChatPrint("[BP] You've reached a milestone and received <rainbow=3>" .. DarkRP.formatMoney(money) .. " and " .. BU3.Items.Items[item].name .. "</rainbow>")
            ply:addMoney(money)
        end
    end

    if SERVER then
        ply:SetNW2Int("BPLevel", ply.BattlePass.Owned.tier)
    end
end

function BATTLEPASS:SetTier(ply, amt)
    self:SetupPass(ply)
    ply.BattlePass.Owned.tier = amt
    ply:SetNW2Int("BPLevel", amt)
end

function BATTLEPASS:AddProgress(ply, amt)
    amt = math.min(amt, 30)
    self:SetupPass(ply)
    
    if CLIENT then return end

    local progress = ply.BattlePass.Owned.progress
    ply.BattlePass.Owned.progress = math.max(progress + amt, 0)

    if ply.BattlePass.Owned.progress >= 10 then
        local diff = ply.BattlePass.Owned.progress - 10
        ply.BattlePass.Owned.progress = 0
        self:AddProgress(ply, diff)
        self:AddTier(ply, 1)

        if (ply.dowaitbp) then
            ply.dowaitbp:Remove()
        end
        ply.dowaitbp = ply:Wait(0, function()
            net.Start("BATTLEPASS.AddTier")
            net.WriteUInt(ply:GetNW2Int("BPLevel"), 8)
            net.Send(ply)
        end)
    end

    net.Start("BATTLEPASS.SetProgress")
    net.WriteUInt(ply:GetNW2Int("BPLevel", 0), 8)
    net.WriteUInt(ply.BattlePass.Owned.progress, 8)
    net.Send(ply)

    self.Database:SavePlayer(ply)
end

function BATTLEPASS:SetProgress(ply, amt)
    self:SetupPass(ply)
    ply.BattlePass.Owned.progress = amt

    if SERVER then
        self.Database:SavePlayer(ply)
    end
end

function BATTLEPASS:SetOwned(ply, state)
    self:SetupPass(ply)
    ply.BattlePass.Owned.owned = state

    if SERVER then
        self.Database:SavePlayer(ply)
    end
end

function BATTLEPASS:CreateItem(mdl, locked)
    return {
        display = mdl,
        func = BATTLEPASS.Unlock.Unbox,
        extra = {
            id = mdl,
            locked = locked or false
        }
    }
end

function BATTLEPASS:CreateChallenge(challengeId, goal, reward, multiplier)
    return {
        id = challengeId,
        goal = goal,
        reward = reward,
        multiplier = multiplier
    }
end

function BATTLEPASS:CreateCategory(id, name, tbl)
    local newTbl = {
        name = name,
        id = id,
        challenges = {}
    }

    for i, v in pairs(tbl) do
        local temp = v
        temp.uid = nil
        newTbl.challenges[v.uid] = temp
    end

    return newTbl
end

function BATTLEPASS:AddPass(pid, data)
    local rewards = {}

    if not BU3 or not BU3.Items or table.IsEmpty(BU3.Items.Items) then
        timer.Simple(.1, function()
            self:AddPass(pid, data)
        end)

        return
    end

    hook.Run("Battlepass.RegisteredPass", data)

    for k, v in pairs(data.rewards) do
        rewards[k] = self:CreateItem(v)
        local item = BU3.Items.Items[v]
        if not item then continue end
        rewards[k].name = item.name
        rewards[k].tooltip = item.name
    end

    local newChallenges = {}

    for cat, challs in pairs(data.challenges) do
        newChallenges[cat] = {}

        for id, chall in pairs(challs) do
            newChallenges[cat][chall.id] = chall
        end
    end

    self.Pass = {
        id = pid,
        name = data.name,
        ends = data.ends,
        rewards = rewards,
        tiers = data.tiers,
        claimable = data.claimable,
        challenges = newChallenges,
        newplayer = data.newplayer
    }

    return self.Pass[pid]
end

function BATTLEPASS:ClaimItem(ply)
    local stage = (ply.bpStage or 0)
    local tier = ply:getLevel()
    local owned = ply.BattlePass.Owned.owned
    local hasClaimedItem = stage >= tier

    if hasClaimedItem then MsgN("You don't deserve it") return end

    if owned then
        for k = (ply.bpStage or 0) + 1, tier do
            local item = BATTLEPASS.Pass.rewards[k]
            item.func(ply, item)
        end
        ply.bpStage = tier
    else
        local last = 0
        for k = 0, tier, 5 do
            if (k == 0) then continue end
            if (k % 5 ~= 0) then continue end
            if k < ply.bpStage then continue end
            if k > stage then break end
            local item = BATTLEPASS.Pass.rewards[k]
            item.func(ply, item)
            last = k
        end
        ply.bpStage = last
    end

    if SERVER then
        BATTLEPASS.Database:SavePlayer(ply)
    end
end

function BATTLEPASS:CanBuyPass(ply)
    return ply:CanAffordStoreCredits(BATTLEPASS.Config.PassPrice)
end

function BATTLEPASS:CanBuyTiers(ply, amt)
    if not ply.BattlePass.Owned.owned then return end

    return ply:CanAffordStoreCredits(BATTLEPASS.Config.TierPrice)
end

concommand.Add("asap_bp_settier", function(ply, cmd, _, args)
    if IsValid(ply) then return end
    local arg = string.Explode(" ", args)
    local sid = arg[1]
    local target = player.GetBySteamID(sid) or player.GetBySteamID64(sid) or player.GetByUniqueID(sid)

    if sid ~= "gonzo" and not IsValid(target) then
        MsgN("Invalid target")

        return
    end

    if (sid == "gonzo") then
        target = gonzo()
    end

    target.BattlePass.Owned.tier = tonumber(arg[2])
    target.bpStage = 0
    target:SendLua("LocalPlayer().BattlePass.Owned.tier = " .. tonumber(arg[2]))
    target:SendLua("LocalPlayer().bpStage = 0")

    if (arg[3]) then
        BATTLEPASS:AddTier(target, tonumber(arg[3]))
    end
end)