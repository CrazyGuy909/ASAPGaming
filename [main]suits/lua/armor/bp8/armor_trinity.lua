AddCSLuaFile()
local runPower = 1.5
local baseHealth = 1500
local baseArmor = 600
local healthIncrease = 0
local armorIncrease = 100
local baseJump = 300
local jumpIncrease = 40
local Gluongun = false

if CLIENT then
    local reticle = surface.GetTextureID("holo/ikelosreticle")
    local weapon_ret = surface.GetTextureID("reticle/jotunn_reticledot")
    local shield = Material("reticle/hammerheadreticle")
    local glare = Material("skin/prism_overlay")
    local beam = Material("tracers/tracer_tornado")
    local nextCheck = 0
    local targets = {}

    function netrunner_Vision(owner)
        if (nextCheck < CurTime()) then
            nextCheck = CurTime() + 1.5
            targets = {}

            for k, v in pairs(ents.FindInSphere(EyePos(), 4096)) do
                if v == owner or not v:IsPlayer() then continue end
                if not v:Alive() then continue end
                targets[v] = true
            end
        end

        cam.IgnoreZ(true)
        render.SuppressEngineLighting(true)
        render.MaterialOverride(glare)

        for ply, _ in pairs(targets) do
            if (IsValid(ply) and IsValid(ply:GetActiveWeapon())) then
                targets[ply] = ply:GetActiveWeapon()
                targets[ply]:DrawModel()
            elseif not IsValid(ply) then
                targets[ply] = nil
            end
        end

        render.MaterialOverride(nil)
        render.SuppressEngineLighting(false)
        cam.IgnoreZ(false)
    end

    function netrunner_VisionUI(owner)
        for ply, wep in pairs(targets) do
            local ply_pos = (ply:EyePos() + ply:GetAimVector() * 8):ToScreen()
            surface.SetTexture(reticle)
            surface.SetDrawColor(color_white)
            surface.DrawTexturedRectRotated(ply_pos.x, ply_pos.y, 128, 128, 0)

            local tr = util.TraceLine({
                start = EyePos(),
                endpos = ply:GetPos() + Vector(0, 0, 32),
                filter = owner
            })

            if (tr.Entity ~= ply) then
                draw.SimpleText(ply:Health() .. "HP - " .. ply:Armor() .. "AP", "XeninUI.TextEntry", ply_pos.x, ply_pos.y - 73, Color(0, 0, 0, 255), 1, 1)
                draw.SimpleText(ply:Health() .. "HP - " .. ply:Armor() .. "AP", "XeninUI.TextEntry", ply_pos.x, ply_pos.y - 74, Color(255, 150, 0, 255), 1, 1)
            end

            if (wep ~= true and IsValid(wep)) then
                local wep_pos = (wep:GetAttachment(1) and wep:GetAttachment(1).Pos or (wep:GetPos() + ply:GetAimVector() * 16)):ToScreen()
                surface.SetTexture(weapon_ret)
                surface.SetDrawColor(color_white)
                surface.DrawTexturedRectRotated(wep_pos.x, wep_pos.y, 64, 64, RealTime() * 32)
                draw.SimpleText(wep:GetPrintName(), "XeninUI.TextEntry", ply_pos.x, ply_pos.y + 62, Color(255, 150, 0, 255), 1, 1)
            end
        end

        if (not LocalPlayer():GetNWBool("ShieldEnabled", false)) then return end
        cam.Start3D(EyePos(), EyeAngles())
        netrunner_DrawShield(LocalPlayer())
        cam.End3D()
    end

    function netrunner_DrawShield(ply)
        if (not ply:GetNWBool("ShieldEnabled", false)) then return end
        render.SetMaterial(shield)
        local tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 128, ply)

        for k = 1, 3 do
            render.DrawQuadEasy(LerpVector(k / 3, ply:GetShootPos(), tr.HitPos), ply:GetAimVector(), 48 + k * 48, 32 + k * 32, color_white, 0)
            render.DrawQuadEasy(LerpVector(k / 3, ply:GetShootPos(), tr.HitPos), -ply:GetAimVector(), 48 + k * 48, 32 + k * 32, color_white, 0)
        end

        render.SetMaterial(beam)
        render.DrawBeam(LerpVector(.33, ply:GetShootPos(), tr.HitPos + ply:GetRight() * 120 + ply:EyeAngles():Up() * 58), tr.HitPos + ply:GetRight() * 82 + ply:EyeAngles():Up() * 38, 4, 0, 1, Color(255, 255, 255, 50))
        render.DrawBeam(LerpVector(.33, ply:GetShootPos(), tr.HitPos + ply:GetRight() * 120 - ply:EyeAngles():Up() * 26), tr.HitPos + ply:GetRight() * 82 - ply:EyeAngles():Up() * 16, 4, 0, 1, Color(255, 255, 255, 50))
        render.DrawBeam(LerpVector(.33, ply:GetShootPos(), tr.HitPos - ply:GetRight() * 120 + ply:EyeAngles():Up() * 58), tr.HitPos - ply:GetRight() * 82 + ply:EyeAngles():Up() * 38, 4, 0, 1, Color(255, 255, 255, 50))
        render.DrawBeam(LerpVector(.33, ply:GetShootPos(), tr.HitPos - ply:GetRight() * 120 - ply:EyeAngles():Up() * 26), tr.HitPos - ply:GetRight() * 82 - ply:EyeAngles():Up() * 16, 4, 0, 1, Color(255, 255, 255, 50))
    end
end

