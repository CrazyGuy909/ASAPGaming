------------------ Jobs panel
local PANEL = {}
PANEL.FavoriteJobs = {}
local search = Material("xenin/search.png")
LOADED_VIP = nil
function PANEL:Init()
    self:Dock(FILL)
    self.Num = 1
    self.Contents = {}
    self.Categories = {}
    
    local ckie = cookie.GetString("FavoriteCustomJobs", nil)
    if (ckie == nil) then
        self.FavoriteJobs = {TEAM_THIEF, TEAM_MINER, TEAM_HITMAN}
    else
        self.FavoriteJobs = util.JSONToTable(ckie)
    end
    if (LOADED_VIP) then return end
    
    for k, v in pairs(RPExtraTeams) do
        if (v.category ~= "Private Jobs") then continue end

        if (v.customCheck(LocalPlayer())) then
            if not LOADED_VIP then
                LOADED_VIP = {}
            end
            LOADED_VIP[k] = true
        end
    end

end

function PANEL:PerformLayout(w, h)
    if (self.Search) then
        self.Search:SetPos(w * .66 + 56 - self.Search:GetWide(), 8)
    end
end

function PANEL:SetContents(contents)
    self.Contents = contents
    self:Populate()
    self.Search = vgui.Create("DPanel", self)
    self.Search:SetSize(64, 32)
    self.Search:SetCursor("hand")
    self.Search.State = false
    self.Search.TextEntry = vgui.Create("DTextEntry", self.Search)
    self.Search.TextEntry:Dock(FILL)
    self.Search.TextEntry:DockMargin(4, 0, 32, 0)
    self.Search.TextEntry:SetFont("XeninUI.TextEntry")
    self.Search.TextEntry:SetUpdateOnType(true)

    self.Search.TextEntry.Paint = function(s, w, h)
        s:DrawTextEntryText(Color(255, 255, 255, 200), Color(225, 150, 0), color_white)
    end

    self.Search.TextEntry:SetVisible(false)

    self.Search.TextEntry.OnValueChange = function(s, val)
        self:DoSearch(val)
    end

    self.Search.OnMousePressed = function(s)
        s:Stop()
        s.State = not s.State
        s:SizeTo(s.State and 228 or 64, 32, .5, 0, .3)

        if (not s.State) then
            s.TextEntry:SetText("")
            self:DoSearch("")
        end

        s.TextEntry:SetVisible(s.State)
    end

    self.Search.Paint = function(s, w, h)
        draw.RoundedBox(16, 0, 0, w, h, Color(26, 26, 26))
        surface.SetDrawColor(color_white)
        surface.SetMaterial(search)
        surface.DrawTexturedRectRotated(w - 14, h / 2, 24, 24, 0)
    end
end

function PANEL:Paint(w, h)
end

local degree = surface.GetTextureID("vgui/gradient-d")

