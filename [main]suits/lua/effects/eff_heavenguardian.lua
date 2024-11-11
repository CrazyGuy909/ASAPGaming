local LIFETIME = math.random(0.2, 0.3) --  How long should this effect live?

----------------
-- Initialize --
----------------
function EFFECT:Init(data)
	self.StartPos 	= data:GetOrigin()
	self.Entity = data:GetEntity()
	self.FillingTime = CurTime() + 4

	local dlight = DynamicLight( self.Entity:EntIndex() )

	if ( dlight ) then

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

	local emitter = ParticleEmitter(self.StartPos)
	for i=1, 16 do
		local cos = math.cos((math.pi * 2) * (i / 16))
		local sin = math.sin((math.pi * 2) * (i / 16))

		local rand = math.random(1,16)
		local id = (rand > 9 and rand or ("0" .. rand))
		local particle = emitter:Add("particle/smokesprites_00" .. id,self.StartPos)
		if particle then
			particle:SetColor(150,175,100,255)
			particle:SetCollide(true)
			particle:SetRollDelta(math.Rand(-1,1))
			particle:SetVelocity(Vector(cos * 1000, sin * 1000, 5))
			particle:SetAirResistance(500)
			timer.Simple(0.25, function()
				--particle:SetVelocity(Vector(0,0,0))
				particle:SetGravity(Vector(cos * 20, sin * 20, 9.81))
				timer.Simple(2, function()
				--particle:SetVelocity(Vector(0,0,0))
					particle:SetRollDelta(math.Rand(-2,2))
					particle:SetGravity(Vector(math.Rand(-2,2), math.Rand(-2,2), 0))
				end)
			end)
			particle:SetDieTime(6)
			particle:SetLifeTime(0)
			particle:SetStartSize(24)
			particle:SetEndSize(196)
		end
	end
	emitter:Finish()

	local emitter = ParticleEmitter(self.StartPos)
	for i=1, 16 do
		local cos = math.cos((math.pi * 2) * (i / 16))
		local sin = math.sin((math.pi * 2) * (i / 16))

		local rand = math.random(1,16)
		local id = (rand > 9 and rand or ("0" .. rand))
		local particle = emitter:Add("particle/smokesprites_00" .. id,self.StartPos)
		if particle then
			particle:SetColor(200,255,150,255)
			particle:SetCollide(true)
			particle:SetRollDelta(math.Rand(-1,1))
			particle:SetVelocity(Vector(cos * 86, sin * 86, 9.81))
			particle:SetAirResistance(50)
			timer.Simple(0.25, function()
				--particle:SetVelocity(Vector(0,0,0))
				particle:SetGravity(Vector(cos * 20, sin * 20, 9.81))
				timer.Simple(2, function()
				--particle:SetVelocity(Vector(0,0,0))
					particle:SetRollDelta(math.Rand(-2,2))
					particle:SetGravity(Vector(math.Rand(-2,2), math.Rand(-2,2), 0))
				end)
			end)
			particle:SetDieTime(6)
			particle:SetLifeTime(0)
			particle:SetStartSize(32)
			particle:SetEndSize(196)
		end
	end
	emitter:Finish()
end

------------------
-- Effect Think --
------------------
function EFFECT:Think()	

	if (!IsValid(self.Entity)) then
		return false
	end

	if (self.FillingTime > CurTime()) then
		if ((self.nParticle or 0) < RealTime()) then
			self.nParticle = RealTime() + .15

			local emitter = ParticleEmitter(self.StartPos)
			for i=1, 4 do
				local cos = math.cos((math.pi * 2) * (i / 4))
				local sin = math.sin((math.pi * 2) * (i / 4))

				local rand = math.random(1,16)
				local id = (rand > 9 and rand or ("0" .. rand))
				local particle = emitter:Add("particle/smokesprites_00" .. id,self.StartPos)
				if particle then
					particle:SetColor(150,175,100,255)
					particle:SetVelocity(Vector(cos * 128, sin * 128, 9.81))
					particle:SetAirResistance(200)
					particle:SetDieTime(2.5)
					particle:SetLifeTime(0)
					particle:SetStartSize(4)
					particle:SetEndSize(16)
				end
			end
			emitter:Finish()
			
		end
		return true
	end

	return false
end


-------------------
-- Render Effect --
-------------------
function EFFECT:Render()

end
