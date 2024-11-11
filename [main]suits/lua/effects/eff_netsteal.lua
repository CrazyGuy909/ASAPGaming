local wave = Material("effects/hl2mmod/hl2mmod_energy_trail_2")
local ganjah = Material("sprites/plasmagun_ball")
local destroy = Material("tracers/tracer_starchaser_ring")
function EFFECT:Init(data)
    self.Start = data:GetOrigin() + Vector(0, 0, 32)
    self.Angles = data:GetAngles()
    self.Type = data:GetFlags()
    self.Progress = 0
    self.InitTime = RealTime()
    self.LifeTime = 1
    self:SetRenderBoundsWS(self.Start, self.Start, Vector(4096, 4096, 4096))
end

function EFFECT:Think()
    if (self.LifeTime <= 0) then return false end
    self.LifeTime = self.LifeTime - FrameTime()
    self.Progress = math.Clamp((RealTime() - self.InitTime) / 1, 0, 1)
    return true
end

function EFFECT:Render()

    render.SetMaterial(self.Type == 1 and wave or (self.Type == 2 and ganjah or destroy))
    if (self.Type < 3) then
        render.StartBeam(9)
        local i = 0
        for k = -4, 4 do
            local x, y = math.cos((k / 16) * math.pi + math.rad(self.Angles.y)) * self.Progress * 1024, math.sin((k / 16) * math.pi + math.rad(self.Angles.y)) * self.Progress * 1024
            local pos = self.Start + Vector(x, y, 0)
            render.AddBeam(pos, 128 * (1 - math.abs(k) / 4), i / 9, Color(255, 255, 255, 255 * ((self.LifeTime / 5) ^ .5)))
            i = i + 1
        end
        render.EndBeam()
    else
        render.SetBlend(1 - self.Progress)
        render.DrawQuadEasy(self.Start + Vector(0, 0, 16), Vector(0, 0, 1), self.Progress * 512, self.Progress * 512, Color(255, 255, 255, 255 * (1 - self.Progress)), RealTime() * -256)
        render.SetBlend(1)
    end
end