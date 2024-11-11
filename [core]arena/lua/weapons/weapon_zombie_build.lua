if (SERVER) then
    SWEP.Weight = 5
    SWEP.AutoSwitchTo = false
    SWEP.AutoSwitchFrom = false
    util.AddNetworkString("Zombies.BuildScrap")

    if TTT then
        SWEP.EquipMenuData = nil
    end
end

if (CLIENT) then
    SWEP.Slot = TTT and 6 or 2
    SWEP.SlotPos = 0
end

SWEP.ShootSound = Sound("Airboat.FireGunRevDown")
SWEP.PrintName = "Builder Hand"
SWEP.Category = "Galaxium"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.ViewModel = "models/weapons/c_toolgun.mdl"
SWEP.WorldModel = "models/weapons/w_toolgun.mdl"
util.PrecacheModel(SWEP.ViewModel)
util.PrecacheModel(SWEP.WorldModel)

Zombie_PropSpawn = {
    {
        MDL = "models/props_c17/concrete_barrier001a.mdl",
        Price = 300,
        Name = "Barricade",
        Health = 500,
        Z = 0,
        Size = Vector(1, 2, 1)
    },
    {
        MDL = "models/props_c17/FurnitureWashingmachine001a.mdl",
        Price = 900,
        Name = "Washer",
        Health = 1350,
        Z = 16,
        Size = Vector(1, 1, 1)
    },
    {
        MDL = "models/props_wasteland/kitchen_fridge001a.mdl",
        Price = 1800,
        Name = "Fridge",
        Z = 0,
        Health = 2000,
        Size = Vector(1, 1, 2)
    },
    {
        MDL = "models/props_wasteland/laundry_dryer001.mdl",
        Price = 1400,
        Name = "Big Washer",
        Z = 64,
        Health = 1800,
        Size = Vector(1, 1, 2)
    },
    {
        MDL = "models/props_c17/shelfunit01a.mdl",
        Price = 400,
        Name = "Shelf",
        Z = 0,
        fixYaw = 90,
        Health = 500,
        Size = Vector(2, 1, 2)
    },
    {
        MDL = "models/props_junk/wood_crate001a.mdl",
        Price = 300,
        Name = "Small Crate",
        Z = 20,
        Health = 300,
        Size = Vector(1, 1, 1)
    },
    {
        MDL = "models/props_junk/wood_crate002a.mdl",
        Price = 350,
        Health = 400,
        Name = "Big Crate",
        Z = 20,
        Size = Vector(1, 2, 2)
    },
    {
        MDL = "models/props_lab/blastdoor001b.mdl",
        Price = 2100,
        Health = 2500,
        Name = "Small Metal door",
        Z = 0,
        Size = Vector(1, 1, 2)
    },
    {
        MDL = "models/props_lab/blastdoor001c.mdl",
        Price = 2500,
        Health = 3000,
        Name = "Big Metal door",
        Z = 0,
        Size = Vector(1, 2, 2)
    }
}

--This also used for variable declaration and SetVar/GetVar getting work
function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "Selection")
    self:NetworkVar("Int", 1, "Rotation")
    self:SetSelection(1)
end

function SWEP:Deploy()
    if CLIENT then
        hook.Add("PreDrawHalos", self, function()
            if (not IsValid(LocalPlayer():GetActiveWeapon())) then
                hook.Remove("PostDrawTranslucentRenderables", self)

                return
            end

            if (LocalPlayer():GetActiveWeapon() ~= self) then
                hook.Remove("PostDrawTranslucentRenderables", self)

                return
            end

            if IsValid(self.Selected) then
                halo.Add({self.Selected}, Color(255, 200, 75), 2, 2, 1, true, true)
            end
        end)

        hook.Add("PostDrawTranslucentRenderables", self, function()
            if (not IsValid(LocalPlayer():GetActiveWeapon())) then
                hook.Remove("PostDrawTranslucentRenderables", self)

                return
            end

            if (LocalPlayer():GetActiveWeapon() ~= self) then
                hook.Remove("PostDrawTranslucentRenderables", self)

                return
            end

            self:Draw3D()
        end)
    else
        self:CallOnClient("Deploy")
    end

    self:SendWeaponAnim(ACT_SLAM_DETONATOR_DRAW)
end

