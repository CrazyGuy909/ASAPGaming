local flash = Material("sprites/mat_jack_shockwave_white")
EFFECT.MaxAlive = 5
function EFFECT:Init(data)
    self.Origin = data:GetOrigin() + Vector(0, 0, 4)
    self.Emitter = ParticleEmitter(self.Origin, false)
    self.TimeScale = data:GetMagnitude() or 1
    self.MaxAlive = 5 / self.TimeScale

    data:GetEntity():EmitSound("thundergun/fly_thundergun_shoot.wav")
    local part = self.Emitter:Add("particle/warp5_explosion", self.Origin)
    part:SetDieTime(1 / self.TimeScale)
    part:SetStartAlpha(255)
    part:SetEndAlpha(0)
    part:SetStartSize(4)
    part:SetEndSize(256)

    local max = math.random(4, 10)
    for k = 1, max do
        local ang = (1 / max) * 2 * math.pi
        local part = self.Emitter:Add("particle/smokestack_nofog", self.Origin + Vector(0, 0, 30) + VectorRand() * 32)
        part:SetDieTime(1 / self.TimeScale)
        part:SetStartAlpha(100)
        part:SetEndAlpha(0)
        part:SetVelocity(Vector(math.cos(ang) * 64), math.sin(ang) * 64, 32)
        part:SetStartSize(4)
        part:SetColor(157, 127, 83)
        part:SetEndSize(math.random(100, 256))
    end
    self.Emitter:Finish()
    self.LifeTime = self.MaxAlive
end

function EFFECT:Think()
    if self.LifeTime > 0 then
        self.LifeTime = self.LifeTime - FrameTime()
        return true
    end
    return false
end

function EFFECT:Render()
    local progress = math.Clamp((self.MaxAlive - self.LifeTime) * self.TimeScale, 0, 1)

    render.SetMaterial(flash)
    render.DrawQuadEasy(self.Origin, Vector(0, 0, 1), 256 * progress, 256 * progress, ColorAlpha(color_white, 255 * (1 - progress)), 0, (RealTime() * 64) % 360)
end

--local eff = EffectData()
--eff:SetOrigin(p(1):GetEyeTrace().HitPos)
--util.Effect("eff_bp1", eff, true, true)