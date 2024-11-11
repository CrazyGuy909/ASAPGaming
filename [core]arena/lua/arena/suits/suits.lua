local GM = {}

if SERVER then
    util.AddNetworkString("ASAP.Arena.Melee.WonGame")
end

GM.Base = "deathmatch"
GM.Name = "Super Suits"
GM.Icon = "vgui/arena/suit"
GM.GameType = "DM"
GM.NoKillStreaks = true
GM.Description = "Suit yourself in a futuristic mayhem"
GM.CaseReward = 554
GM.Weapons = {"infinitygunx99", "mac_bo2_deathmach", "weapon_lightsaber"}
GM.VoteTime = 10
GM.RoundTime = 500
GM.AutoSpawn = "A"
GM.Suits = {
    [1] = "armor_bubblum_3",
    [2] = "armor_raytracing_3",
    [3] = "armor_rescuer_3",
    [4] = "armor_meltdown",
    [5] = "armor_gunsmith_3",
    [6] = "armor_hgs",
    [7] = "armor_bulletsmith_3",
    [8] = "armor_bladesmith_3"
}
GM.CurrentVotes = {}
function GM:Init()
    if CLIENT then
        self.CurrentVotes = {}
        return
    end

    if (not asapArena.Players) then
        asapArena.Players = {}
    end

    self.CurrentVotes = {}
    for k, v in pairs(asapArena.Players) do
        k:SetFrags(0)
        k:SetDeaths(0)
        k:GodDisable()
        k:Freeze(false)
        k:SetNoDraw(false)
        self:PlayerSpawn(k)
        self:DoSync(k)
    end

    for k, v in pairs(player.GetAll()) do
        v:SetNWInt("VotesRemaining", 2)
    end

    self.SuitList = nil
    asapArena:SetState(1)
    SetGlobalInt("Arena.EndRound", CurTime() + self.VoteTime)
    timer.Remove("WarmupTime")
    timer.Remove("EndRound")

    timer.Create("WarmupTime", self.VoteTime, 1, function()
        asapArena:SetState(2)
        SetGlobalInt("Arena.EndRound", CurTime() + self.VoteTime)
        timer.Remove("EndRound")
        self:FinishVotation()

        timer.Create("EndRound", self.RoundTime, 1, function()
            self:EndRound()
        end)

        for k, v in pairs(asapArena:GetPlayers()) do
            v:SetFrags(0)
            v:Spawn()
        end
    end)
end

