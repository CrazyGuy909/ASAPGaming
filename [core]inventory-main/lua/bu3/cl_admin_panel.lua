--[[-------------------------------------------------------------------------
This is a seperate unskinned window for admins to be able to see other users inventories
and add items or delete them.
---------------------------------------------------------------------------]]

BU3.AdminMenu = {}
BU3.AdminMenu.InventoryMenu = nil

function BU3.AdminMenu.OpenInventory(inv, user)
	if BU3.AdminMenu.InventoryMenu ~= nil then
		BU3.AdminMenu.InventoryMenu:Close()
	end

	local frame = vgui.Create("DFrame")
	frame:SetSize(300, 500)
	frame:SetTitle(user:Name().."'s Inventory")
	frame:Center()
	frame:MakePopup()
	frame.Close = function(s)
		s:Remove()
		BU3.AdminMenu.InventoryMenu = nil
	end

	BU3.AdminMenu.InventoryMenu = frame

	local itemList = nil

	-- -1 means nothing
	local selectedItemID = -1

	local function CreateItemList(filter)
		selectedItemID = -1
		if itemList ~= nil then itemList:Remove() end

		local items = inv

		if filter ~= nil and filter ~= "" then
			items = {}
			--If filter is on, lets filter out the items
			local filteredTable = {}
			for k ,v in pairs(inv) do
				local name = BU3.Items.Items[k].name
				if string.match(string.lower(name), string.lower(filter), 1) then
					filteredTable[k] = v
				end
			end
			items = filteredTable
		end

		--Create the scroll panel for the list
		itemList = vgui.Create("DListView", frame)
		itemList:SetPos(5, 35)
		itemList:SetSize(290, 400)
		itemList:SetMultiSelect( false )
		itemList:AddColumn("Item Name")
		itemList.OnRowSelected = function( lst, index, pnl )
			selectedItemID = pnl.itemID
		end
		for k, v in pairs(items) do
			local itemName = BU3.Items.Items[k].name
			for a = 1, v do
				local p = itemList:AddLine(itemName)
				p.itemID = k
			end
		end
	end

	CreateItemList()

	--Create the delete button
	local searchBox = vgui.Create("DTextEntry", frame)
	searchBox:SetPos(5, 400 + 35 + 5)
	searchBox:SetSize(290, 25)
	searchBox:SetUpdateOnType(true)
	searchBox.OnValueChange = function(s , val)
		CreateItemList(val)
	end

	local deleteButton = vgui.Create("DButton", frame)
	deleteButton:SetPos(5, 400 + 35 + 5 + 30)
	deleteButton:SetText("Delete")
	deleteButton:SetSize(290, 25)
	deleteButton.DoClick = function(s)
		net.Start("UB3:AdminDeleteItem")
		net.WriteEntity(user)
		net.WriteInt(selectedItemID, 32)
		net.SendToServer()
	end
end

function BU3.AdminMenu.OpenMenu()
	local frame = vgui.Create("DFrame")
	frame:SetSize(300,130)
	frame:SetTitle("Blue's Unboxing 3 Admin")
	frame:Center()
	frame:MakePopup()

	--Now add a drop down menu to select which user to wish to view

	local selected = nil

	local ComboBox = vgui.Create( "DComboBox", frame)
	ComboBox:SetPos( 5, 50 )
	ComboBox:SetSize( 300 - 10, 25 )
	ComboBox:SetValue( "Select User..." )

	for k, v in pairs(player.GetAll()) do
		local p = ComboBox:AddChoice(v:Name(), v)
	end


	ComboBox.OnSelect = function( panel, index, value )
		for k, v in pairs(player.GetAll()) do
			if v:Name() == value then
				selected = v
				break
			end
		end
		
	end

	--Create a view and cancel button
 
	local view = vgui.Create("DButton", frame)
	view:SetPos(155, 130 - 25)
	view:SetSize(140, 20)
	view:SetText("View Inventory")
	view.DoClick = function() 
		if selected ~= nil then
			net.Start("BU3:AdminOpenInventory")
			net.WriteEntity(selected)
			net.SendToServer()

			frame:Close() 
		end
	end

	local cancel = vgui.Create("DButton", frame)
	cancel:SetPos(5, 130 - 25)
	cancel:SetSize(140, 20)
	cancel:SetText("Cancel")
	cancel.DoClick = function() frame:Close() end

end

net.Receive("BU3:AdminOpenInventory", function()
	local size = net.ReadDouble()
	local data = net.ReadData(size)
	local user = net.ReadEntity()

	local inv = util.Decompress(data)
	inv = util.JSONToTable(inv)

	--Now open the menu
	BU3.AdminMenu.OpenInventory(inv, user)
end)

hook.Add("OnPlayerChat", "BU3OpenAdminMenu", function(ply, text)
	if ply == LocalPlayer() then
		if text == "!unboxadmin" then
			BU3.AdminMenu.OpenMenu()
		end
	end
end)