TOOL.Category = "Gangs"
TOOL.Name = "#tool.gangcomputer.name"

if CLIENT then
    language.Add("tool.gangcomputer.name", "Entities spawner")
    language.Add("tool.gangcomputer.desc", "Spawn an entity and set the zone it owns")
    language.Add("tool.gangcomputer.left", "Spawn an entity")
    language.Add("tool.gangcomputer.right", "Delete the spawned entity")
else
    util.AddNetworkString("Gangs.PlaceComputer")
    util.AddNetworkString("ASAP.Gangs:SaveBase")
    util.AddNetworkString("ASAP.Gangs:UpdateMode")
end

local entities = {
    ["Computer"] = "sent_gang_computer",
    ["Delivery pallets"] = "sent_gang_delivery",
    ["Manufacture table"] = "sent_gang_manufacture_table",
    ["Manufacture machine"] = "sent_gang_manufacture",
    ["Portal"] = "sent_gang_portal",
    ["Pot"] = "sent_gang_pot",
    ["Delivery shaft"] = "sent_gang_dropoff",
}

TOOL.ClientConVar["spawning"] = "Computer"

TOOL.Information = {
    {
        name = "left",
        stage = 0
    },
    {
        name = "right",
        stage = 0
    }
}

--
-- Remove a single entity
--
local offsets = {
    ["sent_gang_delivery"] = 4,
    ["sent_gang_manufacture"] = 27
}
local ranks = {
    trialmoderator = true,
    moderator = true,
    admin = true,
    senioradmin = true,
    superadmin = true,
    owner = true
}


function TOOL:LeftClick(trace)
    if (not ranks[self:GetOwner():GetUserGroup()]) then return end
    if not IsFirstTimePredicted() then return end
    local hit = trace.HitPos + Vector(0, 0, 16)
    local found = false

    if (SERVER and self:GetClientInfo("spawning") == "Delivery shaft") then
        
    end

    for k, v in pairs(asapgangs.Zones) do
        if (hit:WithinAABox(v.Start, v.EndPos)) then
            found = k
            break
        end
    end

    if not found then
        self:GetOwner():ChatPrint("You must place the entity inside a zone")
    else
        if SERVER then
            local class = self:GetClientInfo("spawning")
            local ent = ents.Create(class)

            if (class == "sent_gang_portal") then
                ent:SetPos(trace.HitPos + trace.HitNormal * 2)
                ent:SetAngles(trace.HitNormal:Angle())
            else
                ent:SetPos(trace.HitPos + Vector(0, 0, offsets[ent:GetClass()] or 0))
                ent:SetAngles(Angle(0, self:GetOwner():EyeAngles().y - 90, 0))
            end

            ent:Spawn()
            ent.IsBase = true
            ent.Think = function() end
            ent.Use = function() end
            self:GetOwner().lastPlace = found
            undo.Create(scripted_ents.Get(class).PrintName)
            undo.AddEntity(ent)
            undo.SetPlayer(self:GetOwner())
            undo.Finish()
        end
    end

    return true
end

function TOOL:Deploy()
    local tr = self:GetOwner():GetEyeTrace()
    local var = self:GetClientInfo("spawning")
    local ent = scripted_ents.Get(var)
    if not ent then return end
    self:MakeGhostEntity(ent.Model, tr.HitPos, tr.HitNormal:Angle())
end

function TOOL:Holster()
    self:ReleaseGhostEntity()
end

--
-- Remove this entity and everything constrained
--
function TOOL:RightClick(trace)
    if (not ranks[self:GetOwner():GetUserGroup()]) then return end
    if SERVER and IsValid(trace.Entity) and string.StartWith(trace.Entity:GetClass(), "sent_gang") then
        trace.Entity:Remove()
    end

    return true
end

function TOOL:UpdateGhostComputer(ent, ply)
    if (not IsValid(ent)) then return end
    local trace = ply:GetEyeTrace()

    if (not trace.Hit or IsValid(trace.Entity) and (trace.Entity:IsPlayer() or trace.Entity:GetClass() == "sent_gang_computer")) then
        ent:SetNoDraw(true)

        return
    end

    local CurPos = ent:GetPos()
    local NearestPoint = ent:NearestPoint(CurPos - (trace.HitNormal * 512))
    local Offset = CurPos - NearestPoint
    local pos = trace.HitPos + Offset
    local class = self:GetClientInfo("spawning")

    if (class == "sent_gang_portal") then
        ent:SetPos(trace.HitPos + trace.HitNormal * 2)
        ent:SetAngles(trace.HitNormal:Angle())
    else
        ent:SetPos(pos)
        ent:SetAngles(Angle(0, ply:EyeAngles().y - 90, 0))
    end

    ent:SetNoDraw(false)
end

function TOOL:Think()
    self:UpdateGhostComputer(self.GhostEntity, self:GetOwner())
end

function TOOL:UpdateGhostModel(class)
    local ent = scripted_ents.Get(class)
    if not ent then return end
    local tr = self:GetOwner():GetEyeTrace()

    if IsValid(self.GhostEntity) then
        self.GhostEntity:Remove()
    end

    self.GhostEntity = ents.CreateClientProp(ent.Model)
    self.GhostEntity:Spawn()
    self.GhostEntity:SetPos(tr.HitPos)
    self.GhostEntity:PhysicsDestroy()
    -- SOLID_NONE causes issues with Entity.NearestPoint used by Wheel tool
    --self.GhostEntity:SetSolid( SOLID_NONE )
    self.GhostEntity:SetMoveType(MOVETYPE_NONE)
    self.GhostEntity:SetNotSolid(true)
    self.GhostEntity:SetRenderMode(RENDERMODE_TRANSCOLOR)
    self.GhostEntity:SetColor(Color(255, 255, 255, 150))
end

net.Receive("ASAP.Gangs:UpdateMode", function(l, ply)
    ply:GetWeapon("gmod_tool").Tool["gangcomputer"]:UpdateGhost(net.ReadString())
end)

net.Receive("ASAP.Gangs:SaveBase", function(l, ply)
    if (ply.lastPlace) then
        asapgangs:SaveBase(ply.lastPlace)
    end
end)

function TOOL.BuildCPanel(pnl)
    pnl:Help("Select which entity do you want to spawn")
    local cmb = pnl:ComboBox("Entity", "gangcomputer_spawning")

    for k, v in pairs(entities, true) do
        cmb:AddChoice(k, v, true)
    end

    cmb.OnSelect = function(s, index, val, data)
        local toolgun = LocalPlayer():GetWeapon("gmod_tool")
        if not IsValid(toolgun) then return end
        RunConsoleCommand("gangcomputer_spawning", data)
        toolgun.Tool["gangcomputer"]:UpdateGhostModel(data)
    end

    local btn = pnl:Button("Save zone", "")

    btn.DoClick = function()
        net.Start("ASAP.Gangs:SaveBase")
        net.SendToServer()
    end
end