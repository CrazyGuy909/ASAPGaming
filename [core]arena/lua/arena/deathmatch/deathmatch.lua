local GM = {}
GM.Base = "base"
GM.Name = "DeathMatch"
GM.GameType = "DM"
GM.State = 0
GM.CaseReward = 695
GM.MinPlayers = 4
GM.MoneyReward = {1500000, 400000, 200000}
GM.Duration = 600

function GM:Init(b)
    if CLIENT then return end

    if (not asapArena.Players) then
        asapArena.Players = {}
    end

    if (not b and #asapArena:GetPlayers() < self.MinPlayers) then return end
    asapArena:SetState(0)

    for k, v in pairs(asapArena.Players) do
        if (not IsValid(k)) then continue end
        k:SetFrags(0)
        k:SetDeaths(0)
        k:GodDisable()
        k:Freeze(false)
        k:SetNoDraw(false)
        self:PlayerSpawn(k)
    end

    asapArena:SetState(1)
    SetGlobalInt("Arena.EndRound", CurTime() + self.Duration)
    SetGlobalInt("Arena.DeathmatchScore", 0)
    timer.Remove("Arena.DeathMatch")

    timer.Create("Arena.DeathMatch", self.Duration, 1, function()
        if (asapArena.ActiveGamemode.id == "deathmatch") then
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

function GM:EndRound(ply)
    if (asapArena:GetState() > 1) then
        self:Init()

        return
    end

    asapArena:SetState(2)
    local winners = table.Copy(asapArena:GetPlayers())
    table.sort(winners, function(a, b) return a:GetArenaFrags() > b:GetArenaFrags() end)

    if (IsValid(winners[1]) and winners[1]:GetArenaFrags() >= 15) then
        winners[1]:GiveArenaXP(100, "Winning the match")
        winners[1]:UB3AddItem(self.CaseReward, 1)
        winners[1]:UB3AddItem(1168, 1)
        asapLogs:add("Arena Wins", winners[1], nil, {
            rew = self.CaseReward,
            id = asapArena.ActiveGamemode.id
        })
        hook.Run("onBU3AddItem_Kit", winners[1], 1168)
        winners[1]:addMoney(self.MoneyReward[1])

        if (winners[2] and winners[2]:GetArenaFrags() >= 15) then
            winners[2]:GiveArenaXP(75, "Second place!")
            winners[2]:addMoney(self.MoneyReward[2])
        end

        if (winners[3] and winners[3]:GetArenaFrags() >= 15) then
            winners[3]:GiveArenaXP(40, "Third place!")
            winners[3]:addMoney(self.MoneyReward[3])
        end

        net.Start("Arena.WonCaseRound")
        net.WriteEntity(winners[1])
        net.WriteString("1Mil and Phoenix Crate")
        net.Broadcast()
    end

    for k, v in pairs(winners) do
        v:Freeze(true)

        timer.Simple(5, function()
            if IsValid(v) then
                v:Freeze(false)
            end

            asapArena:StartGamemodeVote()
        end)
    end
end

function GM:PlayerJoin(ply)
    ply:SetFrags(0)
    ply:SetDeaths(0)

    if (#asapArena:GetPlayers() >= self.MinPlayers and asapArena:GetState() == 0) then
        self:Init(true)
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

    if (att:GetArenaFrags() >= 50) then
        self:EndRound()
    end

    local max = GetGlobalInt("Arena.DeathmatchScore", 0)

    if (att:GetArenaFrags() > max) then
        SetGlobalInt("Arena.DeathmatchScore", att:GetArenaFrags())
    end
end

if CLIENT then
    local ammo = Material("asapf4/ammo.png")

    function GM:HUDPaint()
        local players = {}

        for k, v in pairs(player.GetAll()) do
            if (v:InArena()) then
                table.insert(players, v)
            end
        end

        table.sort(players, function(a, b) return a:GetArenaFrags() > b:GetArenaFrags() end)
        local w, h, y = 64, 78, 24

        for k = 1, 5 do
            local ply = players[k]

            if (ply) then
                local bigSize = (w + 8) * math.min(#players, 5)
                local x = ScrW() / 2 - bigSize / 2 - w
                draw.RoundedBox(8, x + (w + 8) * k, y, w, h, ply:GetArenaFrags() >= 45 and Color(230, 150, 0) or Color(26, 26, 26, 150))

                if (not IsValid(ply._arenaAvatar)) then
                    ply._arenaAvatar = vgui.Create("AvatarImage")
                    ply._arenaAvatar:SetSize(w - 8, w - 8)
                    ply._arenaAvatar:SetPlayer(ply, 96)
                    ply._arenaAvatar:SetPaintedManually(true)
                end

                ply._arenaAvatar:SetPos(x + 4 + (w + 8) * k, y + 4)
                ply._arenaAvatar:SetSize(w - 8, w - 8)
                ply._arenaAvatar:PaintManual()
                draw.SimpleText(ply:GetArenaFrags(), "XeninUI.TextEntry", x + w / 2 + (w + 8) * k, y + h - 8, Color(255, 255, 255, 175), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        if (asapArena:GetState() == 0) then
            draw.SimpleText("Waiting players...", "Arena.Small", ScrW() / 2, 112, color_white, 1, 0)
        else
            local time = string.FormattedTime(math.max(GetGlobalInt("Arena.EndRound") - CurTime(), 0), "%02d:%02d")
            draw.SimpleText("Time remaining", "XeninUI.TextEntry", ScrW() / 2, 112, color_white, 1, 0)
            draw.SimpleText(time, "Arena.Medium", ScrW() / 2, 128, color_white, 1, 0)
        end

        local remaining = 50 - GetGlobalInt("Arena.DeathmatchScore", 0)

        if (remaining <= 5) then
            draw.SimpleText("Only " .. remaining .. " kills", "XeninUI.TextEntry", ScrW() / 2, 176, Color(255, 150, 0), 1, 0)
            surface.SetMaterial(ammo)
            local size = 5 * 32

            for k = 1, 5 do
                surface.SetDrawColor(255, 255, 255, k <= remaining and 255 or 50)
                surface.DrawTexturedRect(ScrW() / 2 - size / 2 + (k - 1) * 32, 202, 32, 32)
            end
        end
    end
end

asapArena:AddGamemode("deathmatch", GM)