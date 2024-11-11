AddCSLuaFile()

if SERVER then
    util.AddNetworkString("Armor.Salamander")
end

local salamander_model = "models/konnie/asapgaming/destiny2/valkyrian.mdl"

Armor:Add({
    Name = "Salamander Suit",
    Description = "Hides your suit.",
    Model = salamander_model,
    Entitie = "armor_salamander",
    Cooldown = 1,
    Wallhack = true,
    HUDPaint = function(ply)
        if (ply:GetNWBool("ArmorSalamander")) then
            draw.SimpleText("SUIT HIDDEN", "Arena.Medium", ScrW() / 2, 96, color_white, 1, 1)
        end
    end,
    Health = 2000,
    Armor = 2000,
    OnGive = function(ply)
        ply.immuneToGluon = true
        ply._salamanderStatus = nil
    end,
    -- what happens when they get the suit equipped
    Abilities = {
        [1] = {
            Action = function(s, ply)
                ply:EmitSound("buttons/combine_button2.wav")
                if CLIENT then return end
                net.Start("Armor.Salamander")
                net.WriteEntity(ply)
                net.SendPVS(ply:GetPos())
                ply._salamanderStatus = not (ply._salamanderStatus or false)
                ply:SetNWBool("ArmorSalamander", ply._salamanderStatus)

                if (ply._salamanderStatus) then
                    hook.Call("PlayerSetModel", GAMEMODE, ply)
                else
                    ply:SetModel(salamander_model)
                end
            end,
            Cooldown = 10,
        }
    },
    OnRemove = function(ply)
        ply._salamanderStatus = nil
        ply.immuneToGluon = nil
    end
})

net.Receive("Armor.Salamander", function()
    local ply = net.ReadEntity()
    local eff = EffectData()
    eff:SetEntity(ply)
    util.Effect("salamander", eff, true, true)
end)

Armor:Add({
    Name = "Panzer Armor",
    Description = "No Explosive Damage",
    Model = "models/konnie/asapgaming/destiny2/ironwill.mdl",
    Entitie = "armor_panzer",
    Wallhack = true,
    Health = 2300,
    Armor = 2300,
    Speed = 1.75,
    OnGive = function(ply)
        ply:SetModelScale(1.1)
        ply.immuneToGluon = true

        hook.Add("EntityTakeDamage", ply:SteamID64() .. "_nobombs", function(ent, dmg)
            if (ent == ply and dmg:IsExplosionDamage()) then
                dmg:SetDamage(0)

                return true
            end
        end)

        ply._salamanderStatus = true
    end,
    OnRemove = function(ply)
        hook.Remove("EntityTakeDamage", ply:SteamID64() .. "_nobombs")
        ply:SetModelScale(1)
        ply.immuneToGluon = nil
    end
})

local simZone = 400 * 400

Armor:Add({
    Name = "Simulator Armor",
    Description = "Slow Field",
    Model = "models/konnie/asapgaming/destiny2/simulator.mdl",
    Entitie = "armor_simulatorsuit_v2",
    Cooldown = 1,
    PrePlayerDraw = function(ply)
        local pos = ply:GetPos()
        if (not ply:GetNWBool("SimulatorEnabled")) then return end
        if (halo.RenderedEntity() == ply) then return end
        render.StartWorldRings()
        render.AddWorldRing(pos, 200, 16, 32)
        render.FinishWorldRings(Color(100, 175, 255))
    end,
    Abilities = {
        [1] = {
            Action = function(s, ply)
                if not IsFirstTimePredicted() then return end
                ply:SetNWBool("SimulatorEnabled", not ply:GetNWBool("SimulatorEnabled", false))
            end,
            Cooldown = 5
        }
    },
    OnGive = function(ply)
        hook.Add("Move", ply:SteamID64() .. "_freeze", function(ent, mv)
            if (not ply:GetNWBool("SimulatorEnabled")) then return end
            if (ent == ply) then return end
            local dist = ent:GetPos():DistToSqr(ply:GetPos())

            if (dist < simZone) then
                local power = 1 - dist / simZone
                mv:SetVelocity(mv:GetVelocity() * (1 - power * .8))

                return false
            end
        end)

        ply._salamanderStatus = true
    end,
    OnRemove = function(ply)
        ply:SetNWBool("SimulatorEnabled", not ply:GetNWBool("SimulatorEnabled", false))
        hook.Remove("Move", ply:SteamID64() .. "_freeze")
    end
})