function SWEP:PrimaryAttack()
    if (CurTime() < self:GetNextPrimaryFire()) then return end
    if (not IsFirstTimePredicted()) then return end
    local tr = self.Owner:GetEyeTrace()
    if (tr.HitPos:Distance(self.Owner:GetShootPos()) > 350) then return end
    self:SetNextPrimaryFire(CurTime() + .1)
    local data = Zombie_PropSpawn[self:GetSelection()]

    if (data.Price > self.Owner:GetNWInt("ArenaMoney", 0)) then
        if CLIENT then
            notification.AddLegacy("You don't have enough money", NOTIFY_ERROR, 3)
        end

        return
    end

    self.Owner:SetNWInt("ArenaMoney", self.Owner:GetNWInt("ArenaMoney", 0) - data.Price)

    if SERVER then
        local ent = ents.Create("sent_zombie_barrier")
        ent:SetPos(self.Owner:GetEyeTrace().HitPos + Vector(0, 0, data.Z))
        ent:SetAngles(Angle(0, self.Owner:EyeAngles().y + (data.fixYaw or 0), 0))
        ent:SetSpawnEffect(true)
        ent:Spawn()
        ent:SetMaker(self.Owner)
        ent:SetType(self:GetSelection())
        ent:Init(data)
        ent:Activate()
    else
        self.Scale = 0
    end

    local trace = self.Owner:GetEyeTrace()
    local effectdata = EffectData()
    effectdata:SetOrigin(trace.HitPos)
    effectdata:SetStart(self.Owner:GetShootPos())
    effectdata:SetAttachment(1)
    effectdata:SetEntity(self)
    self:EmitSound(self.ShootSound)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) -- View model animation
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    util.Effect("arena_barrier_birth", effectdata)
end

function SWEP:Initialize()
    self:Deploy()
    self:SetHoldType("revolver")
end

function SWEP:Holster(wep, force)
    if SERVER then
        self:CallOnClient("OnHolster")
    else
        hook.Remove("PreDrawHalos", self)
        hook.Remove("PostDrawTranslucentRenderables", self)

        if IsValid(self.Ghost) then
            self.Ghost:Remove()
        end
    end

    return true
end

function SWEP:SecondaryAttack()
    if (CurTime() < self:GetNextSecondaryFire()) then return end
    if (not IsFirstTimePredicted()) then return end
    local trace = self.Owner:GetEyeTrace()
    if (trace.HitPos:Distance(self.Owner:GetShootPos()) > 350) then return end
    if (not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "sent_zombie_barrier") then return end
    if trace.Entity:GetMaker() ~= self.Owner then return end
    self.Owner:SetNWInt("ArenaMoney", self.Owner:GetNWInt("ArenaMoney", 0) + Zombie_PropSpawn[trace.Entity:GetType()].Price)
    self:SetNextSecondaryFire(CurTime() + 1)

    if IsFirstTimePredicted() and CLIENT then
        surface.PlaySound("ui/hint.wav")
    end

    local effectdata = EffectData()
    effectdata:SetOrigin(trace.HitPos)
    effectdata:SetStart(self.Owner:GetShootPos())
    effectdata:SetAttachment(1)
    effectdata:SetEntity(self)
    self:EmitSound(self.ShootSound)
    self:SendWeaponAnim(ACT_VM_PRIMARYATTACK) -- View model animation
    self.Owner:SetAnimation(PLAYER_ATTACK1)
    util.Effect("arena_barrier_birth", effectdata, true, true)

    if SERVER then
        trace.Entity:Kill()
    end

    return true
end

local wait = 0

function SWEP:Reload()
    if not IsFirstTimePredicted() then return end
    if (wait > CurTime()) then return end
    wait = CurTime() + .5
    local sel = self:GetSelection()
    sel = sel + 1

    if (sel > #Zombie_PropSpawn) then
        sel = 1
    end

    self:SetSelection(sel)

    if CLIENT and IsValid(self.View) then
        self.View:SetModel(Zombie_PropSpawn[self:GetSelection()].MDL)

        if IsValid(self.Ghost) then
            self.Ghost:SetModel(Zombie_PropSpawn[self:GetSelection()].MDL)
        end

        local PrevMins, PrevMaxs = self.View.Entity:GetRenderBounds()
        self.View:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.5, 0.5, 0.5))
        self.View:SetLookAt((PrevMaxs + PrevMins) / 2)
        surface.PlaySound("garrysmod/ui_return.wav")
    end

    return true
