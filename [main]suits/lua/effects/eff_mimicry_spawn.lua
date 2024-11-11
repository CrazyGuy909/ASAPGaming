
----------------
-- Initialize --
----------------
EFFECT.FillingTime = 9999
function EFFECT:Init(data)
    self.StartPos = data:GetOrigin()
    local scale = data:GetMagnitude() or 1
    self.FillingTime = CurTime() + 4 * scale
    local dlight = DynamicLight(self.Entity:EntIndex())

    if (dlight) then
        dlight.Pos = self.StartPos
        dlight.r = 255
        dlight.g = 255
        dlight.b = 50
        dlight.Brightness = 10
        dlight.Size = 256
        dlight.DieTime = CurTime() + 1
        dlight.Decay = 256
    end

    local emitter = ParticleEmitter(self.StartPos)
    local particle = emitter:Add("asap/armors/fire_ring", self.StartPos)

    if particle then
        particle:SetVelocity(Vector(0, 0, -64))
        particle:SetDieTime(.5)
        particle:SetLifeTime(0)
        particle:SetStartSize(4)
        particle:SetEndSize(500 * scale)
    end

    local emitter = ParticleEmitter(self.StartPos)

    for i = 1, math.random(8, 32) * scale do
        local particle = emitter:Add("asap/armors/fire", self.StartPos)

        if particle then
            particle:SetVelocity(VectorRand() * 256 * scale)
            particle:SetAirResistance(75)
            particle:SetDieTime(math.Rand(1.2, 2.5) * scale)
            particle:SetLifeTime(0)
            particle:SetStartSize(4)
            particle:SetEndSize(128 * scale)
        end
    end

    emitter:Finish()
end

------------------
-- Effect Think --
------------------
function EFFECT:Think()
    if (self.FillingTime < CurTime()) then return false end
    return true
end

-------------------
-- Render Effect --
-------------------

function EFFECT:Render()
end