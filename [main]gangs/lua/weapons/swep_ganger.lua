AddCSLuaFile()
SWEP.Base = "weapon_base"
SWEP.Category = "ASAP Gangs"
SWEP.PrintName = "Gang Provider"
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_arms_citizen.mdl"

SWEP.SpawnEntities = {
    [1] = "sent_gang_delivery",
    [2] = "sent_gang_manufacture_table",
    [3] = "sent_gang_portal",
    [4] = "sent_gang_pot"
}

SWEP.Info = {
    [1] = "Prepare your cargo here to sell in dropoffs",
    [2] = "Craft pieces of materials to create rarest materials to sell",
    [3] = "As miner, you can dig materials from a differet material",
    [4] = "Main ingredient for the Manufacture Table, to spawn more pots, you have to craft rarer parts"
}

SWEP.SpawnLimits = {
    [1] = 1,
    [2] = 2,
    [3] = 1,
    [4] = 4
}

function SWEP:SetupDataTables()
    self:NetworkVar("Int", 0, "SpawnClass")
    self:SetSpawnClass(1)
    self:NetworkVarNotify("SpawnClass", function(ent, name, old, new)
        self.spawningClass = ent.SpawnEntities[new]
        if not self.spawningClass then return end
        if CLIENT then
            self:Wait(0, function()
                self:CreateGhostModel()
            end)
        end
    end)
end

function SWEP:Initialize()
    self:SetHoldType("normal")
    self:SetSpawnClass(1)
    self.spawningClass = self.SpawnEntities[self:GetSpawnClass()]
end

function SWEP:CreateGhostModel()
    SafeRemoveEntity(self.Ghost)
    if not self.SpawnEntities[self:GetSpawnClass()] then return end
    self.Ghost = ClientsideModel(scripted_ents.Get(self.SpawnEntities[self:GetSpawnClass()]).Model, RENDERGROUP_OPAQUE)
    self.Ghost:SetNoDraw(true)
end

SWEP.RotateLerp = Angle(0, 0, 0)
SWEP.RotateAmount = 0
function SWEP:Think()
    if SERVER then return end

    local owner = self:GetOwner()
    local tr = util.TraceLine({
        start = owner:GetShootPos(),
        endpos = owner:GetShootPos() + owner:GetAimVector() * 256,
        filter = owner
    })

    if not IsValid(self.Ghost) then
        self:CreateGhostModel()
        return
    end
    self.RotateLerp = LerpAngle(FrameTime() * 2, self.Ghost:GetAngles(), Angle(0, owner:EyeAngles().y + (self.RotateAmount or 0) * 90, 0))
    self.Ghost:SetPos(tr.HitPos + tr.HitNormal * 0.5)
    self.Ghost:SetAngles(self.RotateLerp)
end

function SWEP:PostDrawViewModel()
    if not IsValid(self.Ghost) then return end
    render.SetBlend(.5)
    self.Ghost:DrawModel()
    render.SetBlend(1)
end

function SWEP:GetLevel()
    local owner = self:GetOwner()
    if not IsValid(owner.GangComputer) then
        return
    end

    if not owner.GangComputer.Resources then
        return 1
    end

    local level = 1
    for k = 1, 10 do
        if (level < k and owner.GangComputer.Resources[k] and owner.GangComputer.Resources[k] >= 0) then
            level = k
        end
    end

    return math.ceil(level / 2)
end

function SWEP:OnRemove()
    if CLIENT then
        SafeRemoveEntity(self.Ghost)
    end
end

