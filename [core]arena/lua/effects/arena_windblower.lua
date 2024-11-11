EFFECT.Mat = Material("effects/tool_tracer")

function EFFECT:Init(data)
    self.Crate = data:GetEntity()
end

EFFECT.NextParticle = 0
EFFECT.ExplodeAmount = 0

function EFFECT:Think()
    if (not IsValid(self.Crate)) then return false end

    if (self.NextParticle < RealTime()) then
        self.NextParticle = RealTime() + (self.Crate:GetFallProgress() < 100 and .05 or math.Rand(0, .25))
        local emitter = ParticleEmitter(self.Crate:GetPos())
        local part = emitter:Add("particle/smokesprites_000" .. math.random(1, 9), self.Crate:GetPos() + self.Crate:GetRight() * 128 + self.Crate:GetUp() * 64)

        if (part) then
            part:SetDieTime(3) -- How long the particle should "live"
            part:SetStartAlpha(255) -- Starting alpha of the particle
            part:SetStartSize(64) -- Starting size
            part:SetEndSize(512) -- Size when removed
            part:SetGravity(self.Crate:GetAngles():Right() * 512) -- Gravity of the particle
            part:SetColor(255, 125, 0)
            part:SetVelocity(self.Crate:GetAngles():Right() * 64 + VectorRand() * 64)
            part:SetEndAlpha(0)
        end

        emitter:Finish()
    end

    return true
end

EFFECT.Ripple = Material("particle/warp1_warp")
EFFECT.Splash = false

function EFFECT:Render()
    if not IsValid(self.Crate) then return end

    if (self.Crate:GetFallProgress() >= 100) then
        if (not self.Splash) then
            self.Splash = true

            timer.Simple(0.05, function()
                local emitter = ParticleEmitter(self.Crate:GetPos())

                for k = 0, 25 do
                    local part = emitter:Add("particle/smokesprites_000" .. math.random(1, 9), self.Crate:GetPos() + self.Crate:GetUp() * 64 + self.Crate:GetForward() * -200 + VectorRand() * 64)
                    part:SetDieTime(math.Rand(1, 3))
                    part:SetStartAlpha(255)
                    part:SetEndAlpha(0)
                    part:SetStartSize(32)
                    part:SetEndSize(math.random(32, 128))
                    part:SetColor(75, 75, 75)
                    part:SetGravity(Vector(0, 0, 64) + VectorRand() * 96)
                    part:SetVelocity(self.Crate:GetUp() * 172 + Vector(0, 0, 32))
                end
            end)
        end

        self.ExplodeAmount = Lerp(FrameTime() * 15, self.ExplodeAmount, self.FallExplode and 0 or 100)
        render.SetMaterial(self.Ripple)
        cam.IgnoreZ(true)
        render.DrawSprite(self.Crate:GetPos(), self.ExplodeAmount * 32, self.ExplodeAmount * 32, color_white)
        cam.IgnoreZ(false)

        if (self.ExplodeAmount > 90) then
            self.FallExplode = true
        end
    end
end