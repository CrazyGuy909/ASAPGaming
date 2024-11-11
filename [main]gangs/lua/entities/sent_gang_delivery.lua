AddCSLuaFile()
ENT.Type = "anim"
ENT.Category = "ASAP Gangs"
ENT.PrintName = "Delivery Pallet"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Base = "base_anim"
ENT.Editable = true
ENT.Model = Model("models/props_junk/wood_pallet001a.mdl")
util.PrecacheModel("models/props_survival/cases/case_tools_static.mdl")
if SERVER then
    util.AddNetworkString("ASAP.Gangs:RemovePackage")
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "Gang")
    self:NetworkVar("Int", 1, "Delivery")
    self:SetDelivery(0)
end

function ENT:SpawnFunction(ply, tr, class)
    local ent = ents.Create(class)
    ent:SetPos(tr.HitPos)
    ent:SetAngles(Angle(0, 0, 0))
    ent:Spawn()
    ent:Activate()

    return ent
end

-- Configs --
function ENT:Initialize()
    self:SetModel(self.Model)

    if SERVER then
        self:PhysicsInitBox(-Vector(32, 32, 4), Vector(32, 32, 48))
        self:PhysicsInitStatic(SOLID_BBOX)
        self:Activate()
        self:SetUseType(SIMPLE_USE)
    end
end

local crates = {"models/props_junk/cardboard_box001a.mdl", "models/props_junk/cardboard_box002a.mdl", "models/props_junk/cardboard_box003a.mdl", "models/props_junk/cardboard_box004a.mdl"}
if SERVER then
    util.AddNetworkString("Gangs.OpenDeliveryMenu")
end
function ENT:Use(act)
    if (IsValid(self.Shipper)) then
        DarkRP.notify(act, 1, 10, self.Shipper:Nick() .. " it's already shipping a package, wait until it's been delivered!")
        return
    end
    if (self:GetGang() == act:GetGang()) then
        net.Start("Gangs.OpenDeliveryMenu")
        net.Send(act)
        act._tempOutpost = self
    end
    /*
    self:SetDelivery(self:GetDelivery() + 1)

    if (self:GetDelivery() > 4) then
        self:SetDelivery(0)
    end
    */
end

function ENT:OnRemove()
    if (CLIENT and self.InitModels) then
        for k, v in pairs(self.CModels) do
            v:Remove()
        end
    end
end

local offsets = {0, 0, 3, 8}

ENT.Activated = 0

function ENT:Draw()
    self:DrawModel()

    if not self.InitModels then
        self.InitModels = true
        self.CModels = {}

        for k = 1, 4 do
            local id = math.random(1, 4)
            local ent = ClientsideModel(crates[id])
            ent:SetParent(self)
            local x = (k % 2) * 34 - 16
            local y = math.ceil(k / 2) * 32 - 50
            local z = 16 - offsets[k]
            ent:SetLocalPos(Vector(x, y, z))
            ent:SetLocalAngles(Angle(0, math.random(-5, 5) + (id == 3 and 90 or 0)))
            ent:SetNoDraw(true)
            table.insert(self.CModels, ent)
        end
    elseif (self.Activated ~= self:GetDelivery()) then
        local toEnable = self:GetDelivery() - self.Activated
        local cnt = math.abs(toEnable)

        for k, v in RandomPairs(self.CModels) do
            if (cnt <= 0) then break end
            if not IsValid(v) then continue end
            if (toEnable > 0 and v:GetNoDraw()) then
                v:SetNoDraw(false)
                v:SetParent(self)
                local id = math.random(1, 4)
                v:SetModelScale(id < 3 and math.Rand(.5, .8) or 1, 0)
                local x = (k % 2) * 34 - 16
                local y = math.ceil(k / 2) * 32 - 50
                local z = 16 - offsets[id] - (id < 3 and v:GetModelScale() * 4 or 0)
                v:SetLocalPos(Vector(x, y, z))
                v:SetModel(crates[id])
                v:SetLocalAngles(Angle(0, math.random(-5, 5) + (id == 3 and 90 or 0)))
                cnt = cnt - 1
            end

            if (toEnable < 0 and not v:GetNoDraw()) then
                v:SetNoDraw(true)
                cnt = cnt - 1
            end
        end

        self.Activated = self:GetDelivery()
    end
end

hook.Add("PlayerDeath", "PackageDeliveryDeath", function(ply)
    if (not ply.Packages) then return end
    net.Start("ASAP.Gangs:RemovePackage")
    net.WriteString(ply:SteamID64())
    net.Broadcast()
    if IsValid(ply.ShippingPost) then
        ply.ShippingPost.Shipper = nil
    end
    ply.Packages = {}
end)

hook.Add("PlayerDisconnected", "PackageDeliveryDeath", function(ply)
    if (not ply.Packages) then return end
    net.Start("ASAP.Gangs:RemovePackage")
    net.WriteString(ply:SteamID64())
    net.Broadcast()
    if IsValid(ply.ShippingPost) then
        ply.ShippingPost.Shipper = nil
    end
end)

PACKAGE_POOL = PACKAGE_POOL or {}
hook.Add("PostPlayerDraw", "PackageDelivery", function(ply)
    local packages = ply:GetNWInt("Delivery.Packages", 0)
    if not ply:Alive() then return end
    if not ply.cPackages then
        ply.cPackages = {}
    end
    if (packages <= 0) then
        if (table.Count(ply.cPackages) > 0) then
            for k, v in pairs(ply.cPackages or {}) do
                SafeRemoveEntity(v)
            end
            ply.cPackages = {}
        end
        return
    end

    if packages != table.Count(ply.cPackages) then
        for k, v in pairs(ply.cPackages or {}) do
            SafeRemoveEntity(v)
        end
        ply.cPackages = {}
        for k = 1, packages do
            local ent = ClientsideModel("models/props_survival/cases/case_tools_static.mdl")
            ent:SetLocalPos(Vector(0, 0, 0))
            ent:SetModelScale(math.Rand(.25, .5), 0)
            ent.TotalScale = ent:GetModelScale()
            ent:SetNoDraw(true)
            ent.Scale = 18 * ent:GetModelScale()
            ent.Randomness = math.Rand(-20, 20)
            if not PACKAGE_POOL[ply:SteamID64()] then
                PACKAGE_POOL[ply:SteamID64()] = {}
            end
            table.insert(PACKAGE_POOL[ply:SteamID64()], ent)
            table.insert(ply.cPackages, ent)
        end
    end

    local i = 0
    local boneID = ply:LookupBone("ValveBiped.Bip01_Spine") or -1
    if (boneID != -1) then
        local pos, ang = ply:GetBonePosition(boneID)
        ang:RotateAroundAxis(ang:Right(), 90)
        local up = 0
        for k, v in pairs(ply.cPackages or {}) do
            if not IsValid(v) then
                table.remove(ply.cPackages, k)
                continue
            end
            ang:RotateAroundAxis(ang:Up(), v.Randomness)
            v:SetModelScale(v.TotalScale, 0)
            i = i + 1
            v:DrawModel()
            up = up + v.Scale
            v:SetPos(pos + ang:Right() * (12 - i * 1.5) - ang:Up() * up)
            v:SetAngles(ang)
        end
    end
end)

net.Receive("ASAP.Gangs:RemovePackage", function()
    local sid = net.ReadString()
    if (PACKAGE_POOL[sid]) then
        for k, v in pairs(PACKAGE_POOL[sid]) do
            if IsValid(v) then
                v:Remove()
            end
        end
        PACKAGE_POOL[sid] = nil
    end
end)