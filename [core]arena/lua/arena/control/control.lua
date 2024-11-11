local GM = {}
GM.Base = "base"
GM.Name = "Blazing Battlegrounds"
GM.GameType = "DM"
GM.State = 0
GM.Icon = "vgui/arena/blazingbattleground"
GM.CaseReward = 695
GM.MinPlayers = 2
GM.MoneyReward = 10000
GM.Duration = 600
GM.MaxScore = 75

function GM:Init(b)
    if CLIENT then return end

    if (not asapArena.Players) then
        asapArena.Players = {}
    end

    if (not b and #asapArena:GetPlayers() < self.MinPlayers) then return end
    asapArena:SetState(0)

    local doMove = false
    for k, v in pairs(asapArena.Players) do
        if (not IsValid(k)) then continue end
        k:SetFrags(0)
        k:SetDeaths(0)
        k:SetNWBool("TDM.IsRed", doMove)
        k:GodDisable()
        k:Freeze(false)
        k:SetNoDraw(false)
        doMove = !doMove
        self:PlayerSpawn(k)
    end

    asapArena:SetState(1)
    SetGlobalInt("Arena.EndRound", CurTime() + self.Duration)
    SetGlobalInt("Arena.TDM_A", 0)
    SetGlobalInt("Arena.TDM_B", 0)
    timer.Remove("Arena.DeathMatch")

    timer.Create("Arena.DeathMatch", self.Duration, 1, function()
        if (asapArena.ActiveGamemode.id == "teamdeathmatch") then
            self:EndRound()
        end
    end)
end

function GM:PlayerSpawn(ply)
    ply:SetNoDraw(false)
    ply:GodDisable()

    timer.Simple(0, function()
        self:SelectSpawn(ply)
        self:Loadout(ply)
    end)
end

function GM:OnRemove()
    timer.Remove("Arena.DeathMatch")
end

function GM:EndRound(isRed)
    if (asapArena:GetState() > 1) then
        self:Init()

        return
    end

    if (isRed == nil) then
        self:EndRound(GetGlobalInt("Arena.TDM_A", 0) > GetGlobalInt("Arena.TDM_B"))
        return
    end

    local winners = {}
    for k, v in pairs(asapArena:GetPlayers()) do
        if (v:GetNWBool("TDM.IsRed") == isRed) then
            v.tdmratio = v:GetArenaFrags() / self.MaxScore
            table.insert(winners, v)
        end
    end

    asapArena:SetState(2)
    table.sort(winners, function(a, b) return a:GetArenaFrags() > b:GetArenaFrags() end)

    for k, v in pairs(winners) do
        if (k == 1) then
            v:GiveArenaXP(100, "Winning the match")
            v:UB3AddItem(self.CaseReward, 1)
            asapLogs:add("Arena Wins", v, nil, {
                rew = self.CaseReward,
                id = asapArena.ActiveGamemode.id
            })
            net.Start("Arena.WonCaseRound")
            net.WriteEntity(v)
            net.WriteString(DarkRP.formatMoney(self.MoneyReward * v:GetArenaFrags() * 2) .. " and " .. UB3.Items.Items[self.CaseReward].name)
            net.Broadcast()
        end
        v:GiveArenaXP(30 + v:GetArenaFrags() * 5, "#" .. k .. " place!")
        v:addMoney(self.MoneyReward * v:GetArenaFrags())
    end

    for k, v in pairs(asapArena:GetPlayers()) do
        v:Freeze(true)

        timer.Simple(5, function()
            if IsValid(v) then
                v:Freeze(false)
            end

            asapArena:StartGamemodeVote()
        end)
    end
end

function GM:SetPlayerModel(ply)
    ply:SetModel(table.Random(asapArena.Models[ply:GetNWBool("TDM.IsRed", false) and 2 or 3].Models))
    ply:GetHands():SetModel("models/weapons/c_arms_cstrike.mdl")
    timer.Simple(0, function()
        net.Start("ASAP.HUD.ModelUpdate")
        net.Send(ply)
    end)
    return true
end

function GM:PlayerJoin(ply)
    ply:SetFrags(0)
    ply:SetDeaths(0)
    local count = {0, 0}
    for k, v in pairs(asapArena:GetPlayers()) do
        local tag = v:GetNWBool("TDM.IsRed", false) and 1 or 2
        count[tag] = count[tag] + 1
    end

    ply:SetNWBool("TDM.IsRed", count[1] > count[2])
    if (#asapArena:GetPlayers() >= self.MinPlayers and asapArena:GetState() == 0) then
        self:Init(true)
    end
end

function GM:EntityTakeDamage(ent, dmg)
    if (not ent:GetAttacker():IsPlayer()) then return end
    if (ent:GetNWBool("TDM.IsRed") == dmg:GetAttacker():GetNWBool("TDM.IsRed")) then
        dmg:SetDamage(0)
        return false
    end
end

function GM:PlayerLeave(ply)
    if (asapArena:GetState() == 1 and #asapArena:GetPlayers() <= 1) then
        asapArena:SetState(0)
    end
end

function GM:PlayerDeath(ply, att)
    if (ply == att) then return end
    if (not att:IsPlayer()) then return end
    if (asapArena:GetState() ~= 1) then return end

    local tag = "Arena.TDM_" .. (att:GetNWBool("TDM.IsRed", false) and "A" or "B")
    SetGlobalInt(tag, GetGlobalInt(tag, 0) + 1)

    if (GetGlobalInt(tag, 0) >= self.MaxScore) then
        self:EndRound(att:GetNWBool("TDM.IsRed"))
    end
end

if CLIENT then
    local ammo = Material("asapf4/ammo.png")
    function IsLookingAt(ply, targetVec)
        local diff = targetVec - ply:GetShootPos()
        return ply:GetAimVector():Dot(diff) / diff:Length() >= 0.95 
    end

    function GM:HUDPaint()
        
        if (asapArena:GetState() == 0) then
            draw.SimpleText("Waiting players...", "Arena.Small", ScrW() / 2, 100, color_white, 1, 0)
        else
            local time = string.FormattedTime(math.max(GetGlobalInt("Arena.EndRound") - CurTime(), 0), "%02d:%02d")
            draw.SimpleText("Time remaining", "XeninUI.TextEntry", ScrW() / 2, 100, color_white, 1, 0)
            draw.SimpleText(time, "Arena.Medium", ScrW() / 2, 112, color_white, 1, 0)
        end

        local scoreA = GetGlobalInt("Arena.TDM_A", 0)
        local scoreB = GetGlobalInt("Arena.TDM_B", 0)

        local remaining = 50 - GetGlobalInt("Arena.DeathmatchScore", 0)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(ScrW() / 2 - 64, 58, 64, 38)
        surface.DrawRect(ScrW() / 2, 58, 64, 38)
        surface.SetDrawColor(255, 255, 255, 50)
        surface.DrawOutlinedRect(ScrW() / 2 - 64, 58, 64, 38)
        surface.DrawOutlinedRect(ScrW() / 2, 58, 64, 38)

        local wide = ScrW() * .3
        surface.DrawOutlinedRect(ScrW() / 2 - wide / 2, 47, wide, 12)

        local percent = scoreA / self.MaxScore
        surface.SetDrawColor(228, 133, 25)
        surface.DrawRect(ScrW() / 2 + 2 - (wide / 2) * (percent), 49, (wide / 2 - 2) * percent, 8)
        percent = scoreB / self.MaxScore
        surface.SetDrawColor(25, 170, 228)
        surface.DrawRect(ScrW() / 2, 49, (wide / 2 - 2) * percent, 8)
        
        draw.SimpleText(scoreA, "Arena.Medium", ScrW() / 2 - 32, 76, Color(228, 133, 25), 1, 1)
        draw.SimpleText(scoreB, "Arena.Medium", ScrW() / 2 + 32, 76, Color(25, 170, 228), 1, 1)

        draw.SimpleText("You're " .. (LocalPlayer():GetNWBool("TDM.IsRed", false) and "Orange" or "Blue"), "Arena.Small", ScrW() / 2, 20, LocalPlayer():GetNWBool("TDM.IsRed", false) and Color(228, 133, 25) or Color(25, 170, 228), 1, 0)

        for k, v in pairs(asapArena:GetPlayers()) do
            if (not v:Alive() or v == LocalPlayer()) then continue end
            if (v:GetNWBool("TDM.IsRed", false) == LocalPlayer():GetNWBool("TDM.IsRed", false) && IsLookingAt(LocalPlayer(), v)) then
                local pos = (v:EyePos() - Vector(0, 0, 24)):ToScreen()
                draw.SimpleText("-Ally-", "Arena.Small", pos.x, pos.y + 24, Color(100, 255, 0), 1, 1)

            end
        end
    end
end

asapArena:AddGamemode("tdm", GM)