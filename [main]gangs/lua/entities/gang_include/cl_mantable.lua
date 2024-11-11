function ENT:ProcessNetworking(kind, data)
    if (kind == 0) then
        self.Ingredients = {}

        for k, v in pairs(data) do
            self.Ingredients[k] = v
        end
    elseif (kind == 1) then
        self.Ingredients[data[1]] = data[2]
    end
end

net.Receive("Manufacture:Message", function(l, ply) end)
local minibase = {}
minibase.Message = ""
minibase.Finished = false

if IsValid(gangActiveGamemode) then
    gangActiveGamemode:Remove()
end
gangActiveGamemode = nil

function minibase:Init()
    self:SetTitle("")
    self:SetDraggable(false)
    self:ShowCloseButton(false)
    self.Finished = false
    gangActiveGamemode = self
end

function minibase:SetupGamemode(data, time, diff)
end

function minibase:RequestData(machine, index)
    self.Machine = machine
    net.Start("Manufacture:Message")
    net.WriteString(self.Message)
    net.WriteEntity(self.Machine)
    net.WriteUInt(index, 4)
    net.SendToServer()
end

function minibase:EndGame()
    self.Finished = true

    timer.Simple(1, function()
        if IsValid(self) then
            self:Remove()
        end
    end)
end

vgui.Register("Manufacture:Minigame", minibase, "DFrame")
local PANEL = {}
PANEL.Counter = 0
PANEL.Message = "MinigameA"

function PANEL:Init()
    self:SetSize(592 - 16, 280)
    self:DockPadding(0, 0, 0, 0)
    self:Center()
    self:SetTitle("")
    self:SetDraggable(false)
    self:ShowCloseButton(false)
    self.Max = 1
    self.Life = 1
    self.Body = vgui.Create("DIconLayout", self)
    self.Body:Dock(FILL)
    self.Body:DockMargin(32, 32, 32, 32)
    self.Body:SetSpaceX(8)
    self.Body:SetSpaceY(8)
    self:MakePopup()
    gangActiveGamemode = self
end

local check = Material("battlepass/owned.png")

function PANEL:SetupGamemode(data, time, hard)
    self.Max = time
    self.Life = time

    timer.Simple(time, function()
        if IsValid(self) then
            self:EndGame()
        end
    end)

    for k, v in pairs(data) do
        local btn = vgui.Create("DButton", self.Body)
        btn:SetSize(96, 96)

        if (hard < 2) then
            btn:SetText(hard == 0 and v or string.char(64 + v))
        else
            btn.Symbol = v
            btn.sx = math.min(v, 5) * 12
            btn.sy = math.ceil(v / 5) * 12
            btn:SetText("")
        end

        btn:SetFont("Arena.Small")
        btn.State = 0

        btn.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(66, 66, 66))
            draw.RoundedBox(4, 2, 2, w - 4, h - 4, s.State == 0 and Color(200, 200, 200) or s.State == 1 and Color(108, 230, 52) or Color(255, 100, 0))

            if (s.State == 1) then
                surface.SetMaterial(check)
                surface.SetDrawColor(color_white)
                surface.DrawTexturedRectRotated(w / 2, h / 2, 32, 32, 0)

                return
            end

            if (s.Symbol) then
                for i = 1, s.Symbol do
                    draw.RoundedBox(4, w / 2 + 4 - (s.sx / 2) + (i - 1) % 5 * 12, h / 2 - s.sy / 2 - 4 + math.ceil(i / 5) * 10, 8, 8, Color(66, 66, 66))
                end
            end
        end

        btn.DoClick = function(s)
            if (self.Finished) then
                surface.PlaySound("buttons/button8.wav")

                return
            end

            if (v - self.Counter == 1) then
                s:SetText("")
                self.Counter = self.Counter + 1
                net.Start("Manufacture:Minigame")
                net.WriteInt(1, 4)
                net.WriteInt(self.Counter, 8)
                net.SendToServer()
                s.State = 1
                surface.PlaySound("buttons/blip1.wav")
            else
                net.Start("Manufacture:Message")
                net.WriteString("Failed")
                net.WriteEntity(self.Machine)
                net.SendToServer()
                s.State = 2
                self:EndGame()
            end
        end
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(66, 66, 66))
    draw.RoundedBox(8, 2, 2, w - 4, h - 4, Color(200, 200, 200))

    if (not self.Finished) then
        self.Life = math.max(self.Life - FrameTime(), 0)
    end

    draw.RoundedBox(4, 24, h - 32, w - 48, 16, Color(66, 66, 66))
    draw.RoundedBox(4, 24, h - 32, (w - 48) * (1 - self.Life / self.Max), 16, Color(223, 132, 29))
