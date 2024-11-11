local PANEL = {}

surface.CreateFont("Arena.Title", {
    font = "Montserrat",
    size = 80
})

surface.CreateFont("Arena.Subtitle", {
    font = "Montserrat",
    size = 48
})

surface.CreateFont("Arena.Challenge", {
    font = "Montserrat",
    size = 36
})

surface.CreateFont("Arena.Tiny", {
    font = "Montserrat",
    size = 20
})

local gr = surface.GetTextureID("vgui/gradient-d")
local path = "vgui/arena/stats/"

local icons = {
    [1] = surface.GetTextureID(path .. "kills"),
    [2] = surface.GetTextureID(path .. "deaths"),
    [3] = surface.GetTextureID(path .. "damage"),
    [4] = surface.GetTextureID(path .. "streak")
}

local glow = surface.GetTextureID("particle/particle_glow_04")
function PANEL:Init()
    asapArena.MainPanel = self
    self.ad = LocalPlayer()._arenaData

    if (not self.ad) then
        self.ad = {
            Level = 0,
            Experience = 0,
            Score = 0,
            Data = {},
            Equipment = {}
        }
    end

    self.ae = LocalPlayer()._arenaEquipment or {}
    self:Dock(FILL)
    self.Info = vgui.Create("Panel", self)
    self.Info:Dock(BOTTOM)

    self.Info.Paint = function(s, w, h)
        w = w - 226
        local nextXP = ((LocalPlayer():GetArenaLevel() + 1) * 100)
        draw.SimpleText("Level: " .. LocalPlayer():GetArenaLevel(), "Arena.Stat", 8, 8, Color(255, 255, 255, 175))
        draw.SimpleText(LocalPlayer():GetArenaXP() .. "/" .. nextXP, "Arena.Stat", w - 16, 8, Color(255, 255, 255, 175), TEXT_ALIGN_RIGHT)
        local progress = LocalPlayer():GetArenaXP() / nextXP
        surface.SetDrawColor(255, 255, 255, 50)
        surface.DrawRect(8, h - 24, w - 16, 2)
        surface.DrawRect(8, h - 48, 2, 24)
        surface.DrawRect(w - 10, h - 48, 2, 24)
        surface.SetDrawColor(255, 100, 200, 200)
        surface.DrawRect(12, h - 38, progress * (w - 24), 12)
        surface.SetDrawColor(255, 255, 255, 50)
        local max = math.ceil(nextXP / 100)

        for k = 1, max - 1 do
            surface.DrawRect(8 + k * (w / max), h - 40, 2, 16)
        end
    end

    self.Model = vgui.Create("DModelPanel", self)
    self.Model:Dock(RIGHT)
    local modelPath = table.Random(asapArena.Models[tonumber(self.ae.PlayerModel) or 1].Models)
    self.Model:SetModel(modelPath)
    self.Model.LayoutEntity = function() end
    self.Model:SetFOV(40)
    self.Model:SetCamPos(Vector(40, 20, 57))
    self.Model:SetLookAt(Vector(0, 0, 57))

    self.Model.opaint = self.Model.Paint
    self.Model.Paint = function(s, w, h)
        s:opaint(w, h)
        surface.SetTexture(gr)
        surface.SetDrawColor(Color(16, 16, 16))
        surface.DrawTexturedRect(0, h - 96, w, 96)
    end

    self.Equipment = vgui.Create("Panel", self)
    self.Equipment:Dock(LEFT)
    self.Equipment:DockMargin(0, 8, 8, 0)

    self.Equipment.PerformLayout = function(s, w, h)
        local tall = self.Equipment.Header:GetTall()
        if IsValid(self.Equipment.Daily) then
            self.Equipment.Daily:SetTall(h / 2 - 4 - tall / 2)
        end
        if IsValid(self.Equipment.Weekly) then
            self.Equipment.Weekly:SetTall(h / 2 - 4 - tall / 2)
        end
    end

    self.Equipment.Header = vgui.Create("DLabel", self.Equipment)
    self.Equipment.Header:SetText("Challenges:")
    self.Equipment.Header:SetFont("Arena.Medium")
    self.Equipment.Header:DockMargin(8, 0, 0, 8)
    self.Equipment.Header:Dock(TOP)
    self.Equipment.Header:SizeToContents()
    self.Equipment.Daily = vgui.Create("Panel", self.Equipment)
    self.Equipment.Daily:Dock(TOP)
    self.Equipment.Daily:DockMargin(8, 0, 0, 8)
    self:CreateChallenge("Daily")
    self.Equipment.Weekly = vgui.Create("Panel", self.Equipment)
    self.Equipment.Weekly:Dock(TOP)
    self.Equipment.Weekly:DockMargin(8, 0, 0, 8)
    self:CreateChallenge("Weekly")
    --self.Equipment:InvalidateLayout(true)
    self.Stats = vgui.Create("Panel", self)
    self.Stats:Dock(FILL)

    self.Stats.Paint = function(s, w, h)
        local data = LocalPlayer()._arenaData
        draw.SimpleText("Stats:", "Arena.Medium", 8, 8, color_white)
        surface.SetDrawColor(255, 100, 75, 200)
        surface.SetTexture(icons[1])
        surface.DrawTexturedRectRotated(w / 2, 112, 32, 32, 0)
        surface.SetDrawColor(125, 150, 255, 200)
        surface.SetTexture(icons[2])
        surface.DrawTexturedRectRotated(w / 2, 112 + 64, 32, 32, 0)
        surface.SetTexture(icons[3])
        surface.SetDrawColor(125, 255, 100, 200)
        surface.DrawTexturedRectRotated(w / 2, 112 + 128, 32, 32, 0)
        surface.SetTexture(icons[4])
        surface.SetDrawColor(255, 150, 200, 200)
        surface.DrawTexturedRectRotated(w / 2, 112 + 128 + 64, 32, 32, 0)
        surface.SetDrawColor(255, 255, 255, 25)
        draw.SimpleText(data.Kills or 0, "Arena.Stat", w / 2, 64, Color(255, 100, 75, 255), 1)
        surface.DrawRect(8, 112 - 18, w - 16, 1)
        draw.SimpleText(data.Deaths or 0, "Arena.Stat", w / 2, 64 + 64, Color(125, 150, 255, 255), 1)
        surface.DrawRect(8, 112 - 18 + 64, w - 16, 1)
        draw.SimpleText(math.Round(data.Damage or 0), "Arena.Stat", w / 2, 64 + 128, Color(125, 255, 100, 255), 1)
        surface.DrawRect(8, 112 - 18 + 128, w - 16, 1)
        draw.SimpleText(math.Round(data.Streak or 0), "Arena.Stat", w / 2, 64 + 196, Color(255, 150, 200, 255), 1)
        surface.DrawRect(8, 112 - 18 + 196, w - 16, 1)

        if (data.Weapons and not self.wepList) then
            local i = 0
            self.wepList = {}
            local values = {}

            for k, v in pairs(data.Weapons) do
                values[k] = isnumber(v) and v or v[1]
            end

            for k, v in SortedPairsByValue(values, true) do
                if (i < 4) then
                    table.insert(self.wepList, {weapons.GetStored(k).PrintName, v})
                    i = i + 1
                else
                    break
                end
            end
        elseif (self.wepList) then
            surface.SetDrawColor(color_white)
            for k, v in pairs(self.wepList) do
                local tx, _ = draw.SimpleText(v[1], "Arena.Stat", 16, 342 + (k - 1) * 32, Color(225, 225, 225, 225))
                tx = tx + 8
                local bx, _ = draw.SimpleText(v[2], "Arena.Stat", 16 + tx, 342 + (k - 1) * 32, Color(225, 225, 225, 100))
                surface.SetTexture(icons[1])
                surface.DrawTexturedRect(16 + tx + 4 + bx, 342 + (k - 1) * 32 + 2, 24, 24)
            end
        else
            draw.SimpleText("-Nothing to see here yet-", "Arena.Stat", w / 2, 348, Color(225, 225, 225, 75), 1, 1)
        end
    end

    self.Join = vgui.Create("XeninUI.Button", self.Info)
    self.Join:Dock(RIGHT)
    self.Join:DockMargin(16, 24, 16, 24)
    self.Join:SetWide(196)
    self.Join:SetText("Join")
    self.Join:SetColor(Color(25, 125, 0))

    self.Join.DoClick = function()
        net.Start("ASAP.Arena.JoinArena")
        net.SendToServer()
        DarkRP.closeF4Menu()
    end
