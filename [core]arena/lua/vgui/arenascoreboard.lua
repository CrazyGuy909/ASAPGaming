local PANEL = {}

surface.CreateFont("Arena.SB", {
    font = "Montserrat",
    size = 16
})

local enableVoice = CreateClientConVar("asap_enablevoicearena", 1, true)

function PANEL:Init()
    self:SetSize(ScrW() * .5, ScrH() * .6)
    self:SetTitle("Arena - Deathmatch")
    self:Center()
    local x, y = self:GetPos()
    self:SetPos(x - 72, y)
    self.Header = vgui.Create("DPanel", self)
    self.Header:Dock(TOP)
    self.Header:SetTall(24)
    self.Header:DockMargin(8, 8, 8, 0)

    self.Header.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 20))
        draw.SimpleText("Name", "Arena.SB", 48, h / 2, Color(255, 255, 255, 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Level", "Arena.SB", w / 2, h / 2, Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("K/D", "Arena.SB", w - w / 4 - w / 12, h / 2, Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Score", "Arena.SB", w - w / 6, h / 2, Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("Ping", "Arena.SB", w - 16, h / 2, Color(255, 255, 255, 100), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    self.Options = vgui.Create("Panel", self)
    self.Options:Dock(BOTTOM)
    self.Options:DockMargin(8, 8, 8, 8)
    self.Options:DockPadding(4, 4, 4, 4)
    self.Options:SetTall(42)

    self.Options.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(20, 20, 20))
    end

    self.Loadout = vgui.Create("XeninUI.Button", self.Options)
    self.Loadout:Dock(LEFT)
    self.Loadout:SetText("Loadout")
    self.Loadout:SetWide(148)
    self.Loadout:SetRound(4)
    self.Loadout:DockMargin(0, 0, 4, 0)
    self.Loadout:SetColor(Color(36, 36, 36))

    self.Loadout.DoClick = function()
        if (IsValid(ARENA_LOADOUT)) then
            ARENA_LOADOUT:Remove()
        end
        if (not asapArena.ActiveGamemode.DisableSelect) then
            ARENA_LOADOUT = vgui.Create("asap.Arena.Loadout")
        end
    end

    self.Voice = vgui.Create("XeninUI.Button", self.Options)
    self.Voice:Dock(LEFT)
    self.Voice:SetText(enableVoice:GetBool() and "Disable Arena Voice" or "Enable Arena Voice")
    self.Voice:SetWide(212)
    self.Voice:SetRound(4)
    self.Voice:DockMargin(0, 0, 4, 0)
    self.Voice:SetColor(Color(36, 36, 36))

    self.Voice.DoClick = function(s)
        enableVoice:SetBool(not enableVoice:GetBool())
        s:SetText(enableVoice:GetBool() and "Disable Arena Voice" or "Enable Arena Voice")
        net.Start("ASAP.Arena.VoiceChannel")
        net.WriteBool(enableVoice:GetBool())
        net.SendToServer()
    end

    self.Quit = vgui.Create("XeninUI.Button", self.Options)
    self.Quit:Dock(LEFT)
    self.Quit:SetColor(Color(36, 36, 36))
    self.Quit:SetText("Leave Arena")
    self.Quit:SetRound(4)
    self.Quit:SetWide(148)

    self.Quit.DoClick = function()
        net.Start("ASAP.Arena.Leave")
        net.SendToServer()
        LocalPlayer():SetNWBool("InArena", false)
    end

    self.List = vgui.Create("XeninUI.ScrollPanel", self)
    self.List:Dock(FILL)
    self.List:DockMargin(8, 4, 8, 0)
    self:MakePopup()
    self:SetKeyboardInputEnabled(false)
    self:FillPlayers()

    self.Challenges = {}
    if (LocalPlayer()._arenaData or {}).Challenges then
        local challenge = LocalPlayer()._arenaData.Challenges
        local day = os.date("%j", os.time()) - challenge.Start + 1
        local today = challenge.Daily[day]
        if ((not today or today.Finished) and challenge.Week.Finished) then return end
        if not today then return end
        if (not today.Finished) then
            local wep = weapons.GetStored(today.Weapon)
            if not wep then return end
            local attachments = ""
            local max = table.Count(today.Attachments or {})

            for k, v in pairs(today.Attachments or {}) do
                local att = TFA.Attachments.Atts[v]
                if (att) then
                    attachments = attachments .. att.Name .. (k != max and (max - k == 1 and " and " or ", ") or "")
                end
            end
            local item = BU3.Items.Items[today.Reward]
            local mp = markup.Parse("<font=Arena.Medium>Daily</font>\n<font=Arena.Small><colour=235,235,235,150>Weapon: <colour=237, 89, 0>" .. wep.PrintName .. "</colour>" .. (max > 0 and "\nAttachments: <colour=0, 156, 237>" .. attachments .. "</colour>" or "") .. "\nReward: <color=255, 255, 50>" .. item.name .. "</colour></font>", ScrW() * .25 - 32)
            mp.Data = today.Data
            mp.Challenge = today.Challenge
            if item.iconIsModel then
                mp.Reward = BU3.UI.Elements.ModelView(item.iconID, item.zoom, nil)
            else
                mp.Reward = BU3.UI.Elements.IconView(item.iconID, item.color, nil, false)
            end
            mp.Reward:SetSize(64, 64)
            mp.Reward.PaintOver = function(s, w, h)
                surface.SetDrawColor(255, 255, 255, 100)
                surface.DrawOutlinedRect(0, 0, w, h)
            end
            table.insert(self.Challenges, mp)
        end
        if (not challenge.Week.Finished) then
            local wep = weapons.GetStored(challenge.Week.Weapon)
            if not wep then return end
            local attachments = ""
            local max = table.Count(challenge.Week.Attachments)

            for k, v in pairs(challenge.Week.Attachments) do
                local att = TFA.Attachments.Atts[v]
                if (att) then
                    attachments = attachments .. att.Name .. (k != max and (max - k == 1 and " and " or ", ") or "")
                end
            end
            local item = BU3.Items.Items[challenge.Week.Reward]
            local mp = markup.Parse("<font=Arena.Medium>Weekly" .. "</font>\n<font=Arena.Small><colour=235,235,235,150>Weapon: <colour=237, 89, 0>" .. wep.PrintName .. "</colour>" .. (max > 0 and "\nAttachments: <colour=0, 156, 237>" .. attachments .. "</colour>" or "") .. "\nReward: <color=255, 255, 50>" .. item.name .. "</colour></font>", ScrW() * .25 - 32)
            mp.Data = challenge.Week.Data
            mp.Challenge = challenge.Week.Challenge
            if item.iconIsModel then
                mp.Reward = BU3.UI.Elements.ModelView(item.iconID, item.zoom, nil)
            else
                mp.Reward = BU3.UI.Elements.IconView(item.iconID, item.color, nil, false)
            end
            mp.Reward:SetSize(64, 64)
            mp.Reward.Data = {challenge.Week.Data, challenge.Week.Challenge}
            mp.Reward.PaintOver = function(s, w, h)
                surface.SetDrawColor(255, 255, 255, 100)
                surface.DrawOutlinedRect(0, 0, w, h)
            end
            table.insert(self.Challenges, mp)
        end
    end
end

function PANEL:FillPlayers()
    self.List:Clear()
    local i = 1

    for k, v in pairs(player.GetAll()) do
        if (not v:InArena()) then continue end
        local ply = vgui.Create("arenaSB_Player", self.List)
        ply:SetPlayer(v)
        ply.Master = self
        ply.Index = i
        i = i + 1
    end
end

function PANEL:OnRemove()
    for k, v in pairs(self.Challenges) do
        if (IsValid(v.Reward)) then
            v.Reward:Remove()
        end
    end
end

local gr = surface.GetTextureID("gui/center_gradient")

function PANEL:PaintOver(w, h)
   local tall = 24
   for k, v in pairs(self.Challenges) do
        DisableClipping(true)

        local x, y = self:LocalToScreen(w, 0)
        render.SetScissorRect(x, y - 32, x + ScrW() * .5, y + h, true)
        surface.SetTexture(gr)
        surface.SetDrawColor(0, 0, 0, 255)
        surface.DrawTexturedRect(w + 16 - ScrW() * .25, tall - 16, ScrW() * .5, v:GetHeight() + 92 + 32)
        render.SetScissorRect(0, 0, 0, 0, false)

        v:Draw(w + 16, tall)
        surface.SetDrawColor(255, 255, 255)
        local y = v:GetHeight()
        draw.SimpleText("Kills:", "Arena.SB", w + 16, tall + y + 2, color_white)
        draw.SimpleText(v.Data[1] .. "/" .. v.Challenge[1], "Arena.SB", w + 16 + ScrW() * .25 - 48, tall + y + 2, color_white, TEXT_ALIGN_RIGHT)
        surface.DrawOutlinedRect(w + 16, tall + y + 20, ScrW() * .25 - 48, 12)
        surface.DrawRect(w + 18, tall + y + 22, (ScrW() * .25 - 52) * (v.Data[1] / v.Challenge[1]), 8)
        draw.SimpleText("Headshots:", "Arena.SB", w + 16, tall + y + 2 + 32, color_white)
        draw.SimpleText(v.Data[2] .. "/" .. v.Challenge[2], "Arena.SB", w + 16 + ScrW() * .25 - 48, tall + y + 34, color_white, TEXT_ALIGN_RIGHT)
        surface.DrawOutlinedRect(w + 16, tall + y + 50, ScrW() * .25 - 48, 12)
        surface.DrawRect(w + 18, tall + y + 52, (ScrW() * .25 - 52) * (v.Data[2] / v.Challenge[2]), 8)
        draw.SimpleText("Damage:", "Arena.SB", w + 16, tall + y + 2 + 32 + 30, color_white)
        draw.SimpleText(v.Data[3] .. "/" .. v.Challenge[3], "Arena.SB", w + 16 + ScrW() * .25 - 48, tall + y + 34 + 30, color_white, TEXT_ALIGN_RIGHT)
        surface.DrawOutlinedRect(w + 16, tall + y + 80, ScrW() * .25 - 48, 12)
        surface.DrawRect(w + 18, tall + y + 82, (ScrW() * .25 - 52) * (v.Data[3] / v.Challenge[3]), 8)
        v.Reward:SetPos(x + 16 + ScrW() * .25 - 48 - 64, y + tall * 1.15 + 48)
        tall = tall + v:GetHeight() + 128

        DisableClipping(false)
   end
end

vgui.Register("arenaScoreboard", PANEL, "XeninUI.Frame")
local PLY = {}
PLY.Index = 1

function PLY:Init()
    self:Dock(TOP)
    self:SetTall(40)
    self:DockMargin(0, 0, 0, 8)
    self:SetText("")
end

function PLY:SetPlayer(ply)
    self.Player = ply
    self.Avatar = vgui.Create("AvatarImage", self)
    self.Avatar:SetPlayer(ply, 32)
    self.Avatar:Dock(LEFT)
    self.Avatar:DockMargin(4, 4, 4, 4)
    self.Avatar:SetWide(32)
    self.Name = Label(ply:Nick(), self)
    self.Name:Dock(LEFT)
    self.Name:DockMargin(4, 0, 0, 0)
    self.Name:SetFont("Arena.Small")
    self.Name:SizeToContentsX()
    self.Name:SetTextColor(ply:IsDueling() and Color(255, 156, 0) or Color(175, 175, 175))
end

function PLY:OnMousePressed(l)
    if (self.Player == LocalPlayer()) then return end
    if (LocalPlayer():IsDueling()) then return end
    if (self.Player:IsDueling()) then
        Derma_Message("This player is dueling!")
        return
    end
    
    local menu = DermaMenu()
    menu:Open()
end

local colors = {
    [1] = Color(75, 255, 50),
    [2] = Color(150, 255, 50),
    [3] = Color(225, 100, 50),
    [4] = Color(255, 0, 0)
}

function PLY:Paint(w, h)
    if (not IsValid(self.Player)) then
        self:Remove()
        self.Master:FillPlayers()

        return
    end

    local clr = self.Index % 2 == 1 and 16 or 36
    draw.RoundedBox(4, 0, 0, w, h, Color(clr, clr, clr))
    local ply = self.Player
    draw.SimpleText(ply:GetArenaLevel(), "Arena.Small", w / 2, h / 2, Color(255, 255, 255, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(ply:GetArenaFrags() .. "/" .. ply:GetArenaDeaths(), "Arena.Small", w - w / 4 - w / 12, h / 2, Color(255, 255, 255, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(ply:GetArenaScore(), "Arena.Small", w - w / 6, h / 2, Color(255, 255, 255, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    local ms = ply:Ping()
    local barWide = (28 - 8) / 4

    for k = 1, 4 do
        surface.SetDrawColor(255, 255, 255, 100)
        surface.DrawRect(w - 44 + (4 - k) * (barWide + 2), k * 5 + 6, barWide, h - k * 5 - 16)

        if (math.ceil(ms / 100) <= k) then
            surface.SetDrawColor(colors[math.Clamp(math.ceil(ms / 100), 1, 4)])
            surface.DrawRect(w - 44 + (4 - k) * (barWide + 2), k * 5 + 6, barWide, h - k * 5 - 16)
        end
    end
end

vgui.Register("arenaSB_Player", PLY, "DButton")

hook.Add("PlayerBindPress", "Arena.Scoreboard", function(ply, bind, press)
    if (ply:InArena() and bind == "+showscores") then
        if (press) then
            if IsValid(AR_SB) then
                AR_SB:Remove()
            end

            AR_SB = vgui.Create("arenaScoreboard")
        elseif IsValid(AR_SB) then
            AR_SB:Remove()
        end

        return true
    end
end)