end

vgui.Register("Manufacture:MinigameA", PANEL, "Manufacture:Minigame")
local WORD = {}
WORD.Message = "MinigameB"

function WORD:Init()
    self.Life = 1
    self.Max = 1
    self.Clues = {}
    self:SetSize(400, 172)
    self:ShowCloseButton(false)
    self:Center()
    self.View = vgui.Create("DPanel", self)
    self.View:Dock(TOP)
    self.View:SetTall(48)
    self.View:DockMargin(16, 0, 16, 8)

    self.View.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(26, 26, 26))

        for k, v in pairs(self.Clues) do
            draw.RoundedBox(4, 32 + k * self.LetterWide, 4 + v.y, 32, 32, Color(255, 255, 255, 100))
            draw.SimpleText(v.c, "XeninUI.TextEntry", 32 + k * self.LetterWide + 16, 4 + v.y + 16, Color(0, 0, 0), 1, 1)
        end
    end

    local bot = vgui.Create("Panel", self)
    bot:Dock(BOTTOM)
    bot:SetTall(32)
    bot:DockMargin(16, 8, 16, 38)
    self.Send = vgui.Create("XeninUI.Button", bot)
    self.Send:Dock(RIGHT)
    self.Send:SetText("SEND")
    self.Send:SetRound(4)
    self.Send:DockMargin(4, 0, 0, 0)

    self.Send.DoClick = function()
        if (self.Finished) then return end
        net.Start("Manufacture:Minigame")
        net.WriteInt(2, 4)
        net.WriteString(self.TextBox:GetText())
        net.SendToServer()
    end

    self.Clear = vgui.Create("XeninUI.Button", bot)
    self.Clear:Dock(RIGHT)
    self.Clear:SetWide(32)
    self.Clear:SetText("X")
    self.Clear:SetRound(4)
    self.Clear:DockMargin(4, 0, 0, 0)

    self.Clear.DoClick = function(s)
        self.TextBox:SetText(self.InitialWord or "???")
        self.Offset = 0
        surface.PlaySound("buttons/button10.wav")

        for k, v in pairs(self.Characters) do
            v:SetTextColor(Color(36, 36, 36))
            v.Status = 0
        end
    end

    self.TextBox = vgui.Create("XeninUI.TextEntry", bot)
    self.TextBox:Dock(FILL)
    self:MakePopup()
end

function WORD:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(66, 66, 66))
    draw.RoundedBox(8, 2, 2, w - 4, h - 4, Color(200, 200, 200))

    if (not self.Finished) then
        self.Life = math.max(self.Life - FrameTime(), 0)
    end

    draw.RoundedBox(4, 24, h - 32, w - 48, 16, Color(66, 66, 66))
    draw.RoundedBox(4, 24, h - 32, (w - 48) * (1 - self.Life / self.Max), 16, Color(223, 132, 29))
end

