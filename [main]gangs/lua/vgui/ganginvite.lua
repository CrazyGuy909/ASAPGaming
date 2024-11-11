local PANEL = {}
function PANEL:Init()
    self:SetSize(320, 168)
    self:SetPos(ScrW() - self:GetWide(), ScrH() / 2 - self:GetTall() / 2)
    self:SetTitle("Temporal Gang Invitation")
    self.Bottom = vgui.Create("Panel", self)
    self.Bottom:Dock(BOTTOM)
    self.Bottom:SetTall(32)
    self.Bottom:DockMargin(8, 8, 8, 8)

    self.Bottom.Yes = vgui.Create("XeninUI.Button", self.Bottom)
    self.Bottom.Yes:Dock(LEFT)
    self.Bottom.Yes:SetColor(Color(16, 16, 16))
    self.Bottom.Yes:DockMargin(0, 0, 4, 0)
    self.Bottom.Yes:SetText("Accept")
    self.Bottom.Yes:SetWide(self:GetWide() / 2)
    self.Bottom.Yes.DoClick = function()
        net.Start("Gangs.Invite")
        net.SendToServer()
        self:Remove()
    end

    self.Bottom.No = vgui.Create("XeninUI.Button", self.Bottom)
    self.Bottom.No:Dock(FILL)
    self.Bottom.No:SetColor(Color(16, 16, 16))
    self.Bottom.No:DockMargin(4, 0, 0, 0)
    self.Bottom.No:SetText("Decline")
    self.Bottom.No:SetWide(self:GetWide() / 2)
    self.Bottom.No.DoClick = function()
        self:Remove()
    end
end

function PANEL:Fill(data)
    self.Data = data
    --http.Fetch(data.Icon, function(iconBytes)
        --file.Write("temp_invitation.jpg", iconBytes)
      --  if (IsValid(self.Icon)) then
            --self.Icon = Material("../data/temp_invitation.jpg")
        --end
    --end)
end

function PANEL:PaintOver(w,h)
    draw.SimpleText(self.Data.Name, "Gangs.Medium", 12, 48, color_white)
    draw.SimpleText(self.Data.Tag, "Gangs.Medium", 12, 86, Color(150, 150, 150))

    if (self.Icon) then
        surface.SetMaterial(self.Icon)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(12, 52, 64, 64)
    end
end

vgui.Register("gangInvite", PANEL, "XeninUI.Frame")

local FORM = {}

function FORM:Init()
    self:SetSize(300, 320)
    self:Center()
    self:MakePopup()

    self:SetTitle("Join Form")

    self:SetBackgroundBlur(true)
end

function FORM:SetGang(tag)

    self:SetTitle(tag .. "'s Form")
    local top = Label("Behold! You're going to request us to accept you into our Gang, why would we do that?", self)
    top:DockMargin(8, 8, 8, 8)
    top:SetFont("XeninUI.TextEntry")
    top:SetWrap(true)
    top:SetContentAlignment(5)
    top:Dock(TOP)
    top:SetTall(52)

    local tx = vgui.Create("XeninUI.TextEntry", self)
    local accept = vgui.Create("XeninUI.Button", self)
    accept:Dock(BOTTOM)
    accept:SetTall(36)
    accept:SetText("Send my form")
    accept:DockMargin(8, 8, 8, 8)
    accept.DoClick = function()
        net.Start("Gangs.SendRequest")
        net.WriteString(tag)
        net.WriteString(tx:GetText())
        net.SendToServer()

        self:Remove()
    end

    tx:Dock(FILL)
    tx.textentry:SetMultiline(true)
    tx:DockMargin(8, 0, 8, 0)
end

vgui.Register("gangForm", FORM, "XeninUI.Frame")

local QUICK = {}
function QUICK:Init()
    self:SetSize(320, 168)
    self:SetPos(ScrW() - self:GetWide(), ScrH() / 2 - self:GetTall() / 2)
    self:SetTitle("Temp Gang Invitation")
    self.Bottom = vgui.Create("Panel", self)
    self.Bottom:Dock(BOTTOM)
    self.Bottom:SetTall(32)
    self.Bottom:DockMargin(8, 8, 8, 8)

    self.Bottom.Yes = vgui.Create("XeninUI.Button", self.Bottom)
    self.Bottom.Yes:Dock(LEFT)
    self.Bottom.Yes:SetColor(Color(16, 16, 16))
    self.Bottom.Yes:DockMargin(0, 0, 4, 0)
    self.Bottom.Yes:SetText("Accept")
    self.Bottom.Yes:SetWide(self:GetWide() / 2)
    self.Bottom.Yes.DoClick = function()
        net.Start("ASAP.Gangs:QuickInvite")
        net.WriteEntity(self.Target)
        net.WriteBool(true)
        net.SendToServer()
        self:Remove()
    end

    self.Bottom.No = vgui.Create("XeninUI.Button", self.Bottom)
    self.Bottom.No:Dock(FILL)
    self.Bottom.No:SetColor(Color(16, 16, 16))
    self.Bottom.No:DockMargin(4, 0, 0, 0)
    self.Bottom.No:SetText("Decline")
    self.Bottom.No:SetWide(self:GetWide() / 2)
    self.Bottom.No.DoClick = function()
        self:Remove()
    end
end

function QUICK:Fill(data)
    self.Data = data
end

function QUICK:Setup(target, name, icon)
    self:Fill({
        Tag = target:GetGang(),
        Name = name
    })

    self.Target = target
    self.iconPath = icon
    self:LoadAvatar()
end

function QUICK:LoadAvatar()
    if (not self.iconPath) then return end
    local link = string.Replace(self.iconPath, "https://i.imgur.com/", "")

    if file.Exists("gangs/avatar/" .. link, "DATA") then
        self.Icon = Material("../data/gangs/avatar/" .. link)
    else
        http.Fetch(self.iconPath, function(data)
            file.Write("gangs/avatar/" .. link, data)
            if not IsValid(self) then return end
            self.Icon = Material("../data/gangs/avatar/" .. link)
        end)
    end
end


function QUICK:PaintOver(w,h)
    draw.SimpleText(self.Data.Name, "Gangs.Medium", 86, 48, color_white)
    draw.SimpleText(self.Data.Tag, "Gangs.Medium", 86, 86, Color(150, 150, 150))

    if (self.Icon) then
        surface.SetMaterial(self.Icon)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(12, 52, 64, 64)
    end
end

vgui.Register("gangInvite.quick", QUICK, "XeninUI.Frame")

net.Receive("ASAP.Gangs:QuickInvite", function()
    local request = net.ReadEntity()
    local quick = vgui.Create("gangInvite.quick")
    quick:Setup(request, net.ReadString(), net.ReadString())
end)

net.Receive("Gangs.SendRequest", function()
    local b = net.ReadBool()
    if (!b) then
        Derma_Message("This Gang already got too many invitations, ask to an administrator clear some of those", "Can't send invitation", "Ok")
    end
end)

net.Receive("Gangs.Invite", function()
    local data = net.ReadTable()
    if IsValid(INVITE) then
        INVITE:Remove()
    end

    INVITE = vgui.Create("gangInvite")
    INVITE:Fill(data)
end)

