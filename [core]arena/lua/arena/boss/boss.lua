local GM = {}
GM.Base = "base"
GM.Name = "Boss Mode"
GM.Description = "Something big has appeared"
GM.GameType = "Boss"
GM.State = 0
GM.MinPlayers = 2
GM.NoVote = true
GM.NoKillStreaks = true
GM.DisableSelect = true
GM.NoMinimap = true
GM.BossClass = "sent_asap_boss_1"
GM.AutoSpawn = "E"

GM.MoneyReward = {1500000, 400000, 200000}

GM.Duration = 600

if SERVER then
    util.AddNetworkString("Arena:BossMessage")
end

function GM:Init(class)
    if CLIENT then return end

    for k, v in pairs(player.GetAll()) do
        v.cannotReturnEvent = nil
    end

    if (not asapArena.Players) then
        asapArena.Players = {}
    end

    if (!self.bossActive and class) then
        //SafeRemoveEntity(ARENA_BOSS)
        self.bossActive = true
        self.BossTable = scripted_ents.Get(class)
        local ent = ents.Create(class)
        ent:Spawn()
        ARENA_BOSS = ent
        self.Boss = ent
        self.Boss.Gamemode = self
        net.Start("Arena:BossMessage")
        net.WriteString(class)
        net.Broadcast()
    end

    
    self.Players = 0
    asapArena:SetState(0)

    for k, v in pairs(asapArena.Players) do
        if (not IsValid(k)) then continue end
        k:GodDisable()
        k:Freeze(false)
        k:SetNoDraw(false)
        self:PlayerJoin(k)
        self:PlayerSpawn(k)
    end

    hook.Add("CanPlayerJoinArena", "NoStarters", function(ply)
        if (ply.cannotReturnEvent or asapArena:GetState() == asapArena:GetState() == 2) then
            return false, "The battle has already started"
        end
    end)
end

function GM:EntityTakeDamage(ent, dmg)
    if (ent:IsPlayer() and dmg:GetAttacker():IsPlayer()) then
        dmg:SetDamage(0)
        return true
    end
end

function GM:PlayerSpawn(ply)
    timer.Simple(0, function()
        self:SelectSpawn(ply)
        self:Loadout(ply)
    end)
end

function GM:Loadout(ply)
    ply:SetArmor(200)
    ply:SetMaxArmor(200)
    ply:SetHealth(200)
    ply:SetMaxHealth(200)
    ply:SetJumpPower(400)
    ply:StripWeapons()

    hook.Run("BossLoadout", ply)
end

function GM:SelectSpawn(ply)
    timer.Simple(0, function()
        if (ply.markedToLeave) then
            ply.cannotReturnEvent = true
            ply:LeaveArena()
            return
        end
        ARENA_BOSS:DoSpawn(ply)
    end)
end

function GM:OnRemove()
    if CLIENT then return end
    timer.Remove("SK.Spawn")
    hook.Remove("CanPlayerJoinArena", "NoStarters")

    if IsValid(ARENA_BOSS) then
        ARENA_BOSS:Remove()
    end
end

function GM:EndRound()
    for _, ply in pairs(asapArena:GetPlayers()) do
        for chance, reward in pairs(BossConfig.CaseReward) do
            if (math.random(1, 100) >= chance) then
                ply:UB3AddItem(chance)
            end
        end
    end
end

function GM:UpdateTimer()
    if (IsValid(ARENA_BOSS) and asapArena:GetState() == 0 and self.Players >= BossConfig.MinPlayers) then
        asapArena:SetState(1)
        SetGlobalInt("Arena.EndRound", CurTime() + ChrismasEvents.WaitTime)
        ARENA_BOSS:SetStartStamp(CurTime() + ChrismasEvents.WaitTime)
        ARENA_BOSS.forceStamp = CurTime() + ChrismasEvents.WaitTime

        timer.Create("SK.Spawn", ChrismasEvents.WaitTime, 1, function()
            asapArena:SetState(2)
            ARENA_BOSS:StartBoss()
        end)
    end
end

function GM:PlayerJoin(ply)
    self.Players = (self.Players or 0) + 1
    ply.markedToLeave = nil
    ply:ConCommand("asap_showminimap", 0)

    if IsValid(ARENA_BOSS) then
        self:UpdateTimer()
    end
end

function GM:PlayerLeave(ply)
    self.Players = (self.Players or 0) - 1
    ply:ConCommand("asap_showminimap", 1)
    ply.cannotReturnEvent = true
end

function GM:PlayerDeath(ply, att)
    ply.markedToLeave = true
end

if CLIENT then
    function GM:HUDPaint()
    end

    net.Receive("Arena:BossMessage", function()
        if (LocalPlayer():InArena()) then return end

        if IsValid(CASE_ON) then
            CASE_ON:Remove()
        end

        local class = scripted_ents.Get(net.ReadString())
        surface.PlaySound("ui/achievement_earned.wav")
        local texture = class.Icon
        CASE_ON = vgui.Create("DPanel")
        CASE_ON:SetSize(420, 96)
        CASE_ON:SetPos(ScrW() / 2 - CASE_ON:GetWide() / 2, -96)
        CASE_ON:MoveTo(ScrW() / 2 - CASE_ON:GetWide() / 2, 172, .5)

        CASE_ON.Paint = function(s, w, h)
            local x, y = s:LocalToScreen(0, 0)
            BSHADOWS.BeginShadow()
            draw.RoundedBox(8, x, y, w, h, Color(42, 42, 42))
            BSHADOWS.EndShadow(1, 2, 2)
            surface.SetDrawColor(color_white)
            surface.SetMaterial(texture)
            DisableClipping(true)
            surface.DrawTexturedRectRotated(w / 2, -62, 256 * (class.IconScale or 1), 256 * (class.IconScale or 1), 0)
            DisableClipping(false)
            draw.SimpleText(class.PrintName .. " has invaded us!", "Arena.Small", w / 2, 24, color_white, TEXT_ALIGN_CENTER)
        end

        CASE_ON._btn = vgui.Create("DButton", CASE_ON)
        CASE_ON._btn:SetSize(24, 24)
        CASE_ON._btn:SetPos(CASE_ON:GetWide() - 28, 4)
        CASE_ON._btn:SetText("❌")
        CASE_ON._btn:SetTextColor(color_white)
        CASE_ON._btn.Paint = function() end

        CASE_ON._btn.DoClick = function()
            CASE_ON:Remove()
            surface.PlaySound("ui/hint.wav")
        end

        CASE_ON.Join = vgui.Create("DButton", CASE_ON)
        CASE_ON.Join:Dock(BOTTOM)
        CASE_ON.Join:SetTall(32)
        CASE_ON.Join:SetText("JOIN")
        CASE_ON.Join:SetFont("Arena.Small")
        CASE_ON.Join:SetTextColor(color_white)
        CASE_ON.Join:DockMargin(32, 0, 32, 10)

        CASE_ON.Join.Paint = function(s, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(125, 200, 25))

            if (s:IsHovered()) then
                draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, 50))
            end
        end

        CASE_ON.Join.DoClick = function(s, w, h)
            net.Start("ASAP.Arena.JoinArena")
            net.SendToServer()
            surface.PlaySound("ui/freeze_cam.wav")
            CASE_ON:Remove()
        end

        timer.Simple(60, function()
            if IsValid(CASE_ON) then
                CASE_ON:Remove()
            end
        end)
    end)
end

asapArena:AddGamemode("bossmode", GM)