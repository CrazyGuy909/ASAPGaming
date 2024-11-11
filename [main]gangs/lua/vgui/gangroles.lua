local myGang = (asapgangs.myGang or {})
local PANEL = {}

function PANEL:Init()
    myGang = LocalPlayer():FindGang()
    local footer = vgui.Create("DPanel", self)
    footer:Dock(TOP)
    footer:SetTall(32)
    footer:DockMargin(12, 8, 16, 0)
    footer.Paint = function() end
    footer.Create = vgui.Create("XeninUI.Button", footer)
    footer.Create:Dock(RIGHT)
    footer.Create:SetText("Create Role")
    footer.Create:SetWide(128)

    if (!myGang) then return end

    footer.Create.DoClick = function(s, w, h)
        local role = vgui.Create("Gangs.Roles.Card", self.Roles)
        role:SetData("New role", {})
        role:OpenEdit()
    end

    self.Roles = vgui.Create("XeninUI.ScrollPanel", self)
    self.Roles:Dock(FILL)
    self.Roles:DockMargin(12, 8, 16, 16)
    self:PopulateRoles()
end

function PANEL:PopulateRoles()
    self.Roles:Clear()

    for k, v in pairs(myGang.Ranks or {}) do
        local role = vgui.Create("Gangs.Roles.Card", self.Roles)
        role:SetData(k, v)
    end
end

function PANEL:Paint(w, h)
    draw.SimpleText("Roles", "Gangs.Medium", 12, 8, color_white)
end

vgui.Register("Gangs.Roles", PANEL, "DPanel")
local ROLE = {}

function ROLE:Init()
    self:Dock(TOP)
    self:SetTall(72)
    self:DockMargin(0, 0, 0, 4)
end

local check = surface.GetTextureID("ui/gangs/check")

