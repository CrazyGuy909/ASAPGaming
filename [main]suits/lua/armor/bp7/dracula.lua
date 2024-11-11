if SERVER then
    util.AddNetworkString("Vampire.Succ")
end

local succs = {}

net.Receive("Vampire.Succ", function()
    local owner = net.ReadEntity()
    local mark = net.ReadVector()

    table.insert(succs, {
        owner = owner,
        start = mark,
        life = .5
    })
end)

local bloodStream = Material("particle/water/waterdrop_001a")

hook.Add("PostDrawTranslucentRenderables", "Vampire.Sucks", function()
    if not succs[1] then return end
    render.SetMaterial(bloodStream)

    for k, v in pairs(succs) do
        v.life = v.life - FrameTime()
        local origin = v.owner:GetShootPos() - Vector(0, 0, 10)
        render.DrawBeam(LerpVector(v.life * 3.5, origin, v.start), LerpVector(v.life, origin, v.start), 4, 0, 1, Color(150, 0, 0))

        if (v.life <= 0) then
            table.remove(succs, k)
        end
    end
end)

local maxVampireHealth = 1500
local M_duration = 4

Armor:Add({
    Name = "The Dracula Suit",
    Description = "Lockpicks doors in 1 second",
    Model = "models/konnie/asapgaming/destiny2/cartographer.mdl",
    Entitie = "armor_dracula",
    Wallhack = true,
    Abilities = {
        [1] = {
            Cooldown = 20,
            Description = "Summons a shield",
            Action = function(armor, ply)
                if IsValid(ply:GetNW2Entity("ShieldEntity")) then return end

                if SERVER then
                    if (IsValid(ply._shield)) then return end
                    ply._shield = ents.Create("sent_armor_shield")
                    ply._shield:SetOwner(ply)
                    ply._shield:Spawn()
                    ply:SetNW2Entity("ShieldEntity", ply._shield)
                end
            end
        },
        [2] = {
            Cooldown = 30,
            Description = "Turns yourself into a coffin making you invuln to bullet damage",
            Action = function(armor, ply)
                if SERVER then
                    if (IsValid(ply._coffin)) then
                        ply._coffin:Remove()
                        ply:EmitSound("physics/wood/wood_box_break2.wav")

                        return true
                    end

                    local coffin = ents.Create("sent_dracula_coffin")
                    coffin:SetPos(ply:GetPos() + Vector(0, 0, 10))
                    coffin:SetOwner(ply)
                    coffin:Spawn()
                    coffin:EmitSound("doors/door_squeek1.wav")
                    coffin:SetPlayer(ply)
                    ply._coffin = coffin

                    return 3
                else
                    if (ply._coffin) then
                        ply._coffin = false
                        RunConsoleCommand("optmenu_thirdperson", 0)

                        return true
                    end

                    ply._coffin = true
                    RunConsoleCommand("optmenu_thirdperson", 1)

                    return 3
                end
            end
        },
        [3] = {
            Cooldown = 60,
            Description = "70% damage you cause during ability is on, returns as health",
            Action = function(armor, ply)
                local hookName = ply:SteamID64() .. "_Dracula"

                if SERVER then
                    ply:EmitSound("npc/fast_zombie/fz_alert_far1.wav")

                    hook.Add("EntityTakeDamage", hookName, function(ent, dmg)
                        if not IsValid(ply) then
                            hook.Remove("EntityTakeDamage", hookName)

                            return
                        end

                        if not ent:IsPlayer() and not ent:IsNPC() then return end
                        local att = dmg:GetAttacker()
                        if not IsValid(att) or not att:IsPlayer() or att == ent or ply ~= att then return end

                        if (att:GetGang() and att:GetGang() ~= ent:GetGang()) then
                            net.Start("Vampire.Succ")
                            net.WriteEntity(ply)
                            net.WriteVector(dmg:GetDamagePosition())
                            net.SendPVS(ent:GetPos())
                            ply:SetHealth(math.Clamp(ply:Health() + math.ceil(dmg:GetDamage() * .6), 0, maxVampireHealth))
                            ply:TakeDamage(0)
                        end
                    end)
                else
                    local tab = {
                        ["$pp_colour_addr"] = .1,
                        ["$pp_colour_addg"] = 0,
                        ["$pp_colour_addb"] = 0,
                        ["$pp_colour_brightness"] = -.1,
                        ["$pp_colour_contrast"] = 1.1,
                        ["$pp_colour_colour"] = 0.5,
                        ["$pp_colour_mulr"] = 1,
                        ["$pp_colour_mulg"] = 0,
                        ["$pp_colour_mulb"] = 0
                    }

                    local target = 1
                    local lerped = 0
                    local timeRunning = 0

                    hook.Add("RenderScreenspaceEffects", hookName, function()
                        timeRunning = timeRunning + FrameTime()
                        target = (M_duration - timeRunning) > 1 and 1 or 0
                        lerped = Lerp(FrameTime() * 5, lerped, target)
                        tab["$pp_colour_addr"] = Lerp(lerped, 0, .1)
                        tab["$pp_colour_brightness"] = Lerp(lerped, 0, -.1)
                        tab["$pp_colour_contrast"] = Lerp(lerped, 1, 1.1)
                        tab["$pp_colour_colour"] = Lerp(lerped, 1, .5)
                        tab["$pp_colour_mulr"] = Lerp(lerped, 0, 1)
                        DrawColorModify(tab)
                    end)
                end

                timer.Create(hookName, M_duration, 1, function()
                    hook.Remove(SERVER and "EntityTakeDamage" or "RenderScreenspaceEffects", hookName)
                end)
            end
        },
        [4] = {
            Cooldown = 120,
            Description = "Creates a bloordnado that drains people heals around you",
            Action = function(armor, ply)
                local percent = ply:Health() / ply:GetMaxHealth()
                if (percent > .5) then return false, "You can only cast this ability when your health is at 50%" end

                if CLIENT then
                    RunConsoleCommand("optmenu_thirdperson", 1)

                    return true
                end

                if IsValid(ply._typhon) then
                    ply._typhon:Remove()
                end

                ply._typhon = ents.Create("sent_dracula_shield")
                ply._typhon:SetParent(ply)
                ply._typhon:SetOwner(ply)
                ply._typhon:SetLocalPos(Vector(0, 0, 0))
                ply._typhon:Spawn()

                return true
            end
        }
    },
    Armor = 2000,
    Health = 2300,
    JumpPower = 400,
    Gravity = .75,
    Speed = 2.5,
    OnGive = function(ply)
        ply.immuneToGluon = true
        local hookName = ply:SteamID64() .. "_Dracula"
        hook.Add("lockpickTime", hookName, function(owner, ent)
            if (owner == ply) then
                return 1
            end
        end)
    end,
    OnRemove = function(ply)
        ply.immuneToGluon = nil
        local hookName = ply:SteamID64() .. "_Dracula"
        hook.Remove(SERVER and "EntityTakeDamage" or "RenderScreenspaceEffects", hookName)
        timer.Remove(hookName)
        hook.Remove("lockpickTime", hookName)

        if SERVER then
            SafeRemoveEntity(ply._typhon)
            SafeRemoveEntity(ply._coffin)
            SafeRemoveEntity(ply._shield)
        end
    end
})