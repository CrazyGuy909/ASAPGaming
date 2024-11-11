local PANEL = {}
PANEL.IsReady = false

function PANEL:Init()
    DUEL_CREATION = self

    if IsValid(asapArena.AcceptDuelFrame) then
        asapArena.AcceptDuelFrame:Remove()
    end

    local allowTrade = GetConVar("duel_allowtrade")
    self.IsReady = false
    self:SetTitle("Duel")
    self:SetSize(900, allowTrade:GetBool() and 540 or 410)
    self:Center()
    self:MakePopup()
    local foot = vgui.Create("Panel", self)
    foot:Dock(BOTTOM)
    foot:SetTall(264)
    self.Foot = foot
    local options = vgui.Create("Panel", foot)
    options:Dock(LEFT)
    options:SetWide(228)
    options:DockPadding(8, 8, 0, 8)
    self.Options = options
    self.Chat = vgui.Create("Panel", foot)
    self.Chat:Dock(FILL)
    self.Chat:DockMargin(8, 8, 8, 8)
    local bot = vgui.Create("Panel", self.Chat)
    bot:Dock(BOTTOM)
    self.Ready = vgui.Create("XeninUI.Button", bot)
    self.Ready:SetText("Set Ready")
    self.Ready:Dock(RIGHT)
    self.Ready:SetWide(112)
    self.Ready:DockMargin(8, 0, 0, 0)
    self.Ready:SetRound(4)

    self.Ready.DoClick = function()
        if self.IsCreator and not self.SelectedWeapon then
            Derma_Message("You must select a weapon first!")

            return
        end

        local money = tonumber(self.SelfContainer.Bet:GetText())

        if (not money or money < 1) then
            Derma_Message("You must bet a valid amount of money!")

            return
        end

        if (self.IsSuitDuel) then
            if (self.IsCreator and not self.SelectedZone) then
                Derma_Message("You must select a valid zone to play")

                return
            end

            if (not self.SelectedSuit) then
                Derma_Message("You must select a valid suit")

                return
            end
        end

        self.IsReady = not self.IsReady
        net.Start("Arena.Duel.SetReady")
        net.WriteBool(self.IsReady)
        net.SendToServer()
        self.SelfContainer.Nick:SetTextColor(self.IsReady and Color(41, 190, 61) or Color(212, 110, 26))
    end

    self.Input = vgui.Create("XeninUI.TextEntry", bot)
    self.Input:Dock(FILL)
    self.Input:DockMargin(0, 0, 0, 0)
    self.Input.textentry:DockMargin(0, 0, 0, 0)
    self.Input:SetPlaceholder("Insert a message...")

    self.Input.OnEnter = function(s, val)
        if (val ~= "") then
            net.Start("Arena.Duel.SendMessage")
            net.WriteString(val)
            net.SendToServer()
            s:SetText("")
            s:RequestFocus(107)
            self:AddMessage(val, true)
        end
    end

    self.Log = vgui.Create("RichText", self.Chat)
    self.Log:Dock(FILL)
    self.Log:DockMargin(0, 0, 0, 8)

    self.Log.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(16, 16, 16))
    end

    self.Local = vgui.Create("Panel", self)
    self.Local:Dock(LEFT)
    self.Local:SetWide(self:GetWide() / 2)
    self.Local:DockMargin(8, 8, 0, 0)
    self.Adversary = vgui.Create("Panel", self)
    self.Adversary:Dock(FILL)
    self.Adversary:DockMargin(0, 8, 8, 0)
    self:CreateControls()
    self:InvalidateLayout(true)
end

local function fetchKind(kind)
    local data = {}

    for itemID, _ in pairs(BU3.Inventory.Inventory) do
        local item = BU3.Items.Items[itemID]
        if not item then continue end
        if (item.type ~= kind) then continue end
        if (item.className and asapArena.BlacklistWeapons[item.className]) then continue end
        data[itemID] = item.name
    end

    return data
end