function ROLE:OpenEdit(isEdit, who)
    if (IsValid(EDIT_ROLE)) then
        EDIT_ROLE:Remove()
    end

    EDIT_ROLE = vgui.Create("XeninUI.Frame")
    EDIT_ROLE:SetSize(600, 600)
    EDIT_ROLE:Center()
    EDIT_ROLE:MakePopup()
    EDIT_ROLE:SetTitle("Editing " .. self.Name .. " Role")
    local cont = vgui.Create("DPanel", EDIT_ROLE)
    cont:Dock(FILL)
    cont:DockMargin(8, 8, 8, 8)
    cont.Paint = function(s, w, h) end
    local name = Label("Role's Name", cont)
    name:Dock(TOP)
    name:SetFont("XeninUI.TextEntry")
    EDIT_ROLE.Name = vgui.Create("XeninUI.TextEntry", cont)
    EDIT_ROLE.Name:Dock(TOP)
    EDIT_ROLE.Name:DockMargin(0, 0, 0, 8)
    EDIT_ROLE.Name.textentry:SetEditable(self.Name ~= "Administrator")
    EDIT_ROLE.Name:SetText(self.Name)
    EDIT_ROLE.NameCache = EDIT_ROLE.Name:GetText()
    local color = Label("Colour", cont)
    color:Dock(TOP)
    color:SetFont("XeninUI.TextEntry")
    color.Think = function() end
    local list = vgui.Create("DPanel", cont)
    list:Dock(TOP)
    list:DockMargin(0, 4, 0, 16)
    list:SetTall(42)
    list.Paint = function(s, w, h) end
    local idealWide = (EDIT_ROLE:GetWide() - #GANG_COLORS * 2) / (#GANG_COLORS) - 2

    for k, v in pairs(GANG_COLORS) do
        local option = vgui.Create("DButton", list)
        option:Dock(LEFT)
        option:SetWide(idealWide)
        option:DockMargin(0, 0, 2, 0)
        option:SetText("")
        option.Color = v

        option.Paint = function(s, w, h)
            s.Extra = Lerp(FrameTime() * 8, s.Extra or 0, s:IsHovered() and 0 or 8)
            draw.RoundedBox(8, 0, s.Extra, w, h - s.Extra * 2, v)

            if (self.SelectedColor == k) then
                surface.SetDrawColor(0, 0, 0)
                surface.SetTexture(check)
                surface.DrawTexturedRectRotated(w / 2, h / 2, 32, 32, 0)
            end
        end

        option.OnCursorEntered = function(s)
            EDIT_ROLE.Name:SetTextColor(s.Color)
        end

        option.OnCursorExited = function(s)
            EDIT_ROLE.Name:SetTextColor(GANG_COLORS[self.SelectedColor])
        end

        option.DoClick = function(s)
            self.SelectedColor = k
        end
    end

    local perms = Label("Permissions", cont)
    perms:Dock(TOP)
    perms:SetFont("XeninUI.TextEntry")
    local grid = vgui.Create("DIconLayout", cont)
    grid:Dock(TOP)
    grid:SetSpaceX(16)
    grid:DockMargin(0, 8, 0, 16)
    grid:SetSpaceY(16)
    grid:SetStretchWidth(true)
    grid:SetTall(400)

    if (self.Name == "Administrator") then
        grid.PaintOver = function(s, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 250))
            draw.SimpleText("You can't modify Administrator", "Gangs.Medium", w / 2, h / 2, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    grid.perms = {}
    local i = 0

    for k, v in pairs(GANG_PERMISSIONS) do
        i = i + 1
        local container = vgui.Create("DPanel", grid)
        container:DockPadding(0, 22, 0, 0)
        container:SetSize(182, 64)
        container.ID = (i % #GANG_COLORS + 1)

        container.Paint = function(s, w, h)
            --draw.RoundedBox(8, 0, 0, w, h, Color(36, 36, 36))
            draw.SimpleText(v, "XeninUI.TextEntry", 8, 8, color_white)
            draw.RoundedBox(8, 0, 0, w, h, ColorAlpha(GANG_COLORS[s.ID] or color_white, 25))
        end

        local check = vgui.Create("XeninUI.Checkbox", container)
        check:Dock(FILL)
        check:DockMargin(8, 8, 8, 8)
        check:SetMouseInputEnabled(self.Name ~= "Administrator")

        if (self.Data.Permissions) then
            check:SetState(self.Data.Permissions[k])
        end

        table.insert(grid.perms, {k, check})
    end

    local avatarPanel = vgui.Create("DPanel", cont)
    avatarPanel:Dock(TOP)
    avatarPanel:SetTall(72)
    avatarPanel:DockMargin(0, 0, 8, 0)
    avatarPanel.Paint = function() end
    local avatar = vgui.Create("XeninUI.CircledMask", avatarPanel)
    avatar:Dock(LEFT)
    avatar:SetWide(72)
    avatar:SetVertices(32)
    avatar:DockMargin(4, 0, 16, 0)

    avatar.Drawable = function(s, w, h)
        draw.RoundedBox(h / 2, 0, 0, w, h, Color(36, 36, 36))
        surface.SetDrawColor(color_white)

        if (self.Icon) then
            surface.SetMaterial(self.Icon)
            surface.DrawTexturedRect(0, 0, w, h)
        end
    end

    local icon = Label("Icon URL (Only Imgur)", avatarPanel)
    icon:Dock(TOP)
    icon:SetFont("XeninUI.TextEntry")
    EDIT_ROLE.URL = vgui.Create("XeninUI.TextEntry", avatarPanel)
    EDIT_ROLE.URL:Dock(FILL)
    EDIT_ROLE.URL:DockMargin(0, 8, 0, 0)
    EDIT_ROLE.URL:SetText(self.Data.Avatar or "")

    EDIT_ROLE.URL.OnEnter = function(s, val)
        if (string.find(val, "imgur", 1, true) and (string.EndsWith(val, ".png") or string.EndsWith(val, ".jpg" or string.EndsWith(val, ".jpeg")))) then
            http.Fetch(val, function(data)
                file.Write("gangs/roles/testing.jpg", data)
                self.Icon = Material("../data/gangs/roles/testing.jpg")
            end)
        else
            Derma_Message("Your link must come from imgur", "Error", "Okay")
        end
    end

    local foot = vgui.Create("DPanel", cont)
    foot:Dock(FILL)
    foot:DockMargin(4, 16, 8, 4)
    foot.Paint = function() end
    local save = vgui.Create("XeninUI.Button", foot)

    if (isEdit and self.Name ~= "Administrator") then
        local del = vgui.Create("XeninUI.Button", foot)
        del:Dock(RIGHT)
        del:SetWide(96)
        del:SetText("Delete")
        del:DockMargin(8, 0, 0, 0)

        del.DoClick = function(s)
            net.Start("Gangs.RemoveRole")
            net.WriteString(who)
            net.SendToServer()
            EDIT_ROLE:Remove()
        end

        save:Dock(FILL)
        save:SetWide(128)
    else
        save:Dock(FILL)
    end

    save:SetText("Save and exit")

    --[[


    if (self.Name == "Administrator") then
        grid.Cover = vgui.Create("DPanel", grid)
        grid.PerformLayout = function(s, w, h)
            s.Cover:SetSize(w,h)
        end 
    end
]]
    save.DoClick = function(s, w, h)
        if IsValid(EDIT_ROLE) then
            local perms = {}

            for k, v in pairs(grid.perms) do
                perms[v[1]] = v[2]:GetState()
            end

            local members = {}

            myGang.Ranks[EDIT_ROLE.Name:GetText()] = {
                Name = EDIT_ROLE.Name:GetText(),
                Color = self.SelectedColor,
                Members = members,
                Permissions = perms
            }

            net.Start("Gangs.NewRole")
            net.WriteString(EDIT_ROLE.Name:GetText())
            net.WriteInt(self.SelectedColor, 4)
            net.WriteTable(perms)
            net.WriteString(EDIT_ROLE.URL:GetText())
            net.WriteString(EDIT_ROLE.NameCache)
            net.SendToServer()
            EDIT_ROLE:Remove()
        end
    end
end

function ROLE:SetData(k, v)
    self.Data = v
    self.Name = k
    self.SelectedColor = v.Color or 1
    self.Circle = vgui.Create("XeninUI.CircledMask", self)
    self.Circle:Dock(LEFT)
    self.Circle:SetWide(72)
    self.Circle:SetVertices(32)
    self.Circle:DockMargin(8, 8, 8, 8)

    self.Circle.Drawable = function(s, w, h)
        if (self.Icon) then
            surface.SetDrawColor(color_white)
            surface.SetMaterial(self.Icon)
            surface.DrawTexturedRect(0, 0, w, h)
        end
    end

    file.CreateDir("gangs/roles/")
    if (v.Avatar) then
        local link = string.Replace(v.Avatar or "", "https://i.imgur.com/", "")

        if (file.Exists("gangs/roles/" .. link, "DATA")) then
            self.Icon = Material("../data/gangs/roles/" .. link)
        else
            http.Fetch(v.Avatar, function(data)
                file.Write("gangs/roles/" .. link, data)

                if IsValid(self) then
                    self.Icon = Material("../data/gangs/roles/" .. link)
                end
            end)
        end
    end

    self.Settings = vgui.Create("XeninUI.Button", self)
    self.Settings:Dock(RIGHT)
    self.Settings:SetWide(48)
    self.Settings:SetText("")
    self.Settings:DockMargin(8, 12, 16, 12)
    self.Settings:SetIcon("ui/gangs/edit")

    self.Settings.DoClick = function()
        self:OpenEdit(true, k)
    end
end

function ROLE:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, (self:IsHovered() or self:IsChildHovered()) and Color(36, 36, 36) or Color(26, 26, 26))

    if (self.Data) then
        draw.SimpleText(self.Name, "XeninUI.Navbar.Button", 84, 12, GANG_COLORS[self.SelectedColor])
        local count = table.Count(self.Data.Members or {})
        draw.SimpleText(count .. " Player" .. (count ~= 1 and "s" or ""), "XeninUI.TextEntry", 84, 38, Color(255, 255, 255, 25))
    end
end

vgui.Register("Gangs.Roles.Card", ROLE, "DPanel")