function GM:FinishVotation()
    local winners = {}
    for k, v in SortedPairs(self.CurrentVotes, true) do
        if (#winners < 3) then
            table.insert(winners, k)
        else
            break
        end
    end

    if (#winners < 3) then
        while #winners < 3 do
            ::reroll::
            local _, ran = table.Random(self.Suits)
            if not table.HasValue(winners, ran) then
                table.insert(winners, ran)
                if (#winners == 3) then
                    break
                end
            else
                goto reroll
            end
        end
    end

    net.Start("Suits.Vote")
    net.WriteUInt(2, 3)
    for k = 1, 3 do
        net.WriteUInt(winners[k], 5)
    end
    net.SendArena()
    self.SuitList = table.Copy(winners)
end

function GM:OnRemove()
    timer.Remove("EndRound")
    timer.Remove("WarmupTime")

    for k, v in pairs(asapArena:GetPlayers()) do
        if (v.removeArmorSuit) then
            v:removeArmorSuit()
        end
    end
end

function GM:DoSync(ply)
    net.Start("Suits.Vote")
    net.WriteUInt(0, 3)
    for k, v in pairs(self.Suits) do
        net.WriteUInt(self.CurrentVotes[k] or 0, 8)
    end
    net.Send(ply)
end

function GM:PlayerJoin(ply)
    if (asapArena:GetState() == 1) then
        self:DoSync(ply)
    end
end

function GM:PlayerLeave(ply)
    ply:removeArmorSuit()
end

function GM:EndRound()
    asapArena:StartGamemodeVote()
    local winner
    local lastwinner

    for k, v in pairs(player.GetAll()) do
        if (not v:InArena()) then continue end
        v:removeArmorSuit()
        v:Freeze(true)

        if (not winner or winner:Frags() < v:Frags()) then
            winner = v
        end
    end

    if IsValid(winner) then
        winner:GiveArenaXP(100, "Winning the match")
        net.Start("Arena.WonCaseRound")
        net.WriteEntity(winner)
        net.WriteString("Suit Crate")
        net.Broadcast()
        winner:UB3AddItem(self.CaseReward, 1)
        asapLogs:add("Arena Wins", winner, nil, {
            rew = self.CaseReward,
            id = asapArena.ActiveGamemode.id
        })

        if not asapArena.BanList[winner:SteamID()] then
            asapArena.BanList[winner:SteamID()] = {}
        end

        if not asapArena.BanList[winner:SteamID()].suits then
            asapArena.BanList[winner:SteamID()].suits = 4
        end
    end

    for k, v in pairs(asapArena.BanList or {}) do
        if (not asapArena.BanList[k].suits) then continue end
        asapArena.BanList[k].suits = (asapArena.BanList[k].suits or 1) - 1
        hasChanges = true

        if (asapArena.BanList[k].suits <= 0) then
            asapArena.BanList[k].suits = nil
        end
    end

    file.Write("event_winners.txt", util.TableToJSON(asapArena.BanList))

    if IsValid(lastwinner) then
        lastwinner:GiveArenaXP(75, "Second place!")
    end

    timer.Simple(3, function()
        for k, v in pairs(player.GetAll()) do
            if (not v:InArena()) then continue end
            v:Freeze(false)
        end

        asapArena:SetGamemode("deathmatch")
    end)
end

function GM:PlayerDeath(ply, att)
    if (ply == att) then return end
    if (asapArena:GetState() ~= 2) then return end
    if (not ply:IsPlayer() or not att:IsPlayer()) then return end
    att:SetNW2Int("GG_Kills", att:Frags() + 1)
end

function GM:SelectSpawn(ply)
    if (not ply:InArena()) then return end
    local ranSpawn = table.Random(asapArena.SpawnPoints[self.AutoSpawn].spawns)
    ply:SetPos(ranSpawn - Vector(0, 0, 48))
end

function GM:PlayerSpawn(ply, fs)
    timer.Simple(0, function()
        self:SelectSpawn(ply)
        asapArena:SetPlayerModel(ply)
        ply:StripWeapons()
        ply:GodEnable()
        timer.Simple(1, function()
            if IsValid(ply) then
                if not ply:Alive() or not ply:InArena() or ply:IsDueling() then return end
                if not self.SuitList then return end
                ply:giveArmorSuit(Armor:GetByID(self.Suits[table.Random(self.SuitList)]).Name)
                ply:GodDisable()
            end
        end)

        for k, v in pairs(self.Weapons) do
            ply:Give(v)
        end
    end)
end

local function calculateVote(id)
    local max = 1
    for k, v in pairs(asapArena.ActiveGamemode.CurrentVotes or {}) do
        if (max < v) then
            max = v
        end
    end

    return (asapArena.ActiveGamemode.CurrentVotes[id] or 0) / max
end

function GM:CreatePanel()
    
    if IsValid(S_VOTE) then
        S_VOTE:Remove()
    end

    S_VOTE = vgui.Create("DPanel")
    S_VOTE:SetSize(ScrW(), ScrH())
    S_VOTE.Start = SysTime()
    S_VOTE:SetAlpha(0)
    S_VOTE:AlphaTo(255, .3, 0)
    S_VOTE.Paint = function(s, w, h)
        Derma_DrawBackgroundBlur(s, 0)
        local tx, ty = draw.SimpleText("Vote next Armors", "Gangs.Huge", w / 2, 32, color_white, 1)
        surface.SetDrawColor(255, 255, 255, 50)
        surface.DrawLine(32, 48 + ty, w - 64, 48 + ty)
        _, ty = draw.SimpleText("Game Starts in:", "Gangs.Small", w - 64, 32, color_white, TEXT_ALIGN_RIGHT)
        local time = math.Clamp(GetGlobalInt("Arena.EndRound") - CurTime(), 0, asapArena.ActiveGamemode.VoteTime)
        draw.SimpleText(string.FormattedTime(time, "%02d:%02d"), "Gangs.Small", w - 64, 32 + ty, color_white, TEXT_ALIGN_RIGHT)
        
    end

    S_VOTE.Preview = vgui.Create("DModelPanel", S_VOTE)
    S_VOTE.Preview:Dock(LEFT)
    S_VOTE.Preview:SetWide(ScrW() / 3)
    S_VOTE.Preview:SetModel("models/player/alyx.mdl")
    S_VOTE.Preview:GetEntity():SetSequence("menu_combine")
    S_VOTE.Preview.LayoutEntity = function() end
    S_VOTE.Preview:SetCamPos(Vector(120, -40, 40))
    S_VOTE.Preview:SetLookAt(Vector(0, 0, 40))
    S_VOTE.Preview:SetFOV(30)

    S_VOTE.Right = vgui.Create("DPanel", S_VOTE)
    S_VOTE.Right:Dock(FILL)
    S_VOTE.Right:DockMargin(0, 142, 64, 64)
    S_VOTE.Right:DockPadding(8, 16, 16, 16)
    S_VOTE.Right.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(16, 16, 16, 100))
        draw.SimpleText("You can vote " .. LocalPlayer():GetNWInt("VotesRemaining", 2) .. " time/s", "Gangs.Small", w - 8, h - 16, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

        
        local time = math.Clamp(GetGlobalInt("Arena.EndRound") - CurTime(), 0, asapArena.ActiveGamemode.VoteTime)
        draw.RoundedBoxEx(8, 0, h - 8, w, 8, Color(16, 16, 16), false, false, true, true)
        if (S_VOTE.winner) then
            draw.RoundedBoxEx(8, 0, h - 8, w, 8, Color(209, 139, 34), false, false, true, true)
        else    
            draw.RoundedBoxEx(8, 0, h - 8, w * (1 - time / self.VoteTime), 8, Color(56, 179, 93), false, false, true, true)
        end
        
    end

    S_VOTE.SetWinner = function(s, a, b, c)
        s.winner = {
            [a] = true,
            [b] = true,
            [c] = true,
        }
    end

    S_VOTE.Dismiss = vgui.Create("XeninUI.Button", S_VOTE.Right)
    S_VOTE.Dismiss:Dock(BOTTOM)
    S_VOTE.Dismiss:SetTall(32)
    S_VOTE.Dismiss:SetText("Hide")
    S_VOTE.Dismiss:DockMargin(0, 0, 256, 0)
    S_VOTE.Dismiss:SetRound(8)
    S_VOTE.Dismiss.DoClick = function()
        S_VOTE:Remove()
    end

    S_VOTE.Votes = vgui.Create("XeninUI.ScrollPanel", S_VOTE.Right)
    for k, v in pairs(GM.Suits) do
        local armor = Armor:GetByID(v)
        local option = vgui.Create("DPanel", S_VOTE.Right)
        option:Dock(TOP)
        option:SetTall(48)
        option.ID = k
        option:DockMargin(0, 0, 0, 16)
        option.Paint = function(s, w, h)
            surface.SetDrawColor(255, 255, 255, 50)
            local bwide = s.Button:GetWide() + 8
            surface.DrawOutlinedRect(bwide + 12, h / 2, w - bwide - 16, h / 2 - 4)
            draw.SimpleText("Votes: " .. (asapArena.ActiveGamemode.CurrentVotes[k] or 0), "Arena.Small", bwide + 12, 0, color_white)

            surface.SetDrawColor(223, 150, 41)
            surface.DrawRect(bwide + 14, h / 2 + 2, (w - bwide - 16 - 4) * calculateVote(k), h / 2 - 8)

            if (S_VOTE.winner and S_VOTE.winner[s.ID]) then
                surface.DrawOutlinedRect(bwide + 8, 0, w - 9, h)
            end
        end
        option.Button = vgui.Create("XeninUI.Button", option)
        option.Button:Dock(LEFT)
        option.Button:SetText(armor.Name)
        option.Button:SetWide(228)
        option.Button:SetRound(8)
        option.Button.OnCursorEntered = function(s)
            S_VOTE.Preview:SetModel(armor.Model)
            S_VOTE.Preview:GetEntity():SetSequence(s.pressed and "pose_standing_04" or "menu_combine")
        end

        option.Button.DoClick = function(s)
            if (s.pressed) then
                Derma_Message("You cannot vote the same suit!")
                return
            end
            if LocalPlayer():GetNWInt("VotesRemaining", 2) == 0 then
                Derma_Message("You cannot vote anymore!")
                return
            end

            surface.PlaySound("weapons/projectile_impact.wav")
            s.pressed = true
            s:SetColor(Color(223, 150, 41))
            s:SetText("VOTED")
            S_VOTE.Preview:GetEntity():SetSequence("pose_standing_04")
            net.Start("Suits.Vote")
            net.WriteUInt(1, 3)
            net.WriteUInt(k, 5)
            net.SendToServer()
        end
    end
end

if SERVER then
    util.AddNetworkString("Suits.Vote")

    net.Receive("Suits.Vote", function(l, ply)
        if (not ply:InArena()) then return end
        local id = net.ReadUInt(3)
        if (id == 1) then
            local votes = ply:GetNWInt("VotesRemaining", 2)
            if (votes <= 0) then
                return
            end
            local vote = net.ReadUInt(5)
            ply:SetNWInt("VotesRemaining", votes - 1)
            asapArena.ActiveGamemode.CurrentVotes[vote] = (asapArena.ActiveGamemode.CurrentVotes[vote] or 0) + 1
            net.Start("Suits.Vote")
            net.WriteUInt(3, 3)
            net.WriteUInt(vote, 5)
            net.WriteUInt(asapArena.ActiveGamemode.CurrentVotes[vote], 8)
            net.SendArena()
        end
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
        local w, h, y = 64, 78, 48

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
        draw.SimpleText(asapArena:GetState() == 2 and "Time remaining" or "Warmup", "XeninUI.TextEntry", ScrW() / 2, y + 86, color_white, 1, 0)
        draw.SimpleText(time, "Arena.Medium", ScrW() / 2, y + 98, color_white, 1, 0)
    end

    net.Receive("ASAP.Arena.Melee.WonGame", function()
        local nick = net.ReadString()
        chat.AddText(Color(245, 160, 80), "[Melee] ", color_white, "Player ", Color(250, 75, 75), nick, color_white, " won the game!")
    end)

    net.Receive("Suits.Vote", function()
        local kind = net.ReadUInt(3)
        local gm = asapArena.ActiveGamemode
        if (kind == 0) then
            asapArena.ActiveGamemode.CurrentVotes = {}
            for k = 1, table.Count(gm.Suits) do
                asapArena.ActiveGamemode.CurrentVotes[k] = net.ReadUInt(8)
            end
            gm:CreatePanel()
        elseif (kind == 2) then
            local a, b, c = net.ReadUInt(5), net.ReadUInt(5), net.ReadUInt(5)
            if IsValid(S_VOTE) then
                S_VOTE:SetWinner(a, b, c)
                timer.Simple(3, function()
                    if IsValid(S_VOTE) then
                        S_VOTE:Remove()
                    end
                end)
            end
            local suits = {}
            for k, v in pairs({a, b, c}) do
                table.insert(suits, Armor:GetByID(v).Name)
            end
            chat.AddText(Color(250, 188, 17), "[ARENA] ", color_white, "The chosen suits are ", Color(17, 188, 250), suits[1], ", " .. suits[2], " and " .. suits[3])
            surface.PlaySound("weapons/shatter3.wav")
        elseif (kind == 3) then
            local id, amount = net.ReadUInt(5), net.ReadUInt(8)
            asapArena.ActiveGamemode.CurrentVotes[id] = amount
        end
    end)
end

asapArena:AddGamemode("suits", GM)