function WORD:SetupGamemode(data, time, hard)
    self.Life = time
    self.Max = time
    self.LetterWide = (self.View:GetWide() / #data[1]) - 4
    self.FirstLetter = 0
    self.LastLetter = 0

    for k = 2, #data[2] do
        if (self.FirstLetter == 0 and data[2][k] == "_") then
            self.FirstLetter = k
        elseif (self.FirstLetter ~= 0 and data[2][k] == " ") then
            self.LastLetter = k - 1
        end
    end

    if (self.LastLetter == 0) then
        self.LastLetter = #data[2]
    end

    local i = 0
    self.Offset = 0
    self.Characters = {}

    for k, v in RandomPairs(string.Explode("", data[1])) do
        local btn = vgui.Create("DButton", self.View)
        btn:SetSize(32, 32)
        btn:SetPos(32 + i * self.LetterWide, 4 + math.cos((i / #data[1]) * math.pi * 2) * 4)
        btn:SetText(v)
        btn:SetFont("XeninUI.TextEntry")
        btn.Status = 0

        btn.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(66, 66, 66))
            draw.RoundedBox(4, 2, 2, w - 4, h - 4, s.Status == 0 and Color(200, 200, 200) or Color(228, 154, 27))
        end

        btn.Char = v
        btn.Offset = i

        btn.DoClick = function(s)
            if (s.Status == 1) then return end
            if (self.Offset > self.LastLetter - self.FirstLetter) then return end
            surface.PlaySound("buttons/lightswitch2.wav")
            s.Status = 1
            s:SetTextColor(color_white)
            local chain = string.Explode("", self.TextBox:GetText(), false)
            chain[self.FirstLetter + self.Offset] = s.Char
            self.TextBox:SetText(table.concat(chain))
            self.Offset = self.Offset + 1
        end

        table.insert(self.Characters, btn)
        i = i + 1
    end

    self.TextBox:SetText(data[2])
    self.InitialWord = data[2]
    self.TextBox:RequestFocus()
    self.TextBox:SetEditable(false)

    timer.Simple(time, function()
        if IsValid(self) then
            self:EndGame()
        end
    end)
end

vgui.Register("Manufacture:MinigameB", WORD, "Manufacture:Minigame")
local WIRE = {}
WIRE.Message = "MinigameC"

function WIRE:Init()
    if not originalDragNDrop then
        originalDragNDrop = hook.GetTable()["DrawOverlay"]["DragNDropPaint"]
        hook.GetTable()["DrawOverlay"]["DragNDropPaint"] = nil
    end

    self:SetSize(400, 500)
    self:ShowCloseButton(false)
    self:Center()
    self:DockPadding(0, 0, 0, 0)
    self:Center()
    self:SetTitle("")
    self:SetDraggable(false)
    self:ShowCloseButton(true)
    self.Max = 1
    self.Life = 1
    self:MakePopup()
    self.Inner = vgui.Create("DPanel", self)
    self.Inner:Dock(FILL)
    self.Inner:DockMargin(32, 32, 32, 48)

    self.Inner.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(16, 16, 16))
        draw.RoundedBox(8, 2, 2, w - 4, h - 4, Color(46, 46, 46))
    end

    self.MasterPolies = {}
    self:InvalidateLayout(true)
    local tall = (self.Inner:GetTall()) / 7
    self.Cabbles = {}

    for k = 1, 7 do
        local cbl = vgui.Create("Manufacture:Wire", self.Inner)
        cbl:Dock(TOP)
        cbl.Master = self
        cbl:SetTall(tall - 32)
        table.insert(self.Cabbles, cbl)
    end
end

function WIRE:OnRemove()
    if originalDragNDrop then
        hook.Add("DrawOverlay", "DragNDropPaint", originalDragNDrop)
        originalDragNDrop = nil
    end
end

function WIRE:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(66, 66, 66))
    draw.RoundedBox(8, 2, 2, w - 4, h - 4, Color(200, 200, 200))

    if (not self.Finished) then
        self.Life = math.max(self.Life - FrameTime(), 0)
    end

    draw.RoundedBox(4, 24, h - 32, w - 48, 16, Color(66, 66, 66))
    draw.RoundedBox(4, 24, h - 32, (w - 48) * (1 - self.Life / self.Max), 16, Color(223, 132, 29))
end

function WIRE:SetupGamemode(data, time, hard)
    self.Life = time
    self.Max = time
    local gap = 360 / ((1 - hard / 4) * 7)

    for k = 1, 7 do
        if (data[1][k]) then
            self.Cabbles[k]:Setup(k, HSVToColor(gap * data[1][k], 1, .7), HSVToColor(gap * data[2][k], 1, .7))
        else
            self.Cabbles[k]:Setup(k, Color(46, 46, 46), Color(46, 46, 46))
        end
    end

    timer.Simple(time, function()
        if IsValid(self) then end --self:EndGame()
    end)
end

vgui.Register("Manufacture:MinigameC", WIRE, "Manufacture:Minigame")
local CAB = {}
CAB.ColorA = Color(255, 255, 255)
CAB.ColorB = Color(255, 255, 255)
local deg = surface.GetTextureID("gui/center_gradient")
local wire = surface.GetTextureID("rebel1324/debris/particle_debris_burst_001")

function CAB:Init()
    self:DockMargin(0, 16, 0, 16)
    self.Left = vgui.Create("DButton", self)
    self.Left:SetWide(48)
    self.Left:Dock(LEFT)
    self.Left:SetText("")
    self.Left:Droppable("RightPlug")
    self.Left.Plug = true
    self.IsLit = false

    self.Left:Receiver("LeftPlug", function(s, tbl, drop)
        if (not drop) then return end
        local drag = tbl[1]

        if IsValid(drag) then
            self:Plug(s, drag)
        end
    end)

    self.Left.Paint = function(s, w, h)
        if (not s:IsDragging() and not self.IgnoreWire) then
            surface.SetTexture(wire)
            surface.SetDrawColor(223, 138, 37)
            surface.DrawTexturedRect(w - 32, 0, 32, h)
        end

        surface.SetDrawColor(self.ColorA)
        surface.DrawRect(0, 0, w - 16, h)
        surface.SetDrawColor(Color(255, 255, 255, 50))
        surface.SetTexture(deg)
        surface.DrawTexturedRectRotated(w / 2 - 8, h / 2, h, w - 16, 90)
    end

    self.Right = vgui.Create("DButton", self)
    self.Right:SetWide(48)
    self.Right.IsRight = true
    self.Right:Dock(RIGHT)
    self.Right:SetText("")
    self.Right.Plug = true
    self.Right:Droppable("LeftPlug")

    self.Right.Paint = function(s, w, h)
        if (not s:IsDragging() and not self.IgnoreWire) then
            surface.SetTexture(wire)
            surface.SetDrawColor(223, 138, 37)
            surface.DrawTexturedRect(0, 0, 32, h)
        end

        surface.SetDrawColor(self.ColorB)
        surface.DrawRect(16, 0, w - 16, h)
        surface.SetDrawColor(Color(255, 255, 255, 50))
        surface.SetTexture(deg)
        surface.DrawTexturedRectRotated(w / 2 - 8 + 16, h / 2, h, w - 16, 90)
    end

    self.Right:Receiver("RightPlug", function(s, tbl, drop)
        if (not drop) then return end
        local drag = tbl[1]

        if IsValid(drag) then
            self:Plug(drag, s)
        end
    end)
end

function CAB:Setup(id, a, b)
    self.ID = id
    self.ColorA = a
    self.ColorB = b
    self.Left.ID = id
    self.Right.ID = id
end

local barber = 16

function CAB:Plug(left, right)
    if (left:GetParent() ~= self) then
        left:GetParent():Plug(left, right)

        return
    end

    net.Start("Manufacture:Minigame")
    net.WriteInt(3, 4)
    net.WriteUInt(left.ID, 4)
    net.WriteUInt(right.ID, 4)
    net.SendToServer()
    local ox, uy = left:GetParent():GetPos()
    local oy = 14
    ox = ox + 32
    local fx, fy = right:GetParent():GetPos()
    fy = fy - uy + 14
    fx = self:GetWide() - 32
    self.ForceColor = left:GetParent().ColorA
    self.ForcePoly = {}
    self.IgnoreWire = true

    for k = 0, barber do
        local px = Lerp(k / barber, ox, fx)
        local py = Lerp(Lerp(k / barber, k, barber) / barber, oy, fy)
        k = k + 1
        local nx = Lerp(k / barber, ox, fx)
        local ny = Lerp(Lerp(k / barber, k, barber) / barber, oy, fy)
        k = k - 1
        local poly = {}

        poly = {
            {
                x = px,
                y = py - 14,
                u = 1,
                v = 0
            },
            {
                x = nx,
                y = ny - 14,
                u = 1,
                1
            },
            {
                x = nx,
                y = ny + 14,
                u = 0,
                1
            },
            {
                x = px,
                y = py + 14,
                u = 0,
                0
            },
        }

        table.insert(self.ForcePoly, poly)
    end
end

CAB.DragColor = color_white

function CAB:Paint(w, h)
    local ox, oy = 0, 0
    local isDragging = false
    local isRight = false
    local drag

    if (self.Left:IsDragging()) then
        ox, oy = 32, h / 2
        self.DragColor = self.ColorA
        isDragging = true
        drag = self.Left
    end

    if (self.Right:IsDragging()) then
        ox, oy = w - 32, h / 2
        self.DragColor = self.ColorB
        drag = self.Right
        isDragging = true
        isRight = true
    end

    if (self.IsLit) then
        draw.SimpleText("HERE", nil, 16, 16)
    end

    if not self.IsRight and not isDragging then
        if (not self.ForcePoly) then return end
        DisableClipping(true)

        for k, poly in pairs(self.ForcePoly) do
            surface.SetDrawColor(self.ForceColor)
            draw.NoTexture()
            surface.DrawPoly(poly)
            surface.SetDrawColor(Color(255, 255, 255, 100))
            surface.SetTexture(deg)
            surface.DrawPoly(poly)
        end

        DisableClipping(false)

        return
    end

    if (self.ForcePoly) then return end
    local mx, my = gui.MousePos()
    local cble = vgui.GetHoveredPanel()

    if (IsValid(drag) and cble.Plug and drag.IsRight ~= cble.IsRight) then
        mx, my = cble:LocalToScreen(16, 14)
    end

    local fx, fy = self:ScreenToLocal(mx, my)
    DisableClipping(true)
    surface.SetDrawColor(self.DragColor)
    surface.DrawLine(ox, oy, fx, fy)

    for k = 0, barber do
        local px = Lerp(k / barber, ox, fx)
        local py = Lerp(Lerp(k / barber, k, barber) / barber, oy, fy)
        k = k + 1
        local nx = Lerp(k / barber, ox, fx)
        local ny = Lerp(Lerp(k / barber, k, barber) / barber, oy, fy)
        k = k - 1
        local poly = {}

        if isRight then
            poly = {
                {
                    x = nx,
                    y = ny - 14,
                    u = 1,
                    v = 0
                },
                {
                    x = px,
                    y = py - 14,
                    u = 1,
                    1
                },
                {
                    x = px,
                    y = py + 14,
                    u = 0,
                    1
                },
                {
                    x = nx,
                    y = ny + 14,
                    u = 0,
                    0
                },
            }
        else
            poly = {
                {
                    x = px,
                    y = py - 14,
                    u = 1,
                    v = 0
                },
                {
                    x = nx,
                    y = ny - 14,
                    u = 1,
                    1
                },
                {
                    x = nx,
                    y = ny + 14,
                    u = 0,
                    1
                },
                {
                    x = px,
                    y = py + 14,
                    u = 0,
                    0
                },
            }
        end

        surface.SetDrawColor(self.DragColor)
        draw.NoTexture()
        surface.DrawPoly(poly)
        surface.SetDrawColor(Color(255, 255, 255, 100))
        surface.SetTexture(deg)
        surface.DrawPoly(poly)
    end

    DisableClipping(false)
end

vgui.Register("Manufacture:Wire", CAB, "Panel")
local CARD = {}
CARD.Message = "MinigameD"

function CARD:Init()
    self:SetSize(600, 632)
    self:ShowCloseButton(false)
    self:Center()
    self:DockPadding(0, 10, 0, 0)
    self:Center()
    self:SetTitle("")
    self:SetDraggable(false)
    self:ShowCloseButton(true)
    self.Max = 1
    self.Life = 1
    self:MakePopup()
    self.Container = vgui.Create("DPanel", self)
    self.Container:Dock(FILL)
    self.Container:DockMargin(24, 24, 24, 42)

    self.Container.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(16, 16, 16))
        draw.RoundedBox(8, 2, 2, w - 4, h - 4, Color(46, 46, 46))
    end

    self.Inner = vgui.Create("DIconLayout", self.Container)
    self.Inner:Dock(FILL)
    self.Inner:SetSpaceX(8)
    self.Inner:SetSpaceY(8)
    self.Inner:DockMargin(8, 8, 0, 0)
