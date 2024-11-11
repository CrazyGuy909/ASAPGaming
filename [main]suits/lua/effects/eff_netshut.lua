local beam = Material("particle/muzzleflash_burst_add")
local halo = Material("particle/energy_swave_warp2")
local tractor = Material("particle/beam_smoke_02")
local tractor_glow = Material("particle/beam_warp")
local plasma = Material("sprites/sgmissile_plasma_ball")

function EFFECT:Init(data)
    self.Entity = data:GetEntity()
    self:SetRenderBounds(Vector(-1024, -1024, -1024), Vector(-1024, -1024, -1024) * -1)
    self.Entity:EmitSound("tfa_cso2/weapons/taserknife/taserknife_deploy.wav")
    self.Life = CurTime() + 5
    self.Start = 0
    self.NextCheck = 0
    self.Targets = {}
end

function EFFECT:Render()
    local life = self.Life - CurTime()
    if (life > 1) then
        self.Start = math.min(self.Start + FrameTime() * 4, 1)
    else
        self.Start = self.Life - CurTime()
    end
    render.SetMaterial(halo)
    render.DrawSprite(self.Entity:GetPos() + Vector(0, 0, 30), 96 * self.Start, 96 * self.Start, color_white)

    for k, v in pairs(self.Targets) do
        self.Targets[k] = ((RealTime() * 3) % 1)
        local a = k:GetPos() + Vector(0, 0, 50)
        local b = self.Entity:GetPos() + Vector(0, 0, 50)
        local lerp_start = LerpVector(self.Targets[k] - .25, a, b)
        local lerp_end = LerpVector(self.Targets[k] + .25, a, b)
        render.SetMaterial(tractor_glow)
        render.DrawBeam(a, b, 24, self.Targets[k], self.Targets[k] + 1, Color(120, 200, 255))
        render.SetMaterial(beam)
        render.DrawBeam(lerp_start, lerp_end, 24, 1, 0, Color(120, 200, 255))
        render.SetMaterial(tractor)
        render.DrawBeam(a, b, 24, self.Targets[k], self.Targets[k] + 1, Color(120, 200, 255))
        render.SetMaterial(plasma)
        render.DrawSprite(a + EyeAngles():Forward() * -16, 64, 64, color_white)
    end
end

function EFFECT:Think()
    if (not IsValid(self.Entity) or self.Life < CurTime()) then return false end

    if (self.NextCheck < CurTime()) then
        self.NextCheck = CurTime() + 1
        self.Targets = {}
        for k, v in pairs(ents.FindInSphere(self.Entity:GetPos(), 350)) do
            if (not v:IsPlayer()) then continue end
            if (v:GetGang() != "" and v:GetGang() == self.Entity:GetGang()) then continue end
            self.Targets[v] = 0
        end
    end
    return true
end