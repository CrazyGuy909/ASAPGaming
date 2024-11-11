EFFECT.Mat = Material("effects/tool_tracer")

function EFFECT:DoEmit(finalPos, size, max)
    finalPos = finalPos + max / 4
    local emitter = ParticleEmitter(finalPos)
    local part = emitter:Add( "particle/smokesprites_000" .. math.random(1, 9), finalPos) -- Create a new particle at pos
    if ( part ) then
        part:SetDieTime( .5 ) -- How long the particle should "live"

        part:SetStartAlpha( 100 ) -- Starting alpha of the particle
        part:SetEndAlpha( 0 ) -- Particle size at the end if its lifetime

        part:SetStartSize( size ) -- Starting size
        part:SetEndSize( size * 1.5 ) -- Size when removed

        part:SetGravity( Vector( 0, 0, 150 ) ) -- Gravity of the particle
        part:SetVelocity( VectorRand() * 50 ) -- Initial velocity of the particle
    end
    emitter:Finish()
end

function EFFECT:Init(data)
    self.Parent = data:GetEntity()
    if (not IsValid(self.Parent)) then return end
    self.Start = self.Parent:GetPos()
    self:SetPos(Vector(9999, 9999, 99999))
    self.Direction = self.Parent:GetAngles()
    self.Shadow = ClientsideModel(self.Parent:GetModel())
    self.Shadow:SetPos(self.Start)
    self.Shadow:SetAngles(self.Direction)
    self.Shadow.Scale = Vector(1, 1, 1)
    self.Shadow.Matrix = Matrix()
    timer.Simple(2, function()
        if IsValid(self.Shadow) then
            self.Shadow:Remove()
        end
    end)

    local size = Zombie_PropSpawn[self.Parent:GetType()].Size or Vector(2, 2, 2)
    local min, max = self.Parent:GetCollisionBounds()
    local minWS = self.Parent:LocalToWorld(min)
    local maxWS = self.Parent:LocalToWorld(max)
    local propSize = max - min
    local fwd = self.Parent:GetForward()
    local sid = self.Parent:GetRight()
    local upw = self.Parent:GetUp()
    local finalPos = minWS
    
    for x = 0, size.x == 1 and 0 or size.x do
        local lerpedx = LerpVector(x / size.x, self.Start - fwd * (propSize.x * size.x) / 4, self.Start + fwd * (propSize.x * size.x) / 4)
        self:DoEmit(lerpedx, propSize.x / size.x, max)
        for y = 0, size.y == 1 and 0 or size.y do
            local lerpedxy = LerpVector(y / size.y, lerpedx - sid * (propSize.y * size.y) / 4, lerpedx + sid * (propSize.y * size.y) / 4)
            self:DoEmit(lerpedxy, propSize.y / size.y, max)
            for z = 0, size.z == 1 and 0 or size.z do
                local lerpedxyz = LerpVector(z / size.z, lerpedxy - upw * (propSize.z * size.z) / 4, lerpedxy + upw * (propSize.z * size.z) / 4)
                self:DoEmit(lerpedxyz, propSize.z / size.z, max)
            end
        end
        
    end

end

function EFFECT:Think()
    if (IsValid(self.Shadow)) then
        self.Shadow.Matrix:Scale(self.Shadow.Scale * .98)
        self.Shadow.Matrix:Rotate(Angle(1, 1, 0))
        self.Shadow:SetPos(self.Shadow:GetPos() + Vector(0, 0, 1))
        if (self.Shadow.Matrix:GetScale().x <= 0) then
            return false
        end
        self.Shadow:EnableMatrix("RenderMultiply", self.Shadow.Matrix)
    end

    return IsValid(self.Shadow)
end