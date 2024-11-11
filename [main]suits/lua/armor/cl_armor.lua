function Armor:DrawHUDBar(title, fill, y, charges)
    charges = charges or 1
    local wid = 196
    local hy = ScrH() - 164 - 38 * y
    draw.SimpleText(title, "XeninUI.TextEntry", ScrW() / 2 - wid / 2 + 2, hy - 8 + 2, color_black)
    draw.SimpleText(title, "XeninUI.TextEntry", ScrW() / 2 - wid / 2, hy - 8, color_white)
    draw.RoundedBox(4, ScrW() / 2 - wid / 2, hy + 12, wid, 16, Color(16, 16, 16))
    local maxWide = (wid - charges * 2 - (charges > 1 and 2 or 0)) / charges
    local extra = fill % (1 / charges) * charges
    local tiles = math.floor(fill / (1 / charges))

    for k = 0, tiles - 1 do
        draw.RoundedBox(4, ScrW() / 2 - wid / 2 + 2 + k * (maxWide + 2), hy + 14, maxWide, 12, Color(246, 147, 41))
    end

    draw.RoundedBox(4, ScrW() / 2 - wid / 2 + 2 + tiles * (maxWide + 2), hy + 14, maxWide * extra, 12, Color(235, 235, 235))
end

function Armor:ShowDroppingSuit(seconds)
    local maxTime = seconds or 5
    seconds = seconds or 5

    hook.Add("HUDPaint", "PreparingSuitDrop", function()
        seconds = seconds - FrameTime()

        if seconds <= 0 then
            hook.Remove("HUDPaint", "PreparingSuitDrop")

            return
        end

        draw.SimpleText("Dropping your suit...", XeninUI:Font(24), ScrW() / 2, 56, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(math.Round(seconds, 1), XeninUI:Font(64, true), ScrW() / 2, 132, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        local wide = 200
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(ScrW() / 2 - wide / 2, 74, wide, 16)
        surface.SetDrawColor(255, 255, 255, 150)
        surface.DrawRect(ScrW() / 2 - wide / 2 + 4, 74 + 4, (wide - 8) * (seconds / maxTime), 8)
    end)
end

net.Receive("ASAP.Suits:ShowDropSuit", function()
    local secondsToDrop = net.ReadUInt(4)
    Armor:ShowDroppingSuit(secondsToDrop)
    chat.AddText(Color(226, 109, 0), "[SUITS] ", color_white, "Your suit will drop in ", Color(75, 255, 100), secondsToDrop, color_white, " seconds")
end)

local wide, heigth = 1024, 64
local visorName = os.time() + math.random(CurTime() + 2)
local textureRT = GetRenderTargetEx("armor_rt_" .. visorName, wide, heigth, 0, 0, 12, 2, IMAGE_FORMAT_DEFAULT)

local armorTitle = CreateMaterial("armor_rt_" .. visorName, "UnlitGeneric", {
    ["$basetexture"] = textureRT:GetName(),
    ["$vertexcolor"] = 1,
    ["$vertexalpha"] = 1,
    ["$ignorez"] = 1,
})

net.Receive("armorSend", function()
    local name = net.ReadString()
	print("IM GOATED")
    hook.Remove("HUDPaint", "armorDisplay")
    hook.Remove("PostDrawHUD", "armorDisplay")

    if (name == "nil" and LocalPlayer().armorSuit) then
        local data = Armor:Get(LocalPlayer().armorSuit)

        if (data and data.OnRemoveClient) then
            data.OnRemoveClient(LocalPlayer())
        end

        LocalPlayer().armorSuit = nil
        LocalPlayer().armorData = nil
        LocalPlayer():SetGravity(1)

        return
    end

    LocalPlayer().armorSuit = nil
    local data = Armor:Get(name)
    LocalPlayer().armorData = data
    if (not data) then return end
    LocalPlayer().armorSuit = name
    local str = [[
<font=Armor.HUD><color=:r,:g,:b>:name</color><color=210, 210, 210> - :desc</color></font>
]]
    local col = data.Color or Color(46, 204, 113)
    str = str:Replace(":r", col.r)
    str = str:Replace(":g", col.g)
    str = str:Replace(":b", col.b)
    str = str:Replace(":name", data.Name)
    str = str:Replace(":desc", data.Description)
    str = markup.Parse(str)
    local width = str:GetWidth() + 16

    if (data.OnGiveClient) then
        data.OnGiveClient(LocalPlayer())
    end

    local w = ScrW()
    render.PushRenderTarget(textureRT)
    cam.Start2D()
    render.OverrideAlphaWriteEnable(true, true)
    render.ClearDepth()
    render.Clear(0, 0, 0, 0)
    surface.SetDrawColor(34, 255, 0, 100)
    surface.DrawOutlinedRect(wide / 2 - width / 2, 0, width, 24 + 8)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(wide / 2 - width / 2, 0, width, 24 + 8)
    str:Draw(wide / 2, heigth / 2 - 16, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    render.OverrideAlphaWriteEnable(false)
    cam.End2D()
    render.PopRenderTarget()
    armorTitle:SetTexture("$basetexture", textureRT)

    hook.Add("HUDPaint", "armorDisplay", function()
        surface.SetMaterial(armorTitle)
        surface.SetDrawColor(color_white)
        surface.DrawTexturedRect(w / 2 - wide / 2, 10, wide, heigth)

        if (data.WallHack or data.Wallhack) then
            Armor:DrawESP()
        end
    end)
end)

hook.Add("PrePlayerDraw", "PreDrawArmorVar", function(ply, flag)
    if not ply.armorSuit then return end
    local armorData = Armor:Get(ply.armorSuit)

    if (armorData and armorData.PrePlayerDraw) then
        local res = armorData.PrePlayerDraw(ply)
        if (res) then return res end
    end
end)

local back = surface.GetTextureID("asap/health_back")
local bar = surface.GetTextureID("asap/health_bar")

surface.CreateFont("Armor.HUD.Blur", {
    font = "Montserrat",
    size = 20,
    blursize = 4
})

surface.CreateFont("Armor.HUD2", {
    font = "Montserrat",
    size = 20,
    shadow = true
})

hook.Add("PlayerHUDShouldDraw", "DisableHUDPlayer", function(ply)
    if (ply.armorSuit) then return true end
end)

local lp

hook.Add("PostDrawTranslucentRenderables", "HUDDisplay", function()
    lp = LocalPlayer()

    for _, ply in pairs(player.GetAll()) do
        if ply == lp or not IsValid(ply) or not ply.armorSuit or not ply:Alive() or ply:GetNoDraw() then continue end

        local tr = util.TraceLine({
            start = lp:GetShootPos(),
            endpos = ply:GetShootPos(),
            filter = {lp, ply}
        })

        if (tr.HitWorld or IsValid(tr.Entity)) then continue end
        hook.Run("ArmorDisplay", ply)
    end
end)

local maxDistance = 512 ^ 2

hook.Add("ArmorDisplay", "PostArmorDraw", function(ply)
    if (ply.armorSuit and not ply.armorData) then
        ply.armorData = Armor:Get(ply.armorSuit)
    end

    if (ply.armorSuit and ply.armorData) then
        if (ply:GetColor().a < 200) then return end
        if (ply:GetNWBool("ArmorSalamander")) then return end
        local bone = ply:LookupBone("ValveBiped.Bip01_Head1")

        if (ply.armorData.PostPlayerDraw) then
            ply.armorData.PostPlayerDraw(ply)
        end

        if (bone) then
            local matrix = ply:GetBoneMatrix(bone)
            if not matrix then return end
            local pos = matrix:GetTranslation()
            local dist = LocalPlayer():GetPos():DistToSqr(pos) / maxDistance
            if (dist >= 1) then return end
            local scale = (ply.armorData.Size or 100) / 100
            local vang = EyeAngles()
            vang:RotateAroundAxis(vang:Up(), -90)
            vang:RotateAroundAxis(vang:Forward(), 90)
            vang:RotateAroundAxis(-vang:Right(), 0)
            pos = pos + Vector(0, 0, scale * 16 + dist * 64)
            pos = pos:ToScreen()
            cam.Start2D()
            surface.SetDrawColor(color_white)
            surface.SetTexture(back)
            surface.DrawTexturedRect(pos.x - 128, pos.y, 256, 64)
            surface.SetTexture(bar)
            local health = math.Clamp(ply:Health() / ply:GetMaxHealth(), 0, 1)
            local cf = .164
            local fnl = 1 - .95
            local total = 256 - 256 * (cf + fnl)
            surface.SetDrawColor(Color(0, 0, 0, 200))
            surface.DrawTexturedRect(pos.x - 128, pos.y, 256, 64)
            surface.SetDrawColor(color_white)
            surface.DrawTexturedRectUV(pos.x - 128 + 42, pos.y + 8, total * health, 32, cf, 0, cf + (health * (1 - (cf + fnl))), 1)
            local name = ply:GetNWString("SuitName", "")
            draw.SimpleText(name ~= "" and name or ply.armorSuit, "Armor.HUD.Blur", pos.x - 72, pos.y + 28, Color(0, 0, 0))
            draw.SimpleText(name ~= "" and name or ply.armorSuit, "Armor.HUD2", pos.x - 72, pos.y + 28, color_white)
            draw.SimpleText(ply:Nick(), "Armor.HUD.Blur", pos.x, pos.y - 4, color_black, 1, 1)
            draw.SimpleText(ply:Nick(), "Armor.HUD2", pos.x, pos.y - 4, team.GetColor(ply:Team()), 1, 1)
            surface.SetDrawColor(75, 120, 255)
            surface.DrawRect(pos.x - 128 + 54, pos.y + 22, math.Clamp(ply:Armor() / ply:GetMaxHealth(), 0, 1) * 188, 4)
            cam.End2D()
        end
    end
end)

net.Receive("armorSync", function()
    local ent = net.ReadEntity()
    local typ = net.ReadString()
    ent.armorData = ent.armorSuit and Armor:Get(typ) or nil
    if (ent == LocalPlayer()) then return end
    ent.armorSuit = typ ~= "" and typ or nil
end)

surface.CreateFont("Armor.HUD", {
    size = 18,
    font = "Roboto"
})

surface.CreateFont("Armor.3DHUD", {
    size = 42,
    font = "Roboto",
    shadow = true
})

surface.CreateFont("Armor.3DHUDName", {
    size = 30,
    font = "Roboto",
    shadow = true
})

local glow = surface.GetTextureID("effects/lamp_beam")

local colorAbilities = {Color(255, 114, 58), Color(58, 197, 255), Color(146, 255, 58), Color(255, 58, 253)}

local circles = include("xeninui/libs/circles.lua")
local crcles = {}
local hy = ScrH() - 96
local deg = surface.GetTextureID("vgui/gradient-r")
local alpha = 0

hook.Add("HUDPaint", "SuitAbilities", function()
    if (not LocalPlayer().armorSuit) then return end
    local armorData = LocalPlayer().armorData
    local suit = LocalPlayer().armorSuit
    if not armorData or not armorData.Abilities then return end
    local iconW = 36
    local abilityCount = table.Count(armorData.Abilities)
    local w = (iconW + 8) * abilityCount + 8

    if (LocalPlayer().armorData.HUDPaint) then
        shouldDraw = LocalPlayer().armorData.HUDPaint(LocalPlayer())
    end

    draw.RoundedBox(4, ScrW() / 2 - w / 2, hy, w, iconW + 16, Color(255, 255, 255, 45))
    draw.SimpleText("Abilities:", "XeninUI.TextEntry", ScrW() / 2 - w / 2, hy - 20, color_white)

    if not LocalPlayer()._newCooldowns then
        LocalPlayer()._newCooldowns = {}
    end

    for k = 0, abilityCount - 1 do
        local cooldown = false

        if (LocalPlayer()._newCooldowns[suit] and LocalPlayer()._newCooldowns[suit][k + 1]) then
            cooldown = {LocalPlayer()._newCooldowns[suit][k + 1] - CurTime(), armorData.Abilities[k + 1].Cooldown}
        end

        local ix = ScrW() / 2 - w / 2 + 8 + k * (iconW + 8)
        local clr = colorAbilities[k + 1]
        draw.RoundedBox(4, ix, hy + 8, iconW, iconW, Color(46, 46, 46))
        surface.SetTexture(glow)
        surface.SetDrawColor(ColorAlpha(clr, 125))
        render.SetScissorRect(ix, hy + 8, ix + iconW, hy + 8 + iconW, true)

        if (cooldown == false) then
            draw.SimpleText(string.upper(keybinds.getKey("ability_" .. (k + 1))), "XeninUI.TextEntry", ix + iconW / 2, hy + 8 + iconW / 2, Color(clr.r * 2.8, clr.g * 2.8, clr.b * 2.8), 1, 1)
            surface.DrawTexturedRectRotated(ix + 16, hy + 18, 128, 128, (RealTime() + k * -.5) * -128)
        else
            if not (crcles[k + 1]) then
                local cir = circles.New(CIRCLE_FILLED, iconW, ix + iconW / 2, hy + 26)
                cir:SetDistance(5)
                cir:SetColor(Color(78, 118, 199, 64))
                crcles[k + 1] = cir
            else
                crcles[k + 1]:SetStartAngle(-90)
                crcles[k + 1]:SetEndAngle(Lerp(1 - cooldown[1] / cooldown[2], 0, 360) - 90)
                draw.NoTexture()
                crcles[k + 1]()
                draw.SimpleText(math.ceil(cooldown[1]) .. "s", "XeninUI.TextEntry", ix + iconW / 2, hy + 8 + iconW / 2, Color(255, 255, 255), 1, 1)

                if (LocalPlayer()._newCooldowns[suit][k + 1] <= CurTime()) then
                    LocalPlayer()._newCooldowns[suit][k + 1] = nil
                end
            end
        end

        render.SetScissorRect(0, 0, 0, 0, false)
    end

    alpha = Lerp(FrameTime() * 5, alpha, g_ContextMenu:IsVisible() and 255 or 0)
    surface.SetDrawColor(ColorAlpha(color_black, alpha))
    surface.SetTexture(deg)
    surface.DrawTexturedRect(ScrW() / 2, 0, ScrW() / 2, ScrH())
    local y = 42
    w, h = ScrW(), ScrH()
    local tx, ty = draw.SimpleText("Abilities", "Arena.Medium", w - 24, y, ColorAlpha(color_white, alpha), TEXT_ALIGN_RIGHT)
    surface.SetDrawColor(ColorAlpha(color_white, alpha))
    surface.DrawRect(w - 24 - tx, y + ty, tx, 2)
    local i = 0

    for k = 1, abilityCount do
        if not armorData.Abilities[k].Description then continue end
        i = i + 1
        local clr = colorAbilities[k]
        tx, _ = draw.SimpleText("[" .. string.upper(keybinds.getKey("ability_" .. k)) .. "]", "Arena.Small", w - 24, y + ty + k * 24, ColorAlpha(clr, alpha), TEXT_ALIGN_RIGHT)
        draw.SimpleText(armorData.Abilities[k].Description, "Arena.Small", w - 24 - tx - 6, y + ty + k * 24 + 2, Color(0, 0, 0, alpha), TEXT_ALIGN_RIGHT)
        draw.SimpleText(armorData.Abilities[k].Description, "Arena.Small", w - 24 - tx - 8, y + ty + k * 24, ColorAlpha(clr, alpha), TEXT_ALIGN_RIGHT)
    end

    if armorData.Passive then
        local list = string.Explode("\n", armorData.Passive, false)

        for k, v in pairs(list) do
            if (k == 1) then
                v = "Passive: " .. v
            end

            draw.SimpleText(v, "Arena.Small", w - 24 - 6, y + ty + (i + k) * 24 + 2, Color(0, 0, 0, alpha), TEXT_ALIGN_RIGHT)
            draw.SimpleText(v, "Arena.Small", w - 24 - 8, y + ty + (i + k) * 24, Color(235, 235, 235, alpha), TEXT_ALIGN_RIGHT)
        end
    end
end)

timer.Simple(1, function()
    -- Button down func
    keybinds.RegisterBind("ability_1", "1st Suit Ability", KEY_B, function()
        local ply = LocalPlayer()
        Armor:DoKeyPress(ply, KEY_B, 1)
    end, function() end)

    -- Button down func
    keybinds.RegisterBind("ability_2", "2nd Suit Ability", KEY_N, function()
        local ply = LocalPlayer()
        Armor:DoKeyPress(ply, KEY_N, 2)
    end, function() end)

    -- Button down func
    keybinds.RegisterBind("ability_3", "3rd Suit Ability", KEY_M, function()
        local ply = LocalPlayer()
        Armor:DoKeyPress(ply, KEY_M, 3)
    end, function() end)

    -- Button down func
    keybinds.RegisterBind("ability_4", "4th Suit Ability", KEY_K, function()
        local ply = LocalPlayer()
        Armor:DoKeyPress(ply, KEY_K, 4)
    end, function() end)
end)