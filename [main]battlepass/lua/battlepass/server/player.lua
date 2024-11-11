function BATTLEPASS:Reset(ply)
    ASAPDriver:MySQLDelete("battlepass_players", "aid=" .. ply:SteamID64())
    ASAPDriver:MySQLDelete("battlepass_claimed", "aid=" .. ply:SteamID64())
    ASAPDriver:MySQLDelete("battlepass_challenges", "aid=" .. ply:SteamID64())

    timer.Simple(1, function()
        BATTLEPASS:InitialPlayerSpawn(ply)
    end)
end

function BATTLEPASS:InitialPlayerSpawn(ply)
    local id = BATTLEPASS.Pass.id

    self.Database:GetPlayer(ply, id, function(playerResult)
        if not playerResult then
            playerResult = {
                claimed = "[]",
                tokens = 0,
                stage = 0,
                progress = 0,
                tier = 0,
            }
        end

        self:SetOwned(ply, tobool(playerResult.owned))
        self:SetTier(ply, playerResult.tier)
        local claimedTable = isstring(playerResult.claimed) and util.JSONToTable(playerResult.claimed or "[]") or playerResult.claimed
        ply.bpTokens = playerResult.tokens or 0
        ply.bpClaimed = claimedTable
        ply.bpStage = playerResult.stage or 0

        if not ply.rewardBP and (not playerResult.reward_id or playerResult.reward_id ~= BATTLEPASS.Pass.id) then
            ply.rewardBP = BATTLEPASS.Pass.id
            ply.canClaimBPReward = true
            ply:SendLua("camClaimBPReward = true")
            timer.Simple(0, function()
                ASAPDriver:MySQLQuery("UPDATE battlepass_players SET reward_id='" .. BATTLEPASS.Pass.id .. "' WHERE aid=" .. ply:SteamID64())
            end)
        end

        self:SetProgress(ply, playerResult.progress)

        if (playerResult.tier == 1 and playerResult.progress == 0) then
            self.Database:SavePlayer(ply)
        end

        self.Database:GetChallenges(ply, function(result)
            local tbl = {}

            for i, v in pairs(result or {}) do
                tbl[v.cat_name] = tbl[v.cat_name] or {}

                tbl[v.cat_name][v.challenge_index] = {
                    progress = tonumber(v.progress),
                    stage = tonumber(v.stage or 0)
                }
            end

            ply.ActiveChallenges = {}

            for cat, challengeTbl in pairs(self.Pass.challenges) do
                ply.ActiveChallenges[cat] = ply.ActiveChallenges[cat] or {}

                for index, challenge in pairs(challengeTbl) do
                    local i = challenge.id
                    local oldChallenge = ply.ActiveChallenges[cat][i] or {}
                    local progress = oldChallenge.progress or 0

                    if (tbl[cat] and tbl[cat][i]) then
                        progress = tbl[cat][i].progress
                    end

                    ply.ActiveChallenges[cat][i] = BATTLEPASS:CreateChallengeFromID(challenge.id)

                    if (not ply.ActiveChallenges[cat][i]) then
                        MsgN("Missing challenge ", challenge.id, " in category ", cat, " at index ", i, "!")
                        --PrintTable(challenge)
                        continue
                    end

                    ply.ActiveChallenges[cat][i]:SetProgress(progress)
                    ply.ActiveChallenges[cat][i]:SetGoal(challenge.goal)
                    ply.ActiveChallenges[cat][i]:SetReward(challenge.reward)
                    ply.ActiveChallenges[cat][i]:SetStage((tbl[cat] and tbl[cat][i]) and tbl[cat][i].stage or 0)
                    ply.ActiveChallenges[cat][i]:SetUniqueID(cat .. i)
                    ply.ActiveChallenges[cat][i]:SetPlayer(ply)
                    ply.ActiveChallenges[cat][i].cat = cat
                    ply.ActiveChallenges[cat][i].index = i
                    ply.ActiveChallenges[cat][i].multiplier = challenge.multiplier or .5
                    ply.ActiveChallenges[cat][i]:StartTracking()
                end
            end

            net.Start("BATTLEPASS.TotalSync")
            net.WriteBool(tobool(playerResult.owned))
            net.WriteUInt(playerResult.tier, 8)
            net.WriteFloat(playerResult.progress)
            net.WriteUInt(playerResult.tokens or 0, 16)
            net.WriteUInt(playerResult.stage or 0, 8)
            net.WriteUInt(table.Count(claimedTable or {}), 8)

            for k, v in pairs(claimedTable or {}) do
                net.WriteUInt(k, 24)
                net.WriteUInt(v, 8)
            end

            net.WriteUInt(table.Count(tbl or {}), 8)

            for _id, data in pairs(tbl or {}) do
                net.WriteString(_id)
                net.WriteUInt(table.Count(data or {}), 8)

                for k, v in pairs(data or {}) do
                    net.WriteString(k)
                    net.WriteUInt(v.progress, 16)
                    net.WriteUInt(v.stage, 16)
                end
            end

            net.Send(ply)
        end)
    end)
end

concommand.Add("asap_bp_reload", function(ply, cmd, args)
    if IsValid(ply) then return end
    include("battlepass/shared/pass.lua")
    BroadcastLua('include("battlepass/shared/pass.lua")')

    for k, v in pairs(player.GetAll()) do
        BATTLEPASS:InitialPlayerSpawn(v)
    end
end)

hook.Add("PlayerInitialSpawn", "BATTLEPASS", function(ply)
    BATTLEPASS:InitialPlayerSpawn(ply)
end)

hook.Add("PlayerSay", "BP.PlayerSay", function(ply, text)
    for i, v in pairs(BATTLEPASS.Config.ChatCommands) do
        if (text:find(i)) then
            net.Start("BattlePass.OpenMenu")
            net.Send(ply)
            break
        end
    end
end)