end
local blacklist = {
    "hands","sleeve"
}
function PANEL:CreateChallenge(kind)
    if not LocalPlayer()._arenaData then
        LocalPlayer()._arenaData = {}
    end
    if (not LocalPlayer()._arenaData.Challenges) then
        net.Start("ASAP.Arena:GenerateChallenge")
        net.SendToServer()
        return
    end
    local challTable = LocalPlayer()._arenaData.Challenges
    local challenge
    if kind == "Daily" then
        local day = os.date("%j", os.time()) - (challTable.Start or 0) + 1
        if (day > 7) then
            net.Start("ASAP.Arena:GenerateChallenge")
            net.SendToServer()
            day = 7
        end
        challenge = LocalPlayer()._arenaData.Challenges.Daily[day]
    elseif kind == "Weekly" then
        challenge = challTable.Week
    end
    local btn = self.Equipment[kind]
    btn.Model = vgui.Create("DModelPanel", btn)
    self.Equipment[kind].Paint = function(s, w, h)
        if not challenge or not challenge.Weapon or challenge.Weapon == "" then
            return
        end
        draw.SimpleText(kind, "Arena.Challenge", 0, 0, Color(255, 255, 255, 100))
        draw.RoundedBox(4, 8, 18, w - 16, h - 32, Color(255, 255, 255, 5))

        local a = 255 - btn.Model:GetAlpha()
        draw.SimpleText("Weapon: " .. ((weapons.GetStored((challenge or {}).Weapon) or {}).PrintName or ""), "Arena.Stat", 18, 42, Color(255, 255, 255, a * .5))
        if (not s.Markup) then
            local attachments = ""
            local max = table.Count(challenge.Attachments)
            for k, v in pairs(challenge.Attachments) do
                local att = TFA.Attachments.Atts[v]
                if (att) then
                    attachments = attachments .. att.Name .. (k != max and (max - k == 1 and " and " or ", ") or "")
                end
            end
            s.Markup = markup.Parse("<font=Arena.Stat><colour=255, 255, 255, " .. (a * .5) .. ">Attachments: <colour><color=200, 175, 50" .. (a * .5) .. ">" .. attachments .. "</colour></font>", w - 42)
            local item = BU3.Items.Items[challenge.Reward]
            if not item then return end
            if item.iconIsModel then
                s.Reward = BU3.UI.Elements.ModelView(item.iconID, item.zoom, s)
            else
                s.Reward = BU3.UI.Elements.IconView(item.iconID, item.color, s, false)
            end
            s.Reward:SetSize(96, 96)
            s.Reward.PaintOver = function(s, w, h)
                surface.SetDrawColor(255, 255, 255, 100)
                surface.DrawOutlinedRect(0, 0, w, h)
            end
            s.Reward:SetPos(w - 112, h - 116)
        else
            s.Markup:Draw(16, 72, 0, 0, a * .5)
            draw.SimpleText("Kills:" .. challenge.Data[1] .. "/" .. challenge.Challenge[1], "Arena.Tiny", 16, h - 86, Color(255, 255, 255, a * .5))
            draw.SimpleText("Deaths:" .. challenge.Data[2] .. "/" .. challenge.Challenge[2], "Arena.Tiny", 16, h - 86 + 20, Color(255, 255, 255, a * .5))
            draw.SimpleText("Damage:" .. challenge.Data[3] .. "/" .. challenge.Challenge[3], "Arena.Tiny", 16, h - 86 + 40, Color(255, 255, 255, a * .5))
        end
    end

    btn.Model:SetModel((weapons.GetStored((challenge or {}).Weapon) or {}).WorldModel or "models/weapons/w_pist_p228.mdl")
    btn.Model:Dock(FILL)
    btn.Model:SetFOV(80)
    btn.Model:SetDirectionalLight( BOX_TOP, Color( 255, 255, 255 ) )
    btn.Model:SetDirectionalLight( BOX_FRONT, color_white )
    btn.Model:SetDirectionalLight( BOX_BACK, Color(0,125,255))
    btn.Model:SetAmbientLight(Color(255,255,255))
    btn.Model.LayoutEntity = function() end
    btn.Model.OnCursorEntered = function(s)
        s:AlphaTo(0, .25, 0)
    end
    btn.Model.OnCursorExited = function(s)
        s:AlphaTo(255, .25, 0)
    end
    local ent = btn.Model:GetEntity()
    if IsValid(ent) then
        for k,v in pairs(ent:GetMaterials()) do
            for _,black in pairs(blacklist) do
                if (string.find(v, black, 1, true)) then
                    ent:SetSubMaterial(k - 1, "null")
                end
            end
        end

        local PrevMins, PrevMaxs = btn.Model.Entity:GetRenderBounds()
        btn.Model:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.5, 0.5, 0.5))
        btn.Model:SetLookAt((PrevMaxs + PrevMins) / 2)
    end
