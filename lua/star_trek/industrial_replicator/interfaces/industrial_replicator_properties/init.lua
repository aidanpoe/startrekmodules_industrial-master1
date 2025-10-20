---------------------------------------
---------------------------------------
--        made for Star Trek Module  --
-- Addon Created by HouseofPoe.co.uk --
--        API Created by             --
--       Jan 'Oninoni' Ziegler       --
--                                   --
-- This software can be used freely, --
--    but only distributed by me.    --
--                                   --
--    Copyright © 2025 Jan Ziegler   --
---------------------------------------
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

-- Send client files
if SERVER then
	AddCSLuaFile("cl_panels.lua")
else
	include("cl_panels.lua")
end

SELF.BaseInterface = "base"
-- SELF.LogType = "Industrial Replicator Properties" -- Disabled: Don't show in ship log list

-- Network strings for client-server communication
util.AddNetworkString("Star_Trek.IndustrialReplicator.AddItem")
util.AddNetworkString("Star_Trek.IndustrialReplicator.RemoveItem")
util.AddNetworkString("Star_Trek.IndustrialReplicator.HideItem")
util.AddNetworkString("Star_Trek.IndustrialReplicator.ShowItem")
util.AddNetworkString("Star_Trek.IndustrialReplicator.ModifyItem")
util.AddNetworkString("Star_Trek.IndustrialReplicator.RequestItemList")
util.AddNetworkString("Star_Trek.IndustrialReplicator.SendItemList")
util.AddNetworkString("Star_Trek.IndustrialReplicator.OpenPanel")
util.AddNetworkString("Star_Trek.IndustrialReplicator.AddCategory")
util.AddNetworkString("Star_Trek.IndustrialReplicator.RemoveCategory")
util.AddNetworkString("Star_Trek.IndustrialReplicator.RequestCategories")
util.AddNetworkString("Star_Trek.IndustrialReplicator.SendCategories")
util.AddNetworkString("Star_Trek.IndustrialReplicator.RequestVehicleList")
util.AddNetworkString("Star_Trek.IndustrialReplicator.SendVehicleList")
util.AddNetworkString("Star_Trek.IndustrialReplicator.RequestChairList")
util.AddNetworkString("Star_Trek.IndustrialReplicator.SendChairList")

-- Handle add item request
net.Receive("Star_Trek.IndustrialReplicator.AddItem", function(len, ply)
	if not Star_Trek.IndustrialReplicator.Database.Initialized then
		ply:ChatPrint("[Industrial Replicator] Error: Database not loaded!")
		return
	end
	
	local itemPath = net.ReadString()
	local itemName = net.ReadString()
	local category = net.ReadString()
	local itemType = net.ReadString()
	
	-- Parse item path based on prefix
	local data = itemPath
	if string.sub(itemPath, 1, 6) == "class:" then
		-- Entity/weapon format: class:name -> {Class = "name"}
		local className = string.sub(itemPath, 7)
		data = {Class = className}
	elseif string.sub(itemPath, 1, 8) == "vehicle:" then
		-- Vehicle format: vehicle:name:model:script -> keep as string
		-- Will be handled specially when spawning
		data = itemPath
	end
	
	print("[Industrial Replicator] Adding item - Path:", itemPath, "Data type:", type(data))
	
	local success, result = Star_Trek.IndustrialReplicator.Database:AddItem(data, itemName, category, itemType)
	
	if success then
		if istable(Star_Trek.Logs) then
			Star_Trek.Logs:AddEntry(nil, ply, "Added item: " .. itemName .. " to category " .. category, Star_Trek.LCARS.ColorGreen)
		end
		ply:ChatPrint("[Industrial Replicator] Item added successfully!")
	else
		ply:ChatPrint("[Industrial Replicator] Error: " .. tostring(result))
	end
end)

-- Handle remove item request
net.Receive("Star_Trek.IndustrialReplicator.RemoveItem", function(len, ply)
	local itemId = net.ReadInt(32)
	
	local success, result = Star_Trek.IndustrialReplicator.Database:DeleteItem(itemId)
	
	if success then
		if istable(Star_Trek.Logs) then
			Star_Trek.Logs:AddEntry(nil, ply, "Removed item ID: " .. itemId, Star_Trek.LCARS.ColorOrange)
		end
		ply:ChatPrint("[Industrial Replicator] Item removed successfully!")
	else
		ply:ChatPrint("[Industrial Replicator] Error: " .. tostring(result))
	end
end)

