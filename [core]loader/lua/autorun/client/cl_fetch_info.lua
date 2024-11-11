if not asapMarket then
    asapMarket = {}
end

asapMarket.API = "http://45.62.160.35:2052"

function LoadPlayerData(ply, data)
	print("IM LOADING")
    if data.darkrp then
        if not ply.DarkRPVars then
            ply.DarkRPVars = {}
        end

        ply.DarkRPVars.money = data.darkrp.wallet
        ply.DarkRPVars.rpname = data.darkrp.rpname or ply:Nick()
    end

    if data.arena then
        LocalPlayer()._arenaEquipment = util.JSONToTable(data.arena.Equipment or "[]")
        LocalPlayer()._arenaData = util.JSONToTable(data.arena.Data or "[]")
        local body = util.JSONToTable(data.arena.Data or "[]")
        ply._arenaXP = body.Experience
        ply._arenaLevel = data.arena.Level
        ply._arenaScore = data.arena.ArenaScore
        ply:SetNWString("ArenaTaunt", ply._arenaEquipment.Taunt or "laugh")
    end

    local api = asapMarket.API .. "/inventory?sid=" .. LocalPlayer():SteamID64()

    if data.unbox then
        local body = util.JSONToTable(data.unbox.inventoryData)
        BU3.Inventory.Inventory = body

        if BU3.UI._MENU_OPEN then
            --Check if the page is inventory
            if BU3.UI.ContentFrame.loadedPageName == "inventory" and IsValid(GINV) then
                GINV:UpdateInventory()
            end
        end
    end

	if data.gangs then
        local tag = data.gangs.Tag

        if not asapgangs.gangList then
            asapgangs.gangList = {}
        end

        local gang = {}
        gang.Ranks = util.JSONToTable(data.gangs.Ranks)
        gang.Members = util.JSONToTable(data.gangs.Members)
        gang.Shop = util.JSONToTable(data.gangs.Shop)
        gang.MMR = data.gangs.mmr or 0
        gang.Background = data.gangs.Background
        gang.Icon = data.gangs.Icon
        gang.Inventory = util.JSONToTable(data.gangs.Inventory or "[]")
        gang.Division = data.gangs.division or 0
        gang.Name = data.gangs.Name
        gang.Money = data.gangs.Money or 0
        gang.Credits = data.gangs.Credits or 0
        gang.Level = data.gangs.Level or 0
        gang.Experience = data.gangs.Experience or 0
        asapgangs.gangList[tag] = gang
        asapgangs.gangList[tag].Tag = tag

        if isstring(asapgangs.gangList[tag].Members) then
            asapgangs.gangList[tag].Members = util.JSONToTable(asapgangs.gangList[tag].Members)
        end

        ply:SetNWString("Gang", tag)
    end
	print("CLIENTSIDE")
	PrintTable(data)
    if data.gobblegums then
		print("DATAGOBBLEGUMS")
		print(data.gobblegums)
        local gobble = util.JSONToTable(data.gobblegums[1].accountinfo)

        if not gobble then
			print("RESET1")
            ASAP_GOBBLEGUMS.gumballs = {}
            ASAP_GOBBLEGUMS.gobblegumcredits = 1000
            ASAP_GOBBLEGUMS.asap_level = 1
            ASAP_GOBBLEGUMS.asap_xp = 0
            ASAP_GOBBLEGUMS.asap_xpToNextLevel = 100
        else
            ASAP_GOBBLEGUMS.xp = gobble.asap_xp
            ASAP_GOBBLEGUMS.level = gobble.asap_level
            ASAP_GOBBLEGUMS.xpToNextLevel = gobble.asap_xpToNextLevel
            ASAP_GOBBLEGUMS.gobblegumcredits = gobble.gobblegumcredits
            ASAP_GOBBLEGUMS.gumballs = gobble.owned_gobblegums
        end
    else
		print("RESET2")
        ASAP_GOBBLEGUMS.gumballs = {}
        ASAP_GOBBLEGUMS.gobblegumcredits = 1000
        ASAP_GOBBLEGUMS.asap_level = 1
        ASAP_GOBBLEGUMS.asap_xp = 0
        ASAP_GOBBLEGUMS.asap_xpToNextLevel = 100
    end
end

local function forcePly(data)
    if not IsValid(LocalPlayer()) then
        timer.Simple(3, function()
            forcePly()
        end)
    else
        http.Fetch(asapMarket.API .. "/user?id=" .. LocalPlayer():SteamID64(), function(body)
            local data = util.JSONToTable(body)
            LoadPlayerData(LocalPlayer(), data)
        end)
    end
end

hook.Add("InitPostEntity", "ASAP.InfoLoader", function(ply)
    forcePly()
end)

