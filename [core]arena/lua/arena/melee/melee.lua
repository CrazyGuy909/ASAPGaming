local GM = {}

if SERVER then
    util.AddNetworkString("ASAP.Arena.Melee.WonGame")
end

GM.Base = "base"
GM.Name = "Medieval Mayhem"
GM.Icon = "vgui/arena/medieval"
GM.GameType = "DM"
GM.NoKillStreaks = true
GM.Description = "Grab your sword and come to fight!"
GM.CaseReward = 571
GM.Weapons = {"tfa_cso_stormgiant_v8", "tfa_cso_dragonblade_expert", "tfa_cso_runebreaker_expert", "tfa_cso_ruyi", "tfa_cso_jaydagger", "tfa_cso_janus9", "tfa_cso_beam_sword"}

function GM:Init()
    if CLIENT then return end
	BroadcastLua("DisplayNotification('melee')")
    if (not asapArena.Players) then
        asapArena.Players = {}
    end

    for k, v in pairs(asapArena.Players) do
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
        SetGlobalInt("Arena.EndRound", CurTime() + 5 * 60)
        timer.Remove("EndRound")

        timer.Create("EndRound", 5 * 60, 1, function()
            self:EndRound()
        end)

        for k, v in pairs(asapArena:GetPlayers()) do
            v:SetFrags(0)
            v:Spawn()
        end
    end)
end

function GM:OnRemove()
    timer.Remove("EndRound")
    timer.Remove("WarmupTime")
end

function GM:EndRound()
    local winner
    local lastwinner

    for k, v in pairs(player.GetAll()) do
        if (not v:InArena()) then continue end
        v:Freeze(true)

        if (not winner or winner:Frags() <= v:Frags()) then
            if (lastwinner ~= winner) then
                lastwinner = winner
            end

            winner = v
        end
    end

    if IsValid(winner) then
        winner:GiveArenaXP(100, "Winning the match")
        winner:UB3AddItem(self.CaseReward, 1)
        net.Start("Arena.WonCaseRound")
        net.WriteEntity(winner)
        net.WriteString("Viking Crate")
        net.Broadcast()
    end

    if IsValid(lastwinner) then
        lastwinner:GiveArenaXP(75, "Second place!")
    end

    timer.Simple(3, function()
        for k, v in pairs(player.GetAll()) do
            if (not v:InArena()) then continue end
            v:Freeze(false)
        end

    end)
	asapArena:SetGamemode(GetGlobalString("ActiveGamemode", "deathmatch"))
	asapArena:SetGamemode("deathmatch")
	net.Start("arenaWinnerMessage")
	net.WriteString("melee") -- Replace "gungame" with the actual gamemodeID
	net.WriteString(winner:Nick())
	net.SendToServer()
end

function GM:PlayerJoin(ply)
end

function GM:PlayerLeave(ply)
end

function GM:PlayerDeath(ply, att)
    if (ply == att) then return end
    if (asapArena:GetState() ~= 2) then return end
    if (not ply:IsPlayer() or not att:IsPlayer()) then return end
    att:SetNW2Int("GG_Kills", att:Frags() + 1)
end

function GM:PlayerSpawn(ply, fs)
    timer.Simple(0, function()
        self:SelectSpawn(ply)
        asapArena:SetPlayerModel(ply)
        ply:StripWeapons()
        ply:Give(table.Random(self.Weapons))
    end)
end

if CLIENT then
    function GM:HUDPaint()
        local players = {}

        for k, v in pairs(player.GetAll()) do
            if (v:InArena()) then
                table.insert(players, v)
            end
        end

        table.sort(players, function(a, b) return a:Frags() > b:Frags() end)
        local w, h, y = 64, 78, 20

        for k = 1, 5 do
            local ply = players[k]

            if (ply) then
                local bigSize = (w + 8) * math.min(#players, 5)
                local x = ScrW() / 2 - bigSize / 2 - w
                draw.RoundedBox(8, x + (w + 8) * k, y, w, h, Color(26, 26, 26, 150))

                if (not IsValid(ply._arenaAvatar)) then
                    ply._arenaAvatar = vgui.Create("AvatarImage")
                    ply._arenaAvatar:SetSize(w - 8, w - 8)
                    ply._arenaAvatar:SetPlayer(ply, 96)
                    ply._arenaAvatar:SetPaintedManually(true)
                end

                ply._arenaAvatar:SetPos(x + 4 + (w + 8) * k, y + 4)
                ply._arenaAvatar:SetSize(w - 8, w - 8)
                ply._arenaAvatar:PaintManual()
                draw.SimpleText(ply:Frags(), "XeninUI.TextEntry", x + w / 2 + (w + 8) * k, y + h - 8, Color(255, 255, 255, 175), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        local time = string.FormattedTime(math.max(GetGlobalInt("Arena.EndRound") - CurTime(), 0), "%02d:%02d")
        draw.SimpleText(asapArena:GetState() == 2 and "Time remaining" or "Warmup", "XeninUI.TextEntry", ScrW() / 2, 112, color_white, 1, 0)
        draw.SimpleText(time, "Arena.Medium", ScrW() / 2, 128, color_white, 1, 0)
    end

    net.Receive("ASAP.Arena.Melee.WonGame", function()
        local nick = net.ReadString()
        chat.AddText(Color(245, 160, 80), "[Jousting Jedi] ", color_white, "Player ", Color(250, 75, 75), nick, color_white, " won the game!")
    end)
end

asapArena:AddGamemode("melee", GM)