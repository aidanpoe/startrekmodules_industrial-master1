---------------------------------------
---------------------------------------
--         Star Trek Modules         --
--                                   --
--            Created by             --
--       Jan 'Oninoni' Ziegler       --
--                                   --
-- This software can be used freely, --
--    but only distributed by me.    --
--                                   --
--    Copyright © 2022 Jan Ziegler   --
---------------------------------------
---------------------------------------

---------------------------------------
-- Ind. Replicator Props | Client    --
---------------------------------------

if SERVER then return end

-- Function to open ADD panel
local function OpenAddPanel()
	print("[Industrial Replicator CLIENT] Creating ADD panel")
	local frame = vgui.Create("DFrame")
	frame:SetSize(500, 400)
	frame:Center()
	frame:SetTitle("Add New Replicator Item")
	frame:MakePopup()
	
	local y = 30
	
	-- Item Path/Class
	local pathLabel = vgui.Create("DLabel", frame)
	pathLabel:SetPos(20, y)
	pathLabel:SetSize(200, 20)
	pathLabel:SetText("Model Path or Entity Class:")
	
	local pathEntry = vgui.Create("DTextEntry", frame)
	pathEntry:SetPos(20, y + 25)
	pathEntry:SetSize(460, 25)
	pathEntry:SetPlaceholderText("e.g. models/props/chair.mdl or class:weapon_physcannon")
	
	y = y + 60
	
	-- Display Name
	local nameLabel = vgui.Create("DLabel", frame)
	nameLabel:SetPos(20, y)
	nameLabel:SetSize(200, 20)
	nameLabel:SetText("Display Name:")
	
	local nameEntry = vgui.Create("DTextEntry", frame)
	nameEntry:SetPos(20, y + 25)
	nameEntry:SetSize(460, 25)
	nameEntry:SetPlaceholderText("e.g. Comfortable Chair")
	
	y = y + 60
	
	-- Category
	local catLabel = vgui.Create("DLabel", frame)
	catLabel:SetPos(20, y)
	catLabel:SetSize(200, 20)
	catLabel:SetText("Category:")
	
	local catCombo = vgui.Create("DComboBox", frame)
	catCombo:SetPos(20, y + 25)
	catCombo:SetSize(300, 25)
	
	-- Get categories from database
	local categories = {"FURNITURE", "EQUIPMENT", "CARGO", "MEDICAL", "ENG", "AWAY MISSION", "TOOLS", "MISC"}
	for _, cat in ipairs(categories) do
		catCombo:AddChoice(cat)
	end
	
	local newCatBtn = vgui.Create("DButton", frame)
	newCatBtn:SetPos(330, y + 25)
	newCatBtn:SetSize(150, 25)
	newCatBtn:SetText("Create New Category")
	newCatBtn.DoClick = function()
		Derma_StringRequest(
			"New Category",
			"Enter new category name:",
			"",
			function(text)
				catCombo:AddChoice(text)
				catCombo:SetValue(text)
			end
		)
	end
	
	y = y + 60
	
	-- Type
	local typeLabel = vgui.Create("DLabel", frame)
	typeLabel:SetPos(20, y)
	typeLabel:SetSize(200, 20)
	typeLabel:SetText("Item Type:")
	
	local typeCombo = vgui.Create("DComboBox", frame)
	typeCombo:SetPos(20, y + 25)
	typeCombo:SetSize(300, 25)
	typeCombo:AddChoice("prop")
	typeCombo:AddChoice("entity")
	typeCombo:AddChoice("weapon")
	typeCombo:AddChoice("vehicle")
	typeCombo:AddChoice("chair")
	typeCombo:SetValue("prop")
	
	y = y + 60
	
	-- Submit Button
	local submitBtn = vgui.Create("DButton", frame)
	submitBtn:SetPos(150, y + 20)
	submitBtn:SetSize(200, 40)
	submitBtn:SetText("Add Item")
	submitBtn.DoClick = function()
		local path = pathEntry:GetValue()
		local name = nameEntry:GetValue()
		local cat = catCombo:GetValue()
		local itemType = typeCombo:GetValue()
		
		if path == "" or name == "" or cat == "" then
			Derma_Message("Please fill in all fields!", "Error", "OK")
			return
		end
		
		net.Start("Star_Trek.IndustrialReplicator.AddItem")
		net.WriteString(path)
		net.WriteString(name)
		net.WriteString(cat)
		net.WriteString(itemType)
		net.SendToServer()
		
		frame:Close()
	end