-- Handle hide item request
net.Receive("Star_Trek.IndustrialReplicator.HideItem", function(len, ply)
	local itemPath = net.ReadString()
	local itemName = net.ReadString()
	local category = net.ReadString()
	local itemType = net.ReadString()
	local isHardcoded = net.ReadBool()
	
	-- Parse item path if it starts with "class:"
	local data = itemPath
	if string.sub(itemPath, 1, 6) == "class:" then
		local className = string.sub(itemPath, 7)
		data = {Class = className}
	end
	
	local success, result
	if isHardcoded then
		success, result = Star_Trek.IndustrialReplicator.Database:HideHardcodedItem(data, itemName, category, itemType)
	else
		-- For database items, just set visibility
		-- We need to find the item ID first
		local allItems = Star_Trek.IndustrialReplicator.Database:GetAllItems(true)
		for _, item in ipairs(allItems) do
			local itemPathStr = istable(item.item_path) and util.TableToJSON(item.item_path) or item.item_path
			local dataStr = istable(data) and util.TableToJSON(data) or data
			if itemPathStr == dataStr and item.category == category then
				success, result = Star_Trek.IndustrialReplicator.Database:SetItemVisibility(item.id, false)
				break
			end
		end
	end
	
	if success then
		if istable(Star_Trek.Logs) then
			Star_Trek.Logs:AddEntry(nil, ply, "Hidden item: " .. itemName, Star_Trek.LCARS.ColorOrange)
		end
		ply:ChatPrint("[Industrial Replicator] Item hidden successfully!")
	else
		ply:ChatPrint("[Industrial Replicator] Error: " .. tostring(result or "Item not found"))
	end
end)

-- Handle show item (unhide) request
net.Receive("Star_Trek.IndustrialReplicator.ShowItem", function(len, ply)
	local itemPath = net.ReadString()
	local itemName = net.ReadString()
	local category = net.ReadString()
	local itemType = net.ReadString()
	local isHardcoded = net.ReadBool()
	
	-- Parse item path if it starts with "class:"
	local data = itemPath
	if string.sub(itemPath, 1, 6) == "class:" then
		local className = string.sub(itemPath, 7)
		data = {Class = className}
	end
	
	local success, result
	-- Find the item and set visibility to true
	local allItems = Star_Trek.IndustrialReplicator.Database:GetAllItems(true)
	for _, item in ipairs(allItems) do
		local itemPathStr = istable(item.item_path) and util.TableToJSON(item.item_path) or item.item_path
		local dataStr = istable(data) and util.TableToJSON(data) or data
		if itemPathStr == dataStr and item.category == category and item.item_name == itemName then
			success, result = Star_Trek.IndustrialReplicator.Database:SetItemVisibility(item.id, true)
			break
		end
	end
	
	if success then
		if istable(Star_Trek.Logs) then
			Star_Trek.Logs:AddEntry(nil, ply, "Showed item: " .. itemName, Star_Trek.LCARS.ColorGreen)
		end
		ply:ChatPrint("[Industrial Replicator] Item shown successfully!")
	else
		ply:ChatPrint("[Industrial Replicator] Error: " .. tostring(result or "Item not found"))
	end
end)

-- Handle modify item request
net.Receive("Star_Trek.IndustrialReplicator.ModifyItem", function(len, ply)
	local itemId = net.ReadInt(32)
	local itemPath = net.ReadString()
	local itemName = net.ReadString()
	local category = net.ReadString()
	local itemType = net.ReadString()
	
	-- Parse item path if it starts with "class:"
	local data = itemPath
	if string.sub(itemPath, 1, 6) == "class:" then
		local className = string.sub(itemPath, 7)
		data = {Class = className}
	end
	
	local success, result = Star_Trek.IndustrialReplicator.Database:UpdateItem(itemId, data, itemName, category, itemType)
	
	if success then
		if istable(Star_Trek.Logs) then
			Star_Trek.Logs:AddEntry(nil, ply, "Modified item: " .. itemName, Star_Trek.LCARS.ColorGreen)
		end
		ply:ChatPrint("[Industrial Replicator] Item modified successfully!")
	else
		ply:ChatPrint("[Industrial Replicator] Error: " .. tostring(result))
	end
end)

