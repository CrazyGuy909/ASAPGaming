local GM = {}


GM.Base = "base"
GM.Name = "Mechanical Royal Game"
GM.Icon = "vgui/arena/case"
GM.Description = "Mechanical Royal Crate has appeared with some goodies"
GM.GameType = "DM"
GM.NoKillStreaks = true
local weaponList = {
    "infinitygunx99", "tfa_cso_quantum_horizon",
    "tfa_cso_plasmagunexc", "tfa_cso_lunarcannon",
    "tfa_cso_magnum_shooter", "tfa_cso_plasmagunexd",
    "tfa_cso_flamethrower", "weapon_bms_gluon",
    "tfa_cso_tank", "tfa_cso_magnumdrillex",
    "csgo_default_t_golden",
}
local suitsNames = {
    [1] = "armor_rass",
    [2] = "armor_neon",
    [3] = "armor_rescuer_3",
    [4] = "armor_osiris",
    [5] = "armor_gunsmith_3",
    [6] = "armor_hgs",
    [7] = "armor_bulletsmith_3",
    [8] = "armor_bladesmith_3",
    [9] = "armor_dracula",
    [10] = "armor_rwarrior",
    [11] = "armor_rescuer_2",
}
GM.MaxLevel = 0
GM.Rewards = {
    351, 353
}

function GM:Init()
    if CLIENT then return end

    if (not asapArena.Players) then
        asapArena.Players = {}
    end

    for k, v in pairs(asapArena.Players) do
        k:SetNWInt("GGLevel", 1)
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
            v:SetNWInt("GGLevel", 1)
            v:Spawn()
            self:Loadout(v)
        end
    end)

    SetGlobalBool("Arena.CaseEvent", true)
    asapArena:StartCaseEvent(true)

    self.MaxLevel = 1
end

function GM:EntityTakeDamage(ply, dmg)
    local att = dmg:GetAttacker()
    if not IsValid(att) or not att:IsPlayer() then return end
    if (IsValid(att:GetActiveWeapon()) and att:GetActiveWeapon():GetClass() == "csgo_default_t_golden") then
        dmg:ScaleDamage(10)
    end
    if ((ply.godTime or 0) > CurTime()) then
        dmg:SetDamage(0)
        return true
    end
end

function GM:SelectSpawn(ply)
    if (not ply:InArena()) then return end
    
    local favSpawn = string.byte(string.upper(ply:GetInfo("arena_fav_spawn")))
    if (not favSpawn or favSpawn < 65 or favSpawn > 70) then
        favSpawn = math.random(65, 70)
    end

    local ranSpawn = table.Random(asapArena.SpawnPoints[string.char(favSpawn)].spawns)
    ply:SetPos(ranSpawn - Vector(0, 0, 48))
end

function GM:PlayerSpawn(ply, fs)
    timer.Simple(0.1, function()
        self:SelectSpawn(ply)
        self:Loadout(ply)
    end)
    timer.Simple(.1, function()
        ply:GodDisable()
        ply.godTime = CurTime() + 3
    end)
end

function GM:SetPlayerModel()
end

