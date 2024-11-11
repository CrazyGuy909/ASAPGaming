------------------ Parent panel for shit
local PANEL = {}
local search = Material("xenin/search.png")

function PANEL:Init()
    self:Dock(FILL)
    self.Num = 1
    self.Key = 0
    self.Contents = {}
    self.Categories = {}
    self.Type = 0
    self.Placeholder = {}
    self.Placeholder.name = "None"
    self.Placeholder.price = ""
    self.Placeholder.description = ""
    self.Placeholder.model = ""
    self.ShouldEnable = true
end

function PANEL:PerformLayout(w, h)
    if (self.Search) then
        --local wide, height = ScrW()*0.8 - 220, ScrH()*0.8 - 55
        self.Search:SetPos(w * .66 + 56 - self.Search:GetWide(), 8)
    end
end

function PANEL:SetContents(contents, conttype)
    self.Contents = table.Copy(contents)
    self.Type = conttype

    if conttype == 1 then
        self.LoopCheck = self.CheckEntity
    elseif conttype == 2 then
        self.LoopCheck = self.CheckWeapon
    elseif conttype == 3 then
        self.LoopCheck = self.CheckShipment
    elseif conttype == 4 then
        self.LoopCheck = self.CheckAmmo
    elseif conttype == 5 then
        self.LoopCheck = self.CheckFood
    end

    self.IsAmmo = conttype == 4
    self.IsEntity = conttype == 1
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

function PANEL:GetContents()
    return self.Contents
end