function PANEL:CreateControls()
    local options = self.Options

    for k, v in pairs(options:GetChildren()) do
        v:Remove()
    end

    local lbl = Label("Suits duel", options)
    lbl:SetFont("XeninUI.TextEntry")
    lbl:SizeToContents()
    lbl:Dock(TOP)
    self.IsDuel = vgui.Create("XeninUI.Checkbox", options)
    self.IsDuel:Dock(TOP)
    self.IsDuel:SetTall(28)
    self.IsDuel:DockMargin(0, 4, 0, 4)
    self.IsDuel:SetState(self.IsSuitDuel or false)

    self.IsDuel.OnStateChanged = function(s, val)
        self.IsSuitDuel = val
        net.Start("Arena.Duel:SetSuit")
        net.WriteUInt(0, 4)
        net.WriteBool(self.IsSuitDuel)
        net.SendToServer()
        self:CreateControls()
    end

    if (self.IsSuitDuel) then
        self.Zone = vgui.Create("XeninUI.Button", options)
        self.Zone:Dock(TOP)
        self.Zone:SetRound(4)
        self.Zone:SetText("-Zone-")
        self.Zone:SetColor(Color(16, 16, 16))
        self.Zone:SetTooltip("Where do you want to do the duel")
        self.Zone:DockMargin(0, 4, 0, 4)

        self.Zone.DoClick = function(s)
            local x, y = s:LocalToScreen(0, s:GetTall())
            local menu = XeninUI:DropdownPopup(x, y)

            --self:PopulateItems()
            for k, v in SortedPairs(asapArena.SuitZones) do
                menu:AddChoice(k, function()
                    net.Start("Arena.Duel:SetSuit")
                    net.WriteUInt(2, 4)
                    net.WriteString(k)
                    net.SendToServer()
                    s:SetText(k)
                    self.SelectedZone = k
                end)
            end
        end
    else
        local lbl = Label("Max Kills", options)
        lbl:SetFont("XeninUI.TextEntry")
        lbl:SizeToContents()
        lbl:Dock(TOP)
        self.MaxKills = vgui.Create("XeninUI.TextEntry", options)
        self.MaxKills:SetNumeric(true)
        self.MaxKills:SetUpdateOnType(false)
        self.MaxKills:SetText(5)
        self.MaxKills:Dock(TOP)
        self.MaxKills:DockMargin(0, 4, 0, 4)

        self.MaxKills.textentry.OnEnter = function(s, t)
            local val = tonumber(t)

            if (not val) then
                s:SetText(5)

                return
            end

            if (val > 15 or val < 1) then
                s:SetText(val > 15 and 15 or 1)
                s:SetCaretPos(#s:GetText())

                return
            end

            if (self.IsCreator) then
                net.Start("Arena.Duel.UpdateMoney")
                net.WriteUInt(2, 3)
                net.WriteUInt(val, 5)
                net.SendToServer()
            end
        end
    end

    local lbl = Label("Bet Credits", options)
    lbl:SetFont("XeninUI.TextEntry")
    lbl:SizeToContents()
    lbl:Dock(TOP)
    self.Credits = vgui.Create("XeninUI.TextEntry", options)
    self.Credits:SetNumeric(true)
    self.Credits:SetUpdateOnType(true)
    self.Credits:SetText(0)
    self.Credits:Dock(TOP)
    self.Credits:DockMargin(0, 4, 0, 0)

    self.Credits.textentry.OnEnter = function(s, t)
        local val = tonumber(t)

        if (not val) then
            s:SetText(0)

            return
        end

        if (val < 600) then
            s:SetText(0)
            Derma_Message("You cannot bet something below 600 credits!")

            return
        end

        if (val > (LocalPlayer():GetStoreCredits() - (LocalPlayer()._oldCredits or 0))) then
            Derma_Message("You don't have that many tradable credits", "Error")

            return
        end

        if (LocalPlayer():GetStoreCredits() < val) then
            s:SetText(LocalPlayer():GetStoreCredits())

            return
        end

        net.Start("Arena.Duel.UpdateMoney")
        net.WriteUInt(3, 3)
        net.WriteUInt(val, 16)
        net.SendToServer()
    end
end

function PANEL:Setup(target, isGuest)
    self.IsCreator = isGuest == nil

    if (not isGuest) then
        self:SetTitle("Duel - You're the host")
    else
        self.MaxKills:SetEditable(false)
        self.Credits:SetEditable(false)
        self.IsDuel:SetMouseInputEnabled(false)
    end

    self:CreateSlot(self.Local, LocalPlayer())
    self:CreateSlot(self.Adversary, target)
    self.Occluder = vgui.Create("DPanel", self)
    local w, h = self:GetSize()
    self.Occluder:SetSize(w, h - 42)
    self.Occluder:SetPos(0, 42)

    self.Occluder.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 240))

        if not isGuest then
            draw.SimpleText("Waiting reply from", "Gangs.Small", w / 2, h / 2.5, Color(255, 255, 255, 255), 1, 1)
            draw.SimpleText(self.EnemyContainer.Player:Nick(), "Gangs.Small", w / 2, h / 2.5 + 32, Color(255, 255, 255, 255), 1, 1)
        end
    end
