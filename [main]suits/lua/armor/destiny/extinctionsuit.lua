AddCSLuaFile()

Armor:Add({
    Name = "Extinction Suit",
    Description = "Makes you a big bullet magnet.",
    Model = "models/konnie/asapgaming/destiny2/antiextinction.mdl",
    Entitie = "armor_extinction",
    Cooldown = 10,
    Wallhack = true,
    noArrest = true,
    ScreenColor = Color(0, 0, 0, 0),
    HUDPaint = function(ply)
        if ply:GetNW2Bool("ExtinctionSuit") and (ply._extinctionSuit or 0) > 0 then
            ply._extinctionSuit = ply._extinctionSuit - FrameTime()
            draw.SimpleText("Magnetic Shield:", "XeninUI.TextEntry", ScrW() / 2 + 1, 121, Color(0, 0, 0), 1, TEXT_ALIGN_BOTTOM)
            draw.SimpleText("Magnetic Shield:", "XeninUI.TextEntry", ScrW() / 2, 120, color_white, 1, TEXT_ALIGN_BOTTOM)
            surface.SetDrawColor(0, 0, 0)
            surface.DrawRect(ScrW() / 2 - 128, 128, 256, 24)
            surface.SetDrawColor(255, 255, 255)
            surface.DrawRect(ScrW() / 2 - 128 + 2, 130, 252 * (ply._extinctionSuit / 10), 20)
        end
    end,
    Health = 1200,
    Armor = 2500,
    Speed = 1.3,
    OnGive = function(ply)
        ply.immuneToGluon = true
    end,
    -- what happens when they get the suit equipped
    Abilities = {
        [1] = {
            Cooldown = 30,
            Action = function(s, ply)
                ply._extinctionSuit = 10

                if SERVER then
                    hook.Remove("EntityFireBullets", ply)
                    hook.Add("EntityFireBullets", ply, fireBulletsArmor)
                    ply:SetNW2Bool("ExtinctionSuit", true)
                end

                ply:Wait(10, function()
                    ply:SetNW2Bool("ExtinctionSuit", false)
                    hook.Remove("EntityFireBullets", ply)
                end)
            end
        }
    },
    OnRemove = function(ply)
        hook.Remove("EntityFireBullets", ply)
        ply.immuneToGluon = nil
    end
})

function fireBulletsArmor(owner, ent, data)
    if (data.Attacker == owner) then return end

    local tr = util.TraceHull({
        start = data.Src,
        endpos = data.Src + data.Dir * data.Distance,
        mins = -Vector(16, 16, 16),
        maxs = Vector(16, 16, 16),
        filter = ent
    })

    local dist = tr.HitPos:Distance(owner:GetPos())

    if (dist < 200) then
        data.Dir = ((owner:GetPos() + Vector(0, 0, 30)) - data.Src):GetNormalized()
        data.Damage = data.Damage / 2
        data.Force = data.Force / 2
        owner:EmitSound("weapons/fx/nearmiss/bulletltor0" .. math.random(1, 9) .. ".wav", 75, 100, .6)

        return true
    end
end

if SERVER then return end
local vortex = Material("effects/strider_bulge_dx60")

hook.Add("PostPlayerDraw", "ExintionSuit", function(ply)
    if (not ply:GetNW2Bool("ExtinctionSuit")) then return end
    render.SetMaterial(vortex)
    render.DrawSprite(ply:GetPos() + Vector(0, 0, 40), 64, 128, color_white)
end)