-- Handle request for item list
net.Receive("Star_Trek.IndustrialReplicator.RequestItemList", function(len, ply)
	if not Star_Trek.IndustrialReplicator.Database.Initialized then
		ply:ChatPrint("[Industrial Replicator] Error: Database not loaded!")
		return
	end
	
	local includeHardcoded = net.ReadBool()
	
	-- Get database items
	local dbItems = Star_Trek.IndustrialReplicator.Database:GetAllItems(true)
	
	-- Get hardcoded items if requested
	local allItems = {}
	
	-- Add database items
	for _, item in ipairs(dbItems) do
		local pathStr = istable(item.item_path) and util.TableToJSON(item.item_path) or item.item_path
		
		table.insert(allItems, {
			id = item.id,
			path = pathStr,
			name = item.item_name,
			category = item.category,
			type = item.item_type,
			visible = item.is_visible,
			hardcoded = item.is_hardcoded
		})
	end
	
	-- Add hardcoded items if requested
	if includeHardcoded then
		for _, cat in ipairs(Star_Trek.IndustrialReplicator.Categories) do
			for _, button in ipairs(cat.Buttons) do
				local pathStr = istable(button.Data) and util.TableToJSON(button.Data) or button.Data
				
				-- Check if item is hidden
				local isHidden = Star_Trek.IndustrialReplicator.Database:IsItemHidden(button.Data, cat.Name)
				
				table.insert(allItems, {
					id = -1,
					path = pathStr,
					name = button.Name,
					category = cat.Name,
					type = istable(button.Data) and "entity" or "prop",
					visible = not isHidden,
					hardcoded = true
				})
			end
		end
	end
	
	-- Send to client
	net.Start("Star_Trek.IndustrialReplicator.SendItemList")
	net.WriteTable(allItems)
	net.Send(ply)
end)

-- Handle add category request
net.Receive("Star_Trek.IndustrialReplicator.AddCategory", function(len, ply)
	local categoryName = net.ReadString()
	
	local success, result = Star_Trek.IndustrialReplicator.Database:AddCategory(categoryName)
	
	if success then
		if istable(Star_Trek.Logs) then
			Star_Trek.Logs:AddEntry(nil, ply, "Added category: " .. categoryName, Star_Trek.LCARS.ColorGreen)
		end
		ply:ChatPrint("[Industrial Replicator] Category added successfully!")
		
		-- Send updated category list back
		timer.Simple(0.1, function()
			if IsValid(ply) then
				SendCategoryList(ply)
			end
		end)
	else
		ply:ChatPrint("[Industrial Replicator] Error: " .. tostring(result))
	end
end)

-- Handle remove category request
net.Receive("Star_Trek.IndustrialReplicator.RemoveCategory", function(len, ply)
	local categoryName = net.ReadString()
	
	local success, result = Star_Trek.IndustrialReplicator.Database:DeleteCategory(categoryName)
	
	if success then
		if istable(Star_Trek.Logs) then
			Star_Trek.Logs:AddEntry(nil, ply, "Removed category: " .. categoryName, Star_Trek.LCARS.ColorRed)
		end
		ply:ChatPrint("[Industrial Replicator] Category deleted successfully!")
		
		-- Send updated category list back
		timer.Simple(0.1, function()
			if IsValid(ply) then
				SendCategoryList(ply)
			end
		end)
	else
		ply:ChatPrint("[Industrial Replicator] Error: " .. tostring(result))
	end
end)