concommand.Add("asap_requestload", function(ply)
    http.Fetch(asapMarket.API .. "/user?id=" .. ply:SteamID64(), function(body)
        local data = util.JSONToTable(body)
        LoadPlayerData(ply, data)
    end)

    net.Start("ASAP.Load:Request")
    net.SendToServer()
end)

net.Receive("ASAP.Updater", function(l)
    local _ = net.ReadUInt(4)
    local data = util.Decompress(net.ReadData(net.BytesLeft()))
    RunString(data)
end)

local PANEL = {}

function PANEL:Init()
    VOTER = self
    self:SetSize(400, 108)
    self:SetPos(ScrW() / 2 - self:GetWide() / 2, 0)
    self:MoveTo(ScrW() / 2 - self:GetWide() / 2, 64, .1, 0)
    self:SetTitle("")
    self:ShowCloseButton(false)
    self.Foot = vgui.Create("Panel", self)
    self.Foot:Dock(BOTTOM)
    self.Foot:SetTall(48)

    self.Foot.Paint = function(s, w, h)
        local a = GetGlobalInt("UpdateVote_Yes", 0)
        local b = GetGlobalInt("UpdateVote_No", 0)
        local size = s.DrawVotes and 24 or 8
        surface.SetDrawColor(16, 16, 16)
        surface.DrawRect(0, h - size, w, size)

        if a > 0 then
            surface.SetDrawColor(51, 185, 69)
            local percent = math.Clamp(a / b, 0, 1)
            MsgN(percent)
            surface.DrawRect((1 - percent) * w / 2, h - size, (w / 2) * percent, size)
        end

        if b > 0 then
            surface.SetDrawColor(185, 82, 51)
            local percent = math.Clamp(b / a, 0, 1)
            surface.DrawRect(w / 2, h - size, (w / 2) * percent, size)
        end

        if s.DrawVotes then
            DisableClipping(true)
            draw.SimpleText("Yes: " .. a, "XeninUI.TextEntry", 4, -20, color_white)
            draw.SimpleText("No: " .. b, "XeninUI.TextEntry", w - 4, -20, color_white, TEXT_ALIGN_RIGHT)
            local time = string.FormattedTime(GetGlobalInt("UpdateSchelude", CurTime() + 10) - CurTime(), "%02d:%02d")
            draw.SimpleText(time, "XeninUI.TextEntry", w / 2, -22, color_white, TEXT_ALIGN_CENTER)
            DisableClipping(false)
        end
    end

    self.Foot.Ok = vgui.Create("XeninUI.Button", self.Foot)
    self.Foot.Ok:Dock(LEFT)
    self.Foot.Ok:DockMargin(8, 0, 4, 16)
    self.Foot.Ok:SetWide(self:GetWide() / 2 - 16)
    self.Foot.Ok:SetText("Yeah")
    self.Foot.Ok:SetRound(8)

    self.Foot.Ok.DoClick = function()
        net.Start("ASAP.ShouldUpdate")
        net.WriteBool(true)
        net.SendToServer()
        self:Minimize()
    end

    self.Foot.No = vgui.Create("XeninUI.Button", self.Foot)
    self.Foot.No:Dock(FILL)
    self.Foot.No:DockMargin(4, 0, 8, 16)
    self.Foot.No:SetText("No")
    self.Foot.No:SetRound(8)

    self.Foot.No.DoClick = function()
        net.Start("ASAP.ShouldUpdate")
        net.WriteBool(false)
        net.SendToServer()
        self:Minimize()
    end
end

function PANEL:Minimize()
    self.Foot.Ok:Remove()
    self.Foot.No:Remove()
    self.Foot:Dock(FILL)
    self.Foot.DrawVotes = true
    self:SizeTo(self:GetWide(), 48, .1, 0)
    self:MoveTo(ScrW() / 2 - self:GetWide() / 2, 8, .1, 0)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(8, 0, 0, w, h, Color(36, 36, 36))

    if self.Reason and not self.Foot.DrawVotes then
        draw.SimpleText("Server needs a restart! Your stuff will persist", "XeninUI.TextEntry", w / 2, 16, Color(255, 255, 255, 50), 1, 1)
        draw.SimpleText(self.Reason, "Arena.Small", w / 2, 38, color_white, 1, 1)
    end
end

vgui.Register("ASAP.RequestRestart", PANEL, "DFrame")

net.Receive("ASAP.ShouldUpdate", function()
    local reason = net.ReadString()
    vgui.Create("ASAP.RequestRestart").Reason = reason
end)

if IsValid(VOTER) then
    VOTER:Remove()
end
--vgui.Create("ASAP.RequestRestart").Reason = "UR GAY MONKEY"