end

if SERVER then return end
-- GetRenderTarget returns the texture if it exists, or creates it if it doesn't
local TEX_SIZE = 256
local RTTexture = RT.Create("Builder_ToolGun", TEX_SIZE, TEX_SIZE)
local matScreen = Material("models/weapons/v_toolgun/screen")

function SWEP:DrawHUD()
end

--[[---------------------------------------------------------
	We use this opportunity to draw to the toolmode
		screen's rendertarget texture.
-----------------------------------------------------------]]
SWEP.DoReload = true

function SWEP:RenderScreen()
    if (self.DoReload) then
        if IsValid(self.View) then
            self.View:Remove()
        end

        self.View = vgui.Create("DModelPanel")
        self.View:SetPaintedManually(true)
        self.View:SetSize(TEX_SIZE - 8, TEX_SIZE - 96)
        self.View:SetPos(4, 48)
        self.View:SetModel(Zombie_PropSpawn[self:GetSelection()].MDL)
        local PrevMins, PrevMaxs = self.View.Entity:GetRenderBounds()
        self.View:SetCamPos(PrevMins:Distance(PrevMaxs) * Vector(0.5, 0.5, 0.5))
        self.View:SetLookAt((PrevMaxs + PrevMins) / 2)
        self.View:SetFOV(90)

        self.View.PaintOver = function(s, w, h)
            surface.SetDrawColor(255, 00, 0)
            surface.DrawOutlinedRect(0, 0, w, h)
        end

        self.DoReload = false
    end

    -- Set the material of the screen to our render target
    matScreen:SetTexture("$basetexture", RTTexture)
    RT.Pop(RTTexture)
    -- Background
    surface.SetDrawColor(36, 36, 36, 255)
    surface.DrawRect(0, 0, TEX_SIZE, TEX_SIZE)
    self.View:PaintManual()
    surface.SetDrawColor(56, 56, 56)
    surface.DrawRect(0, 0, TEX_SIZE, 48)
    surface.DrawRect(0, TEX_SIZE - 48, TEX_SIZE, 48)
    draw.SimpleText(Zombie_PropSpawn[self:GetSelection()].Name, "Arena.Medium", TEX_SIZE / 2, 64, color_white, 1)
    draw.SimpleText(DarkRP.formatMoney(Zombie_PropSpawn[self:GetSelection()].Price), "Arena.Medium", TEX_SIZE / 2, TEX_SIZE - 92, color_white, 1)
    draw.SimpleText("Zombie Builder v3.49", "Arena.Small", TEX_SIZE / 2, 12, color_white, 1)
    draw.SimpleText("[Spawn]", "Arena.Small", 8, TEX_SIZE - 38, color_white, 0)
    draw.SimpleText("[Remove]", "Arena.Small", TEX_SIZE - 10, TEX_SIZE - 38, color_white, 2)
    RT.Push(RTTexture)
end

SWEP.Angle = Angle(0, 0, 0)
SWEP.Scale = .7

function SWEP:Draw3D()
    local tr = LocalPlayer():GetEyeTrace()
    local element = Zombie_PropSpawn[self:GetSelection()]
    self.Angle = Angle(0, self.Owner:EyeAngles().y + (element.fixYaw or 0), 0)

    if (tr.HitWorld or not tr.Entity:IsPlayer()) then
        if (not IsValid(self.Ghost)) then
            self.Ghost = ClientsideModel(element.MDL)
            self.Ghost:SetNoDraw(true)
        end

        local clr = tr.HitPos:Distance(self.Owner:GetShootPos()) < 350 and Color(0, 175, 175, 175) or Color(255, 75, 75, 100)
        self.Ghost:SetPos(tr.HitPos + tr.HitNormal * (element.Z or 16))
        self.Ghost:SetAngles(self.Angle)

        if (self.Scale < 0.7) then
            self.Scale = Lerp(FrameTime() * 2, self.Scale, .8)
        end

        render.SetBlend(self.Scale)
        render.SetColorMaterial()
        render.CullMode(MATERIAL_CULLMODE_CW)
        render.DrawSphere(tr.HitPos, 350, 30, 30, clr)
        render.CullMode(MATERIAL_CULLMODE_CCW)
        render.DrawSphere(tr.HitPos, 350, 30, 30, clr)
        self.Ghost:DrawModel()
        render.SetBlend(1)
    end
end