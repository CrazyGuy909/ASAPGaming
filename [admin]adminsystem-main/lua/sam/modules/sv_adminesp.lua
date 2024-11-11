util.AddNetworkString("SAM.ToggleESP")

local function adminespf(args, sender)
    local ply = args[1]
    net.Start("SAM.ToggleESP")
    net.Send(ply)

    if (ply.esptoggle) then
        SAM.CommandEcho("#P has disabled ESP for #P", {sender, ply})
        ply.esptoggle = nil
    else
        SAM.CommandEcho("#P has enabled ESP for #P", {sender, ply})
        ply.esptoggle = true
    end
end
SAM.RegisterCommand({name = "ESP", description = "Toggle ESP", command = "esp", permission = "sam.esp", func = adminespf, args = {SAM.Args.ply}, allowRCONUsage = true, checkIfCanTarget = true})