end

function PANEL:PerformLayout(w, h)
    self.Info:SetTall(96)
    self.Model:SetWide(w * .3)
    self.Equipment:SetWide(w * .45)
end

function PANEL:Paint(w, h)
    draw.RoundedBoxEx(16, 0, 0, w, h, Color(16, 16, 16), false, false, false, true)
end

vgui.Register("Arena.Main", PANEL, "DPanel")

net.Receive("Arena.Duel:DuelFound", function()
    local a = net.ReadEntity()
    local b = net.ReadEntity()

    if IsValid(asapArena.waitingPanel) then
        asapArena.waitingPanel:Remove()
    end

    local frame = vgui.Create("XeninUI.Frame")
    frame.SpawnTime = CurTime()
    frame.PaintOver = function(s, w, h)
        draw.RoundedBox(8, 0, h - 8, w * (1 - (CurTime() - s.SpawnTime) / 10), 8, Color(11, 212, 255))
        if (CurTime() - s.SpawnTime > 10) then
            s:Remove()
        end
    end
    frame:SetSize(600, 92)
    frame:SetPos(ScrW() / 2 - frame:GetWide() / 2)
    frame.A = vgui.Create("AvatarImage", frame)
    frame.A:SetSize(64, 64)
    frame.A:SetPos(8, 8)
    frame.A:SetPlayer(a, 64)
    frame.A.oPaint = frame.A.Paint
    frame.A.Paint = function(s, w, h)
        surface.SetDrawColor(a:GetNWBool("DuelReady", false) and Color(71, 248, 47) or Color(248, 161, 47))
        DisableClipping(true)
        surface.DrawRect(-4, -4, w + 8, h + 8)
        DisableClipping(false)
    end

    frame.B = vgui.Create("AvatarImage", frame)
    frame.B:SetSize(64, 64)
    frame.B:SetPos(frame:GetWide() - 80, 8)
    frame.B:SetPlayer(b, 64)
    frame.B.oPaint = frame.B.Paint
    frame.B.Paint = function(s, w, h)
        surface.SetDrawColor(b:GetNWBool("DuelReady", false) and Color(71, 248, 47) or Color(248, 161, 47))
        DisableClipping(true)
        surface.DrawRect(-4, -4, w + 8, h + 8)
        DisableClipping(false)
    end

    local lbl = Label((a == LocalPlayer() and b or a):Nick() .. " will be your opponent", frame)
    lbl:SetSize(frame:GetWide() - 96 * 2, 32)
    lbl:SetPos(96, 8)
    lbl:SetContentAlignment(5)
    lbl:SetFont("XeninUI.TextEntry")
    frame.Accept = vgui.Create("XeninUI.Button", frame)
    frame.Accept:SetSize(frame:GetWide() - 96 * 2 - 4, 32)
    frame.Accept:SetText("ACCEPT DUEL")
    frame.Accept:SetPos(96, 40)
    frame.Accept:SetColor(Color(68, 175, 54))
    frame.Accept.DoClick = function(s)
        net.Start("Arena.Duel:DuelFound")
        net.WriteBool(true)
        net.SendToServer()
        frame.AcceptDuel = true
    end
    frame.OnRemove = function(s)
        if (s.AcceptDuel) then return end
        net.Start("Arena.Duel:DuelFound")
        net.WriteBool(false)
        net.SendToServer()
    end

    asapArena.AcceptDuelFrame = frame
end)
/*
if IsValid(ARENA_F) then
    ARENA_F:Remove()
end
ARENA_F = vgui.Create("DFrame")
ARENA_F:SetSize(ScrW() * .75, ScrH() * .75)
ARENA_F:Center()
ARENA_F:MakePopup()
vgui.Create("Arena.Main", ARENA_F)
*/
hook.Add("OnPopulateF4Categories", "AddArenaPanel", function(pnl)
    pnl.ArenaC = vgui.Create("Arena.Main", pnl)
    pnl:AddCat("Arena", Material("asapf4/arena.png"), pnl.ArenaC, {Color(255, 225, 60), Color(255, 126, 0)})
end)

hook.Add("F4MenuOpen", "Arena.DismissF4", function()
    if (LocalPlayer():InArena()) then
        Derma_Query("Do you want to leave arena?", "Exit arena", "Yeah", function()
            net.Start("ASAP.Arena.Leave")
            net.SendToServer()
            LocalPlayer():SetNWBool("InArena", false)
        end, "No!")

        return false
    end
end)