------------------ Dashboard showing info
local PANEL = {}
local wide, height = ScrW() * 0.9 - 220, ScrH() * 0.9

function PANEL:Init()
    self.Col = Color(16, 16, 16)
    self:Dock(FILL)

    self.Paint = function(this, w, h)
        draw.RoundedBoxEx(16, 0, 0, w, h, Color(6, 6, 6), false, false, false, true)
    end

    self.Admins = {}
    self.Commands = vgui.Create("DPanel", self)
    self.Commands:Dock(BOTTOM)
    self.Commands:DockMargin(5, 0, 5, 5)
    self.Commands:SetTall(height * 0.5)
    self.Commands.Paint = function(this, w, h) end
    local cmds = util.JSONToTable(cookie.GetString("commands_list", "{}"))

    self.GeneralCommands = {
        {
            name = "Battlepass",
            command = "battlepass"
        },
        {
            name = "Gangs",
            command = "say !gangs"
        },
        {
            name = "Gobblegums",
            command = "say !gobblegums"
        },
        {
            name = "Skills",
            command = "say !skills"
        },
        {
            name = "Store",
            command = "say !store"
        }
    }

    self.RoleplayCommands = {
        {
            name = "Change Roleplay Name",
            command = "say /rpname {}"
        },
        {
            name = "Change Job Title",
            command = "say /job {}"
        },
        {
            name = "Drop Money",
            command = "say /dropmoney {}"
        },
        {
            name = "Drop Weapon",
            command = "say /dropweapon"
        },
        {
            name = "Give Money",
            command = "say /give {}"
        },
        {
            name = "Sell All Doors",
            command = "say /unownalldoors"
        },
    }

    self.CivilCommands = {
        {
            name = "Search Warrant",
            command = "say /warrant {}"
        },
        {
            name = "Make Wanted",
            command = "say /wanted {}"
        },
        {
            name = "Remove Wanted",
            command = "say /unwanted {}"
        }
    }

    self.MayorCommands = {
        {
            name = "Start Lockdown",
            command = "say /lockdown"
        },
        {
            name = "Stop Lockdown",
            command = "say /unlockdown"
        },
        {
            name = "Add Law",
            command = "say /addlaw {}"
        },
        {
            name = "Place Lawboard",
            command = "say /placelaws"
        },
        {
            name = "Broadcast Message",
            command = "say /broadcast {}"
        }
    }

    self.CustomCommands = {
    }

    for con, items in pairs(cmds) do
        if not self[con] then continue end

        for _, v in pairs(items) do
            table.insert(self[con], v)
        end
    end

    self:AddClassCommands("General", Color(92, 184, 92), "GeneralCommands")
    self:AddClassCommands("Roleplay", Color(91, 192, 222), "RoleplayCommands")
    self:AddClassCommands("Civil Protection", Color(66, 139, 202), "CivilCommands")
    self:AddClassCommands("Mayor", Color(217, 83, 79), "MayorCommands")
    self:AddClassCommands("Custom", Color(217, 79, 20604), "CustomCommands")
    self.StaffList = vgui.Create("DPanel", self)
    self.StaffList:SetSize(wide / 2 - 4, height / 2 - 48)
    self.StaffList:Dock(LEFT)
    self.StaffList:DockMargin(12, 12, 8, 5)

    self.StaffList.Paint = function(this, w, h)
        draw.RoundedBox(16, 0, 0, w, h, Color(26, 26, 26, 255))
        draw.SimpleText("Staff Online", "aMenuTitle", 12, 6, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        surface.SetDrawColor(200, 175, 0)
        surface.DrawRect(10, 40, w - 24, 2)
    end

    self.StaffList:DockPadding(0, 6, 0, 0)
    self.StaffList.List = vgui.Create("DScrollPanel", self.StaffList)
    self.StaffList.List:Dock(FILL)
    self.StaffList.List:DockMargin(10, 45, 10, 10)
    aMenu.PaintScroll(self.StaffList.List)
    self:UpdateStaff()

    timer.Create("aMenuStaffUpdate", 5, 0, function()
        if self:IsValid() then
            self:UpdateStaff()
        end
    end)

    self.JobsGraph = vgui.Create("DPanel", self)
    self.JobsGraph:SetSize(wide / 2 - 16, height / 2 - 48)
    self.JobsGraph:Dock(RIGHT)
    self.JobsGraph:DockPadding(0, 6, 0, 0)
    self.JobsGraph:DockMargin(12, 12, 10, 5)

    self.JobsGraph.Paint = function(this, w, h)
        draw.RoundedBox(16, 0, 0, w, h, Color(26, 26, 26, 255))
        draw.SimpleText("Job Distribution", "aMenuTitle", 12, 6, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        surface.SetDrawColor(180, 75, 150)
        surface.DrawRect(10, 39, w - 20, 2)
    end

    --draw.RoundedBox(2, 10, 37, w-20, 2, self.Col)
    local totalJobs = {}
    local toDraw = {}
    local curstart = 0

    for k, v in pairs(player.GetAll()) do
        if team.NumPlayers(v:Team()) ~= 0 and not totalJobs[v:Team()] then
            totalJobs[v:Team()] = team.NumPlayers(v:Team())
        end
    end

    local count = 255

    for k, v in pairs(totalJobs) do
        local numsections = 360 / #player.GetAll()
        local en = curstart + (v * numsections)
        local col = team.GetColor(k)

        table.insert(toDraw, {
            name = team.GetName(k),
            col = Color(col.r, col.g, col.b, 200),
            startang = curstart,
            endang = en
        })

        curstart = en
    end

    self.JobsGraph.Info = vgui.Create("DScrollPanel", self.JobsGraph)
    self.JobsGraph.Info:Dock(FILL)
    self.JobsGraph.Info:DockMargin(5, 45, 10, 10)

    self.JobsGraph.Info.Paint = function(this, w, h)
        draw.RoundedBox(16, 0, 0, w, h, Color(16, 16, 16))
    end

    aMenu.PaintScroll(self.JobsGraph.Info)

    for k, v in pairs(totalJobs) do
        local base = vgui.Create("DPanel", self.JobsGraph.Info)
        base:Dock(TOP)
        base:DockPadding(20, 0, 0, 0)
        base:DockMargin(5, 3, 5, 3)

        base.Paint = function(this, w, h)
            if aMenu.ChartFullColour then
                draw.RoundedBox(16, 0, 0, w, h, team.GetColor(k))
                draw.RoundedBox(16, 0, 0, w, h, Color(0, 0, 0, 40))
            else
                draw.RoundedBox(16, 0, 0, w, h, Color(41, 41, 41))
                draw.RoundedBox(16, 5, 5, 32, 32, team.GetColor(k))
            end
        end

        base.lbl = vgui.Create("DLabel", base)

        base.lbl.PerformLayout = function()
            base.lbl:SetAutoStretchVertical(true)
            base.lbl:SetText(team.GetName(k) .. " \nPlayers: " .. v)
            base.lbl:SizeToContentsY()
            base:SizeToChildren(false, true)
            base:SetTall(base:GetTall() + 3)
        end

        base.lbl:Dock(FILL)

        if aMenu.ChartFullColour then
            base.lbl:DockMargin(3, 2, 2, 2)
        else
            base.lbl:DockMargin(23, 2, 2, 2)
        end

        base.lbl:SetFont("aMenu19")
        base.lbl.Paint = function(this, w, h) end --draw.RoundedBox(4, 0, 0, w, h, Color(41, 41, 41))
    end
end

function PANEL:UpdateStaff()
    for k, v in pairs(self.Admins) do
        v:Remove() --Get rid of the old panels
    end

    table.Empty(self.Admins) --Get rid of those nulls

    --Start over
    for k, v in pairs(player.GetAll()) do
        if v:IsValid() and aMenu.StaffGroups[v:GetUserGroup()] then
            v.Base = vgui.Create("DPanel", self.StaffList.List)
            v.Base:Dock(TOP)
            v.Base:DockMargin(0, 0, 5, 6)
            v.Base:SetTall(54)
            surface.SetFont("aMenuJob")
            local pw, ph = surface.GetTextSize(v:Nick())
            local str = aMenu.StaffGroups[v:GetUserGroup()]

            v.Base.Paint = function(this, w, h)
                if not IsValid(v) then
                    this:Remove()

                    return
                end

                draw.RoundedBox(h / 2, 0, 0, w, h, this.Hovering and Color(46, 46, 46) or Color(36, 36, 36, 255))
                draw.SimpleText(v:Nick(), "aMenuJob", 52, 1, Color(210, 210, 210), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                surface.SetDrawColor(team.GetColor(v:Team()))
                surface.DrawRect(60, 28, w - 64, 2)
                draw.SimpleText(str, "aMenu20", 52, 30, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            end

            v.Base.Avatar = vgui.Create("AvatarCircleMask", v.Base)
            v.Base.Avatar:SetPlayer(v, 64)
            v.Base.Avatar:SetPos(4, 4)
            v.Base.Avatar:SetSize(46, 46)
            v.Base.Avatar:SetMaskSize(46 / 2)
            v.Base.Button = vgui.Create("DButton", v.Base)
            v.Base.Button:Dock(FILL)
            v.Base.Button:SetText("")

            v.Base.Button.Paint = function(s)
                if IsValid(v) and IsValid(v.Base) then
                    v.Base.Hovering = s:IsHovered()
                end
            end

            v.Base.Button.DoClick = function()
                local menu = DermaMenu(v.Base.Button)

                menu.HelpButton = menu:AddOption("Request Assistance", function()
                    RunConsoleCommand("say", "@Need help from an admin.")
                end)

                menu:AddOption("Steam Profile", function()
                    v:ShowProfile()
                end)

                menu:Open()
                menu.Paint = function() end

                menu.PaintOver = function(this, w, h)
                    draw.RoundedBox(4, 0, 0, w, h, Color(46, 46, 46, 255))

                    for k, v in pairs(this:GetCanvas():GetChildren()) do
                        local x, y = v:GetPos()

                        if v.Hovered then
                            draw.RoundedBox(2, x + 2, y + 2, w - 4, 18, aMenu.Color)
                        end

                        draw.SimpleText(v:GetText(), "aMenu14", x + 21, y + 4, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        surface.SetMaterial(v:GetText() == "Steam Profile" and aMenu.ProfileButton or aMenu.MessageButton)
                        surface.SetDrawColor(210, 210, 210)
                        surface.DrawTexturedRect(5, y + 6, 12, 12)
                    end
                end
            end

            table.insert(self.Admins, v.Base)
        end
    end
end

function PANEL:AddButton(v, colour, content, base)
    local b = vgui.Create("aMenuButton", base)
    b:Dock(TOP)
    b:SetTall(math.min(self.Commands:GetTall() / #self[content], 40))
    b:DockMargin(5, 5, 5, 5)
    b.Text = v.name
    b.Col = colour

    b.DoClick = function()
        local cmd = v.command

        if string.EndsWith(cmd, "{}") then
            Derma_StringRequest("aMenu string request", "Input", "", function(text)
                LocalPlayer():ConCommand(string.Replace(cmd, "{}", text))
            end, function(text)
                print("Cancelled input")
            end)
        else
            LocalPlayer():ConCommand(cmd)
        end
    end

    if not v.custom then return end

    b:SetColor(Color(56, 46, 26))
    b.OnMousePressed = function(s, m)
        if m ~= MOUSE_RIGHT then
            s:DoClick()
            return
        end

        local menu = DermaMenu(s)

        menu:AddOption("Remove command", function()
            local cmds = util.JSONToTable(cookie.GetString("commands_list", "{}"))
            cmds[content] = cmds[content] or {}

            for k, v in pairs(cmds[content]) do
                if v.name ~= s.Text then continue end
                table.remove(cmds[content], k)
                break
            end

            cookie.Set("commands_list", util.TableToJSON(cmds))
            s:Remove()
        end)

        menu:AddOption("Rename command", function()
            Derma_StringRequest("Edit Command", "Write a new command name", s.Text, function(text)
                local cmds = util.JSONToTable(cookie.GetString("commands_list", "{}"))
                cmds[content] = cmds[content] or {}

                for k, v in pairs(cmds[content]) do
                    if v.name ~= s.Text then continue end
                    v.name = text
                    break
                end

                cookie.Set("commands_list", util.TableToJSON(cmds))
                s.Text = text
            end, function(text)
                print("Cancelled input")
            end)
        end)

        menu:AddOption("Change command", function()
            Derma_StringRequest("Edit Command", "Write what the command will do", s.Text, function(text)
                local cmds = util.JSONToTable(cookie.GetString("commands_list", "{}"))
                cmds[content] = cmds[content] or {}

                for k, v in pairs(cmds[content]) do
                    if v.name ~= s.Text then continue end
                    v.command = text
                    break
                end

                cookie.Set("commands_list", util.TableToJSON(cmds))
            end, function(text)
                print("Cancelled input")
            end)
        end)

        menu:AddOption("Cancel", function() end)
        menu:Open()
    end
end

function PANEL:AddClassCommands(name, colour, content)
    self:InvalidateLayout(true)
    local base = vgui.Create("DPanel", self.Commands)
    base:SetWide(wide / 5 - 8)
    base:Dock(LEFT)
    base:DockMargin(8, 8, 0, 8)
    base:DockPadding(5, 46, 5, 5)

    base.Paint = function(this, w, h)
        draw.RoundedBox(16, 0, 0, w, h, Color(26, 26, 26))
        draw.SimpleText(name, "aMenuTitle", 12, 4, Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.RoundedBox(2, 10, 37, w - 20, 2, colour)
    end

    local add = vgui.Create("aMenuButton", base)
    add:SetText("+")
    add:Dock(BOTTOM)
    add:SetTall(40)
    add.Text = "+"
    add.Col = Color(255, 150, 0)

    add.DoClick = function()
        local popup = vgui.Create("XeninUI.Frame")
        popup:SetTitle("New command")
        popup:SetSize(400, 172)
        popup:Center()
        popup.Title = vgui.Create("XeninUI.TextEntry", popup)
        popup.Title:Dock(TOP)
        popup.Title:DockMargin(8, 8, 8, 8)
        popup.Title:SetPlaceholder("Command Name")

        popup.Desc = vgui.Create("XeninUI.TextEntry", popup)
        popup.Desc:Dock(TOP)
        popup.Desc:DockMargin(8, 0, 8, 8)
        popup.Desc:SetTall(32)
        popup.Desc:SetPlaceholder("What command should be ran on pressed")
        popup.Desc.textentry.OnKeyCode = function(s, key)
            if (key == KEY_ENTER) then
                popup.Send:DoClick()
            end
        end
        popup.Send = vgui.Create("XeninUI.Button", popup)
        popup.Send:Dock(FILL)
        popup.Send:DockMargin(8, 0, 8, 8)
        popup.Send:SetText("Send")

        popup.Send.DoClick = function()
            local title = popup.Title:GetText()
            local desc = popup.Desc:GetText()

            if title == "" or desc == "" then
                Derma_Message("Please fill in all fields", "Error", "Ok")

                return
            end

            self:AddButton({
                name = title,
                command = desc,
                custom = true
            }, colour, content, base)

            local cmds = util.JSONToTable(cookie.GetString("commands_list", "{}"))
            cmds[content] = cmds[content] or {}

            table.insert(cmds[content], {
                name = title,
                command = desc,
                custom = true
            })

            cookie.Set("commands_list", util.TableToJSON(cmds))
            popup:Remove()
        end

        popup:MakePopup()
    end

    local scroll = vgui.Create("XeninUI.ScrollPanel", base)
    scroll:DockMargin(0, 0, 0, 8)
    scroll:Dock(FILL)

    for k, v in pairs(self[content]) do
        self:AddButton(v, colour, content, scroll)
    end
end

vgui.Register("aMenuDashboard", PANEL, "DPanel")