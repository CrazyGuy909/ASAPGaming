local disqualificator = {}
local CHALLENGE = {}
CHALLENGE.__index = CHALLENGE

function CHALLENGE.New(player, name, desc, icon, uid, progress, goal)
    local newChallenge = setmetatable({}, CHALLENGE)
    newChallenge.name = name
    newChallenge.desc = desc
    newChallenge.icon = icon
    newChallenge.uid = uid
    newChallenge.stage = 0
    newChallenge.progress = progress or 0

    --newChallenge.goal = goal or 10
    newChallenge.goal = tonumber(goal) or 10

    newChallenge.player = player

    if player then
        newChallenge.pid = player:SteamID64()
    end

    newChallenge.hooks = {}
    return newChallenge
end

function CHALLENGE:SetName(name)
    self.name = name
end

function CHALLENGE:GetName()
    return self.name
end

function CHALLENGE:SetDesc(desc)
    self.desc = desc
end

function CHALLENGE:GetDesc()
    return self.desc
end

function CHALLENGE:SetIcon(icon)
    self.icon = icon
end

function CHALLENGE:GetIcon()
    return self.icon
end

function CHALLENGE:SetID(id)
    self.uid = id
end

function CHALLENGE:GetID()
    return self.uid
end

function CHALLENGE:SetStage(stage)
    self.stage = stage
end

function CHALLENGE:GetStage()
    return self.stage
end

function CHALLENGE:SetFormatting(func)
    self.format = func
end

function CHALLENGE:GetFormatting(...)
    return self.format(...)
end

function CHALLENGE:SetProgress(amt)
    local startProgress = self.progress or 0
    self.progress = amt

    if SERVER and startProgress < self:GetGoal() then
        self:Save()
    end
end

function CHALLENGE:GetProgress()
    return self.progress
end

function CHALLENGE:SetFinishedDesc(str)
    self.doneDesc = str
end

function CHALLENGE:GetFinishedDesc()
    return self.doneDesc
end

local maxStages = CreateConVar("asap_bp_maxstages", 15, FCVAR_ARCHIVE, "Max stages for challenges")
function CHALLENGE:AddProgress(amt)
    if not disqualificator[self.player:SteamID64()] then
        disqualificator[self.player:SteamID64()] = {
            [self.index] = 0
        }
    end

    local completedToday = disqualificator[self.player:SteamID64()][self.index] or 0
    if (completedToday >= maxStages:GetInt()) then
        self.player:ChatPrint("You have reached the maximum amount of stages for today! (" .. maxStages:GetInt() .. ")")
        return
    end
    local maxGoal = self:GetGoal()
    self.progress = self.progress + amt

    if self.progress >= maxGoal then
        disqualificator[self.player:SteamID64()][self.index] = completedToday + 1
        self:OnStageComplete()
        self.progress = 0
        self:NetworkProgress()
    end

    if SERVER then
        self:Save()
    end
end

function CHALLENGE:AddToQueue()
    if self.player then
        BATTLEPASS.QueuedChallengeRequests[self.player:SteamID64() .. "$_$" .. self.cat .. "$_$" .. self.index .. "$_$" .. (self.stage or 0)] = self.progress
    end
end

function CHALLENGE:Save()
    local cat = self.cat
    local index = self.index

    if self.player then
        BATTLEPASS.Database:SaveChallenge(self.player, cat, index, nil, self.stage)
    end
end

function CHALLENGE:NetworkProgress()
    if CLIENT then return end
    net.Start("BATTLEPASS.SyncChallengeProgress")
    net.WriteString(self.cat)
    net.WriteString(self.index)
    net.WriteFloat(self.progress)
    net.WriteUInt(self.player.BattlePass.Owned.progress, 8)
    net.WriteUInt(self.stage, 8)
    net.Send(self.player)
end

function CHALLENGE:SetReward(reward)
    self.reward = reward
end

function CHALLENGE:GetRewardByStage(override)
    return self.reward-- + self.stage
end

function CHALLENGE:SetGoal(goal)
    self.goal = tonumber(goal) or 10
end

function CHALLENGE:GetGoal()
    return math.ceil(self.goal + self.goal * (self.multiplier or 0.5) * self.stage)
end

function CHALLENGE:SetIcon(dir)
    self.icon = Material(dir, "smooth")