end

function PANEL:AddMessage(msg, isLocal, isInfo)
    if (isInfo) then
        self.Log:InsertColorChange(100, 100, 100, 255)
        self.Log:AppendText(msg .. "\n")
    else
        local talker = not isLocal and self.EnemyContainer.Player or self.SelfContainer.Player
        self.Log:InsertColorChange(100, 100, 100, 255)
        self.Log:AppendText(talker:Nick() .. ": ")
        self.Log:InsertColorChange(235, 235, 235, 255)
        self.Log:AppendText(msg .. "\n")
    end
end

function PANEL:CreateSlot(panel, ply)
    panel.Player = ply
    panel.Avatar = vgui.Create("AvatarImage", panel)
    panel.Avatar:SetSize(96, 96)
    panel.Avatar:SetPos(16, 8)
    panel.Avatar:SetPlayer(ply, 96)
    local lbl = Label(ply:Nick(), panel)
    lbl:SetSize(panel:GetWide(), 32)
    lbl:SetFont("Gangs.Small")
    lbl:SetPos(16, 108)
    lbl:SetTextColor(Color(212, 110, 26))
    lbl:SetContentAlignment(4)
    panel.Nick = lbl
    local lbl = Label("Money:", panel)
    lbl:SetSize(panel:GetWide(), 32)
    lbl:Dock(TOP)
    lbl:DockMargin(128, 0, 0, 0)
    lbl:SetFont("XeninUI.TextEntry")
    lbl:SetContentAlignment(4)
    panel.Bet = vgui.Create("XeninUI.TextEntry", panel)
    panel.Bet:Dock(TOP)
    panel.Bet:SetNumeric(true)
    panel.Bet:DockMargin(128, 0, 8, 0)
    panel.Bet:SetEditable(ply == LocalPlayer())
    panel.Bet:SetPlaceholder("500")
    panel.Bet:SetTooltip("How much money do you bet in this battle")
    panel.Weapons = vgui.Create("XeninUI.Button", panel)
    panel.Weapons:SetSize(172, 32)
    panel.Weapons:SetPos(128, 72)
    panel.Weapons:SetMouseInputEnabled(ply == LocalPlayer())
    panel.Weapons:SetRound(4)
    panel.Weapons:SetText("-Weapon-")
    panel.Weapons:SetColor(Color(16, 16, 16))
    panel.Weapons:SetTooltip("Which weapon do you want to fight with")
    panel.Weapons:DockMargin(0, 4, 0, 4)

    panel.Weapons.DoClick = function(s)
        local x, y = s:LocalToScreen(0, s:GetTall())
        local menu = XeninUI:DropdownPopup(x, y)

        for k, v in SortedPairs(fetchKind("weapon")) do
            menu:AddChoice(v, function()
                local item = BU3.Items.Items[k]
                net.Start("Arena.Duel.SelectWeapon")
                net.WriteString(item.className)
                net.WriteUInt(k, 16)
                net.SendToServer()
                s:SetText(v)
                self.SelectedWeapon = item.className
            end)
            --self:PopulateItems()
        end
    end

    panel.Suit = vgui.Create("XeninUI.Button", panel)
    panel.Suit:SetSize(122, 32)
    panel.Suit:SetPos(128 + 182, 72)
    panel.Suit:SetRound(4)
    panel.Suit:SetVisible(false)
    panel.Suit:SetText("-Suit-")
    panel.Suit:SetMouseInputEnabled(ply == LocalPlayer())
    panel.Suit:SetColor(Color(16, 16, 16))
    panel.Suit:SetTooltip("Which weapon do you want to fight with")
    panel.Suit:DockMargin(0, 4, 0, 4)

    panel.Suit.DoClick = function(s)
        local x, y = s:LocalToScreen(0, s:GetTall())
        local menu = XeninUI:DropdownPopup(x, y)

        --self:PopulateItems()
        for k, v in SortedPairs(fetchKind("suit")) do
            menu:AddChoice(v, function()
                --self._filter = func
                net.Start("Arena.Duel:SetSuit")
                net.WriteUInt(1, 4)
                net.WriteString(v)
                net.SendToServer()
                s:SetText(v)
                self.SelectedSuit = v
            end)
            --self:PopulateItems()
        end
    end

    if (ply == LocalPlayer()) then
        panel.Bet.OnEnter = function(s, val)
            local money = tonumber(val)

            if (not money or money < 0 or not LocalPlayer():canAfford(money)) then
                Derma_Message("You have introduced an incorrect value (Possibly can't afford it)")
            end

            net.Start("Arena.Duel.UpdateMoney")
            net.WriteUInt(1, 3)
            net.WriteFloat(money)
            net.SendToServer()
        end
    end

    if (ply ~= LocalPlayer()) then
        self.EnemyContainer = panel
    else
        self.SelfContainer = panel
    end

    local allowTrade = GetConVar("duel_allowtrade")
    if (not allowTrade:GetBool()) then return end
    local trade = vgui.Create("Panel", panel)
    trade:Dock(BOTTOM)
    trade:SetTall(72)
    trade:DockMargin(8, 16, 8, 16)
    panel.Items = {}

    for k = 1, 5 do
        local btn = vgui.Create("DButton", trade)
        btn:Dock(LEFT)
        btn:SetWide(64)
        btn:DockMargin(4, 4, 4, 4)
        btn:SetText("")
        btn.Father = panel

        btn.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, s.OutlineColor and s.OutlineColor or Color(66, 66, 66))
            draw.RoundedBox(4, 2, 2, w - 4, h - 4, Color(26, 26, 26))
        end

        btn.DoClick = function(s, w, h)
            if (LocalPlayer() ~= ply) then return end
            local itemSelect = ItemPicker()

            itemSelect.OnItemSelected = function(s, id, val)
                if IsValid(btn.Content) then
                    btn.Content:Remove()
                end

                local item = BU3.Items.Items[id]
                if not item then
                    Derma_Message("You cannot bet this item")
                    return false
                end

                if (item.perm and LocalPlayer():HasWeapon(item.className)) then
                    Derma_Message("You cannot bet an item you have equipped")
                    return
                end

                if (item.rankRestricted) then
                    Derma_Message("You cannot bet this item")
                    return false
                end

                self:SetupItem(k, btn, id, val, true)
            end
        end

        table.insert(panel.Items, btn)
    end
