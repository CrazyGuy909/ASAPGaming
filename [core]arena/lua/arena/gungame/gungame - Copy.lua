local GM = {}

if SERVER then
    util.AddNetworkString("ASAP.Arena.Gungame.LevelUp")
end

GM.Base = "base"
GM.Name = "Venator Vengence"
GM.Icon = "vgui/arena/venator"
GM.Description = "The Venator Dropped Reward in Arena"
GM.GameType = "DM"
GM.NoKillStreaks = true

local weaponList = {
    "weapon_752_e11",
    "weapon_752_e5",
    "weapon_752_dlt19",
    "weapon_752_dc15s",
    "weapon_752_dc17m_br",
    "weapon_752_dc15a",
    "weapon_752_bowcaster",
    "weapon_752_ee3",
    "weapon_jew_emp_rifle",
    "weapon_jew_iondisruptor",
    "weapon_jew_westarm5",
    "dc17m_shotgun",
    "weapon_jew_dc17m_at",
    "weapon_752_dsbp",
    "weapon_752_ihr",
    "csgo_bayonet",
}

GM.MaxLevel = 0
GM.Rewards = {198}

function GM:Init()
    if CLIENT then return end

    if not asapArena.Players then
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
        end
    end)

    SetGlobalBool("Arena.CaseEvent", true)
    asapArena:StartCaseEvent(true)
    self.MaxLevel = 1
end

function GM:SelectSpawn(ply)
    if not ply:InArena() then return end

    if ply.armorSuit then
        ply:SetNWBool("InArena", false)
        asapArena:Run("PlayerLeave", nil, ply)
        asapArena:SavePlayer(ply)
        ply:SetTeam(TEAM_CITIZEN)
        local spawn = hook.Run("PlayerSelectSpawn", ply)
        ply:SetPos(spawn:GetPos())

        return
    end

    local favSpawn = string.byte(string.upper(ply:GetInfo("arena_fav_spawn")))
    if (not favSpawn or favSpawn < 65 or favSpawn > 70) then
        favSpawn = math.random(65, 70)
    end

    local ranSpawn = table.Random(asapArena.SpawnPoints[string.char(favSpawn)].spawns)
    ply:SetPos(ranSpawn - Vector(0, 0, 48))
end

function GM:EntityTakeDamage(ply, dmg)
    if (ply.godTime or 0) > CurTime() then
        dmg:SetDamage(0)

        return true
    end
end

