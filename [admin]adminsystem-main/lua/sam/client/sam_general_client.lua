-- LocalPlayer Permissions Checker
function SAM.HasPermission(permission)
	for k,v in pairs(SAM.Default_Config.ranks) do
		if (v.name == LocalPlayer():GetUserGroup()) then
			if (table.HasValue(v.permissions, permission) or table.HasValue(v.permissions, "*")) then
				return true
			end
		end
	end
	return false
end

-- ClearDecals command Client-Side
net.Receive("SAM.RemoveAllDecalsNM", function()
	RunConsoleCommand("r_cleardecals")
end)

-- Noclip Management
hook.Add("PlayerNoClip", "SAM.ManageNoclip", function(ply, desiredState)
	if (desiredState == true) then
		if (SAM.HasPermission("sam.noclip")) then
			if (table.HasValue(SAM.Default_Config.adminmodecommands, "BindNoclip")) then
				if (LocalPlayer():GetNWBool("sam_adminmode", false) == false) then
					return false
				end
			end
			return true
		end
	else
		return true
	end
    return false
end)

-- Error Handler
net.Receive("SAM.ShootError", function()
    local errormsg = net.ReadString()
    chat.AddText(SAM.Default_Config.prefixcolor, SAM.Default_Config.prefix, Color(255,0,0), errormsg)
end)

-- Command Echo
net.Receive("SAM.CommandEcho", function()
    local echo,args = net.ReadString(),net.ReadTable()
    for i = 1,10 do echo = string.gsub(echo, "  ", " ") end
    if not (args[1]) then
        chat.AddText(SAM.Default_Config.prefixcolor, SAM.Default_Config.prefix, echo)
    else
        local outputTable = {SAM.Default_Config.prefixcolor, SAM.Default_Config.prefix}
        local arc = 1
        for k,v in pairs(string.Split(echo, " ")) do
            if (v == "#P") then
                if (args[arc]:IsValid()) then
                    table.insert(outputTable, team.GetColor(args[arc]:Team()))
                    table.insert(outputTable, args[arc]:Name().." ")
                    arc = arc + 1
                else
                    table.insert(outputTable, Color(0,0,0))
                    table.insert(outputTable, "CONSOLE ")
                    arc = arc + 1
                end
            elseif (v == "#N") then
                table.insert(outputTable, SAM.Default_Config.echoNumberColor)
                table.insert(outputTable, args[arc].." ")
                arc = arc + 1
            elseif (v == "#S") then
                table.insert(outputTable, SAM.Default_Config.echoStringColor)
                table.insert(outputTable, args[arc].." ")
                arc = arc + 1
            elseif (v == "#T") then
                table.insert(outputTable, SAM.Default_Config.echoTimeColor)
                table.insert(outputTable, args[arc].." ")
                arc = arc + 1
			elseif (v == "#MP") then
				for k,v in pairs(args[arc]) do
					local tm = IsValid(v) and v.Team and v:Team() or 1
					if (k == 1) then
						table.insert(outputTable, team.GetColor(tm))
	                    table.insert(outputTable, v:Nick())
					else
						table.insert(outputTable, Color(255,255,255))
						table.insert(outputTable, ",")
						table.insert(outputTable, team.GetColor(tm))
	                    table.insert(outputTable, v:Nick())
					end
				end
				table.insert(outputTable, Color(255,255,255))
				table.insert(outputTable, " ")
				arc = arc + 1
            else
                table.insert(outputTable, SAM.Default_Config.echoDefaultColor)
                table.insert(outputTable, v.." ")
            end
        end
        chat.AddText(unpack(outputTable))
    end
end)

-- Clear Corpses
net.Receive("SAM.ClientRemoveRagdolls", function()
	for k,v in pairs(ents.GetAll()) do
		if (v:GetClass() == "class C_ClientRagdoll") then
			v:Remove()
		end
	end
end)

-- Staff Chat
net.Receive("SAM.SendStaffMessage", function()
	local sender = net.ReadEntity()
	local message = net.ReadString()

	chat.AddText(SAM.Default_Config.prefixcolorstaff,SAM.Default_Config.prefixstaff,team.GetColor(sender:Team()),sender:Name(),Color(255,255,255),": ",SAM.Default_Config.staffchatcolor,message)
end)