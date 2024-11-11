AddCSLuaFile()

Armor:Add({
    Name = "Heaven Guardian Suit",
    Description = "Flight",
    Model = "models/konnie/asapgaming/destiny2/solstice.mdl",
    Entitie = "armor_hgs",
    Wallhack = true,
    Health = 2500,
    Armor = 2500,
    JumpPower = 350,
    RunSpeed = 1.15,
    OnGive = function(ply)
        ply.immuneToGluon = true

        hook.Add("KeyPress", ply, function(self, ply, key)
            if (self == ply and key == IN_JUMP) then
                ply:SetNWFloat("GravitySH", -1)
                ply:SetLocalVelocity(Vector(0, 0, 0))
            end
        end)

        hook.Add("KeyRelease", ply, function(self, ply, key)
            if (self == ply and key == IN_JUMP) then
                ply:SetNWFloat("GravitySH", 1)
            end
        end)
    end,
    -- what happens when they get the suit equipped
    Abilities = {
        [1] = {
            Cooldown = 30,
            Action = function(s, ply)
                if SERVER then
                    ply._guardianShield = 10
                    hook.Remove("Think", ply:EntIndex() .. "_heavenGuardian")

                    hook.Add("Think", ply:EntIndex() .. "_heavenGuardian", function()
                        ply._guardianShield = (ply._guardianShield or 10) - FrameTime()

                        if ((ply._guardianNextHeal or 0) < CurTime()) then
                            ply._guardianNextHeal = CurTime() + .75

                            for k, v in pairs(ents.FindInSphere(ply:GetPos(), 172)) do
                                if (v:IsPlayer()) then
                                    v:SetHealth(math.Clamp(v:Health() + v:GetMaxHealth() / 10, 0, v:GetMaxHealth()))
                                    local eff = EffectData()
                                    eff:SetStart(ply:GetPos() + Vector(0, 0, 35))
                                    eff:SetOrigin(v:GetPos() + Vector(0, 0, 35))
                                    util.Effect("tracer_heal", eff, true, true)
                                end
                            end
                        end

                        if (ply._guardianShield <= 0) then
                            hook.Remove("Think", ply:EntIndex() .. "_heavenGuardian")
                        end
                    end)
                end
            end
        }
    },
    OnRemove = function(ply)
        ply.immuneToGluon = nil
        ply:SetNWFloat("GravitySH", 0)
        hook.Remove("Think", ply:EntIndex() .. "_heavenGuardian")
        hook.Remove("KeyPress", ply)
        hook.Remove("KeyRelease", ply)
    end
})