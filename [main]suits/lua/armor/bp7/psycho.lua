local runPower = .4
local baseHealth = 2500
local baseArmor = 2000
local baseJump = 400
local Gluongun = true

if SERVER then
    util.AddNetworkString("Psycho.Start")
    util.AddNetworkString("Psycho.End")
end

local sphereContainers = {}
local combine = Material("effects/strider_pinch_dudv_dx60")
local sphere = Material("asap/hexa_red")
local line = Material("effects/strider_tracer")

hook.Add("PostDrawTranslucentRenderables", "Psycho.Renderer", function()
    for k, d in pairs(sphereContainers) do
        for _, v in pairs(d) do
            if not IsValid(v) or not IsValid(k) then
                sphereContainers[k] = nil
                continue
            end

            render.SetMaterial(combine)
            render.DrawSprite(v:GetPos() + Vector(0, 0, 32), 132, 132, Color(255, 100, 50))
            render.SetMaterial(sphere)
            render.DrawSphere(v:GetPos() + Vector(0, 0, 32), 42, 16, 16, color_white)
            render.SetMaterial(line)
            render.DrawBeam(k:EyePos() - Vector(0, 0, 8), v:GetPos() + Vector(0, 0, 32), 16, (RealTime() * 4) % 1, (RealTime() * 4) % 1 - 1, color_white)
            v:DrawModel()
        end
    end
end)

net.Receive("Psycho.Start", function()
    local owner = net.ReadEntity()
    local taker = net.ReadEntity()
    if (IsValid(owner) and owner.AnimRestartGesture) then
        owner:AnimRestartGesture(6, ACT_HL2MP_IDLE_MAGIC, false)
    end

    if not sphereContainers[owner] then
        sphereContainers[owner] = {}
    end

    table.insert(sphereContainers[owner], taker)
end)

net.Receive("Psycho.End", function()
    local owner = net.ReadEntity()
    if not IsValid(owner) then return end
    owner:AnimResetGestureSlot(6)
    sphereContainers[owner] = nil
    timer.Remove(owner:SteamID64() .. "_Psycho.Countdown")
end)

local function armorDisplayBar(title, fill, y)
    local wid = 196
    draw.SimpleText(title, "XeninUI.TextEntry", ScrW() / 2 - wid / 2 + 2, ScrH() / 1.6 + y * 38 - 8 + 2, color_black)
    draw.SimpleText(title, "XeninUI.TextEntry", ScrW() / 2 - wid / 2, ScrH() / 1.6 + y * 38 - 8, color_white)
    draw.RoundedBox(4, ScrW() / 2 - wid / 2, ScrH() / 1.6 + y * 38 + 12, wid, 16, Color(16, 16, 16))
    draw.RoundedBox(4, ScrW() / 2 - wid / 2 + 2, ScrH() / 1.6 + y * 38 + 14, (wid - 4) * fill, 12, Color(255, 255, 255))
end

