local GM = {}

if SERVER then
    util.AddNetworkString("ASAP.Arena.RareGungame.LevelUp")
end

GM.Base = "base"
GM.Name = "Mythical Madness"
GM.Icon = "vgui/arena/rareroyal256.png"
GM.Description = "The Rumble in the Tumble has begun."
GM.NoVote = true
GM.GameType = "DM"
GM.NoKillStreaks = true
local weaponList = {"tfa_cso2_awp_ss", "tfa_cso_gungnir_nrm", "tfa_cso_magnum_lancer", "infinitygunx99", "tfa_doom_gauss", "tfa_cso_gunkata", "mac_bo2_deathmach", "m27__mystifier", "destiny_recluse", "tfa_cso_m134_zhubajie", "tfa_cso_starchasersr", "tfa_cso_thunderpistol", "tfa_cso_destroyer", "tfa_cso2_pkm_fire", "tfa_cso_starchaserar", "tfa_cso_tornadoc", "tfa_cso_laserminigun", "tfa_cso_savery_v6", "tfa_cso_magnumdrill_expert", "tfa_cso_xtracker_nrm", "tfa_cso_guardian", "tfa_cso_elvenranger", "tfa_cso_janus11b", "tfa_cso_janus3b", "tfa_cso2_waltherpp", "csgo_bayonet_ultraviolet"}
GM.MaxLevel = 0
GM.Rewards = {1054}

function GM:Init()
    if CLIENT then return end

    if (not asapArena.Players) then
        asapArena.Players = {}
    end

    for k, v in pairs(asapArena.Players) do
        k:SetNW2Int("GGLevel", 1)
        k:SetFrags(0)
        k:SetDeaths(0)
        k:GodDisable()
        k:Freeze(false)
        k:SetNoDraw(false)
        self:PlayerSpawn(k)
    end

    asapArena:SetState(1)
    SetGlobalInt("Arena.EndRound", CurTime() + 60)
    timer.Remove("WarmupTime")
    timer.Create("WarmupTime", 60, 1, function()
        asapArena:SetState(2)
        for k, v in pairs(asapArena:GetPlayers()) do
            v:SetFrags(0)
            v:SetNW2Int("GGLevel", 1)
            v:Spawn()
        end
    end)

    SetGlobalBool("Arena.RareCaseEvent", true)
    asapArena:StartRareCaseEvent(true)

    self.MaxLevel = 1
end

function GM:EndRound(ply, case)
    asapArena:StartGamemodeVote()
    if not asapArena.BanList[ply:SteamID()] then
        asapArena.BanList[ply:SteamID()] = {}
    end

    asapArena.BanList[ply:SteamID()].gungame = 4

    for k, v in pairs(asapArena.BanList or {}) do
        if not asapArena.BanList[k].gungame then continue end
        asapArena.BanList[k].gungame = (asapArena.BanList[k].gungame or 1) - 1
        hasChanges = true

        if (asapArena.BanList[k].gungame <= 0) then
            asapArena.BanList[k].gungame = nil
        end
    end

    file.Write("event_winners.txt", util.TableToJSON(asapArena.BanList))
    case:ResetSequence("open")
    case:SetSequence("open")
    case:SetPlaybackRate(1)
    ply:EmitSound("misc/achievement_earned.wav")

    if (ply.UB3AddItem) then
        for k, v in pairs(self.Rewards) do
            ply:UB3AddItem(v, 1)
            asapLogs:add("Arena Wins", ply, nil, {
                rew = 351,
                id = asapArena.ActiveGamemode.id
            })
        end
    end

    net.Start("Arena.GotCrate")
    net.WriteEntity(ply)
    net.Broadcast()
    asapArena:EndCaseEvent()

    timer.Simple(case:SequenceDuration() - .25, function()
        for k = 1, 6 do
            timer.Simple(k / 10, function()
                local effectdata = EffectData()
                effectdata:SetOrigin(case:GetPos() + case:GetUp() * 128 + VectorRand() * 64)
                util.Effect("balloon_pop", effectdata)
            end)
        end
    end)

    timer.Simple(case:SequenceDuration() + 1.5, function()
        case:ResetSequence("idle")
        case:SetSequence("idle")
    end)

    timer.Simple(case:SequenceDuration() + 3, function()
        if IsValid(case) then
            case.OldAngle = case:GetAngles()
            case:SetFallProgress(0)
            case:EmitSound("create_rotate")
            case.ReleaseState = 1
        end
    end)
end