end)

-- Remove Item Panel
concommand.Add("star_trek_replicator_remove", function(ply, cmd, args)
	local frame = vgui.Create("DFrame")
	frame:SetSize(700, 500)
	frame:Center()
	frame:SetTitle("Remove Replicator Item")
	frame:MakePopup()
	
	-- Search box
	local searchLabel = vgui.Create("DLabel", frame)
	searchLabel:SetPos(20, 30)
	searchLabel:SetSize(100, 20)
	searchLabel:SetText("Search:")
	
	local searchEntry = vgui.Create("DTextEntry", frame)
	searchEntry:SetPos(80, 30)
	searchEntry:SetSize(600, 25)
	searchEntry:SetPlaceholderText("Type to search items...")
	
	-- List view
	local itemList = vgui.Create("DListView", frame)
	itemList:SetPos(20, 65)
	itemList:SetSize(660, 350)
	itemList:SetMultiSelect(false)
	itemList:AddColumn("ID")
	itemList:AddColumn("Name")
	itemList:AddColumn("Category")
	itemList:AddColumn("Type")
	itemList:AddColumn("Path")
	
	-- Request items from server
	net.Start("Star_Trek.IndustrialReplicator.RequestItemList")
	net.WriteBool(false) -- Don't include hardcoded items
	net.SendToServer()
	
	-- Receive items
	net.Receive("Star_Trek.IndustrialReplicator.SendItemList", function()
		local items = net.ReadTable()
		
		itemList:Clear()
		for _, item in ipairs(items) do
			if not item.hardcoded then
				itemList:AddLine(item.id, item.name, item.category, item.type, item.path)
			end
		end
		
		-- Update search
		searchEntry.OnChange = function(self)
			local search = string.lower(self:GetValue())
			itemList:Clear()
			
			for _, item in ipairs(items) do
				if not item.hardcoded then
					local matchName = string.find(string.lower(item.name), search, 1, true)
					local matchCat = string.find(string.lower(item.category), search, 1, true)
					
					if search == "" or matchName or matchCat then
						itemList:AddLine(item.id, item.name, item.category, item.type, item.path)
					end
				end
			end
		end
	end)
	
	-- Remove button
	local removeBtn = vgui.Create("DButton", frame)
	removeBtn:SetPos(250, 430)
	removeBtn:SetSize(200, 40)
	removeBtn:SetText("Remove Selected Item")
	removeBtn.DoClick = function()
		local selected = itemList:GetSelectedLine()
		if not selected then
			Derma_Message("Please select an item to remove!", "Error", "OK")
			return
		end
		
		local line = itemList:GetLine(selected)
		local itemId = tonumber(line:GetValue(1))
		local itemName = line:GetValue(2)
		
		Derma_Query(
			"Are you sure you want to remove '" .. itemName .. "'?",
			"Confirm Removal",
			"Yes",
			function()
				net.Start("Star_Trek.IndustrialReplicator.RemoveItem")
				net.WriteInt(itemId, 32)
				net.SendToServer()
				
				frame:Close()
			end,
			"No"
		)
	end
end)

