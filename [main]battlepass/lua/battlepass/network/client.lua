local function forceDataToBeRead(owned, tier, progress, stage, tbl, claimedItems, tokens)
    if not IsValid(LocalPlayer()) or (not BU3 or not BU3.Items) or not BATTLEPASS.Pass.challenges then
        timer.Simple(1, function()
            forceDataToBeRead(owned, tier, progress, stage, tbl, claimedItems, tokens)
        end)
        return
    end

    local ply = LocalPlayer()
    ply.BattlePass = {}
    ply.ActiveChallenges = {}
    ply.bpTokens = tokens
    ply.bpClaimed = claimedItems
    ply.bpStage = stage
    BATTLEPASS:SetOwned(ply, owned)
    BATTLEPASS:SetTier(ply, tier)
    BATTLEPASS:SetProgress(ply, progress)

    for cat, challengeTbl in pairs(BATTLEPASS.Pass.challenges) do
        ply.ActiveChallenges[cat] = ply.ActiveChallenges[cat] or {}
        for index, challenge in pairs(challengeTbl) do
            local i = challenge.id
            local oldChallenge = ply.ActiveChallenges[cat][i] or {}
            local actualProgress = oldChallenge.actualProgress or 0
            local actualStage = 0

            if (tbl[cat] and tbl[cat][i]) then
                actualProgress = tbl[cat][i].progress
                actualStage = tbl[cat][i].stage
            end

            ply.ActiveChallenges[cat][i] = BATTLEPASS:CreateChallengeFromID(challenge.id)
            if not ply.ActiveChallenges[cat][i] then continue end
            ply.ActiveChallenges[cat][i]:SetProgress(actualProgress)
            ply.ActiveChallenges[cat][i]:SetGoal(challenge.goal)
            ply.ActiveChallenges[cat][i]:SetReward(challenge.reward)
            ply.ActiveChallenges[cat][i]:SetStage(actualStage)
            ply.ActiveChallenges[cat][i]:SetUniqueID(cat .. i)
            ply.ActiveChallenges[cat][i]:SetPlayer(ply)
            ply.ActiveChallenges[cat][i].cat = cat
            ply.ActiveChallenges[cat][i].index = i
            ply.ActiveChallenges[cat][i].multiplier = challenge.multiplier or .5
        end
    end

end

net.Receive("BATTLEPASS.TotalSync", function(len)
    local owned = net.ReadBool()
    local tier = net.ReadUInt(8)
    local progress = net.ReadFloat()
    local tokens = net.ReadUInt(16)
    local stage = net.ReadUInt(8)
    local claimsTbl = {}

    for k = 1, net.ReadUInt(8) do
        claimsTbl[net.ReadUInt(24)] = net.ReadUInt(8)
    end
    local tbl = {}
    for _id = 1, net.ReadUInt(8) do
        local cat = net.ReadString()
        tbl[cat] = {}
        for i = 1, net.ReadUInt(8) do
            tbl[cat][net.ReadString()] = {
                progress = net.ReadUInt(16),
                stage = net.ReadUInt(16)
            }
        end
    end
    //MsgN(owned, " ", tier, " ", progress, " ", tbl, " ", claimsTbl, " ", tokens, " ", claimedItems)
    forceDataToBeRead(owned, tier, progress, stage, tbl, claimsTbl, tokens, claimedItems)
end)

net.Receive("BATTLEPASS.SyncChallengeProgress", function(len)
    local ply = LocalPlayer()
    local cat = net.ReadString()
    local index = net.ReadString()
    local progress = net.ReadFloat()
    local star = net.ReadUInt(8)
    local stage = net.ReadUInt(8)
    if not ply.ActiveChallenges[cat] then return end
    local tbl = ply.ActiveChallenges[cat][index]

    if (tbl and progress >= tbl:GetGoal()) then
        ply.BattlePass.Owned.progress = star
    end

    if not ply.ActiveChallenges[cat] then return end
    ply.ActiveChallenges[cat][index]:SetStage(stage)
    ply.ActiveChallenges[cat][index]:SetProgress(progress, true)
end)

net.Receive("BATTLEPASS.AddTier", function(len)
    local amt = net.ReadUInt(8)
    BATTLEPASS:AddTier(LocalPlayer(), amt)
end)

net.Receive("BATTLEPASS.SetProgress", function(len)
    local tier, progress = net.ReadUInt(8), net.ReadUInt(8)
    print(tier, progress)
    LocalPlayer().BattlePass.Owned.tier = tier
    LocalPlayer():SetNW2Int("BPLevel", tier)
    LocalPlayer().BattlePass.Owned.progress = progress
end)


net.Receive("BattlePass.OpenMenu", function(len)
    LocalPlayer():ConCommand("battlepass")
end)

net.Receive("BATTLEPASS.BuyStore", function()
    LocalPlayer().bpTokens = net.ReadUInt(16)
    LocalPlayer().bpClaimed = LocalPlayer().bpClaimed or {}
    LocalPlayer().bpClaimed[net.ReadUInt(24)] = net.ReadUInt(8)
    surface.PlaySound("doubleornothing/x3.mp3")
    BPSHOP.Currency:SetText(LocalPlayer().bpTokens)
end)