Armor:Add({
    Name = "Butterfly Suit",
    Description = "3 Shields protecting you from back, left and right",
    Model = "models/konnie/asapgaming/destiny2/wovenfiresmith.mdl",
    Entitie = "armor_butterfly",
    Wallhack = true,
    Health = 2000,
    Armor = 2000,
    Speed = 2.1,
    OnGive = function(ply)
        if (IsValid(ply._protectus)) then
            ply._protectus:Remove()
        end

        ply.immuneToGluon = true
        local ent = ents.Create("sent_armor_specialshield")
        ent:SetOwner(ply)
        ent:Spawn()
        ply._protectus = ent
        ply._salamanderStatus = true
    end,
    OnRemove = function(ply)
        if (IsValid(ply._protectus)) then
            ply._protectus:Remove()
        end

        ply.immuneToGluon = nil
    end
})

Armor:Add({
    Name = "Jäger Suit",
    Description = "Infinate Jump - Enables a scouting camera",
    Model = "models/konnie/asapgaming/destiny2/luxe.mdl",
    Entitie = "armor_jager",
    Cooldown = 1,
    Wallhack = true,
    Health = 1800,
    Armor = 1800,
    Speed = 2.9,
    Gravity = .75,
    OnGive = function(ply)
        ply.immuneToGluon = true

        hook.Add("KeyPress", ply:SteamID64() .. "_armor", function(pl, key)
            if (pl == ply and key == IN_JUMP and not pl:IsOnGround()) then
                local vel = pl:GetVelocity()
                pl:SetLocalVelocity(Vector(vel.x, vel.y, pl:GetJumpPower()))
                pl:EmitSound("items/ammocrate_open.wav")
                local eff = EffectData()
                eff:SetOrigin(pl:GetPos() + Vector(0, 0, 32))
                util.Effect("GlassImpact", eff, true, true)
            end
        end)

        ply._salamanderStatus = true
        ply:Wait(.1, function()
            ply._baseStats = {ply:GetRunSpeed(), ply:GetWalkSpeed()}
        end)
    end,
    -- what happens when they get the suit equipped
    Abilities = {
        [1] = {
            Action = function(s, ply)
                if not IsFirstTimePredicted() then return end
                ply._camOn = not (ply._camOn or false)

                if SERVER then
                    ply:SetRunSpeed(ply._camOn and 1 or ply._baseStats[1])
                    ply:SetWalkSpeed(ply._camOn and 1 or ply._baseStats[2])
                end

                if SERVER then return end

                if (not ply._camOn) then
                    hook.Remove("CalcView", "freeCam")
                else
                    local pos = EyePos()

                    hook.Add("CalcView", "freeCam", function(ply, _, ang)
                        if (not ply.armorSuit) then
                            hook.Remove("CalcView", "freeCam")

                            return
                        end

                        local tbl = {}
                        pos = pos + ang:Right() * (input.IsButtonDown(KEY_A) and -1 or (input.IsButtonDown(KEY_D) and 1 or 0))
                        pos = pos + ang:Forward() * (input.IsButtonDown(KEY_S) and -1 or (input.IsButtonDown(KEY_W) and 1 or 0))
                        tbl.origin = pos
                        tbl.drawviewer = true

                        return tbl
                    end)
                end
            end,
            Cooldown = 5,
        }
    },
    OnRemove = function(ply)
        hook.Remove("KeyPress", ply:SteamID64() .. "_armor")
        hook.Remove("CalcView", "freeCam")
        ply.immuneToGluon = nil
        ply._baseStats = nil
    end
})

