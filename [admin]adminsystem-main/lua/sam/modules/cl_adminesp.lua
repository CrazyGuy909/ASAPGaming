surface.CreateFont("SAM.ESPFont", {
   font = "Arial",
   size = 15,
   weight = 50,
   antialias = true
})
surface.CreateFont("SAM.ESPFontBig", {
   font = "Arial",
   size = 25,
   weight = 50,
   antialias = true
})

local function DrawText(strText, oCol, iXPos, iYPos, big)
    if (big) then
        draw.SimpleTextOutlined(strText, "SAM.ESPFontBig", iXPos, iYPos-10, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
    else
    	draw.SimpleTextOutlined(strText, "SAM.ESPFont", iXPos, iYPos, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, color_black)
    end
end

local function drawesp()
    if not (SAM.HasPermission("sam.esp")) then return end

    for k,v in pairs(player.GetAll()) do
        if (LocalPlayer():GetPos():Distance(v:GetPos()) > 100) then continue end
        if (v == LocalPlayer() or !v:Alive()) then continue end
        local Pos = (v:GetPos() + Vector(0, 0, 50)):ToScreen()
        DrawText("Name: "..v:Nick(), team.GetColor(v:Team()), Pos.x, Pos.y + 13 * 0, true)
        DrawText("SteamID: "..v:SteamID(), Color(255, 255, 255, 255), Pos.x, Pos.y + 13 * 1)
        DrawText("Health: "..v:Health(), Color(255, 255, 255, 255), Pos.x, Pos.y + 13 * 3)
        DrawText("Armor: "..v:Armor(), Color(255, 255, 255, 255), Pos.x, Pos.y + 13 * 4)
        DrawText("Usergroup: "..v:GetUserGroup(), Color(255, 255, 255, 255), Pos.x, Pos.y + 13 * 5)
    end
end
local function drawhalos()
    halo.Add(player.GetAll(), Color(255,0,0), 0, 0, 2, true, true)
end

net.Receive("SAM.ToggleESP", function()
    if (hook.GetTable().HUDPaint["SAM.DrawESP"]) then
        hook.Remove("HUDPaint", "SAM.DrawESP")
        hook.Remove("PreDrawHalos", "SAM.DrawHalos")
    else
        hook.Add("HUDPaint", "SAM.DrawESP", drawesp)
        hook.Add("PreDrawHalos", "SAM.DrawHalos", drawhalos)
    end
end)
