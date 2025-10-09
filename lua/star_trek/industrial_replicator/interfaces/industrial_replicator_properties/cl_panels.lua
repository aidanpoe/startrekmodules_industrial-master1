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

-- Store functions in a global table so they can be called
Star_Trek.IndustrialReplicator = Star_Trek.IndustrialReplicator or {}
Star_Trek.IndustrialReplicator.Panels = {}

-- Load theme
local THEME = Star_Trek.IndustrialReplicator.Theme

-- Helper function to create back button
local function CreateBackButton(frame, onClickCallback)
	local backBtn = vgui.Create("DButton", frame)
	backBtn:SetSize(80, 24)
	backBtn:SetPos(8, 8)
	backBtn:SetText("")
	backBtn.Paint = function(self, w, h)
		local hovered = self:IsHovered()
		local bgColor = hovered and THEME.PrimaryGold or Color(48, 48, 48, 200)
		local textColor = hovered and Color(0, 0, 0) or THEME.PrimaryGold
		
		THEME.DrawRoundedBox(0, 0, w, h, bgColor)
		draw.SimpleText("← Back", "IRep_WindowTitle", w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	backBtn.DoClick = function()
		frame:Close()
		if onClickCallback then
			onClickCallback()
		end
	end
	return backBtn
end

-- Function to open ADD panel
function Star_Trek.IndustrialReplicator.Panels.OpenAddPanel()
	print("[Industrial Replicator CLIENT] Creating ADD panel")
	
	local frame = vgui.Create("DFrame")
	frame:SetSize(500, 520)
	frame:Center()
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:MakePopup()
	
	-- Custom paint with theme
	frame.Paint = function(self, w, h)
		THEME.PaintFrame(self, w, h, "ADD NEW ITEM")
	end
	
	-- Back button
	CreateBackButton(frame, function()
		-- Reopen the main management menu
		timer.Simple(0.1, function()
			if IsValid(LocalPlayer()) then
				Star_Trek.IndustrialReplicator.Panels.OpenManagementMenu()
			end
		end)
	end)
	
	-- Custom close button
	local closeBtn = vgui.Create("DButton", frame)
	closeBtn:SetSize(24, 24)
	closeBtn:SetPos(frame:GetWide() - 32, 8)
	closeBtn:SetText("✕")
	closeBtn:SetFont("IRep_WindowTitle")
	closeBtn:SetTextColor(THEME.PrimaryGold)
	closeBtn.Paint = function(self, w, h)
		local hovered = self:IsHovered()
		local bgColor = hovered and THEME.PrimaryGold or Color(0, 0, 0, 0)
		local textColor = hovered and Color(0, 0, 0) or THEME.PrimaryGold
		
		THEME.DrawRoundedBox(0, 0, w, h, bgColor)
		draw.SimpleText("✕", "IRep_WindowTitle", w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	closeBtn.DoClick = function()
		frame:Close()
	end
	
	local y = 60  -- Start AFTER the separator (was 30, now 60)
	
	-- Item Path/Class
	local pathLabel = vgui.Create("DLabel", frame)
	pathLabel:SetPos(20, y)
	pathLabel:SetSize(200, 20)
	pathLabel:SetText("Model Path or Entity Class:")
	pathLabel:SetTextColor(THEME.PrimaryGold)
	
	local pathEntry = vgui.Create("DTextEntry", frame)
	pathEntry:SetPos(20, y + 25)
	pathEntry:SetSize(460, 25)
	pathEntry:SetPlaceholderText("Props: models/props/chair.mdl | Entities: weapon_crossbow | Vehicles: Jeep")
	
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
	
	-- Request categories from server
	net.Start("Star_Trek.IndustrialReplicator.RequestCategories")
	net.SendToServer()
	
	-- Receive and populate categories
	net.Receive("Star_Trek.IndustrialReplicator.SendCategories", function()
		local categories = net.ReadTable()
		
		catCombo:Clear()
		for _, cat in ipairs(categories) do
			catCombo:AddChoice(cat.category_name)
		end
	end)
	
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
	
	-- Help text
	local helpLabel = vgui.Create("DLabel", frame)
	helpLabel:SetPos(20, y + 60)
	helpLabel:SetSize(460, 80)
	helpLabel:SetWrap(true)
	helpLabel:SetAutoStretchVertical(true)
	helpLabel:SetTextColor(Color(100, 200, 100))
	helpLabel:SetText("✓ Auto-Format Enabled: Just type the class name!\nExamples:\n  Props: models/props/chair.mdl\n  Weapons: weapon_crossbow (auto-adds 'class:')\n  Entities: sent_ball (auto-adds 'class:')\n  Vehicles: Jeep, Airboat, Jalopy (auto-configured!)")
	
	y = y + 60
	
	-- Submit Button
	local submitBtn = vgui.Create("DButton", frame)
	submitBtn:SetPos(150, y + 90)
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
		
		-- Vehicle presets for common GMod vehicles
		local vehiclePresets = {
			["jeep"] = {model = "models/buggy.mdl", script = "scripts/vehicles/jeep_test.txt"},
			["airboat"] = {model = "models/airboat.mdl", script = "scripts/vehicles/airboat.txt"},
			["jalopy"] = {model = "models/vehicle.mdl", script = "scripts/vehicles/jalopy.txt"},
			["pod"] = {model = "models/vehicles/prisoner_pod_inner.mdl", script = nil}, -- Simple seat
		}
		
		-- Auto-configure vehicles and chairs
		if itemType == "vehicle" or itemType == "chair" then
			local vehicleName = path:lower():gsub("^class:", ""):Trim()
			
			if vehiclePresets[vehicleName] then
				-- User typed a preset vehicle name - auto configure it!
				local preset = vehiclePresets[vehicleName]
				path = "vehicle:" .. vehicleName .. ":" .. preset.model .. ":" .. (preset.script or "")
				
				Derma_Message(
					"✓ Auto-configured vehicle!\n\n" ..
					"Vehicle: " .. vehicleName:upper() .. "\n" ..
					"Model: " .. preset.model .. "\n" ..
					(preset.script and ("Script: " .. preset.script) or "Simple seat vehicle"),
					"Vehicle Added",
					"OK"
				)
			elseif itemType == "chair" then
				-- Chair type: assume it's a model path or convert to seat
				if string.find(path, "^models/") then
					-- It's a model path - create a seat with this model
					path = "vehicle:chair:" .. path .. ":"
					
					Derma_Message(
						"✓ Auto-configured chair!\n\n" ..
						"Type: Sittable Chair\n" ..
						"Model: " .. path:gsub("vehicle:chair:", ""):gsub(":$", ""),
						"Chair Added",
						"OK"
					)
				else
					-- Not a model, treat as regular entity
					if not string.find(path, "^class:") and not string.find(path, "^vehicle:") then
						path = "class:" .. path
					end
				end
			else
				-- Custom vehicle - just add class prefix
				if not string.find(path, "^class:") and not string.find(path, "^models/") and not string.find(path, "^vehicle:") then
					path = "class:" .. path
				end
			end
		-- Auto-add class: prefix for entities/weapons if not already present
		elseif (itemType == "entity" or itemType == "weapon") then
			if not string.find(path, "^class:") and not string.find(path, "^models/") then
				path = "class:" .. path
				print("[Industrial Replicator] Auto-added 'class:' prefix: " .. path)
			end
		end
		
		net.Start("Star_Trek.IndustrialReplicator.AddItem")
		net.WriteString(path)
		net.WriteString(name)
		net.WriteString(cat)
		net.WriteString(itemType)
		net.SendToServer()
		
		frame:Close()
	end
end

-- Function to open REMOVE panel
function Star_Trek.IndustrialReplicator.Panels.OpenRemovePanel()
	print("[Industrial Replicator CLIENT] Creating REMOVE panel")
	
	local THEME = Star_Trek.IndustrialReplicator.Theme
	
	local frame = vgui.Create("DFrame")
	frame:SetSize(700, 500)
	frame:Center()
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:MakePopup()
	
	-- Custom paint with theme
	frame.Paint = function(self, w, h)
		THEME.PaintFrame(self, w, h, "REMOVE ITEM")
	end
	
	-- Back button
	CreateBackButton(frame, function()
		timer.Simple(0.1, function()
			if IsValid(LocalPlayer()) then
				Star_Trek.IndustrialReplicator.Panels.OpenManagementMenu()
			end
		end)
	end)
	
	-- Custom close button
	local closeBtn = vgui.Create("DButton", frame)
	closeBtn:SetSize(24, 24)
	closeBtn:SetPos(frame:GetWide() - 32, 8)
	closeBtn:SetText("✕")
	closeBtn:SetFont("Trebuchet18")
	closeBtn:SetTextColor(THEME.PrimaryGold)
	closeBtn.Paint = function(self, w, h)
		local col = self:IsHovered() and THEME.PrimaryGold or THEME.PrimaryGold
		draw.SimpleText("✕", "Trebuchet18", w/2, h/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	closeBtn.DoClick = function()
		frame:Close()
	end
	
	-- Search box
	local searchLabel = vgui.Create("DLabel", frame)
	searchLabel:SetPos(20, 60)  -- Changed from 30 to 60
	searchLabel:SetSize(100, 20)
	searchLabel:SetText("Search:")
	searchLabel:SetTextColor(THEME.PrimaryGold)
	
	local searchEntry = vgui.Create("DTextEntry", frame)
	searchEntry:SetPos(80, 60)  -- Changed from 30 to 60
	searchEntry:SetSize(600, 25)
	searchEntry:SetPlaceholderText("Type to search items...")
	searchEntry:SetTextColor(THEME.PrimaryGold)
	
	-- List view
	local itemList = vgui.Create("DListView", frame)
	itemList:SetPos(20, 95)  -- Changed from 65 to 95
	itemList:SetSize(660, 320)  -- Reduced height to fit
	itemList:SetMultiSelect(false)
	itemList:AddColumn("Name")
	itemList:AddColumn("Category")
	itemList:AddColumn("Type")
	itemList:AddColumn("Source")
	
	-- Request items from server (include hardcoded items now)
	net.Start("Star_Trek.IndustrialReplicator.RequestItemList")
	net.WriteBool(true) -- Include hardcoded items
	net.SendToServer()
	
	-- Receive items
	local allItems = {}
	net.Receive("Star_Trek.IndustrialReplicator.SendItemList", function()
		allItems = net.ReadTable()
		
		itemList:Clear()
		for _, item in ipairs(allItems) do
			if item.visible then -- Only show visible items
				local source = item.hardcoded and "Hardcoded" or "Custom"
				itemList:AddLine(item.name, item.category, item.type, source):SetSortValue(5, item)
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
						itemList:AddLine(item.name, item.category, item.type, source):SetSortValue(5, item)
					end
				end
			end
		end
	end)
	
	-- Remove button (text changes based on item type)
	local removeBtn = vgui.Create("DButton", frame)
	removeBtn:SetPos(250, 430)
	removeBtn:SetSize(200, 40)
	removeBtn:SetText("Remove/Hide Selected Item")
	removeBtn.DoClick = function()
		local selected = itemList:GetSelectedLine()
		if not selected then
			Derma_Message("Please select an item to remove!", "Error", "OK")
			return
		end
		
		local line = itemList:GetLine(selected)
		local item = line:GetSortValue(5)
		
		if item.hardcoded then
			-- Hardcoded items get hidden
			Derma_Query(
				"'" .. item.name .. "' is a hardcoded item.\n\nIt will be HIDDEN from the replicator menu.\n\nContinue?",
				"Hide Hardcoded Item",
				"Yes, Hide It",
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
		else
			-- Custom items get deleted
			Derma_Query(
				"'" .. item.name .. "' is a custom item.\n\nIt will be PERMANENTLY DELETED.\n\nContinue?",
				"Delete Custom Item",
				"Yes, Delete It",
				function()
					net.Start("Star_Trek.IndustrialReplicator.RemoveItem")
					net.WriteInt(item.id, 32)
					net.SendToServer()
					
					frame:Close()
				end,
				"No"
			)
		end
	end
end

-- Function to open HIDE panel
function Star_Trek.IndustrialReplicator.Panels.OpenHidePanel()
	print("[Industrial Replicator CLIENT] Creating HIDE panel")
	
	local THEME = Star_Trek.IndustrialReplicator.Theme
	
	local frame = vgui.Create("DFrame")
	frame:SetSize(700, 500)
	frame:Center()
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:MakePopup()
	
	-- Custom paint with theme
	frame.Paint = function(self, w, h)
		THEME.PaintFrame(self, w, h, "HIDE/SHOW ITEM")
	end
	
	-- Back button
	CreateBackButton(frame, function()
		timer.Simple(0.1, function()
			if IsValid(LocalPlayer()) then
				Star_Trek.IndustrialReplicator.Panels.OpenManagementMenu()
			end
		end)
	end)
	
	-- Custom close button
	local closeBtn = vgui.Create("DButton", frame)
	closeBtn:SetSize(24, 24)
	closeBtn:SetPos(frame:GetWide() - 32, 8)
	closeBtn:SetText("✕")
	closeBtn:SetFont("Trebuchet18")
	closeBtn:SetTextColor(THEME.PrimaryGold)
	closeBtn.Paint = function(self, w, h)
		local col = self:IsHovered() and THEME.PrimaryGold or THEME.PrimaryGold
		draw.SimpleText("✕", "Trebuchet18", w/2, h/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	closeBtn.DoClick = function()
		frame:Close()
	end
	
	-- Search box
	local searchLabel = vgui.Create("DLabel", frame)
	searchLabel:SetPos(20, 60)
	searchLabel:SetSize(100, 20)
	searchLabel:SetText("Search:")
	searchLabel:SetTextColor(THEME.PrimaryGold)
	
	local searchEntry = vgui.Create("DTextEntry", frame)
	searchEntry:SetPos(80, 60)
	searchEntry:SetSize(600, 25)
	searchEntry:SetPlaceholderText("Type to search items...")
	searchEntry:SetTextColor(THEME.PrimaryGold)
	
	-- List view
	local itemList = vgui.Create("DListView", frame)
	itemList:SetPos(20, 95)
	itemList:SetSize(660, 320)
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
	
	-- Hide/Show button (create BEFORE OnRowSelected handler)
	local hideBtn = vgui.Create("DButton", frame)
	hideBtn:SetPos(250, 430)
	hideBtn:SetSize(200, 40)
	hideBtn:SetText("Hide/Show Selected Item")
	hideBtn.DoClick = function()
		local selected = itemList:GetSelectedLine()
		if not selected then
			Derma_Message("Please select an item first!", "Error", "OK")
			return
		end
		
		local line = itemList:GetLine(selected)
		local item = line:GetSortValue(6)
		
		-- Determine action based on current visibility
		local action = item.visible and "hide" or "show"
		local actionText = item.visible and "Hide" or "Show"
		
		Derma_Query(
			"Are you sure you want to " .. string.lower(actionText) .. " '" .. item.name .. "'?",
			"Confirm " .. actionText,
			"Yes",
			function()
				if item.visible then
					-- Hide the item
					net.Start("Star_Trek.IndustrialReplicator.HideItem")
					net.WriteString(item.path)
					net.WriteString(item.name)
					net.WriteString(item.category)
					net.WriteString(item.type)
					net.WriteBool(item.hardcoded)
					net.SendToServer()
				else
					-- Show the item (unhide)
					net.Start("Star_Trek.IndustrialReplicator.ShowItem")
					net.WriteString(item.path)
					net.WriteString(item.name)
					net.WriteString(item.category)
					net.WriteString(item.type)
					net.WriteBool(item.hardcoded)
					net.SendToServer()
				end
				
				-- Refresh the list after a short delay
				timer.Simple(0.2, function()
					if IsValid(frame) then
						net.Start("Star_Trek.IndustrialReplicator.RequestItemList")
						net.WriteBool(true) -- Include hardcoded items
						net.SendToServer()
					end
				end)
			end,
			"No"
		)
	end
	
	-- Receive items
	local allItems = {}
	local selectedItem = nil
	
	net.Receive("Star_Trek.IndustrialReplicator.SendItemList", function()
		allItems = net.ReadTable()
		
		itemList:Clear()
		-- Show ALL items (both visible and hidden)
		for _, item in ipairs(allItems) do
			local source = item.hardcoded and "Hardcoded" or "Custom"
			local status = item.visible and "Visible" or "HIDDEN"
			itemList:AddLine(item.name, item.category, item.type, source, status):SetSortValue(6, item)
		end
		
		-- Update search
		searchEntry.OnChange = function(self)
			local search = string.lower(self:GetValue())
			itemList:Clear()
			
			for _, item in ipairs(allItems) do
				local matchName = string.find(string.lower(item.name), search, 1, true)
				local matchCat = string.find(string.lower(item.category), search, 1, true)
				
				if search == "" or matchName or matchCat then
					local source = item.hardcoded and "Hardcoded" or "Custom"
					local status = item.visible and "Visible" or "HIDDEN"
					itemList:AddLine(item.name, item.category, item.type, source, status):SetSortValue(6, item)
				end
			end
		end
	end)
	
	-- Track selected item to update button text
	itemList.OnRowSelected = function(panel, rowIndex, row)
		selectedItem = row:GetSortValue(6)
		
		-- Update button text based on visibility
		if selectedItem.visible then
			hideBtn:SetText("Hide Selected Item")
		else
			hideBtn:SetText("Show Selected Item")
		end
	end
end

-- Function to open MODIFY panel
function Star_Trek.IndustrialReplicator.Panels.OpenModifyPanel()
	print("[Industrial Replicator CLIENT] Creating MODIFY panel")
	
	local THEME = Star_Trek.IndustrialReplicator.Theme
	
	local frame = vgui.Create("DFrame")
	frame:SetSize(700, 600)
	frame:Center()
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:MakePopup()
	
	-- Custom paint with theme
	frame.Paint = function(self, w, h)
		THEME.PaintFrame(self, w, h, "MODIFY ITEM")
	end
	
	-- Back button
	CreateBackButton(frame, function()
		timer.Simple(0.1, function()
			if IsValid(LocalPlayer()) then
				Star_Trek.IndustrialReplicator.Panels.OpenManagementMenu()
			end
		end)
	end)
	
	-- Custom close button
	local closeBtn = vgui.Create("DButton", frame)
	closeBtn:SetSize(24, 24)
	closeBtn:SetPos(frame:GetWide() - 32, 8)
	closeBtn:SetText("✕")
	closeBtn:SetFont("Trebuchet18")
	closeBtn:SetTextColor(THEME.PrimaryGold)
	closeBtn.Paint = function(self, w, h)
		local col = self:IsHovered() and THEME.PrimaryGold or THEME.PrimaryGold
		draw.SimpleText("✕", "Trebuchet18", w/2, h/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	closeBtn.DoClick = function()
		frame:Close()
	end
	
	-- Search box
	local searchLabel = vgui.Create("DLabel", frame)
	searchLabel:SetPos(20, 60)
	searchLabel:SetSize(100, 20)
	searchLabel:SetText("Search:")
	searchLabel:SetTextColor(THEME.PrimaryGold)
	
	local searchEntry = vgui.Create("DTextEntry", frame)
	searchEntry:SetPos(80, 60)
	searchEntry:SetSize(600, 25)
	searchEntry:SetPlaceholderText("Type to search items...")
	
	-- List view
	local itemList = vgui.Create("DListView", frame)
	itemList:SetPos(20, 90)
	itemList:SetSize(660, 200)
	itemList:SetMultiSelect(false)
	itemList:AddColumn("Name")
	itemList:AddColumn("Category")
	itemList:AddColumn("Type")
	itemList:AddColumn("Source")
	
	-- Request items from server (include hardcoded items now)
	net.Start("Star_Trek.IndustrialReplicator.RequestItemList")
	net.WriteBool(true) -- Include hardcoded items
	net.SendToServer()
	
	-- Edit fields
	local y = 305
	
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
	
	-- Request categories from server
	net.Start("Star_Trek.IndustrialReplicator.RequestCategories")
	net.SendToServer()
	
	-- Receive and populate categories
	net.Receive("Star_Trek.IndustrialReplicator.SendCategories", function()
		local categories = net.ReadTable()
		
		catCombo:Clear()
		for _, cat in ipairs(categories) do
			catCombo:AddChoice(cat.category_name)
		end
	end)
	
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
	local selectedIsHardcoded = false
	
	net.Receive("Star_Trek.IndustrialReplicator.SendItemList", function()
		allItems = net.ReadTable()
		
		itemList:Clear()
		for _, item in ipairs(allItems) do
			if item.visible then -- Only show visible items
				local source = item.hardcoded and "Hardcoded" or "Custom"
				itemList:AddLine(item.name, item.category, item.type, source):SetSortValue(5, item)
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
						itemList:AddLine(item.name, item.category, item.type, source):SetSortValue(5, item)
					end
				end
			end
		end
	end)
	
	-- Handle item selection
	itemList.OnRowSelected = function(panel, rowIndex, row)
		local item = row:GetSortValue(5)
		selectedId = item.id
		selectedIsHardcoded = item.hardcoded
		
		pathEntry:SetValue(item.path)
		nameEntry:SetValue(item.name)
		catCombo:SetValue(item.category)
		typeCombo:SetValue(item.type)
		
		-- Enable fields only for custom items (hardcoded items are read-only)
		if item.hardcoded then
			pathEntry:SetEnabled(false)
			nameEntry:SetEnabled(false)
			catCombo:SetEnabled(false)
			typeCombo:SetEnabled(false)
		else
			pathEntry:SetEnabled(true)
			nameEntry:SetEnabled(true)
			catCombo:SetEnabled(true)
			typeCombo:SetEnabled(true)
		end
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
		
		if selectedIsHardcoded then
			Derma_Message("Cannot modify hardcoded items!\n\nThey are read-only.", "Error", "OK")
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
end

-- Function to open MANAGE CATEGORIES panel
function Star_Trek.IndustrialReplicator.Panels.OpenManageCategoriesPanel()
	print("[Industrial Replicator CLIENT] Creating MANAGE CATEGORIES panel")
	
	local THEME = Star_Trek.IndustrialReplicator.Theme
	
	local frame = vgui.Create("DFrame")
	frame:SetSize(600, 500)
	frame:Center()
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:MakePopup()
	
	-- Custom paint with theme
	frame.Paint = function(self, w, h)
		THEME.PaintFrame(self, w, h, "MANAGE CATEGORIES")
	end
	
	-- Back button
	CreateBackButton(frame, function()
		timer.Simple(0.1, function()
			if IsValid(LocalPlayer()) then
				Star_Trek.IndustrialReplicator.Panels.OpenManagementMenu()
			end
		end)
	end)
	
	-- Custom close button
	local closeBtn = vgui.Create("DButton", frame)
	closeBtn:SetSize(24, 24)
	closeBtn:SetPos(frame:GetWide() - 32, 8)
	closeBtn:SetText("✕")
	closeBtn:SetFont("Trebuchet18")
	closeBtn:SetTextColor(THEME.PrimaryGold)
	closeBtn.Paint = function(self, w, h)
		local col = self:IsHovered() and THEME.PrimaryGold or THEME.PrimaryGold
		draw.SimpleText("✕", "Trebuchet18", w/2, h/2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	closeBtn.DoClick = function()
		frame:Close()
	end
	frame:MakePopup()
	
	-- Info label (moved lower to avoid yellow separator line)
	local infoLabel = vgui.Create("DLabel", frame)
	infoLabel:SetPos(20, 60)
	infoLabel:SetSize(560, 20)
	infoLabel:SetText("Note: Hardcoded categories cannot be removed")
	infoLabel:SetTextColor(THEME.PrimaryGold)
	
	-- Add category section
	local addLabel = vgui.Create("DLabel", frame)
	addLabel:SetPos(20, 90)
	addLabel:SetSize(200, 20)
	addLabel:SetText("Add New Category:")
	addLabel:SetTextColor(THEME.PrimaryGold)
	
	local addEntry = vgui.Create("DTextEntry", frame)
	addEntry:SetPos(20, 115)
	addEntry:SetSize(400, 25)
	addEntry:SetPlaceholderText("Enter category name (e.g., WEAPONS, SCIENCE, etc.)")
	addEntry:SetTextColor(THEME.PrimaryGold)
	
	local addBtn = vgui.Create("DButton", frame)
	addBtn:SetPos(430, 105)
	addBtn:SetSize(150, 25)
	addBtn:SetText("Add Category")
	addBtn:SetFont("Trebuchet24")
	addBtn.DoClick = function()
		local catName = addEntry:GetValue()
		
		if catName == "" then
			Derma_Message("Please enter a category name!", "Error", "OK")
			return
		end
		
		-- Send to server
		net.Start("Star_Trek.IndustrialReplicator.AddCategory")
		net.WriteString(catName)
		net.SendToServer()
		
		addEntry:SetValue("")
	end
	
	-- Category list
	local listLabel = vgui.Create("DLabel", frame)
	listLabel:SetPos(20, 145)
	listLabel:SetSize(200, 20)
	listLabel:SetText("Existing Categories:")
	
	local categoryList = vgui.Create("DListView", frame)
	categoryList:SetPos(20, 170)
	categoryList:SetSize(560, 230)
	categoryList:SetMultiSelect(false)
	categoryList:AddColumn("Category Name")
	categoryList:AddColumn("Type")
	categoryList:AddColumn("Item Count")
	
	-- Request categories from server
	net.Start("Star_Trek.IndustrialReplicator.RequestCategories")
	net.SendToServer()
	
	-- Receive categories
	net.Receive("Star_Trek.IndustrialReplicator.SendCategories", function()
		local categories = net.ReadTable()
		
		categoryList:Clear()
		for _, cat in ipairs(categories) do
			local catType = cat.is_hardcoded and "Hardcoded" or "Custom"
			local itemCount = cat.item_count or 0
			categoryList:AddLine(cat.category_name, catType, itemCount):SetSortValue(4, cat)
		end
	end)
	
	-- Remove button
	local removeBtn = vgui.Create("DButton", frame)
	removeBtn:SetPos(200, 410)
	removeBtn:SetSize(200, 40)
	removeBtn:SetText("Remove Selected Category")
	removeBtn:SetFont("Trebuchet24")
	removeBtn.DoClick = function()
		local selected = categoryList:GetSelectedLine()
		
		if not selected then
			Derma_Message("Please select a category to remove!", "Error", "OK")
			return
		end
		
		local line = categoryList:GetLine(selected)
		local cat = line:GetSortValue(4)
		
		if cat.is_hardcoded then
			Derma_Message("Cannot remove hardcoded category!\n\nHardcoded categories are built-in.", "Error", "OK")
			return
		end
		
		Derma_Query(
			"Are you sure you want to delete the category '" .. cat.category_name .. "'?\n\nThis will also DELETE ALL ITEMS in this category!",
			"Confirm Deletion",
			"Yes, Delete",
			function()
				net.Start("Star_Trek.IndustrialReplicator.RemoveCategory")
				net.WriteString(cat.category_name)
				net.SendToServer()
			end,
			"Cancel"
		)
	end
end

-- Function to open BROWSE VEHICLES panel
function Star_Trek.IndustrialReplicator.Panels.OpenBrowseVehiclesPanel()
	print("[Industrial Replicator CLIENT] Creating BROWSE VEHICLES panel")
	
	local THEME = Star_Trek.IndustrialReplicator.Theme
	
	local frame = vgui.Create("DFrame")
	frame:SetSize(900, 600)
	frame:Center()
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:MakePopup()
	
	-- Custom paint with theme
	frame.Paint = function(self, w, h)
		THEME.PaintFrame(self, w, h, "BROWSE VEHICLES")
	end
	
	-- Custom close button
	local closeBtn = vgui.Create("DButton", frame)
	closeBtn:SetSize(24, 24)
	closeBtn:SetPos(frame:GetWide() - 32, 8)
	closeBtn:SetText("✕")
	closeBtn:SetFont("Trebuchet18")
	closeBtn.Paint = function(self, w, h)
		local col = self:IsHovered() and THEME.PrimaryGold or Color(180, 180, 180)
		draw.SimpleText("✕", "Trebuchet18", w / 2, h / 2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	closeBtn.DoClick = function()
		frame:Close()
	end
	
	local y = 50
	
	-- Info label
	local infoLabel = vgui.Create("DLabel", frame)
	infoLabel:SetPos(20, y)
	infoLabel:SetSize(860, 40)
	infoLabel:SetWrap(true)
	infoLabel:SetText("Select a vehicle from the list below and click 'Add to Replicator' to add it.\nVehicles are automatically detected from your server.")
	infoLabel:SetTextColor(Color(200, 200, 200))
	
	y = y + 50
	
	-- Search box
	local searchLabel = vgui.Create("DLabel", frame)
	searchLabel:SetPos(20, y)
	searchLabel:SetSize(100, 20)
	searchLabel:SetText("Search:")
	
	local searchBox = vgui.Create("DTextEntry", frame)
	searchBox:SetPos(80, y)
	searchBox:SetSize(400, 25)
	
	y = y + 35
	
	-- Vehicle list
	local vehicleList = vgui.Create("DListView", frame)
	vehicleList:SetPos(20, y)
	vehicleList:SetSize(860, 380)
	vehicleList:SetMultiSelect(false)
	vehicleList:AddColumn("Name")
	vehicleList:AddColumn("Category")
	vehicleList:AddColumn("Model")
	vehicleList:AddColumn("Class")
	
	-- Category dropdown
	local categoryLabel = vgui.Create("DLabel", frame)
	categoryLabel:SetPos(20, y + 390)
	categoryLabel:SetSize(150, 20)
	categoryLabel:SetText("Add to Category:")
	
	local categoryCombo = vgui.Create("DComboBox", frame)
	categoryCombo:SetPos(140, y + 390)
	categoryCombo:SetSize(250, 25)
	
	-- Request categories
	net.Start("Star_Trek.IndustrialReplicator.RequestCategories")
	net.SendToServer()
	
	net.Receive("Star_Trek.IndustrialReplicator.SendCategories", function()
		local categories = net.ReadTable()
		categoryCombo:Clear()
		for _, cat in ipairs(categories) do
			categoryCombo:AddChoice(cat.category_name)
		end
		if #categories > 0 then
			categoryCombo:SetValue(categories[1].category_name)
		end
	end)
	
	-- Add button
	local addBtn = vgui.Create("DButton", frame)
	addBtn:SetPos(350, y + 440)
	addBtn:SetSize(200, 40)
	addBtn:SetText("Add Selected to Replicator")
	addBtn:SetFont("Trebuchet24")
	addBtn.DoClick = function()
		local selected = vehicleList:GetSelectedLine()
		if not selected then
			Derma_Message("Please select a vehicle first!", "Error", "OK")
			return
		end
		
		local category = categoryCombo:GetValue()
		if not category or category == "" then
			Derma_Message("Please select a category!", "Error", "OK")
			return
		end
		
		local line = vehicleList:GetLine(selected)
		local name = line:GetColumnText(1)
		local model = line:GetColumnText(3)
		local class = line:GetColumnText(4)
		local vehicleData = line:GetSortValue(5)
		
		-- Create vehicle format string
		local vehicleScript = ""
		if vehicleData.keyValues and vehicleData.keyValues.vehiclescript then
			vehicleScript = vehicleData.keyValues.vehiclescript
		end
		
		local path = "vehicle:" .. class .. ":" .. model .. ":" .. vehicleScript
		
		net.Start("Star_Trek.IndustrialReplicator.AddItem")
		net.WriteString(path)
		net.WriteString(name)
		net.WriteString(category)
		net.WriteString("vehicle")
		net.SendToServer()
		
		Derma_Message("Added " .. name .. " to category " .. category .. "!", "Success", "OK")
	end
	
	-- Request and populate vehicle list
	net.Start("Star_Trek.IndustrialReplicator.RequestVehicleList")
	net.SendToServer()
	
	net.Receive("Star_Trek.IndustrialReplicator.SendVehicleList", function()
		local vehicles = net.ReadTable()
		
		vehicleList:Clear()
		
		for _, veh in ipairs(vehicles) do
			local line = vehicleList:AddLine(veh.name, veh.category, veh.model, veh.class)
			line:SetSortValue(5, veh) -- Store full vehicle data
		end
		
		-- Search functionality
		searchBox.OnValueChange = function(self, value)
			vehicleList:Clear()
			
			for _, veh in ipairs(vehicles) do
				local searchLower = value:lower()
				if value == "" or 
				   string.find(veh.name:lower(), searchLower) or
				   string.find(veh.category:lower(), searchLower) or
				   string.find(veh.class:lower(), searchLower) then
					local line = vehicleList:AddLine(veh.name, veh.category, veh.model, veh.class)
					line:SetSortValue(5, veh)
				end
			end
		end
	end)
end

-- Function to open BROWSE CHAIRS panel
function Star_Trek.IndustrialReplicator.Panels.OpenBrowseChairsPanel()
	print("[Industrial Replicator CLIENT] Creating BROWSE CHAIRS panel")
	
	local THEME = Star_Trek.IndustrialReplicator.Theme
	
	local frame = vgui.Create("DFrame")
	frame:SetSize(900, 600)
	frame:Center()
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:MakePopup()
	
	-- Custom paint with theme
	frame.Paint = function(self, w, h)
		THEME.PaintFrame(self, w, h, "BROWSE CHAIRS")
	end
	
	-- Custom close button
	local closeBtn = vgui.Create("DButton", frame)
	closeBtn:SetSize(24, 24)
	closeBtn:SetPos(frame:GetWide() - 32, 8)
	closeBtn:SetText("✕")
	closeBtn:SetFont("Trebuchet18")
	closeBtn.Paint = function(self, w, h)
		local col = self:IsHovered() and THEME.PrimaryGold or Color(180, 180, 180)
		draw.SimpleText("✕", "Trebuchet18", w / 2, h / 2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	closeBtn.DoClick = function()
		frame:Close()
	end
	
	local y = 50
	
	-- Info label
	local infoLabel = vgui.Create("DLabel", frame)
	infoLabel:SetPos(20, y)
	infoLabel:SetSize(860, 40)
	infoLabel:SetWrap(true)
	infoLabel:SetText("Select a chair from the list below and click 'Add to Replicator' to add it.\nChairs are automatically detected from your server.")
	infoLabel:SetTextColor(Color(200, 200, 200))
	
	y = y + 50
	
	-- Search box
	local searchLabel = vgui.Create("DLabel", frame)
	searchLabel:SetPos(20, y)
	searchLabel:SetSize(100, 20)
	searchLabel:SetText("Search:")
	
	local searchBox = vgui.Create("DTextEntry", frame)
	searchBox:SetPos(80, y)
	searchBox:SetSize(400, 25)
	
	y = y + 35
	
	-- Chair list
	local chairList = vgui.Create("DListView", frame)
	chairList:SetPos(20, y)
	chairList:SetSize(860, 380)
	chairList:SetMultiSelect(false)
	chairList:AddColumn("Name")
	chairList:AddColumn("Category")
	chairList:AddColumn("Model")
	chairList:AddColumn("Class")
	
	-- Category dropdown
	local categoryLabel = vgui.Create("DLabel", frame)
	categoryLabel:SetPos(20, y + 390)
	categoryLabel:SetSize(150, 20)
	categoryLabel:SetText("Add to Category:")
	
	local categoryCombo = vgui.Create("DComboBox", frame)
	categoryCombo:SetPos(140, y + 390)
	categoryCombo:SetSize(250, 25)
	
	-- Request categories
	net.Start("Star_Trek.IndustrialReplicator.RequestCategories")
	net.SendToServer()
	
	net.Receive("Star_Trek.IndustrialReplicator.SendCategories", function()
		local categories = net.ReadTable()
		categoryCombo:Clear()
		for _, cat in ipairs(categories) do
			categoryCombo:AddChoice(cat.category_name)
		end
		if #categories > 0 then
			categoryCombo:SetValue(categories[1].category_name)
		end
	end)
	
	-- Add button
	local addBtn = vgui.Create("DButton", frame)
	addBtn:SetPos(350, y + 440)
	addBtn:SetSize(200, 40)
	addBtn:SetText("Add Selected to Replicator")
	addBtn:SetFont("Trebuchet24")
	addBtn.DoClick = function()
		local selected = chairList:GetSelectedLine()
		if not selected then
			Derma_Message("Please select a chair first!", "Error", "OK")
			return
		end
		
		local category = categoryCombo:GetValue()
		if not category or category == "" then
			Derma_Message("Please select a category!", "Error", "OK")
			return
		end
		
		local line = chairList:GetLine(selected)
		local name = line:GetColumnText(1)
		local model = line:GetColumnText(3)
		
		-- Create chair format string
		local path = "vehicle:chair:" .. model .. ":"
		
		net.Start("Star_Trek.IndustrialReplicator.AddItem")
		net.WriteString(path)
		net.WriteString(name)
		net.WriteString(category)
		net.WriteString("chair")
		net.SendToServer()
		
		Derma_Message("Added " .. name .. " to category " .. category .. "!", "Success", "OK")
	end
	
	-- Request and populate chair list
	net.Start("Star_Trek.IndustrialReplicator.RequestChairList")
	net.SendToServer()
	
	net.Receive("Star_Trek.IndustrialReplicator.SendChairList", function()
		local chairs = net.ReadTable()
		
		chairList:Clear()
		
		for _, chair in ipairs(chairs) do
			local line = chairList:AddLine(chair.name, chair.category, chair.model, chair.class)
			line:SetSortValue(5, chair) -- Store full chair data
		end
		
		-- Search functionality
		searchBox.OnValueChange = function(self, value)
			chairList:Clear()
			
			for _, chair in ipairs(chairs) do
				local searchLower = value:lower()
				if value == "" or 
				   string.find(chair.name:lower(), searchLower) or
				   string.find(chair.category:lower(), searchLower) or
				   string.find(chair.class:lower(), searchLower) then
					local line = chairList:AddLine(chair.name, chair.category, chair.model, chair.class)
					line:SetSortValue(5, chair)
				end
			end
		end
	end)
end

---------------------------------------
-- Function to open BROWSE ALL panel (vehicles and chairs combined)
---------------------------------------
function Star_Trek.IndustrialReplicator.Panels.OpenBrowseAllPanel()
	print("[Industrial Replicator CLIENT] Creating BROWSE ALL panel")
	
	local frame = vgui.Create("DFrame")
	frame:SetSize(900, 600)
	frame:Center()
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:MakePopup()
	frame:SetDraggable(true)
	
	-- Custom paint
	frame.Paint = function(self, w, h)
		THEME.PaintFrame(self, w, h, "BROWSE VEHICLES & CHAIRS")
	end
	
	-- Back button
	CreateBackButton(frame, function()
		timer.Simple(0.1, function()
			if IsValid(LocalPlayer()) then
				Star_Trek.IndustrialReplicator.Panels.OpenManagementMenu()
			end
		end)
	end)
	
	-- Custom close button
	local closeBtn = vgui.Create("DButton", frame)
	closeBtn:SetSize(24, 24)
	closeBtn:SetPos(frame:GetWide() - 32, 8)
	closeBtn:SetText("✕")
	closeBtn:SetFont("IRep_WindowTitle")
	closeBtn:SetTextColor(THEME.PrimaryGold)
	closeBtn.Paint = function(self, w, h)
		local hovered = self:IsHovered()
		local bgColor = hovered and THEME.PrimaryGold or Color(0, 0, 0, 0)
		local textColor = hovered and Color(0, 0, 0) or THEME.PrimaryGold
		
		THEME.DrawRoundedBox(0, 0, w, h, bgColor)
		draw.SimpleText("✕", "IRep_WindowTitle", w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	closeBtn.DoClick = function()
		frame:Close()
	end
	
	local y = 80
	
	-- Type filter (All, Vehicles, Chairs)
	local filterLabel = vgui.Create("DLabel", frame)
	filterLabel:SetPos(THEME.Padding * 2, y)
	filterLabel:SetSize(100, 24)
	filterLabel:SetText("Show:")
	filterLabel:SetFont("IRep_Label")
	filterLabel:SetTextColor(THEME.PrimaryGold)
	
	local filterCombo = vgui.Create("DComboBox", frame)
	filterCombo:SetPos(120, y)
	filterCombo:SetSize(150, 30)
	filterCombo:SetValue("All")
	filterCombo:AddChoice("All")
	filterCombo:AddChoice("Vehicles Only")
	filterCombo:AddChoice("Chairs Only")
	filterCombo:SetFont("Trebuchet18")
	filterCombo:SetTextColor(THEME.PrimaryGold)
	filterCombo.Paint = function(self, w, h)
		THEME.PaintComboBox(self, w, h)
	end
	
	y = y + 45
	
	-- Search box
	local searchLabel = vgui.Create("DLabel", frame)
	searchLabel:SetPos(THEME.Padding * 2, y)
	searchLabel:SetSize(100, 24)
	searchLabel:SetText("Search:")
	searchLabel:SetFont("IRep_Label")
	searchLabel:SetTextColor(THEME.PrimaryGold)
	
	local searchBox = vgui.Create("DTextEntry", frame)
	searchBox:SetPos(120, y)
	searchBox:SetSize(400, 30)
	searchBox:SetPlaceholderText("Search by name, category, or class...")
	searchBox:SetFont("Trebuchet18")
	searchBox:SetTextColor(THEME.PrimaryGold)
	searchBox.Paint = function(self, w, h)
		THEME.PaintTextEntry(self, w, h)
	end
	
	y = y + 45
	
	-- Item list
	local itemList = vgui.Create("DListView", frame)
	itemList:SetPos(THEME.Padding * 2, y)
	itemList:SetSize(frame:GetWide() - THEME.Padding * 4, 260)
	itemList:SetMultiSelect(false)
	
	-- Add columns and set gold text immediately
	local col1 = itemList:AddColumn("Type")
	col1:SetFixedWidth(80)
	col1.Header:SetTextColor(THEME.PrimaryGold)
	
	local col2 = itemList:AddColumn("Name")
	col2:SetFixedWidth(200)
	col2.Header:SetTextColor(THEME.PrimaryGold)
	
	local col3 = itemList:AddColumn("Category")
	col3:SetFixedWidth(150)
	col3.Header:SetTextColor(THEME.PrimaryGold)
	
	local col4 = itemList:AddColumn("Model")
	col4:SetFixedWidth(250)
	col4.Header:SetTextColor(THEME.PrimaryGold)
	
	local col5 = itemList:AddColumn("Class")
	col5:SetFixedWidth(150)
	col5.Header:SetTextColor(THEME.PrimaryGold)
	
	-- Style the list
	itemList:SetHeaderHeight(25)
	itemList.Paint = function(self, w, h)
		THEME.PaintListView(self, w, h)
	end
	
	-- Disable right click menu
	itemList.OnRowRightClick = function() end
	
	-- Override line painting for gold text and selection
	local oldAddLine = itemList.AddLine
	itemList.AddLine = function(self, ...)
		local line = oldAddLine(self, ...)
		
		-- Set line background paint
		line.Paint = function(panel, w, h)
			if panel:IsSelected() then
				surface.SetDrawColor(THEME.SecondaryGold)
				surface.DrawRect(0, 0, w, h)
			elseif panel:IsHovered() then
				surface.SetDrawColor(Color(214, 177, 64, 50))
				surface.DrawRect(0, 0, w, h)
			end
			return true
		end
		
		-- Set text color for all columns in this line
		for i = 1, 5 do -- We have 5 columns
			local col = line:GetColumnText(i)
			if col then
				line:SetColumnText(i, col) -- Re-set to trigger update
			end
		end
		
		-- Override each column's paint to use gold text
		for i, column in pairs(line.Columns) do
			if column then
				column:SetTextColor(THEME.PrimaryGold)
			end
		end
		
		return line
	end	y = y + 275
	
	-- Category selector
	local catLabel = vgui.Create("DLabel", frame)
	catLabel:SetPos(THEME.Padding * 2, y)
	catLabel:SetSize(150, 24)
	catLabel:SetText("Add to Category:")
	catLabel:SetFont("IRep_Label")
	catLabel:SetTextColor(THEME.PrimaryGold)
	
	local categoryCombo = vgui.Create("DComboBox", frame)
	categoryCombo:SetPos(180, y)
	categoryCombo:SetSize(300, 30)
	categoryCombo:SetValue("Select a category...")
	categoryCombo:SetFont("Trebuchet18")
	categoryCombo:SetTextColor(THEME.PrimaryGold)
	categoryCombo.Paint = function(self, w, h)
		THEME.PaintComboBox(self, w, h)
	end
	
	-- Request categories
	net.Start("Star_Trek.IndustrialReplicator.RequestCategories")
	net.SendToServer()
	
	net.Receive("Star_Trek.IndustrialReplicator.SendCategories", function()
		local categories = net.ReadTable()
		categoryCombo:Clear()
		
		for _, cat in ipairs(categories) do
			categoryCombo:AddChoice(cat.category_name)
		end
	end)
	
	y = y + 45
	
	-- Add button
	local addBtn = vgui.Create("DButton", frame)
	addBtn:SetPos(350, y)
	addBtn:SetSize(200, 40)
	addBtn:SetText("")
	addBtn.Paint = function(self, w, h)
		THEME.PaintButton(self, w, h, "Add Selected", self:IsHovered(), self:IsDown())
	end
	addBtn.DoClick = function()
		local selected = itemList:GetSelectedLine()
		if not selected then
			Derma_Message("Please select an item first!", "Error", "OK")
			return
		end
		
		local category = categoryCombo:GetValue()
		if not category or category == "" or category == "Select a category..." then
			Derma_Message("Please select a category!", "Error", "OK")
			return
		end
		
		local line = itemList:GetLine(selected)
		local itemType = line:GetColumnText(1)
		local name = line:GetColumnText(2)
		local model = line:GetColumnText(4)
		
		local path
		if itemType == "Chair" then
			-- Create chair format string
			path = "vehicle:chair:" .. model .. ":"
		else
			-- Get the stored vehicle data
			local vehicleData = line:GetSortValue(6)
			local vehicleScript = ""
			if vehicleData and vehicleData.keyValues and vehicleData.keyValues.vehiclescript then
				vehicleScript = vehicleData.keyValues.vehiclescript
			end
			-- Create vehicle format string
			path = "vehicle:" .. vehicleData.class .. ":" .. model .. ":" .. vehicleScript
		end
		
		net.Start("Star_Trek.IndustrialReplicator.AddItem")
		net.WriteString(path)
		net.WriteString(name)
		net.WriteString(category)
		net.WriteString(itemType == "Chair" and "chair" or "vehicle")
		net.SendToServer()
		
		Derma_Message("Added " .. name .. " to category " .. category .. "!", "Success", "OK")
	end
	
	-- Store all items for filtering
	local allItems = {}
	
	-- Function to populate list based on filter
	local function PopulateList(filterValue, searchValue)
		itemList:Clear()
		
		searchValue = searchValue or ""
		local searchLower = searchValue:lower()
		
		for _, item in ipairs(allItems) do
			-- Apply type filter
			if filterValue == "All" or 
			   (filterValue == "Vehicles Only" and item.type == "Vehicle") or
			   (filterValue == "Chairs Only" and item.type == "Chair") then
				
				-- Apply search filter
				if searchValue == "" or 
				   string.find(item.name:lower(), searchLower) or
				   string.find(item.category:lower(), searchLower) or
				   string.find(item.class:lower(), searchLower) then
					local line = itemList:AddLine(item.type, item.name, item.category, item.model, item.class)
					line:SetSortValue(6, item.data) -- Store full data
				end
			end
		end
	end
	
	-- Filter change handler
	filterCombo.OnSelect = function(self, index, value)
		PopulateList(value, searchBox:GetValue())
	end
	
	-- Request and populate combined list (vehicles + chairs)
	net.Start("Star_Trek.IndustrialReplicator.RequestVehicleList")
	net.SendToServer()
	
	net.Start("Star_Trek.IndustrialReplicator.RequestChairList")
	net.SendToServer()
	
	-- Receive vehicles
	net.Receive("Star_Trek.IndustrialReplicator.SendVehicleList", function()
		local vehicles = net.ReadTable()
		
		for _, vehicle in ipairs(vehicles) do
			table.insert(allItems, {
				type = "Vehicle",
				name = vehicle.name,
				category = vehicle.category,
				model = vehicle.model,
				class = vehicle.class,
				data = vehicle
			})
		end
		
		-- Populate list after receiving data
		PopulateList(filterCombo:GetValue(), searchBox:GetValue())
	end)
	
	-- Receive chairs
	net.Receive("Star_Trek.IndustrialReplicator.SendChairList", function()
		local chairs = net.ReadTable()
		
		for _, chair in ipairs(chairs) do
			table.insert(allItems, {
				type = "Chair",
				name = chair.name,
				category = chair.category,
				model = chair.model,
				class = chair.class,
				data = chair
			})
		end
		
		-- Populate list after receiving data
		PopulateList(filterCombo:GetValue(), searchBox:GetValue())
	end)
	
	-- Search functionality
	searchBox.OnValueChange = function(self, value)
		PopulateList(filterCombo:GetValue(), value)
	end
end

print("[Industrial Replicator] Client panels loaded")

