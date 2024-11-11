local function nobombs(ply)
    ply.immuneToGluon = true
    ply.wallhackActive = true
    ply.noFallDmg = true

    hook.Add("EntityTakeDamage", ply:SteamID64() .. "_nobombs", function(ent, dmg)
        if (ent == ply and dmg:IsExplosionDamage()) then
            dmg:SetDamage(0)

            return true
        end
    end)
end

local function oldbomb(ply)
    hook.Remove("EntityTakeDamage", ply:SteamID64() .. "_nobombs")
    ply:SetHealth(100)
    ply:SetArmor(0)
    ply.immuneToGluon = nil
    ply.wallhackActive = nil
    ply.noFallDmg = nil

    if (ply._oldRunSpeed) then
        ply:SetRunSpeed(ply._oldRunSpeed)
        ply._oldRunSpeed = nil
    end
end

Armor:Add({
    Name = "BP7 Shadow", -- Reinhardt
    Description = "No Explosive Damage",
    Model = "models/konnie/asapgaming/reinhardt_blackhardt.mdl",
    Entitie = "armor_bp1_1",
    Size = 200,
    Health = 5000,
    Armor = 5000,
    Speed = 1.75,
    OnGive = function(ply)
        nobombs(ply)
    end,
    OnRemove = function(ply)
        oldbomb(ply)
    end
})

Armor:Add({
    Name = "BP7 Volcano", -- Reinhardt
    Description = "No Explosive Damage",
    Model = "models/konnie/asapgaming/reinhardt_bloodhardt.mdl",
    Entitie = "armor_bp1_2",
    Size = 200,
    Health = 5000,
    Armor = 5000,
    Speed = 1.3,
    OnGive = function(ply)
        nobombs(ply)
    end,
    OnRemove = function(ply)
        oldbomb(ply)
    end
})

if CLIENT then
    local beam_mat = Material("trails/1ktracer2")

    hook.Add("PostPlayerDraw", "DrawPriest.Beam", function(ply)
        local beam = ply:GetNWEntity("AttachedTo")

        if (IsValid(beam)) then
            local start = ply:GetPos() + Vector(0, 0, (ply:EyePos().z - ply:GetPos().z) * .6)
            local endpos = beam:GetPos() + Vector(0, 0, (beam:EyePos().z - beam:GetPos().z) * .6)
            local dir = (endpos - start):Angle()
            local lerp = 0
            render.SetMaterial(beam_mat)
            local beamSize = 32
            render.StartBeam(beamSize)

            for k = 1, beamSize do
                local offset = dir:Up() * (math.cos(RealTime() * 2 + k / 4) * 8) + dir:Right() * (math.sin(RealTime() / 4 + k / 4) * 4)
                lerp = Lerp(k / beamSize, start + offset, endpos + offset)
                render.AddBeam(lerp, 16 + 8 * math.cos(math.pi * 2 * (k / beamSize)), k / beamSize, color_white)
            end

            render.EndBeam()
        end
    end)
end

local noloop = false

Armor:Add({
    Name = "BP X Suit", -- Reinhardt
    Description = "No Explosive Damage - Sould bounding",
    Model = "models/konnie/asapgaming/reinhardt_balderich.mdl",
    Entitie = "armor_bp1_3",
    Wallhack = true,
    Size = 200,
    Health = 6000,
    Armor = 6000,
    Speed = .7,
    OnGive = function(ply)
        nobombs(ply)
        local hookName = ply:SteamID64() .. "_priest"
        hook.Remove("EntityTakeDamage", hookName)

        hook.Add("EntityTakeDamage", hookName, function(ent, dmg)
            if (not IsValid(ply) or not ply:Alive()) then
                hook.Remove("EntityTakeDamage", hookName)

                return
            end

            if (noloop) then return end

            if (ply._attachedTo == ent) then
                noloop = true
                ply:TakeDamageInfo(dmg)
                ply:EmitSound("physics/metal/chain_impact_hard1.wav")
                noloop = false
                dmg:SetDamage(0)

                return true
            end
        end)

        timer.Create(hookName, 1, 0, function()
            if not IsValid(ply) or not ply:Alive() then
                timer.Remove(hookName)

                return
            end

            if (IsValid(ply._attachedTo) and ply._attachedTo:GetPos():Distance(ply:GetPos()) > 256) then
                ply._attachedTo:SetNWEntity("AttachedTo", game.GetWorld())
                ply:EmitSound("botw/stasis/stop.wav")
                ply._attachedTo = nil
            end
        end)
    end,
    Abilities = {
        [1] = {
            Cooldown = 15,
            Action = function(armor, ply)
                local tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 400, ply)
                if (not tr.Entity:IsPlayer()) then return false, "Target must be a player" end

                if (IsValid(ply._attachedTo)) then
                    ply._attachedTo:SetNWEntity("AttachedTo", game.GetWorld())

                    if (tr.Entity == ply._attachedTo) then
                        ply:EmitSound("botw/stasis/stop.wav")
                        ply._attachedTo = nil

                        return true
                    end
                end

                ply:EmitSound("physics/metal/chain_impact_soft2.wav")
                ply._attachedTo = tr.Entity
                tr.Entity:SetNWEntity("AttachedTo", ply)
            end,
            Description = "Bonds to a player and redirects his damage to you"
        }
    },
    OnRemove = function(ply)
        oldbomb(ply)
    end
})