concommand.Add("store", function()
    if (LocalPlayer():InArena()) then return end
    local frame = vgui.Create("Store.Frame")
    frame:SetSize(XeninUI.Frame.Width, XeninUI.Frame.Height)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle("Galaxium Store")
end)

local PANEL = {}

function PANEL:Init()
    self:SetSize(600, 228)
    self:SetTitle("Send Tokens")
    self:Center()
    self:MakePopup()
    self.Avatar = vgui.Create("AvatarImage", self)
    self.Avatar:Dock(LEFT)
    self.Avatar:SetPlayer(LocalPlayer(), 128)
    self.Avatar:SetWide(148)
    self.Avatar:DockMargin(16, 16, 16, 16)
    self.Select = vgui.Create("XeninUI.Button", self)
    self.Select:Dock(TOP)
    self.Select:DockMargin(0, 16, 16, 16)
    self.Select:SetText("Pick a player")

    self.Select.DoClick = function(s)
        local sel = PlayerSelector()

        sel.OnSelect = function(s, ply)
            self.Player = ply
            self.Select:SetText(ply:Nick())
            self.Avatar:SetPlayer(ply, 128)
        end

        sel:Open()
    end

    local lbl = Label("You have " .. LocalPlayer():GetStoreCredits(), self)
    lbl:SetFont("Arena.Small")
    lbl:SetTextColor(color_white)

    if (LocalPlayer()._oldCredits) then
        lbl:SetText("You have " .. LocalPlayer():GetStoreCredits() .. " (" .. LocalPlayer()._oldCredits .. " non tradable)")
    end

    lbl:Dock(TOP)
    lbl:DockMargin(0, 0, 0, 16)
    self.Credits = vgui.Create("XeninUI.TextEntry", self)
    self.Credits:Dock(TOP)
    self.Credits:DockMargin(0, 0, 16, 0)
    self.Credits:SetPlaceholder("Insert tokens to send")
    self.Credits:SetNumeric(true)
    self.Credits:SetUpdateOnType(true)

    self.Credits.OnValueChange = function(s, val)
        if (not tonumber(val)) then return end

        if (tonumber(val) > LocalPlayer():GetStoreCredits()) then
            s:SetText(LocalPlayer():GetStoreCredits())
        elseif (tonumber(val) < 0) then
            s:SetText(0)
        end
    end

    self.Send = vgui.Create("XeninUI.Button", self)
    self.Send:Dock(FILL)
    self.Send:DockMargin(0, 16, 16, 16)
    self.Send:SetText("Send Tokens")

    self.Send.DoClick = function()
        if (not self.Player) then
            Derma_Message("You have to select a player first!", "Error")

            return
        end

        local val = tonumber(self.Credits:GetText())
        if not val then return end

        if (val <= 0) then
            Derma_Message("You can only GIVE tokens, not receive numb numb", "Error")

            return
        end

        if (val < 600) then
            Derma_Message("You can only trade a minimum of 600 tokens!", "Error")

            return
        end

        if (math.Round(val / 100) ~= val / 100) then
            local fml = math.ceil(val / 100 - 1) * 100
            Derma_Message("You've introduce an invalid amount\nNearest valid value is " .. fml .. " or " .. (fml + 100), "Error")

            return
        end

        if (val > LocalPlayer():GetStoreCredits()) then
            Derma_Message("You don't have that many tradable tokens", "Error")

            return
        end

        Derma_Query("Are you sure do you want to send " .. val .. " tokens to player " .. self.Player:Nick() .. "?\nThis cannot be reversed due any means", "Sending tokens", "Yeah", function()
            net.Start("Store.TradePoints")
            net.WriteInt(val, 16)
            net.WriteEntity(self.Player)
            net.SendToServer()
            self:Remove()
        end, "No")
    end
end

vgui.Register("XeninUI.Trade", PANEL, "XeninUI.Frame")

if IsValid(TR_) then
    TR_:Remove()
end