end

function PANEL:SetupItem(i, btn, id, am, dispatch)
    local item = BU3.Items.Items[id]

    if (id ~= nil or id == 0) then
        for k, v in pairs(btn.Father.Items) do
            if ((v.ItemID or "") == id) then return end
        end
    end

    btn.ItemID = id

    if (dispatch) then
        net.Start("Arena.Duel:SetItemTrade")
        net.WriteUInt(i, 3)
        net.WriteUInt(id or 0, 12)
        net.SendToServer()
    end

    if not item then
        btn:SetTooltip(nil)
        btn.OutlineColor = nil

        return
    end

    local iconPreview

    if item.iconIsModel then
        iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, btn)
    else
        iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, btn, false)
    end

    iconPreview:Dock(FILL)
    iconPreview:DockMargin(0, 0, 0, 0)
    iconPreview.zoom = item.zoom
    iconPreview:SetMouseInputEnabled(false)
    btn.Content = iconPreview
    btn:SetTooltip(item.name)
    btn.OutlineColor = BU3.Items.RarityToColor[item.itemColorCode]
end

function PANEL:SendAcceptance(result)
    if result then
        self.Occluder:Remove()
    else
        Derma_Message("Your duel request has been declined!")
        self:Remove()
    end
end

function PANEL:OnRemove()
    if (self.Dispatched) then return end
    net.Start("Arena.Duel.Cancel")
    net.SendToServer()