function PANEL:Populate()
    local wide, height = ScrW() * 0.8 - 220, ScrH() * 0.8 - 55

    if self.Contents[1].name == team.GetName(LocalPlayer():Team()) then
        self.Selected = self.Contents[2]
    else
        self.Selected = self.Contents[1]
    end

    self.Preview = vgui.Create("DPanel", self)
    self.Preview:Dock(RIGHT)
    self.Preview:SetWide((wide * 0.33) - 15) --thank mr scrollbar

    self.Preview.Paint = function(this, w, h)
        draw.RoundedBoxEx(16, 0, 0, w, h, Color(16, 16, 16, 255), false, false, false, true)
    end

    self.Preview.Model = vgui.Create("DModelPanel", self.Preview)
    self.Preview.Model:Dock(TOP)
    self.Preview.Model:SetSize(self.Preview:GetWide(), height * 0.4)
    self.Preview.Model:SetCamPos(Vector(55, 45, 57))
    self.Preview.Model:SetLookAt(Vector(0, 0, 57))
    self.Preview.Model.OPaint = self.Preview.Model.Paint

    self.Preview.Model.Paint = function(s, w, h)
        s:OPaint(w, h)
        surface.SetTexture(degree)
        surface.SetDrawColor(16, 16, 16)
        surface.DrawTexturedRect(0, h - 64, w, 64)
    end

    self.Preview.Model:SetFOV(35)
    self.Preview.Model:SetMouseInputEnabled(false)

    self.Preview.Model.LayoutEntity = function(ent)
        ent:RunAnimation()
    end

    self.Preview.Title = vgui.Create("DPanel", self.Preview)
    self.Preview.Title:Dock(TOP)
    self.Preview.Title:DockMargin(5, 12, 5, 5)
    self.Preview.Title:SetTall(32)

    self.Preview.Title.Paint = function(this, w, h)
        local tx, ty = self.Preview.Title:LocalToScreen(0, 0)
        local clr = team.GetColor(self.Selected.team)
        draw.SimpleText(self.Selected.name, "aMenuTitle", w / 2, 0, Color(clr.r * 1.7, clr.g * 1.7, clr.b * 1.7), TEXT_ALIGN_CENTER)
        render.SetScissorRect(tx, ty + h / 1.7, tx + w, ty + h, true)
        draw.SimpleText(self.Selected.name, "aMenuTitle", w / 2, 0, clr, TEXT_ALIGN_CENTER)
        render.SetScissorRect(0, 0, 0, 0, false)
    end

    self.Preview.Title.PerformLayout = function()
        self.Preview.Title:SetText(self.Selected.name)
    end

    self.Preview.Description = vgui.Create("DScrollPanel", self.Preview)
    self.Preview.Description:Dock(TOP)
    self.Preview.Description:DockMargin(5, 0, 5, 5)
    self.Preview.Description:SetTall(height * 0.4)
    self.Preview.Description.Paint = function(this, w, h) end
    self.Preview.Description.Text = vgui.Create("DLabel", self.Preview.Description)
    self.Preview.Description.Text:Dock(TOP)
    self.Preview.Description.Text:DockMargin(5, 5, 5, 5)
    self.Preview.Description.Text:SetTall(height * 0.4)
    self.Preview.Description.Text:SetFont("aMenu14")
    self.Preview.Description.Text:SetWrap(true)
    self.Preview.Description.Text:SetContentAlignment(8)

    self.Preview.Description.Text.PerformLayout = function()
        local text = ""

        if self.Selected.weapons and self.Selected.weapons[1] and aMenu.DisplayWeapons then
            --functions for getting the weapon names from the job table from the original DarkRP F4 menu
            local getWepName = fn.FOr{fn.FAnd{weapons.Get, fn.Compose{fn.Curry(fn.GetValue, 2)("PrintName"), weapons.Get}}, fn.Id}
            local getWeaponNames = fn.Curry(fn.Map, 2)(getWepName)
            local weaponString = fn.Compose{fn.Curry(fn.Flip(table.concat), 2)("\n"), fn.Curry(fn.Seq, 2)(table.sort), getWeaponNames, table.Copy}
            self.Preview.Description.Text:SetText(self.Selected.description .. "\n\n Additional Equipment: \n" .. weaponString(self.Selected.weapons))
        else
            self.Preview.Description.Text:SetText(self.Selected.description)
        end

        self.Preview.Description:SizeToContents()
    end

    self.Preview.Control = vgui.Create("DPanel", self.Preview)
    self.Preview.Control:Dock(BOTTOM)
    self.Preview.Control:SetTall(48)
    self.Preview.Control:DockMargin(5, 0, 5, 8)
    self.Preview.Control.Paint = function(this, w, h) end
    self.Preview.Control.Left = vgui.Create("aMenuButton", self.Preview.Control)
    self.Preview.Control.Left:Dock(LEFT)
    self.Preview.Control.Left.Text = "⇦"
    self.Preview.Control.Left:DockMargin(5, 5, 5, 5)
    self.Preview.Control.Left:SetWide(self.Preview:GetWide() * 0.15 - 10)

    self.Preview.Control.Left.DoClick = function()
        self.Num = self.Num - 1

        if self.Num < 1 then
            self.Num = 1
        end

        if self.Num == #self.Selected.model then return end
        self.Preview.Model:SetModel(self.Selected.model[self.Num])
        self.Preview.Model:InvalidateLayout()
    end

    self.Preview.Control.Right = vgui.Create("aMenuButton", self.Preview.Control)
    self.Preview.Control.Right:Dock(RIGHT)
    self.Preview.Control.Right.Text = "⇨"
    self.Preview.Control.Right:DockMargin(5, 5, 5, 5)
    self.Preview.Control.Right:SetWide(self.Preview:GetWide() * 0.15 - 10)

    self.Preview.Control.Right.DoClick = function()
        if self.Num == #self.Selected.model then return end
        self.Num = self.Num + 1
        self.Preview.Model:SetModel(self.Selected.model[self.Num])
        self.Preview.Model:InvalidateLayout()
    end

    self.Preview.Control.Click = vgui.Create("aMenuButton", self.Preview.Control)
    self.Preview.Control.Click:Dock(FILL)
    self.Preview.Control.Click:DockMargin(0, 5, 0, 5)
    self.Preview.Control.Click:SetWide(self.Preview:GetWide() * 0.7 - 10)

    self.Preview.Control.Click.DoClick = function()
        DarkRP.setPreferredJobModel(self.Selected.team, self.Preview.Model:GetModel())
        print(self.Selected.RequiresVote)

        if self.Selected.vote or self.Selected.RequiresVote(LocalPlayer()) then
            RunConsoleCommand("darkrp", "vote" .. self.Selected.command)
        else
            RunConsoleCommand("darkrp", self.Selected.command)
        end

        DarkRP.closeF4Menu()
    end

    --Putting this shit down here because I hate docking
    self.Preview.Model.PerformLayout = function()
        if istable(self.Selected.model) then
            self.Preview.Model:SetModel(self.Selected.model[self.Num])
        else
            self.Preview.Model:SetModel(self.Selected.model)
        end

        if aMenu.PreviewThemeColour then
            self.Preview.Model.Entity.GetPlayerColor = function() return Vector(aMenu.Color.r / 255, aMenu.Color.g / 255, aMenu.Color.b / 255) end --and putting this in here to stop shit breaking
        end

        if self.Selected.vote == true or (self.Selected.RequiresVote and self.Selected.RequiresVote(LocalPlayer())) then
            self.Preview.Control.Click.Text = "Create vote"

            self.Preview.Control.Click.DoClick = function()
                DarkRP.setPreferredJobModel(self.Selected.team, self.Preview.Model:GetModel())
                RunConsoleCommand("darkrp", "vote" .. self.Selected.command)
                DarkRP.closeF4Menu()
            end
        else
            self.Preview.Control.Click.Text = "Become job"

            self.Preview.Control.Click.DoClick = function()
                DarkRP.setPreferredJobModel(self.Selected.team, self.Preview.Model:GetModel())
                RunConsoleCommand("darkrp", self.Selected.command)
                DarkRP.closeF4Menu()
            end
        end

        self.Preview.Control.Right.Disabled = true
        self.Preview.Control.Left.Disabled = true

        if istable(self.Selected.model) then
            if #self.Selected.model ~= 1 then
                self.Preview.Control.Right.Disabled = false
                self.Preview.Control.Left.Disabled = false
            end
        end
    end

    self.middle = vgui.Create("DPanel", self)
    self.middle:Dock(FILL)

    self:CreateFavoriteCategory()

    self.List = vgui.Create("DScrollPanel", self.middle)
    self.List:Dock(FILL)
    self.List:SetWide(self:GetWide() * 0.66)

    self.List.Paint = function(this, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(16, 16, 16, 255))
    end

    aMenu.PaintScroll(self.List)
    self:DoSearch("")