Armor:Add({
    Name = "Psycho Suit",
    Description = "Can hold an enemy in the air",
    Model = "models/konnie/asapgaming/destiny2/superiorsvision.mdl",
    Entitie = "armor_psycho",
    HUDPaint = function(ply)
        if (IsValid(ply.psychoTarget) and timer.Exists(ply:SteamID64() .. "_Psycho.Countdown")) then
            armorDisplayBar("Duration", timer.TimeLeft(ply:SteamID64() .. "_Psycho.Countdown") / 10, 0)
        end

        if (ply._bubbleExplode) then
            armorDisplayBar("Explosion", 1 - (ply._bubbleExplode - CurTime()) / 2, 1)

            if (CurTime() - ply._bubbleExplode > 0) then
                ply._bubbleExplode = nil
            end
        end

        if (ply._bubbleSield) then
            armorDisplayBar("Shield Duration", 1 - (ply._bubbleSield - CurTime()) / 5, 2)

            if (CurTime() - ply._bubbleSield > 0) then
                ply._bubbleSield = nil
            end
        end
    end,
    Health = baseHealth,
    Armor = baseArmor,
    JumpPower = baseJump,
    Speed = 1 + runPower,
    OnGive = function(ply)
        ply.immuneToGluon = Gluongun
        local hookName = "Psyco_death_" .. ply:SteamID64()

        hook.Add("PlayerDeath", hookName, function(ent)
            if (ply.psychoTarget == ent) then
                ply:Freeze(false)
                net.Start("Psycho.End")
                net.WriteEntity(ply)
                net.SendPVS(ply:GetPos())
            end
        end)
    end,
    -- what happens when they get the suit equipped
    Abilities = {
        [1] = {
            Description = "Holds a player up to 10 seconds, freezes both of you",
            Action = function(armor, ply)
                if (IsValid(ply.psychoTarget)) then
                    if SERVER then
                        ply.psychoTarget:SetMoveType(ply.psychoTarget:IsPlayer() and MOVETYPE_WALK or MOVETYPE_STEP)

                        if (ply.psychoTarget:IsPlayer()) then
                            ply.psychoTarget:Freeze(false)
                        end

                        net.Start("Psycho.End")
                        net.WriteEntity(ply)
                        net.Broadcast()
                        ply.psychoTarget:EmitSound("physics/body/body_medium_impact_soft3.wav")
                        ply:Freeze(false)
                    end

                    timer.Remove(ply:SteamID64() .. "_Psycho.Countdown")
                    ply.psychoTarget = nil

                    return 8
                elseif (ply.psychoTarget == NULL) then
                    ply:Freeze(false)
                end

                local target = ply:GetEyeTrace().Entity
                if (not IsValid(target) or not target:IsPlayer() or not target.armorSuit) then return false end
                ply.psychoTarget = target
                timer.Remove(ply:SteamID64() .. "_Psycho.Countdown")

                timer.Create(ply:SteamID64() .. "_Psycho.Countdown", 10, 1, function()
                    if (IsValid(ply.psychoTarget)) then
                        armor.Abilities[1].Action(armor, ply)
                    end
                end)

                if CLIENT then return 3 end
                target:SetMoveType(MOVETYPE_NONE)
                target:SetPos(target:GetPos() + Vector(0, 0, 16))
                ply:Freeze(true)
                net.Start("Psycho.Start")
                net.WriteEntity(ply)
                net.WriteEntity(target)
                net.Broadcast()
                ply:EmitSound("ambient/energy/weld1.wav")
                target:EmitSound("ambient/energy/whiteflash.wav")

                if (target:IsPlayer()) then
                    target:Freeze(true)
                end

                return 3
            end,
            Cooldown = 30
        },
        [2] = {
            Description = "Creates a shield that will dissapear after 5 seconds",
            Action = function(armor, ply)
                ply._bubbleSield = CurTime() + 5

                if SERVER then
                    local ent = ents.Create("sent_psychoshield")
                    ent:SetPos(ply:GetPos() + Angle(0, ply:GetForward():Angle().y, 0):Forward() * 64 + Vector(0, 0, 0))
                    ent:SetAngles(Angle(0, ply:EyeAngles().y - 90, 0))
                    --ent:SetOwner(ply)
                    ent:Spawn()
                end

                return true
            end,
            Cooldown = 20
        },
        [3] = {
            Description = "Creates a charge that explodes after 2 seconds",
            Action = function(armor, ply)
                ply._bubbleExplode = CurTime() + 2

                if SERVER then
                    local ent = ents.Create("sent_psychobubble")
                    local tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 512, ply)
                    ent:SetPos(tr.HitPos + tr.HitNormal * 8)
                    ent:SetOwner(ply)
                    ent:Spawn()
                end

                return true
            end,
            Cooldown = 15
        },
        [4] = {
            Description = "Holds everyone around you for 3 seconds and then throw them up",
            Action = function(armor, ply)
                ply._psychoUltimate = {}
                ply:EmitSound("ambient/energy/whiteflash.wav")

                for k, v in pairs(ents.FindInSphere(ply:GetPos(), 1024)) do
                    if (not v:IsPlayer()) then continue end
                    if (not v.armorSuit) then continue end
                    if (v == ply) then continue end
                    if (ply:GetGang() ~= "" and ply:GetGang() == v:GetGang()) then continue end
                    v:SetPos(v:GetPos() + Vector(0, 0, 16))
                    v:SetMoveType(MOVETYPE_NONE)

                    if SERVER then
                        net.Start("Psycho.Start")
                        net.WriteEntity(ply)
                        net.WriteEntity(v)
                        net.Broadcast()
                    end

                    ply._psychoUltimate[v] = true
                end

                if SERVER then
                    timer.Simple(3, function()
                        for victim, _ in pairs(ply._psychoUltimate) do
                            if (IsValid(victim)) then
                                victim:SetMoveType(MOVETYPE_WALK)
                                victim:SetPos(victim:GetPos() + Vector(0, 0, 4))
                                victim:SetVelocity(ply:GetAimVector() * 1500)
                            end
                        end

                        net.Start("Psycho.End")
                        net.WriteEntity(ply)
                        net.Broadcast()
                    end)
                end
            end,
            Cooldown = 120
        }
    },
    OnRemove = function(ply)
        if SERVER then
            local hookName = "Psyco_death_" .. ply:SteamID64()
            hook.Remove("PlayerDeath", hookName)
        end

        ply:AnimResetGestureSlot(6)
    end
})