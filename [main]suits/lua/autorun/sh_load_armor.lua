Armor = {}
Armor.Data = {}
Armor.Dictionary = {}

function Armor:Add(tab)
    self.Dictionary[tab.Entitie] = tab

    local oldDescription = tab.Description
    tab.Description = ""
    local items = {}
    if (tab.Speed) then
        table.insert(items, "<color=246,168,0>+" .. (100 * tab.Speed) .. "% Run Speed</color>")
    end
    if (tab.Armor) then
        table.insert(items, "<color=0,172,246>" .. tab.Armor .. "AP</color>")
    end
    if (tab.Health) then
        table.insert(items, "<color=198,27,27>" .. tab.Health .. "HP</color>")
    end
    if (tab.Wallhack or tab.WallHack) then
        table.insert(items, "<color=234,0,255>WallHacks</color>")
    end
    tab.Description = table.concat(items, " - ") .. (oldDescription and " - Abilities: " .. oldDescription or "")

    for k, v in pairs(self.Data) do
        if v.Name == tab.Name then
            self.Data[k] = tab

            return
        end
    end

    tab.IsCosmetic = _ARMOR_COSMETIC

    table.insert(self.Data, tab)
end

function Armor:Get(name)
    if not name then return nil end

    for k, v in pairs(self.Data) do
        if v.Name == name then return v end
    end

    return nil
end

function Armor:GetByID(id)
    if not id then return nil end

    return self.Dictionary[id]
end

if SERVER then
    AddCSLuaFile("armor/cl_armor.lua")
    AddCSLuaFile("armor/cl_wallhack.lua")
    AddCSLuaFile("armor/sh_crafting.lua")
    AddCSLuaFile("armor/suits_bp1.lua")
    AddCSLuaFile("armor/suits_cosmetic.lua")
    AddCSLuaFile("armor/suits_default.lua")
    AddCSLuaFile("armor/suits_destiny.lua")
    AddCSLuaFile("armor/destiny/zeroarmor.lua")
    AddCSLuaFile("armor/destiny/honosuit.lua")
    AddCSLuaFile("armor/destiny/extinctionsuit.lua")
    AddCSLuaFile("armor/destiny/rioter.lua")
    AddCSLuaFile("armor/destiny/heavenguardian.lua")
    AddCSLuaFile("armor/destiny/bp5suits.lua")
    AddCSLuaFile("armor/bp7/bubbletake.lua")
    AddCSLuaFile("armor/bp7/extrasuits.lua")
    AddCSLuaFile("armor/bp7/mimicry.lua")
    AddCSLuaFile("armor/bp7/rescuer.lua")
    AddCSLuaFile("armor/bp7/orangesuit.lua")
    AddCSLuaFile("armor/bp7/psycho.lua")
    include("armor/sv_armor.lua")
else
    include("armor/cl_armor.lua")
    include("armor/cl_wallhack.lua")
end

include("armor/sh_crafting.lua")
_ARMOR_COSMETIC = true
include("armor/suits_cosmetic.lua")
_ARMOR_COSMETIC = false
include("armor/suits_default.lua")
include("armor/suits_destiny.lua")
include("armor/suits_bp1.lua")
include("armor/destiny/zeroarmor.lua")
include("armor/destiny/honosuit.lua")
include("armor/destiny/extinctionsuit.lua")
include("armor/destiny/rioter.lua")
include("armor/destiny/heavenguardian.lua")
include("armor/destiny/bp5suits.lua")
include("armor/bp7/psycho.lua")
include("armor/bp7/bubbletake.lua")
include("armor/bp7/extrasuits.lua")
include("armor/bp7/mimicry.lua")
include("armor/bp7/rescuer.lua")
include("armor/bp7/orangesuit.lua")
include("armor/bp8/armor_bulletsmith.lua")
include("armor/bp8/armor_bladesmith.lua")
include("armor/bp8/armor_gunsmith.lua")
include("armor/bp8/armor_trinity.lua")
include("armor/bp8/armor_karma.lua")
include("armor/bp8/armor_skolas.lua")

for k, v in pairs(file.Find("armor/bp3/*.lua", "LUA")) do
    AddCSLuaFile("armor/bp3/" .. v)
    include("armor/bp3/" .. v)
end
if CLIENT then
    surface.CreateFont("ArmorFixedFont", {
        font = "Trebuchet18", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
        extended = false,
        size = 60,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false
    })
end

