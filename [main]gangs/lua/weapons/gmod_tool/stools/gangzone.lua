TOOL.Category = "Gangs"
TOOL.Name = "#tool.gangzone.name"
local startingPoint
local endPoint

if CLIENT then
    language.Add("tool.gangzone.name", "Gang Zone")
    language.Add("tool.gangzone.desc", "Create your gang zone so you can build your own factory")
    language.Add("tool.gangzone.left", "Set the starting point")
    language.Add("tool.gangzone.left.1", "Close the zone")
    language.Add("tool.gangzone.right", "Cancel Zone Creation")
    language.Add("tool.gangzone.reload", "Save Gang Zone")
else
    util.AddNetworkString("GangZone.SendZone")
end

local ranks = {
    trialmoderator = true,
    moderator = true,
    admin = true,
    senioradmin = true,
    superadmin = true,
    owner = true
}

TOOL.Information = {
    { name = "left", stage = 0 },
    { name = "left.1", stage = 1 },
    { name = "right", stage = 2 },
    { name = "reload", stage = 2 },
}

function TOOL:LeftClick(trace)
    if not ranks[self:GetOwner():GetUserGroup()] then return end
    if self:GetStage() == 0 then
        if CLIENT then
            startingPoint = trace.HitPos
        end
        self:SetStage(1)
    elseif self:GetStage() == 1 then
        if CLIENT then
            endPoint = trace.HitPos
        end
        self:SetStage(2)
    end
    return true
end

function TOOL:Deploy()
    self:SetStage(0)
    if CLIENT then
        toolgun = self
        startingPoint = nil
    end
    displayZone = true
end

function TOOL:Holster()
    self:SetStage(0)
    if CLIENT then
        startingPoint = nil
    end
    displayZone = false
end

function TOOL:RightClick(trace)
    if not ranks[self:GetOwner():GetUserGroup()] then return end
    if self:GetStage() == 2 then
        self:SetStage(0)
        if CLIENT then
            startingPoint = nil
        end
        return true
    end
end

if SERVER then
    net.Receive("GangZone.SendZone", function(l, ply)
        if not ranks[ply:GetUserGroup()] then return end
        local name = net.ReadString()
        local start = net.ReadVector()
        local endpos = net.ReadVector()
        OrderVectors(start, endpos)

        if not asapgangs.Zones then
            asapgangs.Zones = {}
        end

        for k, v in pairs(ents.FindInBox(start, endpos)) do
            if v:isDoor() then
                if not asapgangs.Doors[name] then
                    asapgangs.Doors[name] = {}
                end
                table.insert(asapgangs.Doors[name], v)
            end
        end

        asapgangs.Zones[name] = {
            Gang = "",
            Start = start,
            EndPos = endpos,
        }

        file.Write("gang_zones.txt", util.TableToJSON(asapgangs.Zones, true))
        asapgangs:BroadcastZones()
    end)
end

function TOOL:Reload(trace)
    if not ranks[self:GetOwner():GetUserGroup()] then return end
    if CLIENT and self:GetStage() == 2 then
        Derma_StringRequest("Insert zone name", "It must be an id/number/word, but must be unique!", "zone", function(txt)
            net.Start("GangZone.SendZone")
            net.WriteString(txt)
            net.WriteVector(startingPoint)
            net.WriteVector(endPoint)
            net.SendToServer()
        end)
        return true
    end
end

hook.Add("PreDrawTranslucentRenderables", "Draw.GangZone", function()
    local toolgun = LocalPlayer():GetActiveWeapon()
    if not IsValid(toolgun) or toolgun:GetClass() != "gmod_tool" then return end
    if not string.StartWith(toolgun:GetMode() or "", "gang") then return end
    local stage = toolgun:GetStage()

    if not asapgangs.Zones then
        asapgangs.Zones = {}
    end

    for k, v in pairs(asapgangs.Zones) do
        local diff = v.EndPos - v.Start
        render.DrawWireframeBox(v.Start, Angle(0, 0, 0), Vector(0, 0, 0), diff, Color(75, 175, 255), true)
        render.SetColorMaterial()
        render.CullMode(MATERIAL_CULLMODE_CW)
        render.DrawBox(v.Start, Angle(0, 0, 0), Vector(0, 0, 0), diff, Color(75, 150, 255, 25), true)
        render.CullMode(MATERIAL_CULLMODE_CCW)
    end

    if not startingPoint then return end

    if stage and stage == 1 then
        local hitPos = LocalPlayer():GetEyeTrace().HitPos
        local diff = hitPos - startingPoint
        render.DrawWireframeBox(startingPoint, Angle(0, 0, 0), Vector(0, 0, 0), diff, Color(100, 150, 25), false)
        render.DrawWireframeBox(startingPoint, Angle(0, 0, 0), Vector(0, 0, 0), diff, color_white, true)
    elseif stage and stage == 2 then
        local diff = endPoint - startingPoint
        render.DrawWireframeBox(startingPoint, Angle(0, 0, 0), Vector(0, 0, 0), diff, Color(100, 150, 25), false)
        render.DrawWireframeBox(startingPoint, Angle(0, 0, 0), Vector(0, 0, 0), diff, color_white, true)
        render.SetColorMaterial()
        render.CullMode(MATERIAL_CULLMODE_CW)
        render.DrawBox(startingPoint, Angle(0, 0, 0), Vector(0, 0, 0), diff, Color(125, 255, 50, 50), true)
        render.CullMode(MATERIAL_CULLMODE_CCW)
    end
end)