function PANEL:Populate()
    local wide, height = ScrW() * 0.8 - 220, ScrH() * 0.8 - 96

    if (not self.Contents) or (self.Contents[1] == nil) then
        self.List = vgui.Create("DScrollPanel", self)
        self.List:Dock(FILL)
        self.List:SetWide(self:GetWide() * 0.66)

        self.List.Paint = function(this, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(16, 16, 16, 255))
        end

        local category = self:CreateNewCategory("Nothing to see here!", self.List)

        category.PerformLayout = function()
            category:SetTall(44)
        end

        return
    end

    self.Key = table.KeyFromValue(self.Contents, self.Contents[1])
    self.Selected = self.Contents[1]
    self.Preview = vgui.Create("DPanel", self)
    self.Preview:Dock(RIGHT)
    self.Preview:SetWide((wide * 0.33) - 15) --thank mr scrollbar

    self.Preview.Paint = function(this, w, h)
        draw.RoundedBoxEx(16, 0, 0, w, h, Color(6, 6, 6), false, false, false, true)
    end
    
    self.Preview.Model = vgui.Create("DModelPanel", self.Preview)

    self.Preview.Model:Dock(TOP)
    self.Preview.Model:SetSize(self.Preview:GetWide(), height * 0.4)
    self.Preview.Model:SetCamPos(Vector(45, 55, 35))
    self.Preview.Model:SetLookAt(Vector(0, 0, 10))
    self.Preview.Model:SetFOV(45)
    self.Preview.Model:SetMouseInputEnabled(false)
    --self.Preview.Model.LayoutEntity 	= function(ent)	ent:RunAnimation() end
    self.Preview.Title = vgui.Create("DLabel", self.Preview)
    self.Preview.Title:Dock(TOP)
    self.Preview.Title:DockMargin(5, 12, 5, 5)
    self.Preview.Title:SetTall(32)
    self.Preview.Title:SetFont("aMenuJob")
    self.Preview.Title:SetContentAlignment(8)

    self.Preview.Title.Paint = function(this, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(26, 26, 26, 255))
    end

    self.Preview.Title.PerformLayout = function()
        if self.Selected then
            self.Preview.Title:SetText(self.Selected.name)
        else
            self.Preview.Title:SetText(self.Contents[self.Key].name)
        end
    end

    self.Preview.Description = vgui.Create("DScrollPanel", self.Preview)
    self.Preview.Description:Dock(TOP)
    self.Preview.Description:DockMargin(5, 0, 5, 5)
    self.Preview.Description:SetTall(height * 0.4)

    self.Preview.Description.Paint = function(this, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(26, 26, 26, 255))
    end

    self.Preview.Description.Text = vgui.Create("DLabel", self.Preview.Description)
    self.Preview.Description.Text:Dock(TOP)
    self.Preview.Description.Text:DockMargin(5, 5, 5, 5)
    self.Preview.Description.Text:SetTall(height * 0.4)
    self.Preview.Description.Text:SetFont("aMenu20")
    self.Preview.Description.Text:SetWrap(true)
    self.Preview.Description.Text:SetContentAlignment(8)

    self.Preview.Description.Text.PerformLayout = function()
        self.Preview.Model:SetModel(self.Contents[self.Key].model)
        if isstring(self.Contents[self.Key].price) then
            self.Preview.Description.Text:SetText("")
            self.Preview.Description:SizeToContents()
            self.Preview.Control.Click.Disabled = true

            return
        end

        local price = 0

        if self.Selected then
            if self.Type == 2 then
                price = self.Selected.pricesep
            else
                price = self.Selected.price
            end

            if not price then
                price = 0
            end

            if self.Selected.description or aMenu.Descriptions[tostring(self.Selected.name)] then
                local desc = self.Selected.description or aMenu.Descriptions[tostring(self.Selected.name)]
                self.Preview.Description.Text:SetText(desc .. "\n\nPrice - $" .. (price or "Unknown"))
            else
                self.Preview.Description.Text:SetText("Price - $" .. (price or "Unknown"))
            end
        else
            if self.Type == 2 then
                price = self.Contents[self.Key].pricesep
            else
                price = self.Contents[self.Key].price
            end

            if self.Contents[self.Key].description or aMenu.Descriptions[tostring(self.Contents[self.Key].name)] then
                local desc = self.Contents[self.Key].description or aMenu.Descriptions[tostring(self.Contents[self.Key].name)]
                self.Preview.Description.Text:SetText(desc .. "\n\nPrice - $" .. (price or "Unknown"))
            else
                self.Preview.Description.Text:SetText("Price - $" .. (price or "Unknown"))
            end
        end

        self.Preview.Description:SizeToContents()
    end

    if (self.IsAmmo) then
        self.Preview.Slider = vgui.Create("XeninUI.Slider", self.Preview)
        self.Preview.Slider:Dock(TOP)
        self.Preview.Slider:SetTall(38)
        self.Preview.Slider:DockMargin(8, 8, 8, 16)
        self.Preview.Slider:SetMin(10)
        self.Preview.Slider:SetMax(90)

        self.Preview.Slider.OnValueChanged = function(s, frac)
            if not s.Price then return end
            self.Preview.Click.Text = "Purchase: " .. DarkRP.formatMoney(math.ceil(s:GetValue() / (s.Amount or 1) * s.Price))
        end
    elseif (self.IsEntity and self.Selected.max) then
        self.Preview.Slider = vgui.Create("XeninUI.Button", self.Preview)
        self.Preview.Slider:Dock(TOP)
        self.Preview.Slider:SetTall(38)
        self.Preview.Slider:DockMargin(8, 8, 8, 16)
        self.Preview.Slider:SetText("Remove Entity")
        self.Preview.Slider.DoClick = function()
            Derma_Query("Are you sure do you want to remove this entity? You will be able to spawn a new one", "Delete confirmation", "Yeah", function()
                net.Start("ASAP.RemoveEntity")
                net.WriteString(self.Selected.ent)
                net.WriteString(self.Selected.cmd)
                net.SendToServer()
                surface.PlaySound("garrysmod/save_load1.wav")
            end, "No")
        end
    end

    self.Preview.Click = vgui.Create("aMenuButton", self.Preview)
    self.Preview.Click:Dock(BOTTOM)
    self.Preview.Click:SetTall(36)
    self.Preview.Click:DockMargin(8, 16, 8, 10)

    --Putting this shit down here because I hate docking
    self.Preview.Model.PerformLayout = function()
        
        self.Preview.Click.Text = "Purchase " .. self.Name

        self.Preview.Click.DoClick = function()
            if self.Type == 1 then
                RunConsoleCommand("darkrp", self.Selected.cmd)
            elseif self.Type == 2 then
                net.Start("ASAP.RemoveEntity")
                net.WriteString(self.Selected.ent)
                net.WriteString(self.Selected.cmd)
                net.SendToServer()
                RunConsoleCommand("darkrp", "buy", self.Selected.name)
            elseif self.Type == 3 then
                RunConsoleCommand("darkrp", "buyshipment", self.Selected.name)
            elseif self.Type == 4 then
                --RunConsoleCommand("darkrp", "buyammo", self.Selected.id)
                net.Start("ASAP.PurchaseAmmo")
                net.WriteInt(self.Selected.id, 8)
                net.WriteFloat(self.Preview.Slider:GetValue())
                net.SendToServer()
            else
                RunConsoleCommand("darkrp", "buyfood", self.Selected.name)
            end
        end
    end

    self.List = vgui.Create("DScrollPanel", self)
    self.List:Dock(FILL)
    self.List:SetWide(self:GetWide() * 0.66)

    self.List.Paint = function(this, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(16, 16, 16, 255))
    end

    aMenu.PaintScroll(self.List)
    self:DoSearch("")
end

