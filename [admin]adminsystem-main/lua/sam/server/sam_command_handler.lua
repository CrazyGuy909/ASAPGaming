SAM.Commands = SAM.Commands or {}

SAM.Args = SAM.Args or {
    ply = 01,
    multi_ply = 02,
    number = 03,
    time = 04,
    string = 05,
    string_restofline = 06,
    sql_ply = 07
}

concommand.Add("sam", function(ply, cmd, args)
    local command = string.lower(args[1] or "")
    table.remove(args, 1)
    local commandData = {}

    for k, v in pairs(SAM.Commands) do
        if v.command == command then
            commandData = v
            break
        end
    end

    if table.IsEmpty(commandData) then
        SAM.ShootError(ply, "Command not found!")
    else
        if SAM.HasPermission(ply, commandData.permission) then
            SAM.CommandParser(ply, args, commandData)
        else
            SAM.ShootError(ply, "You do not have permission to run this command!")
        end
    end
end)

function SAM.RegisterCommand(commandData)
    for k, v in pairs(SAM.Commands) do
        if v.name == commandData.name then
            table.remove(SAM.Commands, k)
        end
    end

    table.insert(SAM.Commands, commandData)
    print("SAM Command Registered: " .. commandData.name)
end

function SAM.CommandParser(sender, rargs, commandData)
    local ConfirmedArgs = {}

    for k, v in pairs(commandData.args) do
        if not rargs[k] then
            local argstring = ""

            for k, v in pairs(commandData.args) do
                if v == SAM.Args.ply then
                    argstring = argstring .. " <player>"
                end

                if v == SAM.Args.number then
                    argstring = argstring .. " <number>"
                end

                if v == SAM.Args.time then
                    argstring = argstring .. " <time>"
                end

                if v == SAM.Args.string then
                    argstring = argstring .. " <string>"
                end

                if v == SAM.Args.string_restofline then
                    argstring = argstring .. " <string_restofline>"
                end

                if v == SAM.Args.multi_ply then
                    argstring = argstring .. " <multi_ply>"
                end

                if v == SAM.Args.sql_ply then
                    argstring = argstring .. " <steamid_name>"
                end
            end

            SAM.ShootError(sender, "Incorrect usage: !" .. commandData.command .. argstring)

            return
        end

        if v == SAM.Args.ply then
            if rargs[k] == "^" then
                if not sender:IsValid() then
                    SAM.ShootError(sender, "You cannot target yourself as console!")

                    return
                end

                table.insert(ConfirmedArgs, sender)
            elseif rargs[k] == "*" then
                SAM.ShootError(sender, "This command does not support the * argument!")

                return
            elseif rargs[k] == "@" then
                local entfo = sender:GetEyeTrace().Entity

                if entfo then
                    if entfo:IsPlayer() then
                        table.insert(ConfirmedArgs, entfo)
                    else
                        SAM.ShootError(sender, "You are not looking at a player!")

                        return
                    end
                else
                    SAM.ShootError(sender, "You are not looking at a player!")

                    return
                end
            elseif rargs[k] == "!" then
                SAM.ShootError(sender, "This command does not support the ! argument!")

                return
            else
                local foundPlayer = SAM.FindPlayer(rargs[k], "single")

                if foundPlayer == nil then
                    SAM.ShootError(sender, "You have not supplied a valid player name/sid!")

                    return
                end

                if commandData.checkIfCanTarget == true then
                    if SAM.CanTarget(sender, foundPlayer) then
                        table.insert(ConfirmedArgs, foundPlayer)
                    else
                        SAM.ShootError(sender, "You cannot target this player!")
                    end
                else
                    table.insert(ConfirmedArgs, foundPlayer)
                end
            end
        elseif v == SAM.Args.multi_ply then
            if rargs[k] == "^" then
                if not sender:IsValid() then
                    SAM.ShootError(sender, "You cannot target yourself as console!")

                    return
                end

                table.insert(ConfirmedArgs, {sender})
            elseif rargs[k] == "*" then
                local allPlys = {}
                local showWarning = false

                for k, v in pairs(player.GetAll()) do
                    if SAM.CanTarget(sender, v) then
                        table.insert(allPlys, v)
                    else
                        showWarning = true
                    end
                end

                if not allPlys[1] then
                    SAM.ShootError(sender, "You couldn't target any player found!")

                    return
                else
                    if showWarning == true then
                        SAM.ShootError(sender, "Some players found couldn't be targeted!")
                    end

                    table.insert(ConfirmedArgs, allPlys)
                end
            elseif rargs[k] == "@" then
                local entfo = sender:GetEyeTrace().Entity

                if entfo then
                    if entfo:IsPlayer() then
                        table.insert(ConfirmedArgs, {entfo})
                    else
                        SAM.ShootError(sender, "You are not looking at a player!")

                        return
                    end
                else
                    SAM.ShootError(sender, "You are not looking at a player!")

                    return
                end
            elseif rargs[k] == "!" then
                local plyset = player.GetAll()
                table.RemoveByValue(plyset, sender)
                table.insert(ConfirmedArgs, plyset)
            else
                local foundPlayers = SAM.FindPlayer(rargs[k], "all")

                if not foundPlayers[1] then
                    SAM.ShootError(sender, "You have not supplied a valid player names/sids!")

                    return
                end

                if commandData.checkIfCanTarget == true then
                    local ablePlayers = {}
                    local showWarning = false

                    for k, v in pairs(foundPlayers) do
                        if SAM.CanTarget(sender, v) then
                            table.insert(ablePlayers, v)
                        else
                            SAM.ShootError(sender, "You cannot target this player!")
                            showWarning = true
                        end
                    end

                    if not ablePlayers[1] then
                        SAM.ShootError(sender, "You couldn't target any player found!")

                        return
                    end

                    table.insert(ConfirmedArgs, ablePlayers)

                    if showWarning == true then
                        SAM.ShootError(sender, "Some players found couldn't be targeted!")
                    end
                else
                    table.insert(ConfirmedArgs, foundPlayers)
                end
            end
        elseif v == SAM.Args.number then
            if tonumber(rargs[k]) == nil then
                SAM.ShootError(sender, "You have not supplied a valid number!")

                return
            end

            table.insert(ConfirmedArgs, tonumber(rargs[k]))
        elseif v == SAM.Args.time then
            if SAM.TimeInterpreter(rargs[k]) == 0 then
                SAM.ShootError(sender, "You have not supplied a valid time!")

                return
            end

            local retval = SAM.TimeInterpreter(rargs[k])
            table.insert(ConfirmedArgs, retval)
        elseif v == SAM.Args.string then
            if rargs[k] == " " or rargs[k] == "" or rargs[k] == nil then
                SAM.ShootError(sender, "You have not supplied a valid string!")

                return
            end

            table.insert(ConfirmedArgs, tostring(rargs[k]))
        elseif v == SAM.Args.string_restofline then
            local tempstring = ""

            for j, w in pairs(rargs) do
                if j >= k and w ~= " " and w ~= "" and w ~= nil then
                    tempstring = tempstring .. " " .. w
                end
            end

            if string.sub(tempstring, 1, 1) == " " then
                tempstring = string.sub(tempstring, 2)
            end

            if tempstring == "" then
                SAM.ShootError(sender, "You have not supplied a valid rest of line string!")
            end

            table.insert(ConfirmedArgs, tempstring)
            break
        elseif v == SAM.Args.sql_ply then
            if rargs[k] == "^" then
                if not sender:IsValid() then
                    SAM.ShootError(sender, "You cannot target yourself as console!")

                    return
                end

                local reqArg = sender:SteamID()
                table.insert(ConfirmedArgs, reqArg)
            else
                local rsteamid = ""
                local foundPlayer = SAM.FindPlayer(rargs[k], "single")

                if foundPlayer == nil then
                    rsteamid = rargs[k]
                else
                    if SAM.CanTarget(sender, foundPlayer) then
                        rsteamid = foundPlayer:SteamID()
                    else
                        SAM.ShootError(sender, "You cannot target this player!")

                        return
                    end
                end

                if rsteamid == "" then
                    SAM.ShootError(sender, "You have not supplied a valid player name/sid!")

                    return
                end

                table.insert(ConfirmedArgs, rsteamid)
            end
        end
    end

    commandData.func(ConfirmedArgs, sender)
    hook.Run("onSAM.PostCommand", sender, commandData.command, ConfirmedArgs)
end

function SAM.CommandListener(ply, text, tchat)
    if not tchat then
        local commandData = false

        for k, v in pairs(SAM.Commands) do
            if string.lower("!" .. v.command) == string.lower(string.Split(text, " ")[1]) then
                commandData = v
            end
        end

        if not (commandData == false) then
            if SAM.HasPermission(ply, commandData.permission) then
                if ply:GetUserGroup() == "trialmoderator" then
                    SAM.ShootError(ply, "You must be on duty to use this command!")

                    return ""
                end
                if table.HasValue(SAM.Default_Config.adminmodecommands, commandData.name) and not ply.sam_adminmode then
                    SAM.ShootError(ply, "You must be in adminmode to use this command!")

                    return ""
                end

                for i = 0, 10 do
                    text = string.gsub(text, "  ", " ")
                end

                local args = string.Split(text, " ")
                table.remove(args, 1)
                SAM.CommandParser(ply, args, commandData)

                return ""
            else
                SAM.ShootError(ply, "You do not have permission to run this command!")

                return ""
            end

            hook.Run("onSAM.PreCommand", ply, SAM.HasPermission(ply, commandData.permission))
        end
    end
end

hook.Add("PlayerSay", "SAM.CommandHook", SAM.CommandListener)