-- Helper function to send category list
function SendCategoryList(ply)
	if not Star_Trek.IndustrialReplicator.Database.Initialized then
		ply:ChatPrint("[Industrial Replicator] Error: Database not loaded!")
		return
	end
	
	local categories = Star_Trek.IndustrialReplicator.Database:GetAllCategories()
	
	-- Count items in each category (database items)
	local allItems = Star_Trek.IndustrialReplicator.Database:GetAllItems(true)
	for _, cat in ipairs(categories) do
		cat.item_count = 0
		for _, item in ipairs(allItems) do
			if item.category == cat.category_name then
				cat.item_count = cat.item_count + 1
			end
		end
	end
	
	-- Also count hardcoded items from Star_Trek.IndustrialReplicator.Categories
	if Star_Trek.IndustrialReplicator.Categories then
		for _, hardcodedCat in ipairs(Star_Trek.IndustrialReplicator.Categories) do
			-- Find matching category in our list
			for _, cat in ipairs(categories) do
				if cat.category_name == hardcodedCat.Name then
					-- Add count of hardcoded buttons
					cat.item_count = cat.item_count + #hardcodedCat.Buttons
					break
				end
			end
		end
	end
	
	net.Start("Star_Trek.IndustrialReplicator.SendCategories")
	net.WriteTable(categories)
	net.Send(ply)
end

-- Handle request for category list
net.Receive("Star_Trek.IndustrialReplicator.RequestCategories", function(len, ply)
	SendCategoryList(ply)
end)

-- Opens the properties interface
function SELF:Open(ent)
	local categories = {
		{
			Name = "ADD",
			Color = Star_Trek.LCARS.ColorGreen,
			Buttons = {
				{
					Name = "Add New Item",
					Data = "add",
				},
			},
		},
		{
			Name = "BROWSE",
			Color = Star_Trek.LCARS.ColorBlue,
			Buttons = {
				{
					Name = "Browse Vehicles & Chairs",
					Data = "browse_all",
				},
			},
		},
		{
			Name = "REMOVE",
			Color = Star_Trek.LCARS.ColorRed,
			Buttons = {
				{
					Name = "Remove Item",
					Data = "remove",
				},
			},
		},
		{
			Name = "HIDE",
			Color = Star_Trek.LCARS.ColorOrange,
			Buttons = {
				{
					Name = "Hide Item",
					Data = "hide",
				},
			},
		},
		{
			Name = "MODIFY",
			Color = Star_Trek.LCARS.ColorBlue,
			Buttons = {
				{
					Name = "Modify Item",
					Data = "modify",
				},
			},
		},
		{
			Name = "CLOSE",
			Color = Star_Trek.LCARS.ColorRed,
			Buttons = {},
		},
	}
	
	local success, window = Star_Trek.LCARS:CreateWindow(
		"category_list",
		Vector(0, 0, 0),
		Angle(0, 0, 0),
		nil,
		500,
		500,
		function(windowData, interfaceData, ply, categoryId, buttonId, buttonData)
			if buttonId then
				-- Handle button clicks
				-- Send network message to client to open the panel
				print("[Industrial Replicator] Button clicked:", buttonData.Data, "for player:", ply)
				net.Start("Star_Trek.IndustrialReplicator.OpenPanel")
				net.WriteString(buttonData.Data)
				net.Send(ply)
				print("[Industrial Replicator] Network message sent to client")
				
				interfaceData:Close()
			else
				-- Handle category clicks (Close category)
				if categoryId == 6 then
					windowData:Close()
					return false
				end
			end
		end,
		categories,
		"REPLICATOR PROPERTIES",
		"IND-PROP",
		true
	)
	
	if not success then
		return false, window
	end

	return true, {window}
end

-- Handle request for vehicle list
net.Receive("Star_Trek.IndustrialReplicator.RequestVehicleList", function(len, ply)
	local vehicles = Star_Trek.IndustrialReplicator.VehicleScanner:GetVehicleList()
	
	net.Start("Star_Trek.IndustrialReplicator.SendVehicleList")
	net.WriteTable(vehicles)
	net.Send(ply)
end)

-- Handle request for chair list
net.Receive("Star_Trek.IndustrialReplicator.RequestChairList", function(len, ply)
	local chairs = Star_Trek.IndustrialReplicator.VehicleScanner:GetChairList()
	
	net.Start("Star_Trek.IndustrialReplicator.SendChairList")
	net.WriteTable(chairs)
	net.Send(ply)
end)
