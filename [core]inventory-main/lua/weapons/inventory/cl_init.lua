include("shared.lua")
SWEP.Slot = 1
SWEP.SlotPos = 0
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

function SWEP:PrimaryAttack()
    return
end

SWEP.nextTry = 0

function SWEP:SecondaryAttack()
    if IsFirstTimePredicted() then return end
    if self.nextTry > CurTime() then return end
    self.nextTry = CurTime() + .5
    vgui.Create("gInventory.SavePanel")

    return true
end

function SWEP:Deploy()
    return
end

local PANEL = {}

function PANEL:Init()
    SP = self
    self:ShowCloseButton(false)
    self:SetSize(300, ScrH() * .5)
    self:SetPos(ScrW() / 2 + 196, ScrH() * .25)
    self:MakePopup()
    self:SetTitle("")
    self.canEscape = false
    self.Body = vgui.Create("XeninUI.ScrollPanel", self)
    self.Body:Dock(FILL)
    self.Body:DockMargin(8, 38, 8, 8)

    self.Body.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 100))
    end

    net.Start("BU3:RequestEquipment")
    net.SendToServer()
    local armorData = LocalPlayer().armorData

    if (armorData and BU3.Dictionary[armorData.Entitie]) then
        self:CreateSlot(LocalPlayer(), BU3.Dictionary[armorData.Entitie], true)
    end
end

function PANEL:CreateSlot(ent, itemid, isSuit)
    local item = BU3.Items.Items[itemid]
    if not item then return end
    local obj = vgui.Create("DButton", self.Body)
    obj:Dock(TOP)
    obj.WeaponEntity = ent
    obj:DockMargin(4, 4, 4, 0)
    obj:SetTall(64)
    obj:SetText("")

    obj.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, s:IsHovered() and 150 or 200))
        draw.RoundedBox(8, 4, 4, 56, 56, ColorAlpha(BU3.Items.RarityToColor[item.itemColorCode], s:IsHovered() and 50 or 15))
        draw.SimpleText(item.name, "XeninUI.TextEntry", 64, 4, BU3.Items.RarityToColor[item.itemColorCode])
        draw.SimpleText(item.type, "XeninUI.TextEntry", 64, 20, Color(255, 255, 255, 50))
    end

    local iconPreview

    if item.iconIsModel then
        iconPreview = BU3.UI.Elements.ModelView(item.iconID, item.zoom, obj)
    else
        iconPreview = BU3.UI.Elements.IconView(item.iconID, item.color, obj, false)
    end

    iconPreview:Dock(LEFT)
    iconPreview:SetWide(56)
    iconPreview:DockMargin(8, 8, 8, 8)
    iconPreview.zoom = item.zoom
    iconPreview:SetMouseInputEnabled(false)
    obj.Content = iconPreview

    obj.DoClick = function(s)
        if not IsValid(s.WeaponEntity) then
            s:Remove()

            return
        end

        Derma_Query("Do you want to save this " .. (isSuit and "suit" or "weapon") .. " on your inventory?", "Saving your equipment", "Yes", function()
            local armorData = LocalPlayer().armorData
            if (isSuit and not armorData) then return end
            net.Start("BU3:RequestPickup")
            net.WriteBool(isSuit)

            
            if isSuit then
                local found = false
                for k, v in pairs(BU3.Items.Items) do
                    if v.className == armorData.Entitie then
                        found = k
                        break
                    end
                end
                net.WriteUInt(found or BU3.Dictionary[armorData.Entitie], 16)
            else
                net.WriteEntity(s.WeaponEntity)
            end

            net.SendToServer()

            if IsValid(s) then
                s:Remove()
            end
        end, "No")
    end
end

function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(255, 255, 255, 50))
    draw.SimpleText("Current Inventory:", "Arena.Small", 14, 18, color_black)
    draw.SimpleText("Current Inventory:", "Arena.Small", 16, 16, color_white)
    surface.SetDrawColor(255, 255, 255, 100)
    surface.DrawLine(16, 52, w - 16, 52)

    if (not self.canEscape and not input.IsMouseDown(MOUSE_RIGHT)) then
        self.canEscape = true
    elseif (self.canEscape and input.IsMouseDown(MOUSE_RIGHT)) then
        self:Remove()
    end
end

vgui.Register("gInventory.SavePanel", PANEL, "DFrame")

net.Receive("BU3:RequestEquipment", function()
    local am = net.ReadUInt(8)

    if am == 0 then
        for k, v in pairs(LocalPlayer():GetWeapons()) do
            if not v.ItemID then continue end
            SP:CreateSlot(v, v.ItemID)
        end
    end

    if not IsValid(SP) then return end

    for k = 1, am do
        local ent = net.ReadEntity()
        ent.ItemID = net.ReadUInt(16)
        SP:CreateSlot(ent, ent.ItemID, false)
    end
end)

if IsValid(SP) then
    SP:Remove()
end
