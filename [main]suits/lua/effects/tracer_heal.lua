EFFECT.Mat = Material("asap/armors/heal_ray")
EFFECT.Life = 1

function EFFECT:Init(data)
    self.Position = data:GetStart()

    -- Keep the start and end pos - we're going to interpolate between them
    self.EndPos = data:GetOrigin()
    self.StartPos = self.Position
    self.Dist = self.EndPos:Distance(self.StartPos) / 100
    self.Alpha = 255
    self.Life = 0
    self:SetRenderBoundsWS(self.StartPos, self.EndPos)
end

function EFFECT:Think()
    if (not self.Dist) then return true end
    self.Life = self.Life + FrameTime() * (20 - self.Dist)
    self.Alpha = 255 * (1 - self.Life)

    return self.Life < 1
end

function EFFECT:Render()
    if ((self.Alpha or 255) < 1) then return end
    if (not self.StartPos) then return end
    render.SetMaterial(self.Mat)
    local norm = (self.StartPos - self.EndPos) * self.Life
    local direction = -(self.StartPos - self.EndPos):GetNormalized()
    self.Length = norm:Length()
    render.DrawBeam(self.StartPos - norm - direction * self.Life, self.StartPos - norm + direction * 128, 32, 0, 1, Color(255, 255, 255))
end