end

function CARD:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(66, 66, 66))
    draw.RoundedBox(8, 2, 2, w - 4, h - 4, Color(200, 200, 200))

    if (not self.Finished) then
        self.Life = math.max(self.Life - FrameTime(), 0)
    end

    draw.RoundedBox(4, 24, h - 32, w - 48, 16, Color(66, 66, 66))
    draw.RoundedBox(4, 24, h - 32, (w - 48) * (1 - self.Life / self.Max), 16, Color(223, 132, 29))
end

local img = Material("asap_gumballs/logo1.png")

function CARD:SetupGamemode(data, time, hard)
    self.Life = time
    self.Max = time
    self.FirstSelect = false
    self.CanUse = true
    local w, h = self.Inner:GetSize()
    local size = table.Count(data)
    local cardSize = w / (3 + hard) - 8

    for k = 1, size do
        local btn = vgui.Create("Minigame:Card", self.Inner)
        btn:DockMargin(8, 8, 0, 0)
        btn:SetSize(cardSize, cardSize)
        btn:SetText("")
        btn:Install(data[k])
        btn.Controller = self
    end
end

vgui.Register("Manufacture:MinigameD", CARD, "Manufacture:Minigame")
local NAI = {}

local items = {
    [1] = 64,
    [2] = 157,
    [3] = 195,
    [4] = 313,
    [5] = 418,
    [6] = 641,
    [7] = 893,
    [8] = 1091,
    [9] = 1137,
    [10] = 1176,
    [11] = 1181,
    [12] = 1163,
    [13] = 1154
}