Armor:Add({
    Name = "XIV Armor(BP6)",
    Description = "Infinate Jump - No Explosive Damage - Front Shield (30 second cooldown)",
    Model = "models/konnie/asapgaming/destiny2/saint14.mdl",
    Entitie = "armor_xiv",
    Cooldown = 30,
    Wallhack = true,
    HUDPaint = function(ply)
        local shield = ply:GetNW2Entity("ShieldEntity")

        if IsValid(shield) then
            draw.SimpleText("Shield Life:", "XeninUI.TextEntry", ScrW() / 2 + 1, 121, Color(0, 0, 0), 1, TEXT_ALIGN_BOTTOM)
            draw.SimpleText("Shield Life:", "XeninUI.TextEntry", ScrW() / 2, 120, color_white, 1, TEXT_ALIGN_BOTTOM)
            surface.SetDrawColor(0, 0, 0)
            surface.DrawRect(ScrW() / 2 - 128, 128, 256, 24)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawRect(ScrW() / 2 - 128 + 2, 130, 252 * (shield:Health() / shield.MaxHealth), 20)

            return false
        end
    end,
    Health = 3000,
    Armor = 3000,
    Speed = 2,
    Gravity = .70,
    OnGive = function(ply)
        if (IsValid(ply._protectus)) then
            ply._protectus:Remove()
        end

        ply:SetModelScale(1.25)
        ply.immuneToGluon = true

        hook.Add("EntityTakeDamage", ply:SteamID64() .. "_nobombs", function(ent, dmg)
            if (ent == ply and dmg:IsExplosionDamage()) then
                dmg:SetDamage(0)

                return true
            end
        end)

        hook.Add("KeyPress", ply:SteamID64() .. "_armor", function(pl, key)
            if (pl == ply and key == IN_JUMP and not pl:IsOnGround()) then
                local vel = pl:GetVelocity()
                pl:SetLocalVelocity(Vector(vel.x, vel.y, pl:GetJumpPower()))
                pl:EmitSound("items/ammocrate_open.wav")
                local eff = EffectData()
                eff:SetOrigin(pl:GetPos() + Vector(0, 0, 32))
                util.Effect("GlassImpact", eff, true, true)
            end
        end)

        local ent = ents.Create("sent_armor_specialshield_xiv")
        ent:SetOwner(ply)
        ent:Spawn()
        ply._protectus = ent
        ply._salamanderStatus = true
    end,
    -- what happens when they get the suit equipped
    Abilities = {
        [1] = {
            Action = function(s, ply)
                if IsValid(ply:GetNW2Entity("ShieldEntity")) then return end

                if SERVER then
                    if (IsValid(ply._shield)) then return end
                    ply._shield = ents.Create("sent_armor_shield")
                    ply._shield:SetOwner(ply)
                    ply._shield:Spawn()
                    ply:SetNW2Entity("ShieldEntity", ply._shield)
                end

                return false
            end,
            Cooldown = 40
        }
    },
    OnRemove = function(ply)
        hook.Remove("KeyPress", ply:SteamID64() .. "_armor")
        hook.Remove("EntityTakeDamage", ply:SteamID64() .. "_nobombs")

        if (IsValid(ply._protectus)) then
            ply._protectus:Remove()
        end

        if IsValid(ply._shield) then
            ply._shield:Remove()
        end

        ply:SetModelScale(1)
        ply.immuneToGluon = nil
    end
})

Armor:Add({
    Name = "Horizon Armor",
    Description = "Makes you super fast.",
    Model = "models/konnie/asapgaming/destiny2/luxe2.mdl",
    Entitie = "armor_horizon",
    Wallhack = true,
    Health = 1750,
    Armor = 1500,
    OnGive = function(ply)
        ply.immuneToGluon = true
        ply._salamanderStatus = true
    end,
    -- what happens when they get the suit equipped
    Abilities = {
        [1] = {
            Cooldown = 60,
            Action = function(ply)
                ply._oldRunSpeed = ply:GetRunSpeed()
                ply:SetRunSpeed(4000)

                if SERVER then
                    ply:EmitSound("ojamajo/casting2.wav")
                    ply._trail = ents.Create("info_target")
                    ply._trail:SetParent(ply)
                    ply._trail:SetLocalPos(Vector(0, 0, 40))
                    ply._trail.tr = util.SpriteTrail(ply._trail, 0, color_white, false, 72, 4, 1, 1 / (72 + 4) * 0.5, "trails/plasma")

                    ply.returnSpeed = ply:Wait(4, function()
                        if (IsValid(ply._trail)) then
                            ply._trail:Remove()
                        end

                        ply._oldRunSpeed = nil
                        ply:SetRunSpeed(ply._oldRunSpeed)
                        ply:EmitSound("ojamajo/poof.wav")
                    end)
                end
            end
        }
    },
    OnRemove = function(ply)
        if (IsValid(ply._trail)) then
            ply._trail:Remove()
        end

        if (ply.returnSpeed) then
            ply.returnSpeed:Remove()
        end

        ply:SetRunSpeed(400)
        ply.immuneToGluon = nil
        ply._oldRunSpeed = nil
    end
})