function PANEL:DoSearch(val)
    for k, v in pairs(self.Categories or {}) do
        v:Remove()
    end

    self.Categories = {}

    for k, v in pairs(self.Contents) do
        if (val ~= "" and not string.find(string.lower(v.name), string.lower(val), 1, true)) then continue end
        if v.name == team.GetName(LocalPlayer():Team()) then continue end
        if self:LoopCheck(v) == false then continue end
        local category

        if v.category then
            category = self:CreateNewCategory(v.category, self.List)
        else
            category = self:CreateNewCategory("Unassigned", self.List)
        end

        category:DockPadding(0, 36, 0, 5)
        v.Bar = vgui.Create("DPanel", category)
        v.Bar.Max = v.max
        v.Bar.Cur = #team.GetPlayers(v.team)
        v.Bar.BackAlpha = 0
        v.Bar:DockMargin(10, 10, 10, 0)
        v.Bar:SetTall(70)
        v.Bar.Ent = v

        if v.Bar.Max == 0 then
            v.Bar.Max = "∞"
        end

        local dada = v.Bar
        v.Bar.Paint = function(this, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(36, 36, 36, 255))
            draw.RoundedBox(4, 0, 0, w, h, Color(aMenu.Color.r, aMenu.Color.g, aMenu.Color.b, v.Bar.BackAlpha))
            draw.SimpleText(v.name, "aMenuSubTitle", 72, 6, Color(210, 210, 210), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

            if self.Type == 2 then
                if LocalPlayer():canAfford(v.pricesep) then
                    draw.RoundedBox(4, w - 65, h / 2 - 30, 60, 60, aMenu.Color)
                else
                    draw.RoundedBox(4, w - 65, h / 2 - 30, 60, 60, Color(62, 62, 62, 255))
                end

                draw.SimpleText(DarkRP.formatMoney(v.pricesep), "aMenu20", w - 35, h / 2, Color(210, 210, 210), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            else
                if (v.max and v.max > 0) then
                    local isOccupied = IsValid(CUSTOM_ENTITIES_ON[v.cmd])
                    surface.SetFont("aMenu20")
                    local maxed = isOccupied
                    this.isDelete = maxed
                    local canAfford = LocalPlayer():canAfford(v.price)
                    local clr = (maxed or not canAfford) and Color(240, 55, 55) or Color(82, 150, 60, 255)
                    local text = maxed and "Remove" or DarkRP.formatMoney(v.price)
                    local tx, _ = surface.GetTextSize(text)
                    draw.RoundedBox(4, w - (tx + 20), h - 34, tx + 16, 30, clr)
                    draw.SimpleText(text, "aMenu20", w - (tx + 20) + 8, h - 20, Color(210, 210, 210), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                    draw.SimpleText(v.max, "aMenu20", 96, 96, Color(210, 210, 210), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    return
                end
                surface.SetFont("aMenu20")
                local tx, _ = surface.GetTextSize(DarkRP.formatMoney(v.price))
                local canAfford = LocalPlayer():canAfford(v.price)
                draw.RoundedBox(4, w - (tx + 20), h - 34, tx + 16, 30, not canAfford and Color(240, 55, 55) or Color(82, 150, 60, 255))
                draw.SimpleText(DarkRP.formatMoney(v.price), "aMenu20", w - (tx + 20) + 8, h - 20, Color(210, 210, 210), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            draw.RoundedBox(4, 5, 5, 60, 60, Color(62, 62, 62, 255))
        end

        local modelPath = istable(v.model) and v.model[1] or v.model
        local isSpawnIcon = file.Exists(modelPath, "GAME")
        v.Bar.Model = vgui.Create(isSpawnIcon and "SpawnIcon" or "DModelPanel", v.Bar)
        v.Bar.Model.LayoutEntity = function() return end

        v.Bar.Model:SetModel(modelPath)

        v.Bar.Model:SetPos(5, 5)
        v.Bar.Model:SetSize(60, 60)

        if (not isSpawnIcon) then
            if v.Bar.Model:GetEntity() and v.Bar.Model:GetEntity():GetModelRadius() then
                v.Bar.Model:SetFOV(v.Bar.Model:GetEntity():GetModelRadius())
            else
                v.Bar.Model:SetFOV(20)
            end
            v.Bar.Model:SetCamPos(Vector(105, 94, 85))
            v.Bar.Model:SetLookAt(Vector(10, 10, 15))
        end

        v.Bar.Model.PaintOver = function(this, w, h)
            if LevelSystemConfiguration and v.level then
                if v.level > LocalPlayer():getDarkRPVar("level") then
                    draw.RoundedBox(2, 0, h - 10, w, 10, aMenu.LevelDenyColor)
                else
                    draw.RoundedBox(2, 0, h - 10, w, 10, aMenu.LevelAcceptColor)
                end

                draw.SimpleText(v.level, "aMenu14", w / 2, h - 6, Color(210, 210, 210), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end

        v.Bar.Button = vgui.Create("DButton", v.Bar)
        v.Bar.Button:Dock(FILL)
        v.Bar.Button:SetText("")
        v.Bar.Button.Paint = function() end

        v.Bar.Button.DoClick = function()
            self.Selected = v
            self.Key = k
            self.Num = 1
            self.Preview.Model:InvalidateLayout()

            timer.Simple(0, function()
                if (self.IsAmmo) then
                    self.Preview.Slider.Price = v.price
                    self.Preview.Slider.Amount = v.amountGiven
                    self.Preview.Slider:SetMin(math.ceil(v.amountGiven * .5))
                    self.Preview.Slider:SetMax(math.ceil(v.amountGiven * 3))
                    self.Preview.Slider:SetValue(v.amountGiven)
                    self.Preview.Click.Text = "Purchase: " .. DarkRP.formatMoney(math.ceil(v.price))
                end

                timer.Simple(LocalPlayer():Ping() / 500, function()
                    if IsValid(dada) then
                        dada.cache = nil
                    end
                end)
            end)
        end

        self.Preview.Click.Price = v.price

        v.Bar.Button.DoDoubleClick = function()
            if (dada.isDelete) then
                net.Start("ASAP.RemoveEntity")
                net.WriteString(self.Selected.ent)
                net.WriteString(self.Selected.cmd)
                net.SendToServer()
                surface.PlaySound("garrysmod/save_load1.wav")
                return
            end
            self.Preview.Click.DoClick()
        end

        category:AddChild(v.Bar)
    end

    if #self.Categories == 0 then
        local category = vgui.Create("DPanel", self.List)

        category.PerformLayout = function()
            category:SetSize(self.List:GetWide(), self.List:GetTall())
        end

        category.Paint = function(s, w, h)
            draw.SimpleText("Nothing to see here!", "aMenuJobCat", w / 2, h / 2, Color(255, 255, 255, 75), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        self.Selected = self.Placeholder
        self.ShouldEnable = false
    else
        self.Selected = self.Categories[1]:GetChildren()[1].Ent

        return
    end
end

function PANEL:Paint(w, h)
end

function PANEL:CreateNewCategory(name, parent)
    for k, v in pairs(self.Categories) do
        if v:GetName() == name then return v end
    end

    local category = vgui.Create("aMenuCategory", parent)
    category:SetName(name)
    table.insert(self.Categories, category)

    return category
end

--Entity checking functions from the original DarkRP menu (why re-write these?)
function PANEL:CheckEntity(item)
    local ply = LocalPlayer()
    if istable(item.allowed) and not table.HasValue(item.allowed, ply:Team()) then return false end
    if item.customCheck and not item.customCheck(ply) then return false end

    if not aMenu.ShowAllEntities then
        if not ply:canAfford(item.price) then return false end
    end

    return true
end

function PANEL:CheckWeapon(ship)
    local ply = LocalPlayer()
    if not (ship.separate or ship.noship) then return false end
    local cost = ship.pricesep
    if GAMEMODE.Config.restrictbuypistol and not table.HasValue(ship.allowed, ply:Team()) then return false end
    if ship.customCheck and not ship.customCheck(ply) then return false end

    if not aMenu.ShowAllEntities then
        if not ply:canAfford(cost) then return false end
    end

    return true
end

function PANEL:CheckShipment(ship)
    local ply = LocalPlayer()
    if ship.noship then return false end
    if ship.allowed and not table.HasValue(ship.allowed, ply:Team()) then return false end
    if ship.customCheck and not ship.customCheck(ply) then return false end
    local canbuy, suppress, message, price = hook.Call("canBuyShipment", nil, ply, ship)
    local cost = price or ship.getPrice and ship.getPrice(ply, ship.price) or ship.price

    if not aMenu.ShowAllEntities then
        if not ply:canAfford(cost) then return false end
    end

    if canbuy == false then return false end

    return true
end

function PANEL:CheckAmmo(item)
    local ply = LocalPlayer()
    if item.customCheck and not item.customCheck(ply) then return false end
    local canbuy, suppress, message, price = hook.Call("canBuyAmmo", nil, ply, item)
    local cost = price or item.getPrice and item.getPrice(ply, item.price) or item.price

    if not aMenu.ShowAllEntities then
        if not ply:canAfford(cost) then return false end
    end

    if canbuy == false then return false end

    return true
end

function PANEL:CheckFood(food)
    local ply = LocalPlayer()
    if (food.requiresCook == nil or food.requiresCook == true) and (not RPExtraTeams[ply:Team()] or not RPExtraTeams[ply:Team()].cook) then return false end
    if food.customCheck and not food.customCheck(LocalPlayer()) then return false end

    if not aMenu.ShowAllEntities then
        if not ply:canAfford(food.price) then return false end
    end

    return true
end

function PANEL:LoopCheck(item)
end

vgui.Register("aMenuEntBase", PANEL, "DPanel")