end

function PANEL:UpdateSlot(slot, item)
    local btn = self.Adversary.Items[slot]
    self:SetupItem(slot, btn, item)
end

vgui.Register("asapArena.DuelCreation", PANEL, "XeninUI.Frame")
local INV = {}

function INV:Init()
    if IsValid(DUEL_INVITATION) then
        DUEL_INVITATION.Bottom.No:DoClick()
    end

    DUEL_INVITATION = self

    self:SetSize(320, 132)
    self:SetPos(ScrW() - self:GetWide(), ScrH() / 2 - self:GetTall() / 2)
    self:SetTitle("Duel Invitation")
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
        net.Start("Arena.Duel.InviteResult")
        net.WriteEntity(self.Creator)
        net.WriteBool(true)
        net.SendToServer()

        if IsValid(DUEL_CREATION) then
            DUEL_CREATION:Remove()
        end

        DUEL_CREATION = vgui.Create("asapArena.DuelCreation")
        DUEL_CREATION:Setup(self.Creator, true)
        DUEL_CREATION.Occluder:Remove()
        self.Resolved = true
        self:Remove()
    end

    self.Bottom.No = vgui.Create("XeninUI.Button", self.Bottom)
    self.Bottom.No:Dock(FILL)
    self.Bottom.No:SetColor(Color(16, 16, 16))
    self.Bottom.No:DockMargin(4, 0, 0, 0)
    self.Bottom.No:SetText("Decline")
    self.Bottom.No:SetWide(self:GetWide() / 2)

    self.Bottom.No.DoClick = function()
        net.Start("Arena.Duel.InviteResult")
        net.WriteEntity(self.Creator)
        net.WriteBool(false)
        net.SendToServer()
        self.Resolved = true
        self:Remove()
    end

    timer.Simple(15, function()
        if IsValid(self) then
            self.Bottom.No:DoClick()
        end
    end)
end

function INV:OnRemove()
    if (self.Resolved) then return end
    net.Start("Arena.Duel.InviteResult")
    net.WriteEntity(self.Creator)
    net.WriteBool(false)
    net.SendToServer()
end

function INV:PaintOver(w, h)
    if (IsValid(self.Creator)) then
        draw.SimpleText(self.Creator:Nick(), "Gangs.Medium", 12, 48, color_white)
    end
end

vgui.Register("asapArena:DuelInvite", INV, "XeninUI.Frame")

net.Receive("Arena.Duel:CreateDuel", function(l)
    local a = net.ReadEntity()
    local b = net.ReadEntity()

    if IsValid(DUEL_CREATION) then
        DUEL_CREATION:Remove()
    end

    DUEL_CREATION = vgui.Create("asapArena.DuelCreation")
    DUEL_CREATION:Setup(a == LocalPlayer() and b or a, a ~= LocalPlayer() and true or nil)
    DUEL_CREATION.Occluder:Remove()
end)

if IsValid(DUEL_CREATION) then
    DUEL_CREATION:Remove()
end

--DUEL_CREATION = vgui.Create("asapArena.DuelCreation")
--DUEL_CREATION:Setup(LocalPlayer() == p(1) and p(2) or p(1), LocalPlayer() == p(1))
--DUEL_CREATION.Occluder:Remove()