Armor:Add({
    Name = "Rhino Suit",
    Description = "Glow vision - Shields",
    Model = "models/konnie/asapgaming/destiny2/exigent.mdl",
    Entitie = "armor_rhino",
    Wallhack = true,
    Cooldown = 1,
    Health = 1750,
    Armor = 1750,
    Speed = 1.4,
    OnGive = function(ply)
        if (IsValid(ply._protectus)) then
            ply._protectus:Remove()
        end

        ply.immuneToGluon = true
        local ent = ents.Create("sent_armor_specialshield")
        ent:SetOwner(ply)
        ent:Spawn()
        ply._protectus = ent
        ply._salamanderStatus = true
    end,
    -- what happens when they get the suit equipped
    Abilities = {
        [1] = {
            Action = function(s, ply)
                if not IsFirstTimePredicted() then return end
                if SERVER then return end

                if (not IsValid(ply._globus)) then
                    ply:EmitSound("rm_c4/draw.wav")
                    ply._globus = ClientsideModel("models/maxofs2d/gm_painting.mdl")
                    ply._globus:SetPos(EyePos() + EyeAngles():Forward() * 16)
                    ply._globus:SetAngles(EyeAngles())
                    ply._globus:SetMaterial("models/props_combine/tprings_globe")

                    ply._globus.RenderOverride = function(s)
                        s:DrawModel()
                    end

                    hook.Add("PostDrawViewModel", ply._globus, function(s, vm)
                        if (not ply.armorSuit) then
                            ply._globus:Remove()

                            return
                        end

                        ply._globus:SetPos(vm:GetPos() + vm:GetForward() * 12)
                        local ang = EyeAngles()
                        --ang:RotateAroundAxis(ang:Up(), 90)
                        ply._globus:SetAngles(ang)
                    end)

                    hook.Add("PostPlayerDraw", ply._globus, function(s, ply)
                        if (not ply.armorSuit) then
                            ply._globus:Remove()

                            return
                        end

                        if (ply == LocalPlayer()) then
                            ply._globus:SetPos(EyePos() + ply:GetAimVector() * 12)
                            local ang = EyeAngles()
                            --ang:RotateAroundAxis(ang:Up(), 90)
                            ply._globus:SetAngles(ang)
                        end
                    end)
                else
                    ply:EmitSound("rm_c4/toss.wav")
                    ply._globus:Remove()
                end
            end,
            Cooldown = 40
        }
    },
    OnRemoveClient = function(ply)
        if IsValid(ply._globus) then
            ply._globus:Remove()
        end
    end,
    OnRemove = function(ply)
        if (IsValid(ply._protectus)) then
            ply._protectus:Remove()
        end

        ply.immuneToGluon = nil
    end
})

Armor:Add({
    Name = "Buffalo Armor",
    Description = "Players and Printers close to you will glow through walls",
    Model = "models/konnie/asapgaming/destiny2/shaxx.mdl",
    Entitie = "armor_buffalo",
    Cooldown = 1,
    OnGiveClient = function(ply)
        if CLIENT then
            local nextCheck = 0
            local listEnts = {}

            hook.Add("PreDrawHalos", "armor_halo", function()
                if nextCheck < CurTime() then
                    nextCheck = CurTime() + 1
                    listEnts = {}

                    for k, v in pairs(player.GetAll()) do
                        if (v == ply) then continue end

                        if (v:GetPos():Distance(EyePos()) < 720) then
                            table.insert(listEnts, v)
                        end
                    end

                    for k, v in pairs(ents.FindByClass("asap_money_printer")) do
                        if (v:GetPos():Distance(EyePos()) < 720) then
                            table.insert(listEnts, v)
                        end
                    end
                end

                halo.Add(listEnts, Color(0, 255, 252), 2, 2, 1, true, true)
            end)
        end
    end,
    Health = 2250,
    Armor = 2250,
    Speed = 2,
    OnGive = function(ply)
        ply:SetModelScale(1.1)
        ply.immuneToGluon = true
    end,
    OnRemoveClient = function(ply)
        hook.Remove("PreDrawHalos", "armor_halo")
    end,
    OnRemove = function(ply)
        ply:SetModelScale(1)
        ply.immuneToGluon = nil
    end
})