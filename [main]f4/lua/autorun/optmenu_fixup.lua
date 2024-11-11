if CLIENT then
    local farz = CreateClientConVar("asap_farz", 16500, true, false)
    local fog = CreateClientConVar("asap_fog", 1, true, false)

    hook.Add("PopulateSettings", "optmenu_fixes", function(settings)
        settings:AddSlider("View Distance(Lower = More FPS)", "asap_farz", 1000, 25000, "Perfomance")
        settings:AddCheckbox("Disable Weapon World Models", "tfa_disable_worldmodel", "Perfomance", function() end)
        settings:AddCheckbox("Enable/Disable Shadows", "r_shadows", "Perfomance", function() end)
        settings:AddCheckbox("Enable/Disable Flexes(Example: Face Movement/Blinking)", "r_flex", "Perfomance", function() end)
        settings:AddCheckbox("Enable/Disable Player Eyes", "r_eyes", "Perfomance", function() end)
        settings:AddCheckbox("Enable/Disable Shadows", "r_shadows", "Perfomance", function() end)
        settings:AddCheckbox("Enable/Disable Custom Bullet Impact Effects", "cl_tfa_fx_impact_enabled", "Perfomance", function() end)
        settings:AddCheckbox("Enable/Disable Decals on models (Like blood or bullet holes)", "r_drawmodeldecals", "Visuals", function() end)
        settings:AddCheckbox("Enable/Disable Weapon Inspect Blur", "cl_tfa_inspection_bokeh", "Visuals", function() end)
    end)

    opt_force = 1
    opt_doLerp = false

    hook.Add("OnSelectSpawn", "HelpFarZ", function()
        opt_force = 0
        opt_doLerp = true
    end)

    hook.Add("OnSpawnOpen", "HelpFarZ", function()
        opt_force = 100
        opt_doLerp = false

        timer.Simple(1, function()
            opt_force = 0
        end)
    end)

    local noloop = false

    hook.Add("CalcView", "ModifyFarz", function(ply, pos, ang, fov, znear, zfar, drawviewer, ortho)
        if not noloop then
            noloop = true

            if opt_doLerp then
                opt_force = Lerp(FrameTime() * (2000 / farz:GetInt()), opt_force, 1.1)

                if opt_force >= 1 then
                    opt_doLerp = false
                end
            end

            local data = hook.Run("CalcView", ply, pos, ang, fov, znear, zfar, drawviewer, ortho)
            data.zfar = math.Clamp(farz:GetInt(), 800, 12000) * opt_force
            noloop = false

            return data
        end
    end)

    hook.Add("SetupWorldFog", "HandleMainFog", function()
        local zfar = farz:GetInt()
        if not fog:GetBool() or zfar < 1000 then return true end
    end)
end

if SERVER then
    util.AddNetworkString("F4.Magic")
else
    local text = surface.GetTextureID("ui/asap/f4_projection")

    net.Receive("F4.Magic", function()
        local ply = net.ReadEntity()
        local b = net.ReadBool()
        ply.isDoingMagic = b
        if not IsValid(ply) then return end
    end)

    local physBeam = Material("trails/physbeam")

    hook.Add("PostPlayerDraw", "MagicView", function(ply)
        if ply:InArena() then return end

        if ply.isDoingMagic then
            ply.eyeAttachment = ply:LookupAttachment("eyes") ~= -1 and ply:GetAttachment(ply:LookupAttachment("eyes")) or {
                Pos = ply:GetPos() + Vector(0, 0, 60),
                Ang = ply:GetAngles()
            }
            local att = ply.eyeAttachment
            local pos = att.Pos + att.Ang:Forward() * 22 - att.Ang:Right() * 0 + att.Ang:Up() * 4
            local ang = att.Ang
            ang:RotateAroundAxis(ang:Forward(), 90)
            ang:RotateAroundAxis(ang:Right(), 90)
            render.SetMaterial(physBeam)
            render.DrawBeam(att.Pos + Vector(0, 0, 0), pos + ang:Forward() * 19 + ang:Right() * .5, 1 + (math.tan(RealTime() * 4) * 2) % 2, RealTime() % 1, RealTime() % 1 - 1, Color(255, 255, 255, 35))
            render.DrawBeam(att.Pos + Vector(0, 0, 0), pos - ang:Forward() * 19 + ang:Right() * .5, 1 + (math.tan(RealTime() * 4) * 2) % 2, RealTime() % 1, RealTime() % 1 - 1, Color(255, 255, 255, 35))
            render.DrawBeam(att.Pos + Vector(0, 0, 0), pos + ang:Forward() * 19 + ang:Right() * 19, 1 + (math.tan(RealTime() * 4) * 2) % 2, RealTime() % 1, RealTime() % 1 - 1, Color(255, 255, 255, 35))
            render.DrawBeam(att.Pos + Vector(0, 0, 0), pos - ang:Forward() * 19 + ang:Right() * 19, 1 + (math.tan(RealTime() * 4) * 2) % 2, RealTime() % 1, RealTime() % 1 - 1, Color(255, 255, 255, 35))
            surface.SetDrawColor(Color(255, 255, 255, 255 + math.tan(RealTime() * 16)))
            surface.SetTexture(text)
            cam.Start3D2D(pos, ang, 0.075)
            surface.DrawTexturedRectUV(-256, 0, 512, 256, -0, -0, 1, .492)
            cam.End3D2D()
            ang:RotateAroundAxis(ang:Right(), 180)
            cam.Start3D2D(pos, ang, 0.075)
            surface.DrawTexturedRectUV(-256, 0, 512, 256, 0, .506, 1, 1)
            cam.End3D2D()
        end
    end)
end

hook.Add("CalcMainActivity", "MagicAnimation", function(ply, vel)
    if ply:InArena() then return end
    if ply.isDoingMagic then return ACT_HL2MP_RUN_MAGIC, -1 end
end)