local PANEL = {}

local tags = {
    [GANG_LOG_ALL] = "All",
    [GANG_LOG_INVITE] = "Invites",
    [GANG_LOG_KICK] = "Kicks",
    [GANG_LOG_PURCHASE] = "Purchases",
    [GANG_LOG_DEPOSIT] = "Deposits",
    [GANG_LOG_ROLE] = "Roles/Members"
}

local colors = {
    [GANG_LOG_ALL] = Color(255, 222, 0),
    [GANG_LOG_INVITE] = Color(138, 255, 0),
    [GANG_LOG_KICK] = Color(255, 96, 0),
    [GANG_LOG_PURCHASE] = Color(0, 192, 255),
    [GANG_LOG_DEPOSIT] = Color(200, 0, 255),
    [GANG_LOG_ROLE] = Color(100, 0, 225)
}

logViewer = logViewer or nil
local remaining = 0

function PANEL:Init()
    logViewer = self
    self.Tags = vgui.Create("Panel", self)
    self.Tags:Dock(TOP)
    self.Tags:SetTall(42)
    self.Tags:DockMargin(16, 48, 16, 0)

    self.Update = vgui.Create("XeninUI.Button", self.Tags)
    self.Update:Dock(RIGHT)
    self.Update:SetText("Update")
    self.Update:SetWide(128)
    self.Update.Think = function(s)
        if (remaining > CurTime()) then
            s:SetText(string.FormattedTime(remaining - CurTime(), "%02d:%02d"))
        else
            s:SetText("Update")
        end
    end
    self.Update.DoClick = function()
        self:RequestUpdate()
    end

    self.RemoveLogs = vgui.Create("XeninUI.Button", self.Tags)
    self.RemoveLogs:Dock(RIGHT)
    self.RemoveLogs:SetText("Clear")
    self.RemoveLogs:DockMargin(0, 0, 8, 0)
    self.RemoveLogs:SetWide(96)

    self.RemoveLogs.DoClick = function()
        Derma_Query("Are you sure do you want to clear ALL logs?", "Confirmation", "Yeah", function()
            asapgangs.Log = {}
            net.Start("Gangs.RemoveLogs")
            net.SendToServer()
            self:PopulateLogs()
        end, "NO!")
    end

    for k,v in pairs(tags) do
        local but = vgui.Create("XeninUI.Button", self.Tags)
        but:Dock(LEFT)
        surface.SetFont("XeninUI.TextEntry")
        local wide,_ = surface.GetTextSize(v)
        but:SetWide(wide + 64)
        but:DockMargin(0, 0, 8, 0)
        but:SetText(v)
        but.DoClick = function()
            self:PopulateLogs(k)
        end
    end
    self.Container = vgui.Create("XeninUI.ScrollPanel", self)
    self.Container:Dock(FILL)
    self.Container:DockMargin(16, 16, 16, 16)
    self.Container.Paint = function(s,w,h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0,0,0,150))
    end

    if (asapgangs.Log) then
        self:PopulateLogs()
    else
        self:RequestUpdate()
    end
end

function PANEL:RequestUpdate()
    if (remaining < CurTime()) then
        remaining = CurTime() + 15
        net.Start("Gangs.LogViewer")
        net.SendToServer()
    end
end

function PANEL:Paint()
    draw.SimpleText("Show:", "Gangs.Medium", 16, 8, color_white)
end

function PANEL:PopulateLogs(filter)
    self.Container:Clear()
    for k,v in pairs(asapgangs.Log) do
        if (filter && filter != GANG_LOG_ALL && tonumber(v.kind) != filter) then
            continue
        end
        local log = vgui.Create("Gangs.Logs.Item", self.Container)
        log:SetData(v)
    end
end

vgui.Register("Gangs.Logs", PANEL, "DPanel")

local LOG = {}
LOG.Ready = false
function LOG:Init()
    self:Dock(TOP)
    self:SetTall(72)
    self:DockMargin(4, 4, 4, 0)
end

function LOG:SetData(data)
    self.Avatar = vgui.Create("AvatarImage", self)
    self.Avatar:Dock(LEFT)
    self.Avatar:SetWide(64)
    self.Avatar:DockMargin(4, 4, 4, 4)
    self.Avatar:SetSteamID(data.steamid, 64)

    self.Data = data
    steamworks.RequestPlayerInfo(data.steamid, function(name)
        self.Owner = name
        self.Ready = true
    end)

    self.Options = vgui.Create("Panel", self)
    self.Options:Dock(RIGHT)
    self.Options:SetWide(196)
    self.Options:DockMargin(8,8,8,8)

    self.View = vgui.Create("XeninUI.Button", self.Options)
    self.View:Dock(TOP)
    self.View:SetTall(26)
    self.View:SetRound(4)
    self.View:SetText("View")
    self.View.DoClick = function()
        Derma_Message(data.info, "Log #" .. data.id, "Close")
    end

    self.Delete = vgui.Create("XeninUI.Button", self.Options)
    self.Delete:Dock(BOTTOM)
    self.Delete:SetTall(26)
    self.Delete:SetRound(4)
    self.Delete:SetText("Delete")
    self.Delete.DoClick = function()
        net.Start("Gangs.DeleteLog")
        net.WriteInt(data.id, 16)
        net.SendToServer()
        for k,v in pairs(asapgangs.Log) do
            if (v.id == data.id) then
                table.remove(asapgangs.Log, k)
                logViewer:PopulateLogs()
                break
            end
        end
    end
end

function LOG:Paint(w,h)
    draw.RoundedBox(8, 0, 0, w, h, Color(26,26,26))
    if (self.Ready) then
        draw.SimpleText(self.Owner, "Gangs.Huge", 76, 4, Color(235, 235, 235))
        local tx,_= draw.SimpleText("Kind: ", "Gangs.Small", 76, 42, Color(235, 235, 235, 100))
        draw.SimpleText(tags[self.Data.kind], "Gangs.Small", 76 + tx, 42, colors[self.Data.kind])
    end
end

vgui.Register("Gangs.Logs.Item", LOG, "DPanel")

net.Receive("Gangs.LogViewer", function()
    local data = net.ReadTable()
    asapgangs.Log = data
    if IsValid(logViewer) then
        logViewer:PopulateLogs(asapgangs.Log)
    end
end)
