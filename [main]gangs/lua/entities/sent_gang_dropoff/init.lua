AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
util.AddNetworkString("Gangs.ShaftAnimation")

function ENT:SpawnFunction(ply, tr)
    if (not tr.Hit) then return end
    local SpawnPos = tr.HitPos + tr.HitNormal * -.1
    local ent = ents.Create(self.ClassName)
    local angle = ply:GetAimVector():Angle()
    angle = Angle(0, angle.yaw, 0)
    angle:RotateAroundAxis(angle:Up(), 0)
    ent:SetAngles(angle)
    ent:SetPos(SpawnPos)
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:Initialize()
    self:SetModel("models/gonzo/zmlab/zmlab_dropoffshaft.mdl")
    self:PhysicsInitStatic(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    self:UseClientSideAnimation()
    local phys = self:GetPhysicsObject()

    if (phys:IsValid()) then
        phys:Wake()
        phys:EnableMotion(false)
    end
    --zmlab.f.Dropoffpoint_Initialize(self)
end

ENT.NextUse = 0

function ENT:AcceptInput(input, activator, caller, data)
    local ply = activator
    if (not self:GetIsClosed()) then return end
    local packages = ply:GetNWInt("Delivery.Packages", 0)

    if (packages <= 0) then
        DarkRP.notify(ply, 1, 5, "You don't have anything for us. Craft some weapons/suits parts!")

        return
    end

    if (IsValid(ply.shaftTarget) and ply.shaftTarget ~= self) then
        DarkRP.notify(ply, 1, 5, "Huuuh, I didn't ask for it, wrong shaft sucker!")

        return
    end

    if (self.NextUse > CurTime()) then return end
    self.NextUse = CurTime() + 3 + packages
    self:SetIsClosed(false)

    timer.Simple(1 + packages, function()
        self:SetIsClosed(true)
    end)

    net.Start("Gangs.ShaftAnimation")
    net.WriteEntity(ply)
    net.WriteEntity(self)
    net.WriteUInt(packages, 4)
    net.SendPAS(self:GetPos() + Vector(0, 0, 16))
    self:EmitSound("zpf/zpf_upgrade.wav")
    local totalMoney = 0

    for k, v in pairs(ply.Packages or {}) do
        totalMoney = totalMoney + asapgangs.War.Craftables[k].Price * v
    end

    for k, v in pairs(asapgangs.GetPlayers(ply:GetGang())) do
        v:addMoney(totalMoney)
    end
    DarkRP.notify(ply, 0, 7, "Your gang earned " .. DarkRP.formatMoney(totalMoney) .. "!")
    ply.Packages = nil
    ply.ShippingPost.Shipper = nil
    ply.ShippingPost = nil
    ply:SetNWInt("Delivery.Packages", 0)
    net.Start("ASAP.Gangs:RemovePackage")
    net.WriteString(ply:SteamID64())
    net.Broadcast()

    hook.Run("OnGangPackageDelivered", ply, gang, totalMoney)
end