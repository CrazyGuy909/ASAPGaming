----------------
-- Initialize --
----------------
EFFECT.FillingTime = 9999

function EFFECT:Init(data)
    self.Entity = LocalPlayer()
    if not IsValid(self.Entity) then return end
    self.NextSplash = 0
    self.hl = 3
end

------------------
-- Effect Think --
------------------
function EFFECT:Think()
    if not LocalPlayer():GetNWBool("Dancing.Zone") then
        self.hl = self.hl - FrameTime()
        if (self.hl <= 0) then
            return false
        end
    end

    if (self.NextSplash < CurTime()) then
        self.NextSplash = CurTime() + math.Rand(.2, .7)
        local emitter = ParticleEmitter(self.Entity:GetPos())
        local particle = emitter:Add("effects/asap_balloon", self.Entity:EyePos() + self.Entity:GetAimVector() * 128 + VectorRand() * 128)

        if particle then
            particle:SetVelocity(VectorRand() * 32)
            particle:SetDieTime(math.Rand(3.1, 5.2))
            particle:SetLifeTime(0)
            particle:SetStartSize(16)
            local clr = HSVToColor(math.random(0, 360), 1, 1)
            particle:SetColor(clr.r, clr.g, clr.b, clr.a)
            particle:SetEndSize(16)
            particle:SetEndAlpha(0)
        end

        emitter:Finish()

        for k = 1, math.random(3, 5) do
            local emitter = ParticleEmitter(self.Entity:GetPos())
            local particle = emitter:Add("particles/balloon_bit", self.Entity:EyePos() + self.Entity:GetAimVector() * 16 + VectorRand() * 96 + self.Entity:GetVelocity() / 1.5 + Vector(0, 0, 60))

            if particle then
                particle:SetVelocity(Vector(0, 0, -math.random(60, 90)))
                particle:SetDieTime(math.Rand(3.1, 5.2))
                particle:SetLifeTime(0)
                particle:SetStartAlpha(math.random(30, 60))
                particle:SetStartSize(4)
                local clr = HSVToColor(math.random(0, 360), 1, 1)
                particle:SetColor(clr.r, clr.g, clr.b, clr.a)
                particle:SetEndSize(4)
                particle:SetEndAlpha(255)
            end

            emitter:Finish()
        end
    end

    return true
end