end

local colors = {
    hover = Color(255, 255, 255, 4),
    bright = Color(46, 46, 46),
    dark = Color(16, 16, 16),
}

function PANEL:CreateFavoriteCategory()
    if not IsValid(self.FavPanel) then
        self.FavPanel = vgui.Create("DPanel", self.middle)
        self.FavPanel:Dock(TOP)
        self.FavPanel:SetTall(128)
        self.FavPanel:DockPadding(8, 56, 8, 8)
        self.FavPanel.Paint = function(this, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(16, 16, 16, 255))
            draw.SimpleText("Favorites:", "Arena.Medium", 8, 8, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        self.FavPanel.PerformLayout = function(s, w, h)
            local wide = w / 3 - 16
            for k = 1, 3 do
                local children = s:GetChildren()[k]
                if not IsValid(children) then continue end
                children:SetWide(wide)
                children:DockMargin(k == 1 and 0 or 8, 0, 0, 0)
            end
        end
    else
        for k, v in pairs(self.FavItems) do
            v:Remove()
        end
    end

    self.FavItems = {}
    for k = 1, 3 do
        local job = vgui.Create("DButton", self.FavPanel)
        self.FavItems[k] = job
        job.id = k
        job:Dock(LEFT)
        job:SetText("")
        job.hoverAmount = 0
        job.Paint = function(s, w, h)
            local d = s.Data
            if not d then

                draw.RoundedBox(8, 0, 0, w, h, colors.bright)
                draw.RoundedBox(8, 1, 1, w - 2, h - 2, colors.dark)
                if (s:IsHovered()) then
                    draw.RoundedBox(8, 1, 1, w - 2, h - 2, colors.hover)
                end
                return
            end

            local jobData = RPExtraTeams[self.FavoriteJobs[k]]

            local clr = team.GetColor(self.FavoriteJobs[k])
            draw.RoundedBox(8, 0, 0, w, h, clr)
            draw.RoundedBox(8, 1, 1, w - 2, h - 2, colors.dark)

            s.hoverAmount = Lerp(FrameTime() * 5, s.hoverAmount, s:IsHovered() and 100 or 0)
            draw.RoundedBox(8, 2, 2, w - 4, h - 4, ColorAlpha(clr, s.hoverAmount))
            draw.SimpleText(jobData.name, "Arena.Small", h + 4, 8, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
        job.Data = isnumber(self.FavoriteJobs[k]) and RPExtraTeams[self.FavoriteJobs[k]] or nil
        job.OnMousePressed = function(s, m)
            if not s.Data or not s.Data.team then return end
            if (m == MOUSE_RIGHT) then
                table.RemoveByValue(self.FavoriteJobs, s.Data.team)
                cookie.Set("FavoriteCustomJobs", util.TableToJSON(self.FavoriteJobs))
                self:CreateFavoriteCategory()
                return
            end

            RunConsoleCommand("darkrp", s.Data.command)
            DarkRP.closeF4Menu()
        end

        local hasData = job.Data != nil
        job.icon = vgui.Create("DModelPanel", job)
        job.icon:Dock(LEFT)
        job.icon:SetVisible(hasData)
        job.icon:DockMargin(4, 4, 4, 4)
        if (not hasData) then
            job:SetTextColor(Color(255, 255, 255, 75))
            job:SetFont("XeninUI.TextEntry")
            job:SetText("-Favorite Slot Open-")
            continue
        end
        job.icon:SetModel(isstring(job.Data.model) and job.Data.model or job.Data.model[1])
        job.icon:SetFOV(35)
        job.icon.LayoutEntity = function(s, ent)
            local bone = ent:LookupBone("ValveBiped.Bip01_Head1")
            if bone then
                local pos, ang = ent:GetBonePosition(bone)
                if pos and ang then
                    s:SetLookAt(pos)
                    s:SetCamPos(pos + Vector(32, 16, 0))
                    //ent:SetAngles(ang)
                end
            end
        end
    end
end

function PANEL:DoSearch(val)


    for k, v in pairs(self.Categories or {}) do
        v:Remove()
    end

    self.Categories = {}
    local evalVip = false

    for k, v in pairs(self.Contents) do
        if (val ~= "" and not string.find(string.lower(v.name), string.lower(val), 1, true)) then continue end
        local isVip = v.category == "Private Jobs"
        if LOADED_VIP and isVip and !LOADED_VIP[k] then continue end
        if not isVip and v.name == team.GetName(LocalPlayer():Team()) then continue end

        if v.NeedToChangeFrom then
            if type(v.NeedToChangeFrom) == "number" then
                if v.NeedToChangeFrom ~= LocalPlayer():Team() then continue end
            elseif type(v.NeedToChangeFrom) == "table" then
                local found = false

                for _, e in pairs(v.NeedToChangeFrom) do
                    if e == LocalPlayer():Team() then
                        found = true
                    end
                end

                if not found then continue end
            end
        end

        --if v.customCheck then if not v.customCheck(LocalPlayer()) then continue end end
        local category

        if v.category then
            category = self:CreateNewCategory(v.category, self.List)
        else
            category = self:CreateNewCategory("Unassigned", self.List)
        end

        v.Bar = vgui.Create("DPanel", category)

        v.Bar.Fav = vgui.Create("DButton", v.Bar)
        v.Bar.Fav:Dock(RIGHT)
        v.Bar.Fav:DockMargin(0, 0, 0, 42)
        v.Bar.Fav:SetWide(35)
        v.Bar.Fav:SetText("")
        v.Bar.Fav.Paint = function(s, w, h)
            if not s.cache then
                s.cache = true
                s.fav = table.HasValue(self.FavoriteJobs, v.team)
            end
            draw.SimpleText(s.fav and "★" or "☆", "aMenuSubTitle", w / 2, h / 2, Color(255, 153, 0, s:IsHovered() and 255 or 20), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        v.Bar.Fav.DoClick = function(s)
            if (not s.fav) then
                if (#self.FavoriteJobs > 2) then
                    Derma_Message("You cannot add more than 3 favorites.", "Error", "OK")
                    return
                end
                table.insert(self.FavoriteJobs, v.team)
            elseif (table.HasValue(self.FavoriteJobs, v.team)) then
                table.RemoveByValue(self.FavoriteJobs, v.team)
            end

            s.fav = table.HasValue(self.FavoriteJobs, v.team)
            cookie.Set("FavoriteCustomJobs", util.TableToJSON(self.FavoriteJobs))
            self:CreateFavoriteCategory()
        end

        v.Bar.Max = v.max
        v.Bar.Cur = #team.GetPlayers(v.team)
        v.Bar:SetTall(70)
        v.Bar.BackAlpha = 0

        if v.Bar.Max == 0 then
            v.Bar.Max = "∞"
        end

        local todraw = math.Min(v.Bar.Cur / v.max, 1)

        v.Bar.Paint = function(this, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(36, 36, 36, 255))
            draw.RoundedBox(4, 0, 0, w, h, Color(aMenu.Color.r, aMenu.Color.g, aMenu.Color.b, v.Bar.BackAlpha))
            surface.SetFont("aMenuSubTitle")
            local sw, sh = surface.GetTextSize(string.upper(v.name))
            local clr = team.GetColor(v.team)
            local bright = Color(clr.r * 1.7, clr.g * 1.7, clr.b * 1.7)
            draw.SimpleText(v.name, "aMenuTitle", 70, 1, Color(255, 255, 255, 175), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            draw.RoundedBox(2, 70, 32, w - 74, 2, team.GetColor(v.team))
            draw.RoundedBox(4, w - 65, h - 27, 60, 22, bright)
            draw.SimpleText(DarkRP.formatMoney(v.salary), "aMenuSubTitle", w - 35, h - 15, Color(210, 210, 210), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.RoundedBox(4, 5, 5, 60, 60, Color(62, 62, 62, 255))
            draw.RoundedBox(4, 70, h - 27, w - 140, 22, Color(62, 62, 62, 255))

            if v.Bar.Cur ~= 0 then
                draw.RoundedBox(4, 72, h - 25, (w - 144) * todraw, 18, aMenu.Color)
            end

            draw.SimpleText((v.Bar.Cur or 0) .. "/" .. (v.Bar.Max or 1), "aMenu19", w / 2, h - 17, Color(210, 210, 210), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        v.Bar.Preview = vgui.Create("SpawnIcon", v.Bar)
        v.Bar.Preview:SetPos(5, 5)
        v.Bar.Preview:SetSize(60, 60)

        if istable(v.model) then
            v.Bar.Preview:SetModel(v.model[1])
        else
            v.Bar.Preview:SetModel(v.model)
        end

        v.Bar.Preview.OnCursorEntered = function(s, w, h)
            if (s:IsHovered()) then
                v.Bar.Model = vgui.Create("DModelPanel", v.Bar)
                v.Bar.Model.LayoutEntity = function() return end

                if istable(v.model) then
                    v.Bar.Model:SetModel(v.model[1])
                else
                    v.Bar.Model:SetModel(v.model)
                end

                v.Bar.Model:SetPos(5, 5)
                v.Bar.Model:SetSize(60, 60)
                v.Bar.Model:SetFOV(35)
                v.Bar.Model:SetCamPos(Vector(25, -7, 65))
                v.Bar.Model:SetLookAt(Vector(0, 0, 65))
                v.Bar.Model.alpha = 255

                v.Bar.Model.PaintOver = function(this, w, h)
                    if (this.alpha > 0) then
                        local mdlPath = ""

                        if istable(v.model) then
                            mdlPath = v.model[1]
                        else
                            mdlPath = v.model
                        end

                        local iconPath = "spawnicons/" .. string.Replace(mdlPath, ".mdl", ".png")
                        iconPath = string.Replace(iconPath, "/models/models/", "/models/")

                        if not (file.Exists("materials/" .. iconPath, "MOD")) then
                            iconPath = string.Replace(iconPath, ".png", "_64.png")
                        end

                        surface.SetMaterial(Material(iconPath))
                        surface.SetDrawColor(255, 255, 255, this.alpha)
                        surface.DrawTexturedRect(0, 0, w, h)
                        this.alpha = Lerp(FrameTime() * 10, this.alpha, -1)
                    end

                    if LevelSystemConfiguration and v.level then
                        if v.level > LocalPlayer():getDarkRPVar("level") then
                            draw.RoundedBox(2, 0, h - 10, w, 10, aMenu.LevelDenyColor)
                        else
                            draw.RoundedBox(2, 0, h - 10, w, 10, aMenu.LevelAcceptColor)
                        end

                        draw.SimpleText(v.level, "aMenu14", w / 2, h - 6, Color(210, 210, 210), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end

                if IsValid(v.Bar.Model.Entity) then
                    v.Bar.Model.Entity.GetPlayerColor = function() return Vector(aMenu.Color.r / 255, aMenu.Color.g / 255, aMenu.Color.b / 255) end
                end

                s:Remove()
            end
        end

        v.Bar.Button = vgui.Create("DButton", v.Bar)
        v.Bar.Button:Dock(FILL)
        v.Bar.Button:DockMargin(64, 0, 0, 0)
        v.Bar.Button:SetText("")
        v.Bar.Button.Paint = function() end

        v.Bar.Button.DoClick = function()
            self.Selected = v
            self.Num = 1
            self.Preview.Model:InvalidateLayout()
        end

        v.Bar.Button.DoDoubleClick = function()
            self.Preview.Control.Click.DoClick()
        end

        category:AddChild(v.Bar)
    end
end

function PANEL:CreateNewCategory(Name, parent)
    for k, v in pairs(self.Categories) do
        if (not IsValid(v)) then
            table.RemoveByValue(self.Categories, v)
        end

        if IsValid(v) and v:GetName() == Name then return v end
    end

    category = vgui.Create("aMenuCategory", parent)
    category:SetName(Name)
    table.insert(self.Categories, category)

    if aMenu.SortOrder then
        for k, v in pairs(self.Categories) do
            for i, _ in pairs(DarkRP.getCategories().jobs) do
                if v.Name == _.name then
                    v.sortOrder = _.sortOrder
                end
            end
        end

        --table.SortByMember(self.Categories, "sortOrder", true)
        table.sort(self.Categories, function(a, b)
            if a and a.sortOrder then
                if b and b.sortOrder then return a.sortOrder < b.sortOrder end
            end

            return false
        end)

        local n = vgui.Create("DPanel", self)

        for k, v in ipairs(self.Categories) do
            v:SetParent(n)
        end

        for k, v in ipairs(self.Categories) do
            v:SetParent(self.List)
            v:Dock(TOP)
        end

        n:Remove()
    end

    return category
end

vgui.Register("aMenuContainer", PANEL, "DPanel")

//DarkRP.closeF4Menu()