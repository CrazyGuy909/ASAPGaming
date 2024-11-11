OrangeSuit = OrangeSuit or {}
OrangeSuit.Holders = {}
OrangeSuit.ItemID = 400

hook.Add("EntityTakeDamage", "Orange.Safe", function(ent)
    if (ent:IsPlayer()) then
        ent.SafeFire = CurTime() + 30
    end
end)

hook.Add("PlayerDeath", "Orange.Suit", function(ply)
    if (OrangeSuit.Holster == ply:SteamID64()) then
        OrangeSuit.Holster = nil
        OrangeSuit:Initialize()
    end
end)

hook.Add("PlayerDisconnect", "Orange.Return", function(ply)
    if (OrangeSuit.Holder == ply:SteamID64() and ply:UB3HasItem(OrangeSuit.ItemID)) then
        ply:UB3RemoveItem(OrangeSuit.ItemID, 1)
        local sid = ply:SteamID64()
        local items = table.Copy(ply._ub3inv)

        timer.Simple(1, function()
            BU3.SQL.SaveInventory(sid, items)
            items = nil
        end)

        OrangeSuit:Initialize()
    end
end)

function OrangeSuit:Initialize()
    if true then return end
    if (self.Holder) then return end

    if (player.GetCount() > 16) then
        timer.Simple(math.random(5, 500), function()
            for k, v in RandomPairs(player.GetAll(), false) do
                if (v:InArena()) then continue end
                if (v.SafeFire and v.SafeFire > CurTime()) then continue end
                if (OrangeSuit.Holders[v:SteamID64()]) then continue end
                OrangeSuit.Holders[v:SteamID64()] = true
                self.Holder = v:SteamID64()
                v:BU3GiveItem("")
            end
        end)
    else
        timer.Simple(60, function()
            OrangeSuit:Initialize()
        end)
    end
end

local runPower = .1
local baseHealth = 1500
local baseArmor = 750
local baseJump = 150
local Gluongun = true
local orange = "models/props/cs_italy/orange.mdl"

if SERVER then
    util.AddNetworkString("Orange.SetView")
    util.AddNetworkString("Orange.Remove")
end

net.Receive("Orange.SetView", function()
    local ent = net.ReadEntity()
    hook.Remove("CalcView", "OrangeView")

    hook.Add("CalcView", "OrangeView", function(ply, pos, ang)
        if not IsValid(ent) then
            hook.Remove("CalcView", "OrangeView")

            return
        end

        local tr = util.QuickTrace(ent:GetPos(), ang:Forward() * -128, ent)

        local tbl = {
            origin = tr.HitPos + tr.HitNormal * 8,
            angles = ang,
            drawviewer = true
        }

        return tbl
    end)
end)

net.Receive("Orange.Remove", function()
    local owner = net.ReadEntity()

    SafeRemoveEntity(owner.orange)
end)

local orangeDuration = 3

Armor:Add({
    Name = "Orange Suit",
    Description = "Turns players into an orange?",
    Model = "models/konnie/asapgaming/destiny2/moonfang_hunter_luxe.mdl",
    Entitie = "armor_orange",
    PostPlayerDraw = function(ply)
        if not IsValid(ply.orange) then
            ply.orange = ClientsideModel("models/props/cs_italy/orange.mdl")
            ply.orange:SetNoDraw(true)

            ply.orange.RenderOverride = function(ent)
                if not IsValid(ply) then
                    ent:Remove()

                    return
                end

                ent:DrawModel()
            end

            local matrix = Matrix()
            matrix:Scale(Vector(2.5, 2.5, 2.5))
            ply.orange:EnableMatrix("RenderMultiply", matrix)
        else
            local att = ply:GetAttachment(ply:LookupAttachment("eyes"))
            ply.orange:SetPos(att.Pos + att.Ang:Forward() * -3.5 + att.Ang:Up() * -1)
            ply.orange:SetAngles(att.Ang)
            ply.orange:DrawModel()
        end
    end,
    --SuitDraw(ply, k)
    HUDPaint = function(ply) end,
    Abilities = {
        [1] = {
            Cooldown = 20,
            Action = function(s, ply)
                if CLIENT then return end
                local target = ply:GetEyeTrace().Entity

                if (IsValid(target) and target:IsPlayer()) then
                    local ent = ents.Create("prop_physics")
                    ent:SetModel(orange)
                    ent:SetPos(target:GetPos() + Vector(0, 0, 40))
                    ent:Spawn()
                    ent:EmitSound("ojamajo/poof.wav")
                    local ed = EffectData()
                    ed:SetOrigin(target:GetPos())
                    ed:SetEntity(target)
                    util.Effect("entity_remove", ed, true, true)
                    local effectdata = EffectData()
                    effectdata:SetOrigin(ply:GetEyeTrace().HitPos)
                    effectdata:SetStart(ply:GetShootPos() + Vector(0, 0, -4))
                    effectdata:SetAttachment(1)
                    effectdata:SetEntity(ply)
                    util.Effect("ToolTracer", effectdata, true, true)
                    ply:EmitSound("ambient/energy/spark2.wav")
                    ent:EmitSound("garrysmod/balloon_pop_cute.wav")

                    hook.Add("EntityTakeDamage", ent, function(_, vic, dmg)
                        if (vic == ent) then
                            dmg:SetDamage(0)

                            return true
                        end
                    end)

                    constraint.Keepupright(ent, Angle(0, 0, 0), 0, 0)
                    target:SetMoveType(MOVETYPE_NONE)
                    target:SetParent(ent)
                    target:SetNoDraw(true)

                    if (target:IsPlayer()) then
                        target:Freeze(true)
                        target:GodEnable()

                        timer.Simple(target:Ping() / 1000, function()
                            net.Start("Orange.SetView")
                            net.WriteEntity(ent)
                            net.Send(target)
                        end)

                        timer.Simple(orangeDuration, function()
                            if IsValid(target) then
                                target:Freeze(false)
                                target:GodDisable()

                                if not IsValid(ent) then
                                    target:Spawn()

                                    return
                                end

                                target:SetPos(ent:GetPos())
                                target:SetAngles(Angle(0, target:GetAngles().y, 0))
                                target:SetNoDraw(false)
                                target:SetParent(nil)
                                target:SetMoveType(MOVETYPE_WALK)
                                ent:Remove()
                            end
                        end)
                    elseif (target:IsNPC()) then
                        timer.Simple(orangeDuration, function()
                            if IsValid(ent) then
                                target:SetPos(ent:GetPos())
                                target:SetAngles(Angle(0, target:GetAngles().y, 0))
                                target:SetNoDraw(false)
                                target:SetMoveType(MOVETYPE_STEP)
                                target:SetParent(nil)

                                if IsValid(target:GetActiveWeapon()) then
                                    target:GetActiveWeapon():SetNoDraw(false)
                                end

                                ent:Remove()
                            else
                                target:Remove()
                            end
                        end)
                    end
                end
            end
        }
    },
    Health = baseHealth,
    Armor = baseArmor,
    JumpPower = baseJump,
    Speed = 1 + runPower,
    OnGive = function(ply)
        ply.immuneToGluon = Gluongun
    end,
    OnRemove = function(ply)
        net.Start("Orange.Remove")
        net.WriteEntity(ply)
        net.Broadcast()
    end
})