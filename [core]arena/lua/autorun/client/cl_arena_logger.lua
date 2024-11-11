local PANEL = {}

function PANEL:Init()
    self:SetSize(400, 574)
    self:Center()
    self:SetTitle("Logs")
    self:MakePopup()

    self.List = vgui.Create("DListView", self)
    self.List:Dock(TOP)
    self.List:SetTall(200)
    self.List:DockMargin(8, 8, 8, 8)
    self.List.OnRowSelected  = function(s, rowIndex, row)
        self.Current = self.Data[row:GetValue(1)]
        self.Name = weapons.Get(row:GetValue(1)).PrintName
    end
    --self.List.Paint = function(s, w, h)
        --draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0))
    --end

    self.List:AddColumn("Weapon")
end

local groups = {
    [HITGROUP_GENERIC] = "Generic",
    [HITGROUP_HEAD] = "Head",
    [HITGROUP_CHEST] = "Chest",
    [HITGROUP_STOMACH] = "Stomatch",
    [HITGROUP_LEFTARM] = "Left arm",
    [HITGROUP_RIGHTARM] = "Right arm",
    [HITGROUP_LEFTLEG] = "Left leg",
    [HITGROUP_RIGHTLEG] = "Right leg",
}

function PANEL:PaintOver(w, h)
    if (not self.Current) then return end
    draw.SimpleText(self.Name, "XeninUI.Title", w / 2, 252, Color(235, 235, 235), 1, TEXT_ALIGN_TOP)
    local bullets = (self.Current.Bullets or 0)
    draw.SimpleText("Shoots: " .. bullets, "Arena.Small", 16, 294, Color(235, 235, 235), 0, TEXT_ALIGN_TOP)
    draw.SimpleText("Hits: " .. (self.Current.Hits or 0), "Arena.Small", 16, 324, Color(235, 235, 235), 0, TEXT_ALIGN_TOP)
    local missed = ((self.Current.Bullets or 0) - (self.Current.Hits or 0))
    draw.SimpleText("Missed: " .. missed, "Arena.Small", 16, 354, Color(235, 235, 235), 0, TEXT_ALIGN_TOP)
    draw.SimpleText("Precision: " .. math.Round((1 - missed / bullets) * 100, 1) .. "%", "Arena.Small", 16, 384, Color(235, 235, 235), 0, TEXT_ALIGN_TOP)
    draw.SimpleText("HitGroups:", "Arena.Small", 16, 414, Color(235, 235, 235), 0, TEXT_ALIGN_TOP)
    for k, v in pairs(groups) do
        draw.SimpleText(v .. ": " .. (self.Current.HitGroups[k] or 0), "Arena.Small", 16 + (k % 2) * w / 2 , 414 + math.ceil((k + 1) / 2) * 30, Color(235, 235, 235, 50), 0, TEXT_ALIGN_TOP)
    end
end

function PANEL:SetData(data)
    self.Data = data
    for k, v in pairs(data) do
        self.List:AddLine(k)
    end
end

vgui.Register("Arena.Menu", PANEL, "XeninUI.Frame")

net.Receive("ASAP.Arena:SendStats", function()
    if IsValid(LOGGER) then
        LOGGER:Remove()
    end
    LOGGER = vgui.Create("Arena.Menu")
    LOGGER:SetData(net.ReadTable())
end)