-- Hide Item Panel
concommand.Add("star_trek_replicator_hide", function(ply, cmd, args)
	local frame = vgui.Create("DFrame")
	frame:SetSize(700, 500)
	frame:Center()
	frame:SetTitle("Hide Replicator Item")
	frame:MakePopup()
	
	-- Search box
	local searchLabel = vgui.Create("DLabel", frame)
	searchLabel:SetPos(20, 30)
	searchLabel:SetSize(100, 20)
	searchLabel:SetText("Search:")
	
	local searchEntry = vgui.Create("DTextEntry", frame)
	searchEntry:SetPos(80, 30)
	searchEntry:SetSize(600, 25)
	searchEntry:SetPlaceholderText("Type to search items...")
	
	-- List view
	local itemList = vgui.Create("DListView", frame)
	itemList:SetPos(20, 65)
	itemList:SetSize(660, 350)
	itemList:SetMultiSelect(false)
	itemList:AddColumn("Name")
	itemList:AddColumn("Category")
	itemList:AddColumn("Type")
	itemList:AddColumn("Source")
	itemList:AddColumn("Status")
	
	-- Request items from server
	net.Start("Star_Trek.IndustrialReplicator.RequestItemList")
	net.WriteBool(true) -- Include hardcoded items
	net.SendToServer()
	
	-- Receive items
	local allItems = {}
	net.Receive("Star_Trek.IndustrialReplicator.SendItemList", function()
		allItems = net.ReadTable()
		
		itemList:Clear()
		for _, item in ipairs(allItems) do
			if item.visible then
				local source = item.hardcoded and "Hardcoded" or "Custom"
				itemList:AddLine(item.name, item.category, item.type, source, "Visible"):SetSortValue(5, item)
			end
		end
		
		-- Update search
		searchEntry.OnChange = function(self)
			local search = string.lower(self:GetValue())
			itemList:Clear()
			
			for _, item in ipairs(allItems) do
				if item.visible then
					local matchName = string.find(string.lower(item.name), search, 1, true)
					local matchCat = string.find(string.lower(item.category), search, 1, true)
					
					if search == "" or matchName or matchCat then
						local source = item.hardcoded and "Hardcoded" or "Custom"
						itemList:AddLine(item.name, item.category, item.type, source, "Visible"):SetSortValue(5, item)
					end
				end
			end
		end
	end)
	
	-- Hide button
	local hideBtn = vgui.Create("DButton", frame)
	hideBtn:SetPos(250, 430)
	hideBtn:SetSize(200, 40)
	hideBtn:SetText("Hide Selected Item")
	hideBtn.DoClick = function()
		local selected = itemList:GetSelectedLine()
		if not selected then
			Derma_Message("Please select an item to hide!", "Error", "OK")
			return
		end
		
		local line = itemList:GetLine(selected)
		local item = line:GetSortValue(5)
		
		Derma_Query(
			"Are you sure you want to hide '" .. item.name .. "'?",
			"Confirm Hide",
			"Yes",
			function()
				net.Start("Star_Trek.IndustrialReplicator.HideItem")
				net.WriteString(item.path)
				net.WriteString(item.name)
				net.WriteString(item.category)
				net.WriteString(item.type)
				net.WriteBool(item.hardcoded)
				net.SendToServer()
				
				frame:Close()
			end,
			"No"
		)
	end
end)

