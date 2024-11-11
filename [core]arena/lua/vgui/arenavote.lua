local PANEL = {}

function PANEL:Init()
    if IsValid(VOTE) then
        VOTE:Remove()
    end

    VOTE = self
    self:SetSize(500, 232)
    self:SetTitle("Vote next event")
    self:SetPos(0, 8)
    self:CenterHorizontal()
    self:ShowCloseButton(false)
    self.timerSeconds = 0
    self.Options = {}
end

function PANEL:CreateOptions(data)
    local wide = (self:GetWide() - 16 * 4) / 3
    self.timerSeconds = 15
    self.Options = {}
    local i = 0

    for k, v in pairs(data) do
        local card = vgui.Create("DPanel", self)
        card:Dock(LEFT)
        card:DockMargin(16, 16, 0, 24)
        card:SetWide(wide)
        card:SetTooltip(v.Description)
        card.Mat = Material(v.Icon or "vgui/arena/logo256.png")
        card.column = i

        card.Paint = function(s, w, h)
            if (self.SelectTime) then
                local percent = math.floor((RealTime() * 6) % 3)

                if (self.SelectTime <= 0) then
                    percent = self.Options[self.SelectWinner].column
                else
                    if (percent ~= self.lastPercent) then
                        self.lastPercent = percent
                        LocalPlayer():EmitSound("tfc/weapons/airgun_1.wav", 75, 100, .5)
                    end
                end

                draw.RoundedBox(8, 0, 0, w, h, percent == s.column and Color(201, 123, 60) or Color(36, 36, 36))
            else
                draw.RoundedBox(8, 0, 0, w, h, (s:IsHovered() or s.Vote:IsHovered()) and Color(46, 46, 46) or Color(36, 36, 36))
            end

            surface.SetMaterial(s.Mat)
            surface.SetDrawColor(color_white)
            surface.DrawTexturedRectRotated(w / 2, h / 3 - 2, h * .8, h * .8, 0)
            draw.SimpleText(v.Name, "XeninUI.TextEntry", w / 2, h / 2 + 12, color_white, 1)
        end

        card.Vote = vgui.Create("XeninUI.Button", card)
        card.Vote:Dock(BOTTOM)
        card.Vote:SetText("Vote")
        card.Vote:DockMargin(8, 8, 8, 8)
        card.Vote.ID = k

        card.Vote.Think = function(s)
            s:SetText((asapArena.GameVotes[s.ID] or 0) .. " vote/s")
        end

        card.Vote.DoClick = function(s)
            if (self.SelectTime) then return end
            net.Start("Arena.Votes:DoVote")
            net.WriteString(s.ID)
            net.SendToServer()
            surface.PlaySound("czero/wpn_moveselect.wav")
        end

        card.Vote:SetRound(8)
        i = i + 1
        self.Options[v.id] = card
    end
end

function PANEL:SetWinnerAnim(winner)
    self.SelectTime = 2.5
    self.SelectWinner = winner

    timer.Simple(2.5, function()
        surface.PlaySound("dragonsbreath/dragon_primary_3.wav")
    end)
    timer.Simple(5, function()
        if IsValid(self) then
            self:Remove()
        end
    end)
end

function PANEL:Think()
    if (self.timerSeconds > 0) then
        self.timerSeconds = self.timerSeconds - FrameTime()
    end

    if (self.SelectTime and self.SelectTime > 0) then
        self.SelectTime = self.SelectTime - FrameTime()
    end
end

function PANEL:PaintOver(w, h)
    if (self.timerSeconds > 0) then
        draw.RoundedBox(4, 8, h - 12, w - 8, 8, Color(16, 16, 16))
        draw.RoundedBox(4, 4, h - 12, (w - 8) * (self.timerSeconds / 20), 8, Color(135, 196, 51))
    end
end

vgui.Register("arena.vote", PANEL, "XeninUI.Frame")

if IsValid(VOTE) then
    VOTE:Remove()
end
--vgui.Create("arena.vote")