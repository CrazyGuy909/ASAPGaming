AddCSLuaFile()
DEFINE_BASECLASS("base_anim")
ENT.PrintName = "Coffin"
ENT.Author = ""
ENT.Category = "Fun + Games"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.AutomaticFrameAdvance = true

if SERVER then
    util.AddNetworkString("Coffing.Set")
end

net.Receive("Coffing.Set", function()
    local ent = net.ReadEntity()
    local b = net.ReadBool()
    if not IsValid(ent) then return end

    if (b) then
        ent:AnimRestartGesture(GESTURE_SLOT_JUMP, ACT_HL2MP_IDLE_SUITCASE, false)
    else
        ent:AnimResetGestureSlot(GESTURE_SLOT_JUMP)
    end
end)

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "owning_ent")
end

function ENT:SpawnFunction(ply, tr, ClassName)
    local ent = ents.Create(ClassName)
    ent:SetPos(tr.HitPos + tr.HitNormal * 32)
    ent:Spawn()
    ent:Activate()

    return ent
end

function ENT:SetPlayer(ply)
    --ent:SetOwner(ply)
    self.Player = ply
    ply:SetParent(self)
    ply:Lock()
    ply:SetEyeAngles(Angle(0, 0, 0))
    ply:SetLocalPos(Vector(-4, 0, 2))

    if (ply:GetMoveType() == MOVETYPE_NONE or ply:IsFlagSet(FL_FROZEN)) then
        ply._dontunfreeze = true
    end

    ply:SetMoveType(MOVETYPE_NONE)
    net.Start("Coffing.Set")
    net.WriteEntity(ply)
    net.WriteBool(true)
    net.Broadcast()
end

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/grillsprops/coffins/grill_coffin_open.mdl")
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:DrawShadow(true)
        local phys = self:GetPhysicsObject()

        if (phys:IsValid()) then
            phys:Wake()
        end

        self.DeadTime = CurTime() + 10

        hook.Add("GravGunPickupAllowed", self, function(s, ply, ent)
            if (ent == self) then return false end
        end)
    end

end

function ENT:OnRemove()
    if SERVER then
        self.Player:SetParent(nil)
        self.Player:SetPos(self:GetPos() + self:GetUp() * 8)
        self.Player:UnLock()

        if (not self.Player._dontunfreeze) then
            self.Player:SetMoveType(MOVETYPE_WALK)
        else
            self.Player._dontunfreeze = nil
        end

        self.Player:AnimResetGestureSlot(GESTURE_SLOT_JUMP)
        net.Start("Coffing.Set")
        net.WriteEntity(self.Player)
        net.WriteBool(false)
        net.Broadcast()
    elseif (IsValid(self.Lid)) then
        self.Lid:Remove()
    end
end

ENT.Dispatched = false

function ENT:Think()
    if CLIENT then return end
    if not IsValid(self.Player) then return end

    if (self.DeadTime < CurTime() and not self.Dispatched) then
        self.Dispatched = true
        self:SetSolid(SOLID_NONE)
        SafeRemoveEntityDelayed(self, .1)

        return
    end

    if IsValid(self.Player) and self.Player:Health() < 1500 then
        local missing = 1 - (1500 - self.Player:Health()) / 1500
        self.Player:SetHealth(self.Player:Health() + missing * 100)
        self.Player:ScreenFade(SCREENFADE.IN, Color(255, 150, 0), .15, 0)
        self.Player:TakeDamage(0)
    end

    self:NextThink(CurTime() + 1)

    return true
end

ENT.LastZap = 0

function ENT:OnTakeDamage(dmg)
    if (self.LastZap < CurTime()) then
        self.LastZap = CurTime() + math.Rand(.5, 1.8)
        self:GetPhysicsObject():ApplyForceCenter(VectorRand() * 128 + Vector(0, 0, 128))
    end
end

ENT.Closed = 0

function ENT:DrawTranslucent()
    self:DrawModel()

    if not IsValid(self.Lid) then
        self.Lid = ClientsideModel("models/grillsprops/coffins/grill_coffin_lid.mdl")
        self.Lid:SetParent(self)
        self.Lid:SetLocalPos(Vector(0, 0, 0))
        self.Lid:SetLocalAngles(Angle(90, 0, 0))
        self.Lid.Progress = 90
    else
        if (self.Lid.Progress > 0) then
            self.Lid.Progress = Lerp(FrameTime() * 5, self.Lid.Progress, -1)
        end

        self.Lid:SetLocalAngles(Angle(self.Lid.Progress, 0, 0))
    end
end