if SERVER then
    util.AddNetworkString("ASAP.Arena.SendBullet")
    util.AddNetworkString("ASAP.Arena:SyncWeapon")
    util.AddNetworkString("ASAP.Arena:HitMark")
    util.AddNetworkString("ASAP.Arena:NotifyDeath")
end

hook.Add("PlayerButtonDown", "ASAP.Killstreak.Active", function(ply, key)
    if (not ply:InArena()) then return end
    if not IsFirstTimePredicted() then return end
    if (asapArena.ActiveGamemode and asapArena.ActiveGamemode.NoKillStreaks) then return end

    if key == KEY_G then
        for k, v in pairs(asapArena.KillStreakFunctions) do
            local killStreak = (SERVER and (ply.ArenaStreak or 0) or #(ply.ArenaKills or {})) + (ply._arenaDog and 1 or 0)

            if (killStreak >= v.Kills and v.CanUse(ply)) then
                if SERVER then
                    v.OnUse(ply)
                else
                    surface.PlaySound("music/kill_0" .. math.Clamp(k, 1, 3) .. ".wav")
                end
            end
        end
    end
end)

hook.Add("OnPlayerHitGround", "ASAP.Arena.NoFall", function(ply)
    if (ply:InArena()) then return ply._titaniumLegs end
end)

local canClaimReward = true

local function giveReward(b)
    if (not b) then
        canClaimReward = true
    end

    timer.Simple(math.Rand(10, 15) * 60, function()
        giveReward()
    end)
end

giveReward(true)

hook.Add("PlayerDeath", "ASAP.Arena.Frags", function(ply, inf, att)
    if (not ply:InArena()) then return end
    ply._arenaData.Deaths = (ply._arenaData.Deaths or 0) + 1
    local canRespawn = asapArena:Run("CanPlayerRespawn", nil, ply)
    
    if (ply:IsDueling()) then
        timer.Simple(1, function()
            ply:Spawn()
            asapArena:SpawnPlayerDuel(ply)
        end)
        return
    end

    if (not asapArena.ActiveGamemode or not asapArena.ActiveGamemode.AutoSpawn) then
        net.Start("ASAP.Arena.ShowDeathScreen")
        net.WriteEntity(ply)
        net.WriteEntity(att)
        net.WriteBool(ply:LastHitGroup() == HITGROUP_HEAD)
        net.Send((canRespawn ~= false) and {att, ply} or att)
    elseif (asapArena.ActiveGamemode and asapArena.ActiveGamemode.AutoSpawn) then
        timer.Simple(3, function()
            ply:Spawn()
        end)
    end

    if (canClaimReward) then
        local enoughPlayers = table.Count(asapArena.Players) >= 8
        local enoughTime = CurTime() - (ply.arenaSpawnTime or 3) > (5 * 60)
        local enoughRewards = (ply.arenaRewards or 0) < 5
        local enoughFrags = ply:GetArenaFrags() >= 10

        if (enoughPlayers and enoughTime and enoughRewards and enoughFrags and ply.UB3AddItem) then
            canClaimReward = false
            ply:UB3AddItem(366, 1)
            ply.arenaRewards = (ply.arenaRewards or 0) + 1
            net.Start("ASAP.Arena.GotReward")
            net.Send(ply)
        end
    end

    if (att ~= ply and att:IsPlayer()) then
        //att:AddArenaFrags(1)
        att.ArenaStreak = (att.ArenaStreak or 0) + 1

        if ((att._arenaData.Streak or 0) < att.ArenaStreak) then
            att._arenaData.Streak = att.ArenaStreak
        end

        att:GiveArenaXP(20 + 10 * att.ArenaStreak + (ply:LastHitGroup() == HITGROUP_HEAD and 10 or 0), "Kill")
        ply.ArenaStreak = 0
        //ply:SetFrags(ply:Frags() + 1)
        att:SetHealth(math.Clamp(att:Health() + 25, 1, att:GetMaxHealth()))
        att:SetArmor(math.Clamp(att:Armor() + 25, 1, 100))
        local wep = att:GetActiveWeapon()

        if IsValid(wep) then
            att:GiveAmmo(wep:GetMaxClip1() * 2, wep:GetPrimaryAmmoType(), true)
        end

        att._arenaData.Kills = (att._arenaData.Kills or 0) + 1
        asapArena:GiveWeaponXP(att, wep:GetClass(), ply:LastHitGroup() == HITGROUP_HEAD and 12 or 10)

        if IsValid(att:GetActiveWeapon()) then
            if (not att._arenaData.Weapons) then
                att._arenaData.Weapons = {}
            end

            local stat = att._arenaData.Weapons[att:GetActiveWeapon():GetClass()]

            if (not stat) then
                stat = {0, 0, 0}
            elseif (isnumber(stat)) then
                stat = {stat, 0, 0}
            end

            if (ply:LastHitGroup() == HITGROUP_HEAD) then
                stat[2] = (stat[2] or 0) + 1
            end

            stat[1] = (stat[1] or 0) + 1
            att._arenaData.Weapons[att:GetActiveWeapon():GetClass()] = stat
        end

        net.Start("ASAP.Arena:NotifyDeath")
        net.WriteBool(ply:LastHitGroup() == HITGROUP_HEAD)
        net.Send(att)
    end

    if (not ply:IsDueling()) then
        asapArena:Run("PlayerDeath", nil, ply, att)
    end

    if IsValid(ply._drone) then
        ply._drone:Remove()
    end

    local tag = ply:SteamID64() .. "_antideath"
    timer.Create(tag, 7, 1, function()
        if (IsValid(ply) and not ply:Alive() and ply:InArena()) then
            ply:Spawn()
        end
    end)
end)

local blacklisted = {
    zombie = true,
    melee = true,
    boss = true,
    battleroyale = true,
}
hook.Add("PlayerSpawn", "ASAP.Arena.Spawn", function(ply)
    if (not ply:InArena()) then return end
    asapArena:Run("PlayerSpawn", nil, ply)
    ply.ArenaStreak = 0
    ply:SendLua("LocalPlayer().ArenaStreak = 0 LocalPlayer().ArenaKills = {}")

    timer.Simple(.5, function()
        net.Start("ASAP.Arena.SendShaft")
        net.WriteVector(ply:GetPos())
        net.Send(asapArena:GetPlayers())
    end)

    ply:SetMaxHealth(100)
    ply:SetHealth(100)
    ply:SetWalkSpeed(275)
    ply:SetRunSpeed(400)
    ply:SetJumpPower(200)

    if not blacklisted[asapArena._gameID] then
        local ent = ents.Create("octanepad")
        ent:SetPos(ply:GetPos())
        ent:Spawn()
        ent:Use(ply)
        SafeRemoveEntityDelayed(ent, 1)
    end

    timer.Simple(3, function()
        if IsValid(ply) and ply:Alive() then
            ply:SetWalkSpeed(275)
        end
    end)

    for k, v in pairs(asapArena.KillStreakFunctions) do
        if (not v.CanUse(ply)) then
            v.OnSpawn(ply)
        end
    end
end)

hook.Add("PlayerSpawnObject", "ASAP.Arena.NoSpawn", function(ply)
    if (ply:InArena()) then return false end
end)

hook.Add("EntityTakeDamage", "ASAP.Arena.NoFall", function(ply, dmg)

    local att = dmg:GetAttacker()
    if (att:IsPlayer() and ply:IsPlayer()) then
        net.Start("ASAP.Arena:HitMark")
        net.WriteInt(ply:LastHitGroup() == HITGROUP_CHEST and 1 or (ply:LastHitGroup() == HITGROUP_HEAD and 2 or 0), 3)
        net.WriteBool(dmg:GetDamage() > ply:Health())
        net.Send(att)
    end

    if (not ply:IsPlayer()) then return end
    if (not ply:InArena()) then return end

    if (IsValid(ply._drone)) then
        dmg:SetDamage(0)

        return true
    end


    if (IsValid(att) and att:IsPlayer()) then
        if (not att._arenaData) then
            att._arenaData = {}
        end

        att._arenaData.Damage = (att._arenaData.Damage or 0) + dmg:GetDamage()
        /*
        net.Start("ASAP.Arena:HitMark")
        net.WriteInt(ply:LastHitGroup() == HITGROUP_CHEST and 1 or (ply:LastHitGroup() == HITGROUP_HEAD and 2 or 0), 3)
        net.WriteBool(dmg:GetDamage() > ply:Health())
        net.Send(att)
        */
        if IsValid(att:GetActiveWeapon()) then
            if (not att._arenaData.Weapons) then
                att._arenaData.Weapons = {}
            end

            local stat = att._arenaData.Weapons[att:GetActiveWeapon():GetClass()]

            if (not stat) then
                stat = {0, 0, 0}
            elseif (isnumber(stat)) then
                stat = {stat, 0, 0}
            end

            stat[3] = (stat[3] or 0) + dmg:GetDamage()
            att._arenaData.Weapons[att:GetActiveWeapon():GetClass()] = stat

            if not att.wepSyncs then
                att.wepSyncs = {}
            end

            att.wepSyncs[att:GetActiveWeapon():GetClass()] = true
            timer.Remove(att:EntIndex() .. "_wepSync")

            timer.Create(att:EntIndex() .. "_wepSync", 3, 1, function()
                net.Start("ASAP.Arena:SyncWeapon")
                net.WriteInt(table.Count(att.wepSyncs), 16)

                for k, v in pairs(att.wepSyncs) do
                    local data = att._arenaData.Weapons[k]
                    net.WriteString(k)
                    net.WriteInt(data[1], 32)
                    net.WriteInt(data[2], 32)
                    net.WriteInt(data[3], 32)
                end

                net.Send(att)
                att.wepSyncs = {}
            end)
        end
    end

    return asapArena:Run("EntityTakeDamage", nil, ply, dmg)
end)

net.Receive("ASAP.Arena:SyncWeapon", function()
    local size = net.ReadInt(16)
    local ply = LocalPlayer()

    if (not ply._arenaData.Weapons) then
        ply._arenaData.Weapons = {}
    end

    for k = 1, size do
        local class = net.ReadString()

        if not ply._arenaData.Weapons[class] then
            ply._arenaData.Weapons[class] = {
                0, 0, 0, {1, 0}
            }
        end

        ply._arenaData.Weapons[class][1] = net.ReadInt(32)
        ply._arenaData.Weapons[class][2] = net.ReadInt(32)
        ply._arenaData.Weapons[class][3] = net.ReadInt(32)
    end
end)

hook.Add("canChangeJob", "ASAP.Arena.NoJobs", function(ply)
    if (ply:InArena()) then return false, "You can't change job while playing arena" end
end)

hook.Add("canChatCommand", "ASAP.Arena.NoCommands", function(ply, command)
    if (ply:InArena() and command ~= "ooc" and command ~= "//") then return false end
end)

hook.Add("PlayerDeathThink", "ASAP.Arena.NoRespawn", function(ply)
    if (not ply:InArena()) then return end

    return ply:KeyDown(IN_JUMP)
end)

hook.Add("PlayerDisconnected", "ASAP.Arena.SavePlayer", function(ply)
    if (not ply:InArena()) then return end
    ply:LeaveArena()
end)

hook.Add("PlayerCanHearPlayersVoice", "ASAP.Arena.VoiceLobby", function(listener, talker)
    if (listener:InArena() ~= talker:InArena()) then return false end
    if (talker:InArena() and not talker.ArenaVoice) then return false end
    if (listener:InArena() and not listener.ArenaVoice) then return false end
    if (talker:InArena() and listener.ArenaVoice) then return true end
    if (listener:InArena() and talker.ArenaVoice) then return true end
end)

hook.Add("PlayerInitialSpawn", "ASAP.Arena.CheckEvent", function(ply)
    local lastEvent = cookie.GetNumber("last_case_event", os.time() - 1)

    if (player.GetCount() >= 50 and lastEvent < os.time()) then
        cookie.Set("last_case_event", os.time() + 8 * 60 * 60) -- next event in 8 hours
        RunConsoleCommand("asap_case_event")
    end
end)

hook.Add("Think", "ASAP.Arena.Think", function() end) --asapArena:Run("Think")
if SERVER then return end
local convar = CreateClientConVar("asap_draw_streak", 0)
local huddraw = CreateClientConVar("asap_arena_hud", 1)
local back = surface.GetTextureID("ui/onfire")
local flame = surface.GetTextureID("ui/flame")
local line = surface.GetTextureID("effects/splashwake4")
local circle = surface.GetTextureID("sgm/playercircle")
local fScale = ScrH() / 1080

hook.Add("HUDPaint", "ASAP.Arena.HUD", function()
    if (not LocalPlayer():InArena()) then return end
    if (not huddraw:GetBool()) then return end

    if (convar:GetBool()) then
        local pow = math.min(1, #(LocalPlayer().ArenaKills or {}) / 10)
        surface.SetTexture(back)
        surface.SetDrawColor(Color(255, 255, 255, pow * 255))
        surface.DrawTexturedRect(-64, -64, ScrW() + 128, ScrH() + 128)
    end

    asapArena:Run("HUDPaint")
    if (asapArena.ActiveGamemode and asapArena.ActiveGamemode.NoKillStreaks) then return end
    local ks = 0
    local kills = #(LocalPlayer().ArenaKills or {}) + (LocalPlayer()._arenaDog and 1 or 0)

    for k, obj in SortedPairsByMemberValue(asapArena.KillStreakFunctions, "Kills") do
        local percent = 0
        local lastObj = asapArena.KillStreakFunctions[k - 1]

        if (kills >= obj.Kills) then
            ks = ks + 1
            percent = 1
        elseif (k > 1) then
            percent = (kills - lastObj.Kills) / (obj.Kills - lastObj.Kills)
        end

        if (k > 1) then
            surface.SetTexture(line)

            if (percent == 0) then
                surface.SetDrawColor(Color(75, 75, 75, 150))
                surface.DrawTexturedRect(ScrW() - 78 + 7, ScrH() - fScale * 142 - k * 64 + 24, 18, 48)
                continue
            end

            if (ks == 0 or (kills > asapArena.KillStreakFunctions[ks].Kills)) then
                surface.SetDrawColor(Color(75, 75, 75, 150))
                surface.DrawTexturedRect(ScrW() - 78 + 7, ScrH() - fScale * 142 - k * 64 + 24, 18, 48)
                surface.SetDrawColor(color_white)
                surface.DrawTexturedRectUV(ScrW() - 78 + 7, ScrH() - fScale * 142 - k * 64 + 24 + 48 * (1 - percent), 18, 48 * percent, 0, 0, 1, 1)
            else
                surface.SetDrawColor(Color(255, 255, 255, 255))
                surface.DrawTexturedRect(ScrW() - 78 + 7, ScrH() - fScale * 142 - k * 64 + 24, 18, 48)
            end
        end
    end

    for k, obj in SortedPairsByMemberValue(asapArena.KillStreakFunctions, "Kills") do
        local canRequest = obj.Kills <= #(LocalPlayer().ArenaKills or {}) and obj.CanUse(LocalPlayer())
        surface.SetTexture(circle)
        surface.SetDrawColor(ks >= k and Color(75, 75, 75) or Color(255, 255, 255))
        surface.DrawTexturedRect(ScrW() - 78, ScrH() - fScale * 142 - k * 64, 32, 32)
        local tx, _ = draw.SimpleText(obj.Name, "Arena.Small", ScrW() - 84, ScrH() - fScale * 142 - k * 64 + 4, color_white, TEXT_ALIGN_RIGHT)

        if (canRequest) then
            draw.SimpleText("Request (G) ", "XeninUI.TextEntry", ScrW() - 86 - tx + math.random(-2, 2), ScrH() - fScale * 142 - k * 64 + 8 + math.random(-2, 2), HSVToColor(math.random(0, 360), .7, 1), TEXT_ALIGN_RIGHT)
            draw.SimpleText("Request (G) ", "XeninUI.TextEntry", ScrW() - 86 - tx, ScrH() - fScale * 142 - k * 64 + 8, Color(255, 255, 255, 150), TEXT_ALIGN_RIGHT)
        end

        draw.SimpleText(obj.Kills, "Arena.Small", ScrW() - 42, ScrH() - fScale * 142 - k * 64 + 4, ks >= k and Color(255, 200, 75) or Color(255, 255, 255, 75), TEXT_ALIGN_LEFT)
        surface.SetTexture(flame)
        surface.SetDrawColor(Color(255, 255, 255))

        if k == ks then
            surface.DrawTexturedRect(ScrW() - 78 - 48, ScrH() - fScale * 142 - k * 64 - 90, 128, 128)
        end
    end
end)

hook.Add("HUDShouldDraw", "ASAP.Arena.HideLaws", function(el)
    if (not IsValid(LocalPlayer())) then return end
    if (not LocalPlayer():InArena()) then return end
    if (el == "Agenda") then return false end
end)

hook.Add("CanOpenGobblegums", "ASAP.Arena.DisableGobble", function()
    if LocalPlayer():InArena() then return false end
end)

net.Receive("ASAP.Arena.GotReward", function()
    chat.AddText(Color(255, 210, 0), "[Arena] ", color_white, " You've found an '<rainbow=2>Arena Crate</rainbow>'")
end)