function GM:PlayerSpawn(ply, fs)
    timer.Simple(0, function()
        self:SelectSpawn(ply)
        ply:GodDisable()
        ply.godTime = CurTime() + 3
        local tag = ply:SteamID64() .. "_godmode"

        hook.Add("KeyPress", tag, function(pl, key)
            if pl == ply and key == IN_ATTACK then
                pl:GodDisable()
                ply.godTime = 0
                hook.Remove("KeyPress", tag)
            end
        end)

        asapArena:SetPlayerModel(ply)
        ply:StripWeapons()

        if asapArena:GetState() == 1 then
            ply:Give(weaponList[math.random(1, #weaponList - 1)])
        else
            ply:Give(weaponList[math.min(ply:GetNWInt("GGLevel", 1), #weaponList)])
        end

        if ply:GetNWInt("GGLevel", 1) < #weaponList then
            ply:Give("csgo_flip_lore")
        end

        //if ply:HasWeapon("csgo_bayonet") then
            //self.AutoSpawn = "E"
        //end
    end)
end

function GM:PlayerDeath(ply, att)
    if ply == att then return end
    if asapArena:GetState() == 1 then return end
    if not att:IsPlayer() then return end
    if att:GetNWInt("GGLevel", 1) >= #weaponList then return end

    -- Check if the player has reached the kill count threshold
    if att:Frags() >= 2 then
        -- Level up the player and give them the next weapon
        att:SetNWInt("GGKills", 0) -- Reset the kill count
        att:SetNWInt("GGLevel", math.Clamp(att:GetNWInt("GGLevel", 1) + 1, 1, #weaponList))
        att:StripWeapons()
        att:Give(weaponList[math.min(att:GetNWInt("GGLevel", 1), #weaponList)])
    else
        -- Increment the player's kill count
        att:SetNWInt("GGKills", att:GetNWInt("GGKills", 0) + 1)
    end

    -- If the player reaches the maximum level, remove a specific weapon from their loadout
    if att:GetNWInt("GGLevel", 1) >= #weaponList then
        att:StripWeapon("csgo_bayonet")
    elseif ply:HasWeapon("csgo_bayonet") then
        self.AutoSpawn = "E"
    end

    -- If the player levels up to the maximum level, trigger an event to inform all players
    if self.MaxLevel < att:GetNWInt("GGLevel", 1) then
        net.Start("ASAP.Arena.Gungame.LevelUp")
        net.WriteString(att:Nick())
        net.WriteInt(att:GetNWInt("GGLevel", 1), 16)
        net.Send(asapArena:GetPlayers())
        self.MaxLevel = att:GetNWInt("GGLevel", 1)
    end

    -- Additional logic can be added here if needed
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

        if asapArena.BanList[k].gungame <= 0 then
            asapArena.BanList[k].gungame = nil
        end
    end

    file.Write("event_winners.txt", util.TableToJSON(asapArena.BanList))
    case:ResetSequence("open")
    case:SetSequence("open")
    case:SetPlaybackRate(1)
    ply:EmitSound("misc/achievement_earned.wav")

    if ply.UB3AddItem then
        for k, v in pairs(self.Rewards) do
            ply:UB3AddItem(v, 1)
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
            if v:InArena() then
                table.insert(players, v)
            end
        end

        table.sort(players, function(a, b) return a:GetNWInt("GGLevel", 1) > b:GetNWInt("GGLevel", 1) end)
        local w, h, y = 64, 78, 24

        for k = 1, 5 do
            local ply = players[k]

            if ply then
                local bigSize = (w + 8) * math.min(#players, 5)
                local x = ScrW() / 2 - bigSize / 2 - w
                draw.RoundedBox(8, x + (w + 8) * k, y, w, h, ply:GetNWInt("GGLevel", 1) == #weaponList and Color(230, 150, 0) or Color(26, 26, 26, 150))

                if not IsValid(ply._arenaAvatar) then
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

        if asapArena:GetState() == 1 then
            local time = string.FormattedTime(math.max(GetGlobalInt("Arena.EndRound") - CurTime(), 0), "%02d:%02d")
            draw.SimpleText("Warmup", "XeninUI.TextEntry", ScrW() / 2, 112, color_white, 1, 0)
            draw.SimpleText(time, "Arena.Medium", ScrW() / 2, 128, color_white, 1, 0)

            return
        end

        if LocalPlayer():GetNWInt("GGLevel") == #weaponList then
            draw.SimpleText("OPEN THE CRATE TO WIN THE GAME", "Arena.Small", ScrW() / 2 + 1, y + h + 21, Color(50, 50, 50, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("OPEN THE CRATE TO WIN THE GAME", "Arena.Small", ScrW() / 2, y + h + 20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            local name = weaponList[LocalPlayer():GetNWInt("GGLevel", 1) + 1]
            local wepData = weapons.GetStored(name)

            if wepData then
                name = wepData.PrintName
            end

            draw.SimpleText("Next weapon: " .. name, "Arena.Small", ScrW() / 2 + 1, y + h + 21, Color(50, 50, 50, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            local _, ty = draw.SimpleText("Next weapon: " .. name, "Arena.Small", ScrW() / 2, y + h + 20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            surface.SetTexture(gun)
            surface.SetDrawColor(255, 255, 255, LocalPlayer():Frags() >= 1 and 255 or 75)
            surface.DrawTexturedRect(ScrW() / 2 - 32, y + h + 12 + ty, 32, 32)
            surface.SetDrawColor(255, 255, 255, 75)
            surface.DrawTexturedRect(ScrW() / 2 + 16, y + h + 12 + ty, 32, 32)
        end
    end

    net.Receive("ASAP.Arena.Gungame.LevelUp", function()
        local nick = net.ReadString()
        local level = net.ReadInt(16)
        chat.AddText(Color(245, 160, 80), "[GunGame] ", color_white, "Player ", Color(250, 75, 75), nick, color_white, " has reached level ", Color(85, 230, 85), tostring(level))
    end)
end

asapArena:AddGamemode("gungame", GM)