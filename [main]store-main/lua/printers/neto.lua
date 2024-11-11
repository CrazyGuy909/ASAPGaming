util.AddNetworkString("Store.Printers:Buy")
util.AddNetworkString("Store.Printers:Sync")
util.AddNetworkString("Store.Printers:Select")

hook.Add("DatabaseInitialized", "Printers:DatabaseInitialized", function()
    ASAPDriver:MySQLCreateTable("printer_skins", {
        steamid = "VARCHAR(22)",
        printers = "TEXT",
        selected = "VARCHAR(32)"
    }, "steamid")

    ASAPDriver:MySQLHook("printer_skins", function(ply, data)
        if not data then
            data = {
                printers = "[]",
                selected = "random"
            }

            ASAPDriver:MySQLQuery("INSERT INTO printer_skins (steamid, printers, selected) VALUES (" .. ply:SteamID64() .. ", '[]', 'random')")
        end

        ply.printerSelected = data.selected
        ply.printerInventory = util.JSONToTable(data.printers or "[]") or {}
        net.Start("Store.Printers:Sync")
        net.WriteUInt(#ply.printerInventory, 6)

        for _, v in pairs(ply.printerInventory) do
            net.WriteString(v)
        end

        net.WriteString(ply.printerSelected or "")
        net.Send(ply)
    end)
end)

net.Receive("Store.Printers:Buy", function(l, ply)
    local printer = net.ReadString()
    local inv = ply.printerInventory
    local price = Store.Printers.Skins[printer]
    if not price then return end

    if ply:GetStoreCredits() < price then
        ply:ChatPrint("You don't have enough credits to buy this printer skin!")

        return
    end

    if table.HasValue(inv, printer) then
        ply:ChatPrint("You already own this printer skin!")

        return
    end

    ply:AddStoreCredits(-price)
    table.insert(ply.printerInventory, printer)
    ply.printerSelected = printer

    ASAPDriver:MySQLQuery("UPDATE printer_skins SET printers = '" .. util.TableToJSON(ply.printerInventory) .. "', selected='" .. printer .. "' WHERE steamid = " .. ply:SteamID64(), function()
        MsgC(Color(100, 255, 0), "[PrinterStore] ", color_white, ply:Nick(), " bought a printer skin!")
    end)
end)

net.Receive("Store.Printers:Select", function(l, ply)
    local printer = net.ReadString()

    if printer ~= "random" and not table.HasValue(ply.printerInventory, printer) then
        ply:ChatPrint("You don't own this printer skin!")

        return
    end

    ply.printerSelected = printer

    ASAPDriver:MySQLQuery("UPDATE printer_skins SET selected='" .. printer .. "' WHERE steamid = " .. ply:SteamID64(), function()
        MsgC(Color(100, 255, 0), "[PrinterStore] ", color_white, ply:Nick(), " selected a printer skin!")
    end)
end)

hook.Add("OnPrinterCreated", "Printer:SetSkin", function(printer)
    if not IsValid(printer) then return end -- Check if printer is a valid entity
    local owner = printer:GetOwner()
    if not IsValid(owner) then return end -- Check if owner is valid

    local selected = owner.printerSelected

    if not selected or not owner.printerInventory or #owner.printerInventory == 0 then return end -- Check if selected printer skin is valid and owner has inventory

    if selected == "random" then
        selected = table.Random(owner.printerInventory)
    end

    local mat_a, mat_b = "printer_skins/" .. selected .. "/printer", "printer_skins/" .. selected .. "/rack"
    printer:SetSubMaterial(0, mat_b)
    printer:SetSubMaterial(3, mat_a)
end)

function GiftPrinterSkin(ply)
    local sk
    for skin, _ in RandomPairs(Store.Printers.Skins) do
        if (table.HasValue(ply.printerInventory, skin)) then continue end
        sk = skin
        break
    end

    if sk then
        ply:SendLua("Derma_Message('You have unlocked skin paint " .. sk .. "!', 'Printer Skin', 'OK')")
        table.insert(ply.printerInventory, sk)
        net.Start("Store.Printers:Sync")
        net.WriteUInt(#ply.printerInventory, 6)

        for _, v in pairs(ply.printerInventory) do
            net.WriteString(v)
        end

        net.WriteString(ply.printerSelected or "")
        net.Send(ply)

        ASAPDriver:MySQLQuery("UPDATE printer_skins SET printers = '" .. util.TableToJSON(ply.printerInventory) .. "' WHERE steamid = " .. ply:SteamID64(), function()
            MsgC(Color(100, 255, 0), "[PrinterStore] ", color_white, ply:Nick(), " bought a printer skin!")
        end)
    else
        ply:SendLua("Derma_Message('You already got all skin paints', 'Printer Skin', 'OK')")
        ply:UB3AddItem(1315, 1)
    end
end