function NAI:Init()
    self.FlipStatus = false
    self.IsActive = true
    self.Progress = 0
    self.InAnimation = false
    self.ID = -1
end

function NAI:Install(id)
    self.ID = id
    local item = BU3.Items.Items[items[id]]
    self.Image = BU3.UI.Elements.IconView(item.iconID, item.color, self)
    self:InvalidateLayout(true)
    local w, h = self:GetSize()
    self.Image:SetSize(w, h)
    self.Image:SetMouseInputEnabled(false)
    self.Image:SetPaintedManually(true)
end

function NAI:DoClick()
    if (not self.IsActive) then return end
    if (not self.Controller.CanUse) then return end

    if (not IsValid(self.Controller.Picked)) then
        self.Controller.Picked = self
    elseif (IsValid(self.Controller.Picked)) then
        if (self.Controller.Picked.ID ~= self.ID) then
            self.Controller.CanUse = false
            timer.Simple(.25, function()
                surface.PlaySound("punchies/" .. math.random(1, 5) .. ".mp3")
            end)
            timer.Simple(1, function()
                if IsValid(self) then
                    self.Controller.Picked:Flip()
                    self:Flip()
                    self.Controller.Picked = nil
                end

                if (IsValid(self.Controller)) then
                    self.Controller.CanUse = true
                end
            end)
        else
            self.Controller.Picked = nil
            timer.Simple(.5, function()
                surface.PlaySound("botw/error.wav")
                net.Start("Manufacture:Minigame")
                net.WriteInt(4, 4)
                net.SendToServer()
            end)
        end
    end

    self.IsActive = false
    self.FlipStatus = false
    self.InAnimation = 1
    self.Progress = 0
    self.MustReturn = false
    surface.PlaySound("cw/switch1.wav")