function GM:PlayerDeath(ply, att)
    if (ply == att) then return end
    if (asapArena:GetState() == 1) then return end
    if (not att:IsPlayer()) then return end
    if (att:GetNWInt("GGLevel", 1) >= #weaponList) then return end

    if ((att:Health() / att:GetMaxHealth()) < .3) then
        att:SetHealth(att:GetMaxHealth() * .4)
    end

    if (att:Frags() >= 4) then
        att:SetFrags(0)
        att:SetNWInt("GGLevel", math.Clamp(att:GetNWInt("GGLevel", 1) + 1, 1, #weaponList))
        self:Loadout(att)

        if (att:GetNWInt("GGLevel", 1) < #weaponList) then
            att:StripWeapon("csgo_default_t_golden")
        end

        if (self.MaxLevel < att:GetNWInt("GGLevel", 1)) then
            net.Start("ASAP.Arena.Gungame.LevelUp")
            net.WriteString(att:Nick())
            net.WriteInt(att:GetNWInt("GGLevel", 1), 16)
            net.Send(asapArena:GetPlayers())
            self.MaxLevel = att:GetNWInt("GGLevel", 1)
        end
    end
end

function GM:Loadout(ply)
    ply:StripWeapons()
    local name = weaponList[math.min(ply:GetNWInt("GGLevel", 1), #weaponList)]
    ply:Give(name)
    if (ply:GetNWInt("GGLevel", 1) < #weaponList) then
        ply:Give("tfa_cso_vulcanus9")
    end

    timer.Simple(.1, function()
        ply:giveArmorSuit(Armor:GetByID(suitsNames[math.min(ply:GetNWInt("GGLevel", 1), #suitsNames)]).Name)
        ply:SetHealth(math.min(ply:Health(), 2000))
        ply:SetArmor(math.min(ply:Armor(), 750))
        ply:SetMaxHealth(ply:Health())
        ply:SetMaxArmor(ply:Armor())
        ply:SelectWeapon(name)
    end)
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

if CLIENT then
    local gun = surface.GetTextureID("ui/asap/gun_license")

    function GM:HUDPaint()
        local players = {}

        for k, v in pairs(player.GetAll()) do
            if (v:InArena()) then
                table.insert(players, v)
            end
        end

        table.sort(players, function(a, b) return a:GetNWInt("GGLevel", 1) > b:GetNWInt("GGLevel", 1) end)
        local w, h, y = 64, 78, 24

        for k = 1, 5 do
            local ply = players[k]

            if (ply) then
                local bigSize = (w + 8) * math.min(#players, 5)
                local x = ScrW() / 2 - bigSize / 2 - w
                draw.RoundedBox(8, x + (w + 8) * k, y, w, h, ply:GetNWInt("GGLevel", 1) == #weaponList and Color(230, 150, 0) or Color(26, 26, 26, 150))

                if (not IsValid(ply._arenaAvatar)) then
                    ply._arenaAvatar = vgui.Create("AvatarImage")
                    ply._arenaAvatar:SetSize(w - 8, w - 8)
                    ply._arenaAvatar:SetPlayer(ply, 96)
                    ply._arenaAvatar:SetPaintedManually(true)
                end

                ply._arenaAvatar:SetPos(x + 4 + (w + 8) * k, y + 4)
                ply._arenaAvatar:SetSize(w - 8, w - 8)
                ply._arenaAvatar:PaintManual()
                draw.SimpleText(ply:GetNWInt("GGLevel", 1), "XeninUI.TextEntry", x + w / 2 + (w + 8) * k, y + h - 8, Color(255, 255, 255, 175), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        if (asapArena:GetState() == 1) then
            local time = string.FormattedTime(math.max(GetGlobalInt("Arena.EndRound") - CurTime(), 0), "%02d:%02d")
            draw.SimpleText("Warmup", "XeninUI.TextEntry", ScrW() / 2, 112, color_white, 1, 0)
            draw.SimpleText(time, "Arena.Medium", ScrW() / 2, 128, color_white, 1, 0)
            return
        end

        if (LocalPlayer():GetNWInt("GGLevel") == #weaponList) then
            draw.SimpleText("OPEN THE CRATE TO WIN THE GAME", "Arena.Small", ScrW() / 2 + 1, y + h + 21, Color(50, 50, 50, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("OPEN THE CRATE TO WIN THE GAME", "Arena.Small", ScrW() / 2, y + h + 20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            local name = weaponList[LocalPlayer():GetNWInt("GGLevel", 1) + 1]
            local suitName = Armor:GetByID(suitsNames[LocalPlayer():GetNWInt("GGLevel", 1) + 1]).Name
            local wepData = weapons.GetStored(name)

            if (wepData) then
                name = wepData.PrintName
            end

            draw.SimpleText("Next weapon: " .. name, "Arena.Small", ScrW() / 2 + 1, y + h + 21, Color(50, 50, 50, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Next suit: " .. suitName, "Arena.Small", ScrW() / 2 + 1, y + h + 21 + 24, Color(50, 50, 50, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            local _, ty = draw.SimpleText("Next weapon: " .. name, "Arena.Small", ScrW() / 2, y + h + 20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Next suit: " .. suitName, "Arena.Small", ScrW() / 2, y + h + 44, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            surface.SetTexture(gun)
            for i = 1, 4 do
                surface.SetDrawColor(255, 255, 255, LocalPlayer():Frags() >= i and 255 or 75)
                surface.DrawTexturedRect(ScrW() / 2 - 64 + (i - 1) * 32, y + h + 36 + ty, 32, 32)
            end
        end
    end

end

asapArena:AddGamemode("mechagame", GM)