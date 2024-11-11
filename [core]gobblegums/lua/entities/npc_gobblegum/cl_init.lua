ENT.RenderGroup = RENDERGROUP_BOTH

include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:SetRagdollBones( b )
	self.m_bRagdollSetup = b
end

function ENT:DrawTranslucent()
	self:Draw()
	local pos = self:GetPos() + Vector(0,0,78)
	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Forward(), 90)
	if LocalPlayer():GetPos():Distance(self:GetPos()) < 1000 then
		cam.Start3D2D(pos + ang:Up(), Angle(0, LocalPlayer():EyeAngles().y-90, 90), 0.05)
				draw.SimpleText("GOBBLEGUMS", "Arena.Huge", 3, 3, Color(0,0,0, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)			
				draw.SimpleText("GOBBLEGUMS", "Arena.Huge", 0, 0, Color(255,255,255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_LEFT)			
		cam.End3D2D()	
	end
end