end

function NAI:Paint(w, h)
    if (self.InAnimation) then
        self.Progress = math.Approach(self.Progress, self.InAnimation, FrameTime() * 10)

        if (self.Progress == self.InAnimation) then
            self.InAnimation = false
            self.MustReturn = true
        end
    elseif (self.MustReturn) then
        self.Progress = math.Approach(self.Progress, 0, FrameTime() * 10)

        if (self.Progress == 0) then
            self.MustReturn = false
            self.FlipStatus = not self.FlipStatus
        end
    end

    draw.NoTexture()
    surface.SetDrawColor(Color(26, 26, 26))
    surface.DrawTexturedRectRotated(w / 2, h / 2, w * (1 - self.Progress), h, 0)

    if (not self.FlipStatus) then
        surface.SetMaterial(img)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRectRotated(w / 2, h / 2, h * .5 * (1 - self.Progress), h * .5, 0)
    else
        surface.SetDrawColor(Color(96, 96, 96))
        surface.DrawTexturedRectRotated(w / 2, h / 2, w * (1 - self.Progress), h, 0)
        surface.SetDrawColor(Color(26, 26, 26))
        surface.DrawTexturedRectRotated(w / 2, h / 2, w * (1 - self.Progress) - 2, h - 2, 0)
        self.Image:PaintManual()
        self.Image:SetWide(w * (1 - self.Progress))
    end
