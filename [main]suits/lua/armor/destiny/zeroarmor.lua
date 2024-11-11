AddCSLuaFile()

if SERVER then
    util.AddNetworkString("ArmorDLC.RemoveZero")
    util.AddNetworkString("ArmorDLC.ToggleMask")
end

Armor:Add({
    Name = "ZERO Suit",
    Description = "Creates a double of you that you can control",
    Model = "models/konnie/asapgaming/destiny2/titanretrograde.mdl",
    Entitie = "armor_zero",
    Armor = 1000,
    Health = 2500,
    Speed = 1.5,
    OnGive = function(ply)
        ply:SetNW2Bool("ZeroArmor", true)
    end,
    -- what happens when they get the suit equipped
    Abilities = {
        [1] = {
            Cooldown = 30,
            Action = function(s, ply)
                ply:SetNW2Bool("CrazyShadow", not ply:GetNW2Bool("CrazyShadow"))

                if SERVER then
                    net.Start("ArmorDLC.ToggleMask")
                    net.WriteEntity(ply)
                    net.WriteBool(ply:GetNW2Bool("CrazyShadow"))
                    net.SendPVS(ply:GetPos())
                elseif (ply:GetNW2Bool("CrazyShadow")) then
                    ply._cooldown = 3
                end

                if (ply:GetNW2Bool("CrazyShadow")) then
                    ply:SetNW2Bool("ZeroInvisible", true)
                    ply:SetMaterial("models/shadertest/shader3")

                    ply:Wait(3, function()
                        ply:SetNW2Bool("ZeroInvisible", false)
                        ply:SetMaterial("")
                    end)
                end
            end
        }
    },
    OnRemove = function(ply)
        ply:SetMaterial("")
        ply:SetNW2Bool("ZeroArmor", false)
        net.Start("ArmorDLC.RemoveZero")
        net.WriteEntity(ply)
        net.Broadcast()
    end
})

net.Receive("ArmorDLC.RemoveZero", function()
    local target = net.ReadEntity()
    target:SetNW2Bool("ZeroArmor", false)

    if IsValid(target._zeroShadow) then
        target._zeroShadow:Remove()
    end
end)

net.Receive("ArmorDLC.ToggleMask", function()
    local target = net.ReadEntity()
    local b = net.ReadBool()

    if (not b) then
        timer.Simple(0, function()
            local effectdata = EffectData()
            effectdata:SetOrigin(target._zeroShadow:GetPos())
            util.Effect("zero_illusion", effectdata)
        end)
    end
end)

hook.Add("Move", "Zero.Movement", function(ply, mv)
    if (not ply:GetNW2Bool("ZeroArmor")) then return end

    if (CLIENT and ply:GetNW2Bool("CrazyShadow")) then
        local shadow = ply._zeroShadow
        if (not IsValid(shadow)) then return end
        local dir = shadow.Direction or Angle(0, 0, 0)
        ply._lerpShadow = LerpVector(FrameTime() * 5, ply._lerpShadow or Vector(0, 0, 0), Vector(dir:Right(), dir:Forward(), 0))
        shadow:SetPoseParameter("move_y", ply._lerpShadow.x)
        shadow:SetPoseParameter("move_x", -ply._lerpShadow.y)
        shadow:InvalidateBoneCache()
        shadow:SetCycle((RealTime() % 1) * 1.5)
        shadow:SetSequence("run_all_01")

        return
    end

    ply:SetNW2Float("ZeroX", math.Clamp(ply:GetNW2Float("ZeroX") + mv:GetSideSpeed() / mv:GetMaxSpeed() / 40, -128, 128))

    if IsValid(ply._zeroShadow) then
        ply._lerpShadow = LerpVector(FrameTime() * 4, ply._lerpShadow or Vector(0, 0, 0), Vector(mv:GetSideSpeed() / mv:GetMaxClientSpeed(), mv:GetForwardSpeed() / mv:GetMaxClientSpeed(), 0))
        ply._zeroShadow:SetPoseParameter("move_y", ply._lerpShadow:Angle():Forward().x)
        ply._zeroShadow:SetPoseParameter("move_x", -ply._lerpShadow:Angle():Forward().y)
        ply._zeroShadow:InvalidateBoneCache()
    end
end)

local function shadowThink(ply, b)
    if (not IsValid(ply._zeroShadow)) then
        ply._zeroShadow = ClientsideModel("models/konnie/asapgaming/destiny2/titanretrograde.mdl")
    end

    if (ply:GetNW2Bool("CrazyShadow")) then
        local shadow = ply._zeroShadow

        if ((shadow.nextMove or 0) < RealTime()) then
            shadow.nextMove = RealTime() + math.Rand(.5, 1.25)
            shadow.Axis = (shadow.Axis or 0) + math.random(-180, 180)
        end

        local dir = Angle(0, shadow.Axis or 0, 0)
        local target = shadow:GetPos() + dir:Forward() * (FrameTime() * 25)
        local tr = util.QuickTrace(target + Vector(0, 0, 250), Vector(0, 0, -500), ply)
        shadow:SetPos(tr.HitPos)
        shadow:SetAngles(dir)
        shadow.Direction = dir
        shadow:SetCycle(ply:GetCycle())
        shadow:SetSequence("run_all_01")

        if (ply ~= LocalPlayer()) then
            shadow:SetPoseParameter("move_y", dir:Forward().x)
            shadow:SetPoseParameter("move_x", -dir:Forward().y)
            shadow:InvalidateBoneCache()
        end

        return
    end

    ply._zeroShadow:SetAngles(Angle(0, ply:GetAngles().y, 0))
    local target = ply:GetPos() + ply:GetNW2Float("ZeroX", 0) * ply:EyeAngles():Right()
    local tr = util.QuickTrace(target + Vector(0, 0, 250), Vector(0, 0, -500), ply)
    ply._zeroShadow:SetPos(tr.HitPos)
    ply._zeroShadow:SetCycle(ply:GetCycle())
    ply._zeroShadow:SetSequence(ply:GetSequence())

    if (ply ~= LocalPlayer()) then
        ply._zeroShadow:SetPoseParameter("move_y", target:Angle():Forward().x)
        ply._zeroShadow:SetPoseParameter("move_x", -target:Angle():Forward().y)
        ply._zeroShadow:InvalidateBoneCache()
    end
end

hook.Add("PostDrawTranslucentRenderables", "DrawZeroSuit", function()
    local ply = LocalPlayer()
    if (not ply:GetNW2Bool("ZeroArmor")) then return end
    shadowThink(ply, true)
end)

hook.Add("PrePlayerDraw", "ZeroLocalArmor", function(ply)
    if (ply == LocalPlayer()) then return end
    if (not ply:GetNW2Bool("ZeroArmor")) then return end
    shadowThink(ply)
    if (ply:GetNW2Bool("ZeroInvisible") and ply ~= LocalPlayer()) then return false end
end)