-- Modify Item Panel
concommand.Add("star_trek_replicator_modify", function(ply, cmd, args)
	local frame = vgui.Create("DFrame")
	frame:SetSize(700, 600)
	frame:Center()
	frame:SetTitle("Modify Replicator Item")
	frame:MakePopup()
	
	-- Search box
	local searchLabel = vgui.Create("DLabel", frame)
	searchLabel:SetPos(20, 30)
	searchLabel:SetSize(100, 20)
	searchLabel:SetText("Search:")
	
	local searchEntry = vgui.Create("DTextEntry", frame)
	searchEntry:SetPos(80, 30)
	searchEntry:SetSize(600, 25)
	searchEntry:SetPlaceholderText("Type to search items...")
	
	-- List view
	local itemList = vgui.Create("DListView", frame)
	itemList:SetPos(20, 65)
	itemList:SetSize(660, 200)
	itemList:SetMultiSelect(false)
	itemList:AddColumn("ID")
	itemList:AddColumn("Name")
	itemList:AddColumn("Category")
	itemList:AddColumn("Type")
	
	-- Request items from server
	net.Start("Star_Trek.IndustrialReplicator.RequestItemList")
	net.WriteBool(false) -- Don't include hardcoded items
	net.SendToServer()
	
	-- Edit fields
	local y = 280
	
	local pathLabel = vgui.Create("DLabel", frame)
	pathLabel:SetPos(20, y)
	pathLabel:SetSize(200, 20)
	pathLabel:SetText("Model Path or Entity Class:")
	
	local pathEntry = vgui.Create("DTextEntry", frame)
	pathEntry:SetPos(20, y + 25)
	pathEntry:SetSize(660, 25)
	pathEntry:SetEnabled(false)
	
	y = y + 60
	
	local nameLabel = vgui.Create("DLabel", frame)
	nameLabel:SetPos(20, y)
	nameLabel:SetSize(200, 20)
	nameLabel:SetText("Display Name:")
	
	local nameEntry = vgui.Create("DTextEntry", frame)
	nameEntry:SetPos(20, y + 25)
	nameEntry:SetSize(660, 25)
	nameEntry:SetEnabled(false)
	
	y = y + 60
	
	local catLabel = vgui.Create("DLabel", frame)
	catLabel:SetPos(20, y)
	catLabel:SetSize(200, 20)
	catLabel:SetText("Category:")
	
	local catCombo = vgui.Create("DComboBox", frame)
	catCombo:SetPos(20, y + 25)
	catCombo:SetSize(660, 25)
	catCombo:SetEnabled(false)
	
	local categories = {"FURNITURE", "EQUIPMENT", "CARGO", "MEDICAL", "ENG", "AWAY MISSION", "TOOLS", "MISC"}
	for _, cat in ipairs(categories) do
		catCombo:AddChoice(cat)
	end
	
	y = y + 60
	
	local typeLabel = vgui.Create("DLabel", frame)
	typeLabel:SetPos(20, y)
	typeLabel:SetSize(200, 20)
	typeLabel:SetText("Item Type:")
	
	local typeCombo = vgui.Create("DComboBox", frame)
	typeCombo:SetPos(20, y + 25)
	typeCombo:SetSize(660, 25)
	typeCombo:SetEnabled(false)
	typeCombo:AddChoice("prop")
	typeCombo:AddChoice("entity")
	typeCombo:AddChoice("weapon")
	typeCombo:AddChoice("vehicle")
	typeCombo:AddChoice("chair")
	
	-- Receive items
	local allItems = {}
	local selectedId = nil
	
	net.Receive("Star_Trek.IndustrialReplicator.SendItemList", function()
		allItems = net.ReadTable()
		
		itemList:Clear()
		for _, item in ipairs(allItems) do
			if not item.hardcoded then
				itemList:AddLine(item.id, item.name, item.category, item.type):SetSortValue(5, item)
			end
		end
		
		-- Update search
		searchEntry.OnChange = function(self)
			local search = string.lower(self:GetValue())
			itemList:Clear()
			
			for _, item in ipairs(allItems) do
				if not item.hardcoded then
					local matchName = string.find(string.lower(item.name), search, 1, true)
					local matchCat = string.find(string.lower(item.category), search, 1, true)
					
					if search == "" or matchName or matchCat then
						itemList:AddLine(item.id, item.name, item.category, item.type):SetSortValue(5, item)
					end
				end
			end
		end
	end)
	
	-- Handle item selection
	itemList.OnRowSelected = function(panel, rowIndex, row)
		local item = row:GetSortValue(5)
		selectedId = item.id
		
		pathEntry:SetValue(item.path)
		pathEntry:SetEnabled(true)
		
		nameEntry:SetValue(item.name)
		nameEntry:SetEnabled(true)
		
		catCombo:SetValue(item.category)
		catCombo:SetEnabled(true)
		
		typeCombo:SetValue(item.type)
		typeCombo:SetEnabled(true)
	end
	
	-- Save button
	local saveBtn = vgui.Create("DButton", frame)
	saveBtn:SetPos(250, 540)
	saveBtn:SetSize(200, 40)
	saveBtn:SetText("Save Changes")
	saveBtn.DoClick = function()
		if not selectedId then
			Derma_Message("Please select an item to modify!", "Error", "OK")
			return
		end
		
		local path = pathEntry:GetValue()
		local name = nameEntry:GetValue()
		local cat = catCombo:GetValue()
		local itemType = typeCombo:GetValue()
		
		if path == "" or name == "" or cat == "" then
			Derma_Message("Please fill in all fields!", "Error", "OK")
			return
		end
		
		net.Start("Star_Trek.IndustrialReplicator.ModifyItem")
		net.WriteInt(selectedId, 32)
		net.WriteString(path)
		net.WriteString(name)
		net.WriteString(cat)
		net.WriteString(itemType)
		net.SendToServer()
		
		frame:Close()
	end
end)
