local LIFETIME = math.random(0.2, 0.3) --  How long should this effect live?

----------------
-- Initialize --
----------------
function EFFECT:Init(data)
    self.Entity = data:GetEntity()
    self.StartPos = self.Entity:GetPos()
    self.FillingTime = CurTime() + 4
    local dlight = DynamicLight(self.Entity:EntIndex())

    if (dlight) then
        local c = color_white
        dlight.Pos = self.StartPos
        dlight.r = 255
        dlight.g = 255
        dlight.b = 255
        dlight.Brightness = 10
        dlight.Size = 256
        dlight.DieTime = CurTime() + 0.07
        dlight.Decay = 256
        EmitSound("weapons/hegrenade/explode3.wav", self.StartPos, self.Entity:EntIndex(), CHAN_AUTO, 1, 75, 0, 200)
    end
end

------------------
-- Effect Think --
------------------
function EFFECT:Think()
    if (not IsValid(self.Entity)) then return false end
    self.StartPos = self.Entity:GetPos()

    if ((self.nParticle or 0) < RealTime()) then
        self.nParticle = RealTime() + .15
        local emitter = ParticleEmitter(self.StartPos)

        for i = 1, 4 do
            local cos = math.cos((math.pi * 2) * (i / 4))
            local sin = math.sin((math.pi * 2) * (i / 4))
            local rand = math.random(1, 16)
            local id = (rand > 9 and rand or ("0" .. rand))
            local particle = emitter:Add("particle/smokesprites_00" .. id, self.StartPos)

            if particle then
                particle:SetColor(150, 175, 100, 255)
                particle:SetVelocity(Vector(cos * 196, sin * 196, -64))
                particle:SetAirResistance(75)
                particle:SetDieTime(2)
                particle:SetLifeTime(0)
                particle:SetStartSize(4)
                particle:SetEndSize(128)
            end
        end

        emitter:Finish()
    end

    return true
end

-------------------
-- Render Effect --
-------------------
function EFFECT:Render()
end