print("calling amenu sv")
resource.AddWorkshop("728328781")
util.AddNetworkString("ASAP.PurchaseAmmo")
util.AddNetworkString("ASAP.RemoveEntity")

AddCSLuaFile("amenu/cl_masterpanel.lua")
AddCSLuaFile("amenu/cl_dashboard.lua")
AddCSLuaFile("amenu/cl_entspanel.lua")
AddCSLuaFile("amenu/cl_jobspanel.lua")
AddCSLuaFile("amenu/cl_websites.lua")
AddCSLuaFile("amenu/cl_rules.lua")
AddCSLuaFile("amenu/cl_settings.lua")
AddCSLuaFile("amenu/cl_skillspanel.lua")
AddCSLuaFile("amenu/cl_dailyreward.lua")

AddCSLuaFile("amenu.lua")

util.AddNetworkString("CustomEntity.Network")

net.Receive("F4.Magic", function(l, ply)
    local b = net.ReadBool()
    ply.isDoingMagic = b
    net.Start("F4.Magic", true)
    net.WriteEntity(ply)
    net.WriteBool(b)
    net.Broadcast()
end)

net.Receive("ASAP.PurchaseAmmo", function(l, ply)
    local id = net.ReadInt(8)
    local am = math.Round(net.ReadFloat())
    local ammo = GAMEMODE.AmmoTypes[id]

    if (am <= 0) then return end
    if (am > 999) then return end

    if (ammo && ply:canAfford(ammo.price * (am / ammo.amountGiven))) then
        ply:addMoney(-math.ceil(ammo.price * (am / ammo.amountGiven)))
        ply:SetAmmo(ply:GetAmmoCount(ammo.ammoType) + am, ammo.ammoType)
        ply:EmitSound("items/ammo_pickup.wav")
    end
end)

net.Receive("ASAP.RemoveEntity", function(l, ply)
    local ent = net.ReadString()
    local id = net.ReadString()
    for k, v in pairs(ents.FindByClass(ent)) do
        if (v.Getowning_ent && v:Getowning_ent() == ply and v.DarkRPItem.cmd == id) then
            v:Remove()
            ply:removeCustomEntity({
                cmd = id,
            })
            break
        end
    end
end)

hook.Add("OnChatTab", "HideSkillsCommand", function(text)
    -- Check if the chat message starts with "!skills"
    if string.sub(text, 1, 7) == "!skills" then
        -- Hide the chat message by returning an empty string
        return ""
    end
end)

hook.Add("OnPlayerChat", "HideSkillsCommand3", function(ply, text, teamChat, isDead)
    -- Check if the chat message starts with "!skills"
    if string.sub(text, 1, 7) == "!skills" then
        -- Hide the chat message by returning true
        return true
    end
end)

hook.Add("OnPlayerChat", "HideSkillsCommand5", function(ply, text, teamChat, isDead)
    -- Check if the chat message is "!skills"
    if text == "!skills" then
        -- Hide the command by returning true
        return true
    end
end)

hook.Add("StartChat", "HideSkillsCommand2", function()
    -- Add a hook to intercept the user input before it's sent
    hook.Add("OnChatText", "HideSkillsCommand2", function(text)
        -- Check if the chat message starts with "!skills"
        if string.sub(text, 1, 7) == "!skills" then
            -- Hide the chat message
            return true, ""
        end
    end)
end)

-- Remove the hook when the chat is closed
hook.Add("FinishChat", "HideSkillsCommand2", function()
    hook.Remove("OnChatText", "HideSkillsCommand")
end)

hook.Add("playerBoughtCustomEntity", "PlayerBoughtPrinter", function(ply, tblEnt, ent, cost)
    if not tblEnt.max or tblEnt.max == 0 then return end
    net.Start("CustomEntity.Network")
    net.WriteString(tblEnt.cmd)
    net.WriteUInt(ent:EntIndex(), 16)
    net.Send(ply)
end)