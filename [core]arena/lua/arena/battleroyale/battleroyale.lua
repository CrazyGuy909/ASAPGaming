local GM = {}
GM.Base = "base"
GM.Name = "BattleRoyale"
GM.GameType = "DM"
GM.MinPlayers = 2
GM.Icon = "vgui/arena/biohazard"
GM.Description = "Battleroyale"
GM.CaseReward = 554
GM.NoKillStreaks = true
GM.Warmup = 10
GM.CanRespawn = false

if SERVER then
    util.AddNetworkString("ASAP.Arena:SpectateBattleroyale")
end
function GM:Init()

    if CLIENT then return end

    asapArena:SetState(0)
    BroadcastLua("DisplayNotification('battleroyale')")
    for k, v in pairs(asapArena:GetPlayers()) do
        if (not IsValid(v)) then continue end
        v:SetFrags(0)
        v:GodDisable()
        v:Freeze(false)
        self:PlayerSpawn(v)
    end

    if (#asapArena:GetPlayers() >= self.MinPlayers) then
        asapArena:SetState(1)
        SetGlobalFloat("Arena.ZombieTimer", CurTime() + self.Warmup)
        timer.Simple(self.Warmup, function()
            self:StartGame()
        end)
    end

end

function GM:CanPlayerRespawn(ply)
    net.Start("ASAP.Arena:SpectateBattleroyale")
    net.WriteBool(false)
    net.WriteEntity(ply.ArenaKiller or ply)
    net.Send(ply)
    return false
end

function GM:PlayerJoin(ply)
    ply:SetFrags(0)
    ply:SetDeaths(0)
    if (asapArena:GetState() == 0 and #asapArena:GetPlayers() >= self.MinPlayers) then
        asapArena:SetState(1)
        SetGlobalFloat("Arena.ZombieTimer", CurTime() + self.Warmup)

        timer.Simple(self.Warmup, function()
            asapArena:SetState(2)
            self:StartGame()
        end)
    end
end

function GM:Think()
end

function GM:EndRound(winner)
    hook.Remove("CanPlayerJoinArena", "BR_Dome")
    asapArena:SetState(3)
    winner:Freeze(true)
    winner:GodEnable()

    if IsValid(winner) then
        winner:GiveArenaXP(100, "Winning the match")
        winner:UB3AddItem(self.CaseReward, 1)
        net.Start("Arena.WonCaseRound")
        net.WriteEntity(winner)
        net.WriteString("Suit crate")
        net.Broadcast()
    end

    timer.Simple(3, function()
        for k, v in pairs(asapArena:GetPlayers(true)) do
            v:Freeze(false)
            v:GodDisable()
        end

        asapArena:StartGamemodeVote()
    end)

    if IsValid(BR_Dome) then
        BR_Dome:Remove()
    end
end

function GM:StartGame()
    local drone = ents.Create("sent_arena_drone_br")
    drone:Spawn()
    asapArena:SetState(2)
    timer.Simple(10, function()
        local dome = ents.Create("sent_arena_dome")
        dome:Spawn()

        hook.Add("CanPlayerJoinArena", "BR_Dome", function(s, ply)
            if (asapArena:GetState() == 2 and IsValid(ply)) then
                net.Start("ASAP.Arena:SpectateBattleroyale")
                net.WriteBool(true)
                net.Send(ply)
            end
        end)
    end)
end

net.Receive("ASAP.Arena:SpectateBattleroyale", function(l, ply)
    if SERVER then
        local doSpectate = net.ReadBool()
        local targetEntity = net.ReadEntity()
        if IsValid(targetEntity) and targetEntity != ply then
            ply:LeaveArena()
        end
        if (doSpectate) then
            ply:Spectate(OBS_MODE_CHASE)
            if (targetEntity == ply) then
                for k, v in RandomPairs(asapArena:GetPlayers(true)) do
                    if (v != ply) then
                        ply:SpectateEntity(v)
                    end
                end
            else
                ply:SpectateEntity(targetEntity)
            end
        else
            ply:LeaveArena()
            ply:UnSpectate()
            ply:Spawn()
        end
    else
        vgui.Create("Arena:BR_Spectate")
    end
end)

function GM:PlayerSpawn(ply)
    timer.Simple(0, function()
        self:SelectSpawn(ply)
        self:Loadout(ply)
    end)
end

function GM:Loadout(ply)
    ply:StripWeapons()
    local wep = ply:Give("mac_bo2_ballista")
    ply:SetAmmo(wep:GetMaxClip1() * 4, wep:GetPrimaryAmmoType())
    wep = ply:Give("m9k_coltpython")
    ply:SetAmmo(wep:GetMaxClip1() * 4, wep:GetPrimaryAmmoType())
    wep = ply:Give("m9k_acr")
    ply:SetAmmo(wep:GetMaxClip1() * 4, wep:GetPrimaryAmmoType())
    ply:Give("tfa_csgo_medishot")
    if (not ply._arenaEquipment) then return end

    ply:SetFOV(0, 1)

    timer.Simple(1, function()
        asapArena:SetPlayerModel(ply)
    end)
end

function GM:PlayerLeave(ply)
    ply:SendLua([[
        if IsValid(DEATH) then
            DEATH:Remove()
        end
    ]])
    if (#asapArena:GetPlayers() == 1) then
        for k, v in pairs(asapArena:GetPlayers(true)) do
            self:EndRound(v)
            break
        end
    end
end

function GM:PlayerDeath(ply, att)
    if (asapArena:GetState() < 2) then return end
    if (#asapArena:GetPlayers(true) <= 1)  then
        for k, v in pairs(asapArena:GetPlayers(true)) do
            self:EndRound(v)
            break
        end
    end
    if (IsValid(att)) then
        ply.ArenaKiller = att
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
            draw.SimpleText("Waiting more players...", "Arena.Medium", ScrW() / 2 + 2, 98, Color(0, 0, 0), 1, 1)
            draw.SimpleText("Waiting more players...", "Arena.Medium", ScrW() / 2, 96, color_white, 1, 1)
            draw.SimpleText("Need " .. (self.MinPlayers - #asapArena:GetPlayers(true)), "Arena.Medium", ScrW() / 2 + 32, 128, Color(200, 75, 0), 1, 1)
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
        draw.SimpleText("Players Alive", "Arena.Medium", ScrW() / 2 - 32, 92, Color(75, 175, 255), 1, 1)
        draw.SimpleText(players, "Arena.Medium", ScrW() / 2 + 32, 96 + 24, Color(255, 75, 50), 1, 1)
    end
end

asapArena:AddGamemode("battleroyale", GM)