end

function NAI:Flip(b)
    self.FlipStatus = true
    self.InAnimation = 0
    self.Progress = 1
    self.MustReturn = false
    self.IsActive = true
end

vgui.Register("Minigame:Card", NAI, "DButton")

net.Receive("Manufacture:Minigame", function()
    local id = net.ReadUInt(4)

    if (id == 1) then
        local isFill = net.ReadBool()

        if (isFill) then
            local data = {}

            for k = 1, 10 do
                table.insert(data, net.ReadInt(8))
            end

            gangActiveGamemode:SetupGamemode(data, net.ReadInt(8), net.ReadInt(3))
        else
            local finished = net.ReadBool()

            if (finished) then
                gangActiveGamemode:EndGame()
            end
        end
    elseif (id == 2) then
        local isFill = net.ReadBool()

        if (isFill) then
            local clues = net.ReadString()
            local word = net.ReadString()
            local time = net.ReadInt(8)
            local diff = net.ReadInt(3)

            gangActiveGamemode:SetupGamemode({clues, word}, time, diff)
        else
            local finished = net.ReadBool()
            gangActiveGamemode:EndGame()
        end
    elseif (id == 3) then
        local isFill = net.ReadBool()

        if (isFill) then
            local cabbles = {{}, {}}

            for k = 1, net.ReadUInt(4) do
                table.insert(cabbles[1], net.ReadUInt(4))
                table.insert(cabbles[2], net.ReadUInt(4))
            end

            gangActiveGamemode:SetupGamemode(cabbles, net.ReadInt(8), net.ReadInt(3))
        else
            local succ = net.ReadBool()
            local finish = net.ReadBool()

            if (finish or not succ) then
                gangActiveGamemode:EndGame()
            end
        end
    elseif (id == 4) then
        local isFill = net.ReadBool()

        if (isFill) then
            local limit = net.ReadUInt(6)
            local ids = {}

            for k = 1, limit do
                ids[k] = net.ReadUInt(6)
            end

            local time = net.ReadUInt(6)
            gangActiveGamemode:SetupGamemode(ids, time, net.ReadUInt(3))
        end
    elseif (id == 8) then
        gangActiveGamemode:SetMouseInputEnabled(false)
        timer.Simple(3, function()
            if not IsValid(gangActiveGamemode) then return end
            gangActiveGamemode:Remove()
        end)
    end
end)
