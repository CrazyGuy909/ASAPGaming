net.Receive("Gangs_ToPlayer", function(len)
    local tag = net.ReadString()

    if not asapgangs.gangList then
        asapgangs.gangList = {}
    end

    asapgangs.gangList[tag] = net.ReadTable()
    asapgangs.gangList[tag].Tag = tag

    if isstring(asapgangs.gangList[tag].Members) then
        asapgangs.gangList[tag].Members = util.JSONToTable(asapgangs.gangList[tag].Members)
    end

    if IsValid(GANGS) then
        GANGS:Remove()

        timer.Simple(1, function()
            GANGS = vgui.Create("Gangs.Main")
        end)
    end
end)

net.Receive("Gangs.UpdateXP", function()
    local amount = net.ReadUInt(32)

    if LocalPlayer():GetGang() ~= "" and asapgangs.gangList[LocalPlayer():GetGang()] then
        asapgangs.gangList[LocalPlayer():GetGang()].Experience = amount
    end
end)

net.Receive("Gangs.Update", function()
    local data = net.ReadTable()

    if LocalPlayer():GetGang() ~= "" and asapgangs.gangList[LocalPlayer():GetGang()] then
        for k, v in pairs(data) do
            asapgangs.gangList[LocalPlayer():GetGang()][k] = v
        end
    end
end)

net.Receive("Gangs.UpdateMoney", function()
    local isCredits = net.ReadBool()
    local amount = net.ReadFloat()

    if LocalPlayer():GetGang() ~= "" and asapgangs.gangList[LocalPlayer():GetGang()] then
        asapgangs.gangList[LocalPlayer():GetGang()][isCredits and "Credits" or "Money"] = amount
    end
end)

local outlines = {}
local buffing = {}
local nextCheck = 0
local halos = CreateClientConVar("asap_gangs_halo", "0", true)

hook.Add("PostDrawTranslucentRenderables", "Gangs.DrawOutline", function()
    local ply = LocalPlayer()
    if ply:GetGang() == "" then return end
    if ply:InArena() then return end
    if not halos:GetBool() then return end

    if asapgangs.GetUpgrade(ply:GetGang(), "Halo") > 0 and nextCheck < RealTime() then
        outlines = {}
        buffing = {}
        nextCheck = RealTime() + 2

        for k, v in pairs(player.GetAll()) do
            if v == ply then continue end

            if v:GetGang() == ply:GetGang() then
                local dist = v:GetPos():DistToSqr(ply:GetPos())
                if dist > 400000 then continue end
                table.insert(dist < 180000 and buffing or outlines, v)
            end
        end
    end
end)

--[[
    
]]
local hadNoBuff = true
local buffs = {}

hook.Add("HUDPaint", "Gang.ShowBuff", function()
    local ply = LocalPlayer()
    if ply:GetGang() == "" then return end

    if ply:IsGangBuffed() then
        if hadNoBuff then
            hadNoBuff = false
            buffs = {}

            for k, v in pairs(UPGRADE_TEST) do
                if not v.Buff then continue end
                local upg = asapgangs.GetUpgrade(ply:GetGang(), k)

                if upg > 0 then
                    table.insert(buffs, v.Icon)
                end
            end
        end

        draw.SimpleText("Gang Buffs:", "XeninUI.TextEntry", ScrW() / 2 - 248, ScrH() - 64, color_white)

        for k, v in pairs(buffs) do
            surface.SetMaterial(Material(v))
            surface.SetDrawColor(Color(255, 255, 255, 100))
            surface.DrawTexturedRect(ScrW() / 2 - 184 + k * 28, ScrH() - 66, 24, 24)
        end
    else
        buffs = {}
        hadNoBuff = true
    end
end)

hook.Add("PreDrawHalos", "Gang.Halos", function()
    if not halos:GetBool() then return end
    if not LocalPlayer():GetGang() or LocalPlayer():GetGang() == "" then return end
    //halo.Add(outlines, Color(50, 200, 0), 2, 2, 1, true, true)
    halo.Add(buffing, Color(255, 50, 255), 2, 2, 1, true, true)
end)

local cache = {}
local nextCacheCheck = 0

hook.Add("PreDrawOpaqueRenderables", "GangOutlines", function()
    /*
    render.SetStencilWriteMask(0xFF)
    render.SetStencilTestMask(0xFF)
    render.SetStencilReferenceValue(0)
    render.SetStencilPassOperation(STENCIL_KEEP)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilZFailOperation(STENCIL_REPLACE)

    if nextCacheCheck < CurTime() then
        nextCacheCheck = CurTime() + 5
        cache = {}

        for k, v in pairs(asapgangs.GetMembers(LocalPlayer():GetGang())) do
            if v == LocalPlayer() then continue end
            if v:GetPos():Distance(LocalPlayer():GetPos()) > 2048 then continue end
            table.insert(cache, v)
        end
    end

    for _, ply in pairs(cache) do
        if not IsValid(ply) then continue end
        if not ply:Alive() then continue end
        if ply:InArena() then continue end
        ply:DrawModel()
    end

    render.SetStencilCompareFunction(STENCIL_EQUAL)
    render.ClearBuffersObeyStencil(0, 148, 133, 50, false)
    render.SetStencilEnable(false)
    */
end)

hook.Add("OnLoungePlayerChat", "Gang.Tag", function(Add, ply, text)
    if IsValid(ply) and ply:GetGang() ~= "" then
        Add({Color(175, 200, 255), "[" .. string.upper(ply:GetGang()) .. "] "})
    end
end)