function netrunner_Shield(ply, ent, data)
    if (not ent:IsPlayer()) then return end
    if (ply == ent) then return end
    if (ply:GetGang() ~= "" and ent:GetGang() ~= "" and ply:GetGang() == ent:GetGang()) then return end
    local tr = util.QuickTrace(ply:GetShootPos(), ply:GetAimVector() * 128, ply)
    local found = false

    for k = 3, 1, -1 do
        local ray = util.IntersectRayWithPlane(data.Src, data.Dir, LerpVector(k / 3, ply:GetShootPos(), tr.HitPos), ply:GetAimVector())
        if not ray then continue end
        local pos = ply:WorldToLocal(ray)

        if (pos.y > -40 - 20 * k and pos.y < 40 + 20 * k and pos.z > 2 and pos.z < 120) then
            found = k
            local eff = EffectData()
            eff:SetOrigin(ray)
            eff:SetNormal(ply:GetAimVector())
            eff:SetRadius(8)
            util.Effect("AR2Explosion", eff, true, true)
            break
        end
    end

    if found then return true end
end

Armor:Add({
    Name = "Net Runner",
    Description = "L33T Material",
    Model = "models/TrinityPrime.dx80.mdl",
    Entitie = "armor_netrunner",
    Wallhack = false,
    ScreenColor = Color(255, 100, 72, 200),
    HUDPaint = function(ply)
        netrunner_VisionUI(ply)
    end,
    OnGiveClient = function(ply)
        hook.Add("PostDrawTranslucentRenderables", "NetRunnerUI", function()
            netrunner_Vision(ply)
        end)
    end,
    PostPlayerDraw = function(ply)
        netrunner_DrawShield(ply)
    end,
    Health = baseArmor + armorIncrease,
    Armor = baseHealth + healthIncrease,
    JumpPower = baseJump + jumpIncrease,
    Speed = 1 + runPower,
    OnGive = function(ply)
        ply.immuneToGluon = Gluongun
    end,
    Abilities = {
        [1] = {
            Cooldown = 30,
            Action = function(armor, ply)
                local hookName = ply:EntIndex() .. "_bulletShield"
                ply:SetNWBool("ShieldEnabled", true)

                hook.Add("EntityFireBullets", hookName, function(ent, data)
                    if not IsValid(ply) then
                        hook.Remove("EntityFireBullets", hookName)

                        return
                    end

                    local b = netrunner_Shield(ply, ent, data)
                    if b then return false end
                end)

                timer.Create(ply:EntIndex() .. "_shieldEnt", 5, 1, function()
                    hook.Remove("EntityFireBullets", hookName)

                    if IsValid(ply) then
                        ply:SetNWBool("ShieldEnabled", false)
                        ply:EmitSound("weapons/shatter.wav")
                    end
                end)

                if SERVER then
                    ply:EmitSound("weapons/pap_shot.wav")
                end

                return true
            end,
            Description = "Deploy a shield that will protect you from incoming bullets"
        },
        [2] = {
            Cooldown = 45,
            Description = "Empties weapons in your view",
            Action = function(armor, ply)
                if SERVER then
                    ply:EmitSound("tfa_cso2/weapons/awm_gauss/awm_gauss_hit_effect.wav")
                    local eff = EffectData()
                    eff:SetOrigin(ply:GetPos())
                    eff:SetAngles(ply:EyeAngles())
                    eff:SetFlags(1)
                    util.Effect("eff_netsteal", eff, true, true)

                    for _, v in pairs(ents.FindInCone(ply:GetShootPos(), ply:GetAimVector(), 500, .707)) do
                        if (not v:IsPlayer()) then continue end
                        if (v:GetGang() ~= "" and ply:GetGang() == v:GetGang()) then continue end

                        for i, wep in pairs(v:GetWeapons()) do
                            if (wep:Clip1() > 1) then
                                wep:SetClip1(0)
                            end
                        end
                    end
                end

                return true
            end
        },
        [3] = {
            Cooldown = 30,
            Action = function(armor, ply)
                if SERVER then
                    local eff = EffectData()
                    eff:SetEntity(ply)
                    util.Effect("eff_netshut", eff, true, true)
                    local timerName = ply:EntIndex() .. "_shieldBolt"

                    timer.Create(timerName, 1, 5, function()
                        if (not IsValid(ply)) then
                            timer.Remove(timerName)

                            return
                        end

                        local found = false

                        for k, v in pairs(ents.FindInSphere(ply:GetPos(), 350)) do
                            if not v:IsPlayer() then continue end

                            if (v:Armor() <= 0) then continue end
                            if (v:GetGang() ~= "" and ply:GetGang() == v:GetGang()) then continue end

                            local totalArmor = v:Armor() * .1
                            v:SetArmor(v:Armor() - totalArmor)
                            if (ply:Armor() >= ply:GetMaxArmor()) then continue end
                            ply:SetArmor(ply:Armor() + totalArmor)

                            found = true
                        end

                        if (found) then
                            ply:EmitSound("tfa_cso2/weapons/taserknife_woman/taserknife_woman_slash" .. math.random(1, 3) .. ".wav")
                        end
                    end)
                end

                return true
            end,
            Description = "Steals player armor around you"
        }
    },
    OnRemoveClient = function()
        hook.Remove("PostDrawTranslucentRenderables", "NetRunnerUI")
    end,
    OnRemove = function(ply)
        ply:SetNWBool("ShieldEnabled", false)

        if CLIENT then
            hook.Remove("PostDrawTranslucentRenderables", "NetRunnerUI")
        end
    end
})