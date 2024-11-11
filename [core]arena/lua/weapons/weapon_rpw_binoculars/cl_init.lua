include("shared.lua")
language.Add("weapon_rpw_binoculars", "Binoculars")

surface.CreateFont("rangefinder", {
    font = "TargetID",
    extended = false,
    size = 32,
    weight = 600,
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

SWEP.PrintName = "Binoculars"
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFlip = false
SWEP.DrawWeaponInfoBox = false
SWEP.BounceWeaponIcon = false
SWEP.ViewModelFOV = 65

net.Receive("ASAP.Arena.Nuclear", function()
    local target = net.ReadVector()
    local dist = target:Distance(LocalPlayer():GetPos())

    if (dist < 3000) then
        surface.PlaySound("hl1/fvox/warning.wav")

        timer.Simple(2, function()
            surface.PlaySound("hl1/fvox/evacuate_area.wav")

            for k = 1, 5 do
                timer.Simple(1.5 + k / 2, function()
                    surface.PlaySound("hl1/fvox/buzz.wav")
                end)
            end
        end)
    end

    local pj = ProjectedTexture()
    pj:SetTexture("effects/flashlight001")
    pj:SetColor(Color(255, 0, 0))
    pj:SetFOV(130)
    pj:SetFarZ(3000)
    pj:SetBrightness(15)
    pj:SetConstantAttenuation(2)
    pj:SetPos(target + Vector(0, 0, 600))
    pj:SetAngles(Vector(0, 0, -1):Angle())
    pj:Update()

    timer.Simple(5, function()
        if IsValid(pj) then
            pj:Remove()
        end
    end)
end)

function SWEP:DrawHUD()
    if (self.Zoom_InZoom) then
        local mat_bino_overlay = Material("vgui/hud/rpw_binoculars_overlay_usa")
        local w = ScrW()
        local h = ScrH()
        surface.SetMaterial(mat_bino_overlay)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(0, -(w - h) / 2, w, w)
        local tr = self.Owner:GetEyeTrace()
        local range = (math.ceil(100 * (tr.StartPos:Distance(tr.HitPos) * 0.024)) / 100)

        if tr.HitSky then
            range = "-"
        else
            range = range .. "m"
        end

        surface.SetFont("rangefinder")
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos((w * 0.165), (h / 2) + 16)
        surface.DrawText("Range: " .. range)
        surface.SetTextPos((w * 0.775), (h / 2) + 16)
        surface.DrawText("Zoom: " .. self.Zoom_Current .. "x")
    end
end

function SWEP:AdjustMouseSensitivity()
    if (self.Zoom_InZoom) then
        local zoom = self.Zoom_Current
        local adjustedsens = 1 / zoom

        return adjustedsens
    end
end