function GM:PlayerSpawn(ply, fs)
    timer.Simple(0, function()
        self:SelectSpawn(ply)
        asapArena:SetPlayerModel(ply)
        ply:StripWeapons()
        if (asapArena:GetState() == 1) then
            ply:Give(weaponList[math.random(1, #weaponList - 1)])
        else
            ply:Give(weaponList[math.min(ply:GetNW2Int("GGLevel", 1), #weaponList)])
        end

        if (ply:GetNW2Int("GGLevel", 1) < #weaponList) then
            ply:Give("csgo_m9")
        end
    end)
end

function GM:PlayerDeath(ply, att)
    if (ply == att) then return end
    if (asapArena:GetState() == 1) then return end
    if (att:GetNW2Int("GGLevel", 1) >= #weaponList) then return end
    if (ply:GetNW2Int("GGLevel", 1) ~= self.MaxLevel or ply:GetNW2Int("GGLevel", 1) >= self.MaxLevel) then
        att:SetNW2Int("GG_Kills", att:Frags() + 1)
    else
        att:SetNW2Int("GG_Kills", 2)
    end

    if (att:Frags() >= 2) then
        att:SetFrags(0)
        att:SetNW2Int("GGLevel", att:GetNW2Int("GGLevel", 1) + 1)
        att:StripWeapons()
        att:Give(weaponList[math.min(att:GetNW2Int("GGLevel", 1), #weaponList)])

        if (att:GetNW2Int("GGLevel", 1) >= #weaponList) then
            att:StripWeapon("csgo_default_t_golden")
        end

        if (self.MaxLevel < att:GetNW2Int("GGLevel", 1)) then
            net.Start("ASAP.Arena.RareGungame.LevelUp")
            net.WriteString(att:Nick())
            net.WriteInt(att:GetNW2Int("GGLevel", 1), 16)
            net.Send(asapArena:GetPlayers())
            self.MaxLevel = att:GetNW2Int("GGLevel", 1)
        end
    end
end

if CLIENT then
    local gun = surface.GetTextureID("ui/asap/gun_license")

    function GM:HUDPaint()
        local players = {}

        for k, v in pairs(player.GetAll()) do
            if (v:InArena()) then
                table.insert(players, v)
            end
        end

        table.sort(players, function(a, b) return a:GetNW2Int("GGLevel", 1) > b:GetNW2Int("GGLevel", 1) end)
        local w, h, y = 64, 78, 24

        for k = 1, 5 do
            local ply = players[k]

            if (ply) then
                local bigSize = (w + 8) * math.min(#players, 5)
                local x = ScrW() / 2 - bigSize / 2 - w
                draw.RoundedBox(8, x + (w + 8) * k, y, w, h, ply:GetNW2Int("GGLevel", 1) == #weaponList and Color(230, 150, 0) or Color(26, 26, 26, 150))

                if (not IsValid(ply._arenaAvatar)) then
                    ply._arenaAvatar = vgui.Create("AvatarImage")
                    ply._arenaAvatar:SetSize(w - 8, w - 8)
                    ply._arenaAvatar:SetPlayer(ply, 96)
                    ply._arenaAvatar:SetPaintedManually(true)
                end

                ply._arenaAvatar:SetPos(x + 4 + (w + 8) * k, y + 4)
                ply._arenaAvatar:SetSize(w - 8, w - 8)
                ply._arenaAvatar:PaintManual()
                draw.SimpleText(ply:GetNW2Int("GGLevel", 1), "XeninUI.TextEntry", x + w / 2 + (w + 8) * k, y + h - 8, Color(255, 255, 255, 175), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        if (asapArena:GetState() == 1) then
            local time = string.FormattedTime(math.max(GetGlobalInt("Arena.EndRound") - CurTime(), 0), "%02d:%02d")
            draw.SimpleText("Warmup", "XeninUI.TextEntry", ScrW() / 2, 112, color_white, 1, 0)
            draw.SimpleText(time, "Arena.Medium", ScrW() / 2, 128, color_white, 1, 0)
            return
        end

        if (LocalPlayer():GetNW2Int("GGLevel") == #weaponList) then
            draw.SimpleText("OPEN THE CRATE TO WIN THE GAME", "Arena.Small", ScrW() / 2 + 1, y + h + 21, Color(50, 50, 50, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("OPEN THE CRATE TO WIN THE GAME", "Arena.Small", ScrW() / 2, y + h + 20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            local name = weaponList[LocalPlayer():GetNW2Int("GGLevel", 1) + 1]
            local wepData = weapons.GetStored(name)

            if (wepData) then
                name = wepData.PrintName
            end

            draw.SimpleText("Next weapon: " .. name, "Arena.Small", ScrW() / 2 + 1, y + h + 21, Color(50, 50, 50, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            local _, ty = draw.SimpleText("Next weapon: " .. name, "Arena.Small", ScrW() / 2, y + h + 20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            surface.SetTexture(gun)
            surface.SetDrawColor(255, 255, 255, LocalPlayer():Frags() >= 1 and 255 or 125)
            surface.DrawTexturedRect(ScrW() / 2 - 32, y + h + 12 + ty, 32, 32)
            surface.SetDrawColor(255, 255, 255, 125)
            surface.DrawTexturedRect(ScrW() / 2 + 16, y + h + 12 + ty, 32, 32)
        end
    end

    net.Receive("ASAP.Arena.RareGungame.LevelUp", function()
        local nick = net.ReadString()
        local level = net.ReadInt(16)
        chat.AddText(Color(245, 160, 80), "[RareGunGame] ", color_white, "Player ", Color(250, 75, 75), nick, color_white, " has reached level ", Color(85, 230, 85), tostring(level))
    end)
end

asapArena:AddGamemode("raregungame", GM)