for k, v in pairs(Armor.Data) do
    local ENT = {}
    ENT.Type = "anim"
    ENT.Base = "base_gmodentity"
    ENT.PrintName = v.Name
    ENT.Category = "ASAP Suits"
    ENT.Author = "Gonzo"
    ENT.Spawnable = true
    ENT.AdminOnly = true
    ENT.DisableDuplicator = true
    ENT.DoNotDuplicate = true
    ENT.IconOverride = "reticle/thorndecal"
    ENT.IsCosmetic = v.IsCosmetic

    if SERVER then
        function ENT:SpawnFunction(ply, tr, cs)
            if not tr.Hit then return end

            if not ply:IsAdmin() then
                ply:Kick()

                return
            end

            local SpawnPos = tr.HitPos + tr.HitNormal * 16
            local ent = ents.Create(cs)
            ent:SetPos(SpawnPos)
            ent:Spawn()
            ent:Activate()
            ent.CannotPickup = true

            return ent
        end

        function ENT:Initialize()
            self:SetModel("models/Items/item_item_crate.mdl")
            self:PhysicsInit(SOLID_VPHYSICS)
            self:SetMoveType(MOVETYPE_VPHYSICS)
            self:SetSolid(SOLID_VPHYSICS)
            self:SetUseType(SIMPLE_USE)
            local phys = self:GetPhysicsObject()
            phys:Wake()
        end

        function ENT:Use(ply)
            if v.Blacklist and table.HasValue(v.Blacklist, ply:Team()) then
                DarkRP.notify(ply, 1, 4, "You can't equip this suit as your job!")

                return
            end

            if ply.armorSuit then
                DarkRP.notify(ply, 1, 5, "You have to drop your suit to put on another suit")

                return
            end

            if (self.IsTainted and not self.IsCosmetic) then
                hook.Run("OnSuitStole", ply, v.Name, self)
            end

            ply:giveArmorSuit(v.Name)
            if not self.CannotPickup then
                ply.armorEquipped = v.Name
            end
            self:Remove()
        end
    else
        function ENT:Draw()
            self:DrawModel()
            local angle = Angle(0, 0, 0)
            angle:RotateAroundAxis(Vector(1, 0, 0), 90)
            angle.y = LocalPlayer():GetAngles().y + 90 + 180
            local pos = self:GetPos() + Vector(0, 0, 32)
            cam.Start3D2D(pos, angle, 0.2)
            draw.SimpleTextOutlined(v.Name, "ArmorFixedFont", 0, 0, color_white, 1, 1, 1, Color(60, 157, 208))
            cam.End3D2D()
        end
    end

    scripted_ents.Register(ENT, v.Entitie)
end

local binds = {
    [KEY_B] = 1,
    [KEY_N] = 2,
    [KEY_M] = 3,
    [KEY_K] = 4
}

local colorAbilities = {Color(255, 114, 58), Color(58, 197, 255), Color(146, 255, 58), Color(255, 58, 253)}

if SERVER then
    util.AddNetworkString("Armor.SendAbility")
end

net.Receive("Armor.SendAbility", function(l, ply)
    Armor:DoKeyPress(ply, net.ReadUInt(7))
end)

function Armor:DoKeyPress(ply, btn, id)
    if IsFirstTimePredicted() and btn == KEY_F7 then
        RunConsoleCommand("battlepass")

        return
    end

    if not ply.armorSuit then return end

    if CLIENT then
        net.Start("Armor.SendAbility")
        net.WriteUInt(btn, 7)
        net.SendToServer()
    end

    if not ply:GetNWBool("AllowAbilities", true) then return end
    local armor = Armor:Get(ply.armorSuit)
    if not binds[btn] then return end

    if armor.Abilities then
        if not armor.Abilities[binds[btn]] then return end
        local ability = armor.Abilities[binds[btn]]

        if not ply._newCooldowns then
            ply._newCooldowns = {
                [ply.armorSuit] = {}
            }
        end

        if not ply._newCooldowns[ply.armorSuit] then
            ply._newCooldowns[ply.armorSuit] = {}
        end

        if ply._newCooldowns[ply.armorSuit] and (ply._newCooldowns[ply.armorSuit][binds[btn]] or 0) > CurTime() then
            if CLIENT then
                surface.PlaySound("common/wpn_denyselect.wav")
            end

            return false
        end

        local ret, reason = ability.Action(armor, ply)

        if ret == false then
            if CLIENT then
                surface.PlaySound("common/wpn_denyselect.wav")
                chat.AddText(Color(255, 81, 81), reason or "You can't cast this ability now!")
            end

            return
        end

        if CLIENT and ability.Description then
            chat.AddText(color_white, "[", colorAbilities[binds[btn]], string.upper(keybinds.getKey("ability_" .. id)), color_white, "] ", Color(235, 235, 235), ability.Description)
        end

        ply._newCooldowns[ply.armorSuit][binds[btn]] = CurTime() + (isnumber(ret) and ret or ability.Cooldown)

        return
    end

    if armor.OnAbility and (ply.lastArmorAbilityUsed or 0) < CurTime() then
        local ret = armor.OnAbility(ply)

        if ret == false then
            if CLIENT then
                surface.PlaySound("common/wpn_denyselect.wav")
            end

            return
        end

        ply.lastArmorAbilityUsed = CurTime() + (armor.Cooldown or 10)
        ply.armorCooldown = armor.Cooldown or 10

        return
    end
end