function SWEP:PrimaryAttack()
    if not IsFirstTimePredicted() then return end
    if CLIENT then return end

    local target = self:GetOwner():GetEyeTrace().Entity
    if (IsValid(target) and target.owner == self:GetOwner()) then
        SafeRemoveEntity(target)
        return
    end

    self:SetNextPrimaryFire(CurTime() + 2)

    local class = self.SpawnEntities[self:GetSpawnClass()]
    local canSpawn = true
    local gang = self:GetOwner():GetGang()
    local count = self.SpawnLimits[self:GetSpawnClass()]

    if (self:GetSpawnClass() == 4) then
        count = self:GetLevel()
    end

    for k, v in pairs(ents.FindByClass(class)) do
        if (v:GetGang() == gang) then
            count = count - 1
            if (count <= 0) then
                canSpawn = false
                break
            end
        end
    end

    if not canSpawn then
        self:GetOwner():ChatPrint("<color=red>Your gang has reached the limit of this entity!</color>")
        return
    end

    local tr = util.TraceLine({
        start = self:GetOwner():GetShootPos(),
        endpos = self:GetOwner():GetShootPos() + self:GetOwner():GetAimVector() * 256,
        filter = self:GetOwner()
    })
    local ent = ents.Create(class)
    ent:SetPos(tr.HitPos)
    ent:SetAngles(Angle(0, self:GetOwner():EyeAngles().y + self.RotateAmount * 90, 0))
    ent:SetGang(gang)
    ent:SetSpawnEffect(true)
    ent:Spawn()
    ent:EmitSound("zpf/zpf_upgrade.wav")
    ent.GangComputer = self:GetOwner().GangComputer

    if (class == "sent_gang_portal") then
        ent:SetAngles(tr.HitNormal:Angle())
    end
    ent.owner = self:GetOwner()

    hook.Run("OnGangEntitySpawned", gang, ent)
end

function SWEP:SecondaryAttack()
    if not IsFirstTimePredicted() then return end

    self:SetNextSecondaryFire(CurTime() + .5)
    local target = self:GetSpawnClass() + 1
    if (target > #self.SpawnEntities) then
        target = 1
    end
    self:SetSpawnClass(target)
end

function SWEP:Rotate(am)
    self.RotateAmount = tonumber(am)
end

function SWEP:Reload()
    if CLIENT then return end
    if not IsFirstTimePredicted() then return end
    if (self.nextReload or 0) > CurTime() then return end

    self.RotateAmount = (self.RotateAmount + 1) % 4
    self.nextReload = CurTime() + .5
    self:CallOnClient("Rotate", self.RotateAmount)
end

SWEP.CacheTimer = 0
SWEP.EntitiesCache = nil

local color_red, color_green = Color(214, 32, 32), Color(31, 215, 31)
local bright = Material("particle/particle_glow_04")
function SWEP:DrawHUD()
    if not self.EntitiesCache then
        self.EntitiesCache = {}
        for k, v in pairs(self.SpawnEntities) do
            self.EntitiesCache[k] = {
                class = v,
                name = scripted_ents.Get(v).PrintName,
                count = 0
            }
        end
    end

    if (self.CacheTimer < CurTime()) then
        self.CacheTimer = CurTime() + 1
        for k, v in pairs(self.EntitiesCache) do
            local count = 0
            for i, ent in pairs(ents.FindByClass(v.class)) do
                if (ent:GetGang() == self:GetOwner():GetGang()) then
                    count = count + 1
                end
            end
            v.count = count
        end
    end

    local div = (ScrW() * .8) / #self.EntitiesCache
    local x = ScrW() / 2 - div * (#self.EntitiesCache / 2) + div / 2
    local infoName
    for k, v in pairs(self.EntitiesCache) do
        local fontSize = k == self:GetSpawnClass() and 48 or 20
        if (k == self:GetSpawnClass()) then
            surface.SetMaterial(bright)
            surface.SetDrawColor(color_black)
            surface.SetFont(XeninUI:Font(fontSize))
            local tx, _ = surface.GetTextSize(v.name)
            surface.DrawTexturedRectRotated(x, ScrH() / 2 + 112, tx * 2, 256, 0)
        end
        draw.SimpleTextOutlined(v.name, XeninUI:Font(fontSize), x, ScrH() / 2 + 96, k == self:GetSpawnClass() and Color(255, 255, 255) or Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
        local canSpawn = v.count < self.SpawnLimits[k]
        draw.SimpleTextOutlined(v.count .. " / " .. (k == 4 and self:GetLevel() or self.SpawnLimits[k]), XeninUI:Font(fontSize), x, ScrH() / 2 + 96 + fontSize * .8, k == self:GetSpawnClass() and (canSpawn and color_green or color_red) or Color(255, 255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
        infoName = self.Info[k]
        x = x + div
    end

    draw.SimpleTextOutlined(infoName, XeninUI:Font(24), ScrW() / 2, ScrH() / 2 + 96 + 96, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_black)
end