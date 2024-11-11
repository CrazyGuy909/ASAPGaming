local GM = {}
GM.Base = "base"
GM.Name = "Blazing Battlegrounds"
GM.GameType = "DM"
GM.Description = "The battle has begun."
GM.Icon = "vgui/arena/biohazard"
GM.State = 0
GM.CaseReward = 695
GM.MinPlayers = 2
GM.MoneyReward = 10000
GM.Duration = 600
GM.MaxScore = 75

function GM:Init(b)
    if CLIENT then return end
	BroadcastLua("DisplayNotification('tdm')")
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
        if (asapArena.ActiveGamemode.id == "tdm") then
			print("IAMENDINGROUND")
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
	local winningTeamName = isRed and "Red Team" or "Blue Team"
    for k, v in pairs(asapArena:GetPlayers()) do
        if (v:GetNWBool("TDM.IsRed") == isRed) then
            v.tdmratio = v:GetArenaFrags() / self.MaxScore
            table.insert(winners, v)
        end
    end
	
    asapArena:SetState(2)
    table.sort(winners, function(a, b) return a:GetArenaFrags() > b:GetArenaFrags() end)
	print("HERE")
    for k, v in pairs(winners) do
        if (k == 1) then
            v:GiveArenaXP(100, "Winning the match")
            v:UB3AddItem(self.CaseReward, 1)
            net.Start("Arena.WonCaseRound")
            net.WriteEntity(v)
            net.WriteString("Phoenix Crate")
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

            asapArena:SetGamemode(GetGlobalString("ActiveGamemode", "deathmatch"))
			asapArena:SetGamemode("deathmatch")
			print("SETMODE")
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
    local redTeamCount = 0
    local blueTeamCount = 0
    for _, player in pairs(asapArena:GetPlayers()) do
        if player:GetNWBool("TDM.IsRed", false) then
            redTeamCount = redTeamCount + 1
        else
            blueTeamCount = blueTeamCount + 1
        end
    end

    -- Assign the player to the team with fewer players
    if redTeamCount <= blueTeamCount then
        ply:SetNWBool("TDM.IsRed", true)  -- Assign to Red Team
    else
        ply:SetNWBool("TDM.IsRed", false)  -- Assign to Blue Team
    end

    -- Initialize the game if enough players are present and the game has not started
    if (#asapArena:GetPlayers() >= self.MinPlayers and asapArena:GetState() == 0) then
        self:Init(true)
    end
end

function GM:EntityTakeDamage(ent, dmg)
    if not IsValid(dmg) or not dmg:GetAttacker() or not dmg:GetAttacker():IsPlayer() then
        return
    end
    
    if ent:GetNWBool("TDM.IsRed") == dmg:GetAttacker():GetNWBool("TDM.IsRed") then
        dmg:SetDamage(0)
        return true
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
    local function IsTeammateLookingAt(ply, target)
        if not target:Alive() or target == ply then
            return false
        end

        if target:GetNWBool("TDM.IsRed") ~= ply:GetNWBool("TDM.IsRed") then
            return false
        end

        local diff = target:EyePos() - ply:GetShootPos()
        local aimDir = ply:GetAimVector()
        return aimDir:Dot(diff:GetNormalized()) > 0.95
    end

    function GM:HUDPaint()
        local ply = LocalPlayer()
        local plyTeamColor = ply:GetNWBool("TDM.IsRed", false) and Color(228, 133, 25) or Color(25, 170, 228)
        local plyTeamText = ply:GetNWBool("TDM.IsRed", false) and "Orange" or "Blue"
        
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
		for _, teammate in pairs(asapArena:GetPlayers()) do
            if IsTeammateLookingAt(ply, teammate) then
                local pos = (teammate:EyePos() - Vector(0, 0, 24)):ToScreen()
                draw.SimpleText("-Ally-", "Arena.Small", pos.x, pos.y + 24, Color(100, 255, 0), 1, 1)
            end
        end
        draw.SimpleText("You're " .. (LocalPlayer():GetNWBool("TDM.IsRed", false) and "Orange" or "Blue"), "Arena.Small", ScrW() / 2, 20, LocalPlayer():GetNWBool("TDM.IsRed", false) and Color(228, 133, 25) or Color(25, 170, 228), 1, 0)
    end
end

asapArena:AddGamemode("tdm", GM)