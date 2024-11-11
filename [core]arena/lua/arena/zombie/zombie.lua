local GM = {}
GM.Base = "base"
GM.Name = "Zombies"
GM.GameType = "DM"
GM.State = 0
GM.MinPlayers = 5
GM.Icon = "vgui/arena/biohazard"
GM.Description = "Murderous Mutation"
GM.CaseReward = 554
GM.NoKillStreaks = true
GM.KillerReward = 672
GM.DumbReward = 366
GM.GoldMultiplier = 1
GM.InitialMoney = 1000
GM.Warmup = 60
GM.MaxMoneyPerShoot = 50
GM.ZombieSpawns = {Vector(7511, 4994, -7611)}

if SERVER then
    util.AddNetworkString("ASAP.Arena:SetupFog")
    util.AddNetworkString("ASAP.Arena:ZombieWon")
end

function GM:Init()
    if CLIENT then return end
    asapArena:SetState(0)
    BroadcastLua("DisplayNotification('zombie')")

    for k, v in pairs(asapArena:GetPlayers()) do
        if (not IsValid(v)) then continue end
        self:PlayerSpawn(v)
        v:SetFrags(0)
        v:SetNWBool("ArenaInfected", false)
        v:GodDisable()
        v:SetNWInt("ArenaMoney", self.InitialMoney)
        v:Freeze(false)
        net.Start("ASAP.Arena:SetupFog")
        net.Send(v)
    end

    if (#asapArena:GetPlayers() >= self.MinPlayers) then
        asapArena:SetState(1)
        SetGlobalFloat("Arena.ZombieTimer", CurTime() + self.Warmup)

        timer.Simple(self.Warmup, function()
            self:StartGame()
            asapArena:SetState(2)
        end)
    end
end

hook.Add("MoneyCurrency", "ZombieHUDMoney", function(ply)
    if (not ply:InArena()) then return end
    if (not asapArena.ActiveGamemode) then return end
    if (asapArena.ActiveGamemode.id ~= "zombie") then return end

    return ply:GetNWInt("ArenaMoney", 0), Color(100, 175, 255)
end)

function GM:PlayerJoin(ply)
    ply._maxHealth = 100
    ply:SetFrags(0)
    ply:SetDeaths(0)
    ply:SetNWInt("ArenaMoney", self.InitialMoney)
    ply:GodDisable()

    if (asapArena:GetState() == 0 and #asapArena:GetPlayers() >= self.MinPlayers) then
        asapArena:SetState(1)
        SetGlobalFloat("Arena.ZombieTimer", CurTime() + self.Warmup)

        timer.Simple(self.Warmup, function()
            self:StartGame()
            asapArena:SetState(2)
        end)
    elseif (asapArena:GetState() == 2) then
        ply:SetNWBool("ArenaInfected", true)
    end
end

function GM:Think()
end

local zombieModels = {"models/player/zombie_classic.mdl", "models/player/zombie_fast.mdl", "models/player/zombie_soldier.mdl"}

function GM:Infect(ply)
    ply:SetNWBool("ArenaInfected", true)
    ply._maxHealth = 250
    ply:SetHealth(250)
    ply:EmitSound("npc/zombie/zombie_alert" .. math.random(1, 3) .. ".wav", 120)
    self:Loadout(ply)
    local humanCount = 0
    local survivor = nil
    if (asapArena:GetState() ~= 2) then return end

    timer.Simple(.1, function()
        for k, v in pairs(asapArena:GetPlayers()) do
            if (not v:Alive()) then continue end

            if (not v:GetNWBool("ArenaInfected")) then
                survivor = v
                humanCount = humanCount + 1
                if (humanCount > 1) then break end
            end
        end

        if (humanCount == 1) then
            self:EndRound(survivor)
        end
    end)
end

function GM:EndRound(winner)
    asapArena:StartGamemodeVote()
    asapArena:SetState(3)
    local max = {-1, nil}

    local targets = {}
    for k, v in pairs(asapArena:GetPlayers()) do
        v:Freeze(true)
        v:GodEnable()

        if (v:GetArenaFrags() > max[1]) then
            max = {v:GetArenaFrags(), v}
        end
        table.insert(targets, v)
    end

    if (IsValid(max[2])) then
        max[2]:GiveArenaXP(100, "Most kills")
        max[2]:UB3AddItem(self.KillerReward, 1)
        net.Start("ASAP.Arena:ZombieWon")
        net.WriteEntity(max[2])
        net.WriteString("VIP Crate")
        net.Broadcast()
    end

    for k, v in pairs(asapArena:GetPlayers()) do
        if (v ~= winner and v ~= max[2]) then
            v:UB3AddItem(self.DumbReward, 1)
        end
    end

    if IsValid(winner) then
        winner:GiveArenaXP(100, "Winning the match")
        winner:UB3AddItem(self.CaseReward, 1)
        asapLogs:add("Arena Wins", winner, nil, {
            rew = self.CaseReward,
            id = asapArena.ActiveGamemode.id
        })
        net.Start("Arena.WonCaseRound")
        net.WriteEntity(winner)
        net.WriteString("Phoenix Crate")
        net.Broadcast()
    end

    timer.Simple(3, function()
        for k, v in pairs(targets) do
            v:Freeze(false)
            v:GodDisable()
        end

        asapArena:SetGamemode("deathmatch")
    end)

    for k, v in pairs(ents.FindByClass("sent_zombie_barrier")) do
        v:Remove()
    end
end

function GM:StartGame()
    for k, v in pairs(asapArena:GetPlayers()) do
        v:Spawn()
        v:SetNWBool("ArenaInfected", false)
    end

    local selected = 2

    for k, v in RandomPairs(asapArena:GetPlayers()) do
        if selected > 0 then
            self:Infect(v)
            selected = selected - 1
        end
    end
end

function GM:EntityTakeDamage(ply, dmg)
    local att = dmg:GetAttacker()

    if (att:IsPlayer() and att:GetNWBool("ArenaInfected", false) == ply:GetNWBool("ArenaInfected", false)) then
        dmg:SetDamage(0)

        return true
    end

    if (ply:GetNWBool("ArenaInfected") and (ply._nextYell or 0) < CurTime()) then
        ply:EmitSound("npc/zombie/zombie_pain" .. math.random(1, 6) .. ".wav")
        ply._nextYell = CurTime() + math.Rand(2, 5)
    end

    if (att:IsPlayer() and ply:IsPlayer() and not ply:GetNWBool("ArenaInfected") and dmg:GetDamage() >= ply:Health()) then
        self:Infect(ply)
        att:AddArenaFrags(1)
        dmg:SetDamage(0)

        return true
    end

    if (att:IsPlayer() and ply:IsPlayer() and not att:GetNWBool("ArenaInfected") and ply:GetNWBool("ArenaInfected")) then
        att:SetNWInt("ArenaMoney", att:GetNWInt("ArenaMoney", 0) + math.min(self.MaxMoneyPerShoot, math.Round(dmg:GetDamage() * self.GoldMultiplier)))
    end
end

concommand.Add("bring_arena", function()
    for k, v in pairs(player.GetBots()) do
        v:Spawn()
        v:GodDisable()

        timer.Simple(1, function()
            v:SetNoDraw(false)
            v:SetPos(player.GetByID(1):GetEyeTrace().HitPos + Vector(0, 0, 65 * k))
        end)
    end
end)

function GM:PlayerSpawn(ply)
    ply:SetNWBool("ArenaInfected", asapArena:GetState() > 1)

    if (ply:GetNWBool("ArenaInfected")) then
        ply._maxHealth = math.Clamp(ply._maxHealth + 100, 100, 800)
        ply:SetHealth(ply._maxHealth)
    end

    net.Start("ASAP.Arena:SetupFog")
    net.Send(ply)

    timer.Simple(0, function()
        self:SelectSpawn(ply)
        self:Loadout(ply)
    end)
end

function GM:Loadout(ply)
    if (ply:GetNWBool("ArenaInfected")) then
        local model, _ = table.Random(zombieModels)
        ply:SetModel(model)
        ply:StripWeapons()
        ply:SetNoDraw(false)
        ply:Give("weapon_zombie_knife")
        ply:EmitSound("npc/fast_zombie/fz_alert_far1.wav", 75, math.random(90, 150), 1)
        ply:SetFOV(120, 1)

        return
    end

    if (not ply._arenaEquipment) then return end
    ply:SetFOV(0, 1)

    timer.Simple(1, function()
        asapArena:SetPlayerModel(ply)
    end)

    ply:StripWeapons()
    ply:Give("weapon_zombie_build")

    if (ply._arenaEquipment["Primary"]) then
        local wep = ply:Give(ply._arenaEquipment["Primary"])
        ply:SetAmmo(wep:GetMaxClip1() * 4, wep:GetPrimaryAmmoType())
    end

    if (ply._arenaEquipment["Secondary"]) then
        local wep = ply:Give(ply._arenaEquipment["Secondary"])
        ply:SetAmmo(wep:GetMaxClip1() * 4, wep:GetPrimaryAmmoType())
    end

    if (ply._arenaEquipment["Melee"]) then
        ply:Give(ply._arenaEquipment["Melee"])
    end

    if (ply._arenaEquipment["Misc"]) then
        ply:Give(ply._arenaEquipment["Misc"])
    end
end

function GM:PlayerLeave(ply)
    ply:SetNWBool("ArenaInfected", false)
    for k, v in pairs(ents.FindByClass("sent_zombie_barrier")) do
        if (v:GetMaker() == ply) then
            v:Remove()
        end
    end
end

if CLIENT then
    local gradient = surface.GetTextureID("hud/wvh/timer")
    local heart = surface.GetTextureID("hud/wvh/wolf_ultimate")

    function GM:HUDPaint()
        if (asapArena:GetState() == 0) then
            surface.SetTexture(gradient)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawTexturedRectRotated(ScrW() / 2 + 72, 96 + 12, 720, 128, -4)
            draw.SimpleText("Waiting on players...", "Arena.Medium", ScrW() / 2 + 2, 98, Color(0, 0, 0), 1, 1)
            draw.SimpleText("Waiting on players...", "Arena.Medium", ScrW() / 2, 96, color_white, 1, 1)
            draw.SimpleText("Need " .. (self.MinPlayers - #asapArena:GetPlayers()), "Arena.Medium", ScrW() / 2 + 32, 128, Color(200, 75, 0), 1, 1)

            return
        elseif (asapArena:GetState() == 1) then
            surface.SetTexture(gradient)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawTexturedRectRotated(ScrW() / 2 + 32, 96 + 12, 320, 96, 0)
            draw.SimpleText("Starting in:", "Arena.Medium", ScrW() / 2 + 2, 112, color_black, 1, 1)
            draw.SimpleText("Starting in:", "Arena.Medium", ScrW() / 2, 110, color_white, 1, 1)
            surface.SetTexture(heart)
            surface.DrawTexturedRectRotated(ScrW() / 2, 242, 172, 172, 0)
            draw.SimpleText(math.max(math.Round(GetGlobalFloat("Arena.ZombieTimer", CurTime()) - CurTime()), 0), "Arena.Huge", ScrW() / 2 - 2, 244, Color(150, 25, 0), 1, 1)
            draw.SimpleText(math.max(math.Round(GetGlobalFloat("Arena.ZombieTimer", CurTime()) - CurTime()), 0), "Arena.Huge", ScrW() / 2 - 4, 242, color_white, 1, 1)

            return
        end

        local zombies = 0
        local players = #asapArena:GetPlayers()

        for k = 1, players do
            local ply = asapArena:GetPlayers()[k]

            if (ply:GetNWBool("ArenaInfected", false) or not ply:Alive()) then
                zombies = zombies + 1
            end
        end

        surface.SetTexture(gradient)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawTexturedRectRotated(ScrW() / 2 + 72, 96 + 12, 512, 96, 0)
        draw.SimpleText("Humans " .. (players - zombies), "Arena.Medium", ScrW() / 2 - 32, 92, Color(75, 175, 255), 1, 1)
        draw.SimpleText(zombies .. " Infected", "Arena.Medium", ScrW() / 2 + 32, 96 + 24, Color(255, 75, 50), 1, 1)
    end

    net.Receive("ASAP.Arena:ZombieWon", function()
        local ply = net.ReadEntity()
        local crate = net.ReadString()
        if not IsValid(ply) or not ply.Nick then return end
        chat.AddText(Color(255, 210, 0), "[Arena] ", color_white, ply:Nick(), " with most kills received '<rainbow=2>" .. crate .. "</rainbow>'")
        chat.AddText(Color(255, 210, 0), "[Arena] ", color_white, "All zombies received '<rainbow=2>Arena Crate</rainbow>'")
    end)

    net.Receive("ASAP.Arena:SetupFog", function()
        local ply = LocalPlayer()

        local function fog()
            if (not ply:InArena() or (asapArena.ActiveGamemode and asapArena.ActiveGamemode.id ~= "zombie")) then
                hook.Remove("SetupSkyboxFog", "Arena.ZombieFog")
                hook.Remove("SetupWorldFog", "Arena.ZombieFog")
            end

            render.FogMode(MATERIAL_FOG_LINEAR)
            render.FogStart(100)
            render.FogEnd(1200)
            render.FogColor(10, 80, 50)
            render.FogMaxDensity(1)

            return true
        end

        hook.Add("SetupSkyboxFog", "Arena.ZombieFog", fog)
        hook.Add("SetupWorldFog", "Arena.ZombieFog", fog)

        local tab = {
            ["$pp_colour_addr"] = .1,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = -0.1,
            ["$pp_colour_contrast"] = 1.25,
            ["$pp_colour_colour"] = .7,
            ["$pp_colour_mulr"] = 1,
            ["$pp_colour_mulg"] = 1,
            ["$pp_colour_mulb"] = 0
        }

        hook.Add("RenderScreenspaceEffects", "Arena.ZombiePP", function()
            if (not ply:InArena() or (asapArena.ActiveGamemode and asapArena.ActiveGamemode.id ~= "zombie")) then
                hook.Remove("RenderScreenSpaceEffects", "Arena.ZombiePP")

                return
            end

            if (ply:GetNWBool("ArenaInfected")) then
                DrawColorModify(tab) --Draws Color Modify effect
                DrawSobel(1.5) --Draws Sobel effect
            end
        end)
    end)
end

asapArena:AddGamemode("zombie", GM)