end

function CHALLENGE:SetInput(tbl)
    self.input = tbl
end

function CHALLENGE:SetProgressDesc(desc)
    self.progressDesc = desc
end

function CHALLENGE:GetProgressDesc()
    return self.progressDesc
end

function CHALLENGE:GetTokenReward(stage)
    return math.min(self.reward * (stage or 1) * 10, 300)
end

function CHALLENGE:OnStageComplete(ply)
    BATTLEPASS:AddProgress(ply or self.player, self.reward)
    self.stage = self.stage + 1
    local extra = self:GetTokenReward(self.stage + 1) or 0
    self.player:addTokens(extra)
    self:NetworkProgress()
    self:AddStageNotification(self.stage - 1)
end

if SERVER then
    util.AddNetworkString("BATTLEPASS.StageCompleted")
end

function CHALLENGE:AddStageNotification(stage)
    local tbl = BATTLEPASS.Pass.challenges[self.cat][self.index]
    local extra = self:GetTokenReward(stage or self.stage) or 0
    local name = tbl.name

    if not name then
        name = BATTLEPASS.Challenges[tbl.id]:GetName()
    end

    net.Start("BATTLEPASS.StageCompleted")
    net.WriteUInt(stage, 8)
    net.WriteString(name)
    net.WriteUInt(self:GetRewardByStage(stage), 32)
    net.WriteUInt(extra, 16)
    net.Send(self.player)
end

net.Receive("BATTLEPASS.StageCompleted", function()
    local stage, name, stars, tokens = net.ReadUInt(8), net.ReadString(), net.ReadUInt(32), net.ReadUInt(16)
    BATTLEPASS:AddProgress(LocalPlayer(), stars)
    local msg = "<color=green>" .. name .. " leveled up to stage </color><rainbow=3>" .. (stage + 1) .. "</rainbow>, <color=green>you've earned </color><color=yellow>" .. stars .. " stars </color><color=purple>and " .. tokens .. " tokens!</color>"
    chat.AddText(XeninUI.Theme.Accent, "[BP] ", msg)
end)

ASAPChallenges = ASAPChallenges or {}

function CHALLENGE:AddHook(str, func)
    self.hooks[str] = func
    local uid = self.uid

    hook.Add(str, "ASAP.BP_" .. str .. "_" .. uid, function(...)
        for k, v in pairs(ASAPChallenges[uid] or {}) do
            if not IsValid(k) then
                ASAPChallenges[uid][k] = nil
                continue
            end

            func(v, k, ...)
        end
    end)
end

function CHALLENGE:AddTimer(delay, func)
    table.insert(self.timers, {
        delay = delay,
        func = func
    })
end

function CHALLENGE:StopTracking()
    if IsValid(self.player) then
        ASAPChallenges[self.uid][self.player] = nil
    end
    timer.Remove("BATTLEPASS_Challenges_" .. self.uid .. self.uniqueid .. self.pid)
end

function CHALLENGE:StartTracking()
    for i, v in pairs(self.timers) do
        timer.Create("BATTLEPASS_Challenges_" .. self.uid .. self.uniqueid .. self.pid, v.delay, 0, function(...)
            if not IsValid(self.player) then
                self:Remove()

                return
            end

            v.func(self, self.player, ...)
        end)
    end

    for i, v in pairs(self.hooks) do
        if not ASAPChallenges[self.uid] then
            ASAPChallenges[self.uid] = {}
        end

        ASAPChallenges[self.uid][self.player] = self
    end
end

function CHALLENGE:SetUniqueID(id)
    self.uniqueid = id
end

function CHALLENGE:SetPlayer(ply)
    self.player = ply
    self.pid = ply:SteamID64()
end

function CHALLENGE:Remove()
    self:StopTracking()
end

function BATTLEPASS:CreateTemplateChallenge(...)
    local tempTbl = table.Copy(CHALLENGE)
    tempTbl.hooks = {}
    tempTbl.timers = {}
    tempTbl.stage = 0
    tempTbl.progress = 0
    tempTbl.goal = 10

    return tempTbl
end

function BATTLEPASS:RegisterChallenge(tbl)
    local id = tbl.uid
    if not id then return end
    BATTLEPASS.Challenges[id] = tbl
end