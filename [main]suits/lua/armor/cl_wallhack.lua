local targets = {
    asap_money_printer = "PRINTER",
    sent_gang_computer = "GANG CPU",
    player = true,
}

local nextCheck = 0
local toMeter = 0.0254 * (4 / 3)
local foundEnts = {}
local black = Color(0, 0, 0, 255)
local circleMat = Material("shenesis/circleoutline.png", "noclamp smooth")

function Armor:DrawESP()
    local w = ScrW()
    local ply = LocalPlayer()
    if (nextCheck < CurTime()) then
        nextCheck = CurTime() + 2
        foundEnts = {}

        for i, v in pairs(ents.FindInSphere(ply:EyePos(), 1024)) do
            if (not IsValid(v) or v == ply) then continue end

            if (targets[v:GetClass()] or (v:IsPlayer() and v:Alive())) then
                table.insert(foundEnts, v)
            end
        end
    end

    local pulse = 1 - (nextCheck - CurTime()) / 2
    surface.SetDrawColor(color_white)
    surface.SetMaterial(circleMat)

    for i, v in pairs(foundEnts) do
        if (not IsValid(v)) then continue end
        local center = v:LocalToWorld(v:OBBCenter())
        local dist = math.floor(v:GetPos():Distance(ply:GetPos()) * toMeter)
        local toScreen = center:ToScreen()
        local x, y = toScreen.x, toScreen.y
        if (x < -50 or y < -50 or x > w + 50 or y > ScrH() + 50) then continue end
        local size = pulse * 128
        surface.SetAlphaMultiplier(1 - pulse)
        surface.SetDrawColor(255, 255, 255, (1 - pulse) * 255)
        surface.DrawTexturedRectRotated(x, y, size, size, 0)
        draw.SimpleText(dist .. "m", XeninUI:Font(20, true), x, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(v:IsPlayer() and v:Nick() or targets[v:GetClass()], XeninUI:Font(32, true), x + 2, y + 66, black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(v:IsPlayer() and v:Nick() or targets[v:GetClass()], XeninUI:Font(32, true), x, y + 64, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetAlphaMultiplier(1)
    end
end