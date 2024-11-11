include("shared.lua")
include("capturepoints.lua")

ENT.CanPlayStop = false
ENT.CacheID = nil
ENT.NextPoints = 0
ENT.NextContestMessage = 0
ENT.Contesting = {}
function ENT:Think()
    local found = 0
    local factionContesting
    local isBlocking = false
    local contesting = {}
    for k, v in pairs(ents.FindInBox(self:GetPos() -self:GetBounds() / 2, self:GetPos() + self:GetBounds() / 2)) do
        if (not v:IsPlayer()) then continue end
        if (not v:Alive()) then continue end
        local gangName = v:GetGang()
        if (gangName == "") then continue end
        if (gangName == self:GetFaction()) then
            if (self:GetIsCapturing()) then
                isBlocking = true
                break
            end
        else
            if not factionContesting then
                factionContesting = gangName
            end
            contesting[v] = true
            v.contesting = self
            found = found + 1
        end
    end

    for ply, _ in pairs(self.Contesting) do
        if not IsValid(ply) then
            contesting[ply] = nil
            continue
        end
        if not contesting[ply] then
            ply.contesting = nil
        end
    end
    self.Contesting = contesting

    if found == 0 and self.CanPlayStop then
        self.CanPlayStop = false
        self:EmitSound("misc/hologram_stop.wav", 100)
    end

    if (isBlocking != self:GetIsBlocking()) then
        self:SetIsBlocking(isBlocking)
        if (self:GetIsBlocking() and !self._playingNoise) then
            self:EmitSound("misc/hologram_stop.wav", 100)
            self.NextPoints = CurTime() + 30
            self._playingNoise = self:StartLoopingSound("misc/hologram_malfunction.wav", 100)
        elseif not self:GetIsBlocking() then
            if self._playingNoise then
                self:StopLoopingSound(self._playingNoise)
                self._playingNoise = nil
            end
        end
    end

    if (found > 0 and not self:GetIsCapturing() and not self:GetIsBlocking()) then
        self:SetIsCapturing(true)
        if (self.NextContestMessage < CurTime()) then
            self.NextContestMessage = CurTime() + 60
            for k, v in pairs(player.GetAll()) do
                if (v:GetGang() == self:GetFaction()) then
                    DarkRP.notify(v, 0, 10, "Your control point " .. self:GetZoneName() .. " it's being contested!")
                end
            end
        end
        self.CanPlayStop = true
        self:EmitSound("misc/hologram_start.wav", 100)
        if not self._movesound then
            self._movesound = self:StartLoopingSound("misc/hologram_move.wav", 100)
        end
    end


    self:SetSpeed(found)
    if (factionContesting != self:GetFaction() and not self:GetIsBlocking() and found > 0) then
        self:SetProgress(self:GetProgress() + .1 * self:GetSpeed())
        if (self:GetProgress() >= 100) then
            self:SetProgress(0)
            for k, v in pairs(contesting) do
                hook.Run("OnControlPointCaptured", self, factionContesting, k)
            end
            self:UpdateFaction(factionContesting)
            self:NextThink(CurTime() + 1)
            return true
        end
    end

    if (self:GetProgress() >= 0 and found == 0 and self:GetIsCapturing() and not self:GetIsBlocking()) then
        self:SetProgress(self:GetProgress() - 2)
        if (self:GetProgress() <= 0) then
            if (self._movesound) then
                self:StopLoopingSound(self._movesound)
                self._movesound = nil
            end
            self:SetIsCapturing(false)
            self:SetProgress(0)
            self:SetIsBlocking(false)
            self.NextPoints = CurTime() + 30
            self:NextThink(CurTime() + 1)
            return true
        end
    end

    if (self.NextPoints < CurTime()) then
        self.NextPoints = CurTime() + 60
        asapgangs.AddXP(self.CacheID, math.random(1, 2), true)
        for k, v in pairs(player.GetAll()) do
            if (v:GetGang() == self:GetFaction()) then
                v:addMoney(750)
            end
        end
    end

    self:NextThink(CurTime() + (self:GetIsCapturing() and .05 or .25))
    return true
end


function ENT:UpdateFaction(faction)
    for k, v in pairs(player.GetAll()) do
        if (v:GetGang() == faction) then
            self.CacheID = v:GetGang()
            asapgangs.AddXP(v:GetGang(), 10)
            break
        end
    end
    self:SetIsCapturing(false)
    self:SetSpeed(0)
    self:SetIsBlocking(false)
    self:EmitSound("misc/achievement_earned.wav", 100)
    self:SetFaction(faction)
    if (self._movesound) then
        self:StopLoopingSound(self._movesound)
        self._movesound = nil
    end
    if (self._playingNoise) then
        self:StopLoopingSound(self._playingNoise)
        self._playingNoise = nil
    end

    DarkRP.notifyAll(0, 7.5, "The " .. faction .. " gang has captured the " .. self:GetZoneName() .. " control point!")
    RunConsoleCommand("asap_savecp")
end

