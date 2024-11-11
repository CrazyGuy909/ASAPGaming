include("shared.lua")
GANG_SHAFTS = GANG_SHAFTS or {}

function ENT:Initialize()
    self.Closed = true
    self.RenderStencil = false
    self:CreateClientSideModel()
    GANG_SHAFTS[self:EntIndex()] = self
end

function ENT:CreateClientSideModel()
    self.csModel = ClientsideModel("models/zerochain/zmlab/zmlab_dropoffshaft_shaft.mdl")
    self.csModel:SetPos(self:GetPos())
    self.csModel:SetAngles(self:GetAngles())
    self.csModel:SetParent(self)
    self.csModel:SetNoDraw(true)
end

function ENT:Draw()
    self:DrawModel()
    --self:ThinkNow()
end

function ENT:DrawTranslucent()
    self:Draw()
end

function ENT:Think()
    if IsValid(self.csModel) then
        self.csModel:SetPos(self:GetPos())
        self.csModel:SetAngles(self:GetAngles())
    end

    local closed = self:GetIsClosed()

    if self.Closed ~= closed then
        self.Closed = closed

        if self.Closed then
            zmlab.f.ClientAnim(self, "close", 2)
            self:EmitSound("DropOffSpawn")

            timer.Simple(2, function()
                if IsValid(self) then
                    self.RenderStencil = false
                end
            end)
        else
            self.RenderStencil = true
            zmlab.f.ClientAnim(self, "open", 1)
            self:EmitSound("DropOffSpawn")
        end
    end

    self:SetNextClientThink(CurTime())

    return true
end

function ENT:OnRemove()
    self.csModel:Remove()
end

function ENT:SendPackages(ply, packages)
	for k, v in pairs(self.Animables or {}) do
		if IsValid(v) then
			v:Remove()
		end
	end

	self.Animables = {}

	for k = 1, packages do
		timer.Simple(.5 + k / 1.5, function()
			local ent = ents.CreateClientProp("models/props_survival/cases/case_tools_static.mdl")
			ent:SetSolid(SOLID_NONE)
			ent:SetModelScale(math.Rand(.3, .5), 0)
			ent:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
			ent:SetPos(self:GetPos() + Vector(0, 0, 64))
			ent:DrawShadow(false)
			ent:SetAngles(AngleRand() * 360)
			ent:Spawn()
			--ent:SetNoDraw(true)
			ent:SetLocalAngularVelocity(AngleRand() * 360)
			timer.Simple(3, function()
				if IsValid(ent) then
					ent:Remove()
				end
			end)
			table.insert(self.Animables, ent)
		end)
	end
end

net.Receive("Gangs.ShaftAnimation", function(l)
	local ply = net.ReadEntity()
	local shaft = net.ReadEntity()
	local packages = net.ReadUInt(4)
	if IsValid(shaft) and IsValid(ply) then
		shaft:SendPackages(ply, packages)
	end
end)

hook.Add("PreDrawTranslucentRenderables", "zmlabdrawdropoff2", function(depth, skybox)
    if skybox then return end
    if depth then return end

    for k, s in pairs(GANG_SHAFTS) do
        if not IsValid(s) then continue end
        if (s.RenderStencil == false) then continue end
        render.ClearStencil()
        render.SetStencilEnable(true)
        render.SetStencilWriteMask(255)
        render.SetStencilTestMask(255)
        render.SetStencilReferenceValue(57)
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
        render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
        render.SetStencilFailOperation(STENCIL_ZERO)
        render.SetStencilZFailOperation(STENCIL_ZERO)
        cam.Start3D2D(s:GetPos() + s:GetUp() * 1, s:GetAngles(), 0.5)
        draw.RoundedBox(0, -45, -45, 90, 90, color_white)
        cam.End3D2D()
        render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
        render.SuppressEngineLighting(true)
        render.DepthRange(0, 0.8)

        if (IsValid(s.csModel)) then
			s.csModel:DrawModel()
			for _, v in pairs(s.Animables or {}) do
				if IsValid(v) then
					v:DrawModel()
				end
			end
        else
            s:CreateClientSideModel()
        end

        render.SuppressEngineLighting(false)
        render.SetStencilEnable(false)
        render.DepthRange(0, 1)
    end
end)