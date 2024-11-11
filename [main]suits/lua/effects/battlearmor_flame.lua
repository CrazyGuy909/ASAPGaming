function EFFECT:Init(data)
if CLIENT then
	local ply = data:GetEntity()
	local propeller1_pos = ply:GetAttachment(ply:LookupAttachment("Jetpack_L1"))
	if (propeller1_pos == nil) then return end
	propeller1_pos = propeller1_pos.Pos
	
	local propeller2_pos = ply:GetAttachment(ply:LookupAttachment("Jetpack_R1"))
	propeller2_pos = propeller2_pos.Pos

	local emitter1 = ParticleEmitter(propeller1_pos, false)
	local emitter2 = ParticleEmitter(propeller2_pos, false)
	local particle = {}
	
	for j=0,2 do
		particle[1] = emitter1:Add("models/mechassault/lonewolf/battle_armor/jumpjets", propeller1_pos)
		particle[2] = emitter2:Add("models/mechassault/lonewolf/battle_armor/jumpjets", propeller2_pos)
		
			local light = DynamicLight(ply:EntIndex())
        if (light) then
            light.Pos = ply:GetPos()
            light.r = 40
            light.g = 40
            light.b = 155
            light.Brightness = 8
            light.Decay = 10
            light.Size = 140
            light.DieTime = CurTime() + 0.1
        end
		
		if (particle[1] and particle[2]) then
			for i=1,2 do
				particle[i]:SetDieTime(0.06)
				particle[i]:SetStartAlpha(255)
				particle[i]:SetEndAlpha(0)
				particle[i]:SetStartSize(math.Rand(4, 4.2))
				particle[i]:SetEndSize(math.random(0.5, 1))
				particle[i]:SetRoll(math.random(0, 0))
				particle[i]:SetRollDelta(math.random(0, 0))
				particle[i]:SetCollide(true)
				particle[i]:SetAirResistance( 90 )
			end
		end
	end
	
	for j=0,1 do
		particle[1] = emitter1:Add("particle/smokesprites_000" .. math.random(1, 9), propeller1_pos)
		particle[2] = emitter2:Add("particle/smokesprites_000" .. math.random(1, 9), propeller2_pos)
		
		if (particle[1] and particle[2]) then
			for i=1,2 do
				particle[i]:SetDieTime(0.08)
				particle[i]:SetStartAlpha(255)
				particle[i]:SetEndAlpha(0)
				particle[i]:SetStartSize(math.Rand(4, 4.5))
				particle[i]:SetEndSize(math.random(0.5, 1))
				particle[i]:SetRoll(math.random(-10, 10))
				particle[i]:SetRollDelta(math.random(-10, 10))
				particle[i]:SetCollide(true)
				particle[i]:SetColor(40, 40, 80)
				particle[i]:SetAirResistance( 90 )
			end
		end
	end
	
	emitter1:Finish()
	emitter2:Finish()
end
end
		
function EFFECT:Think()
	return false
end

function EFFECT:Render()
end