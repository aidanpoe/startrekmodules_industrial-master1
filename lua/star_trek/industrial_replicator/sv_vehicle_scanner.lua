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
--   Vehicle Scanner | Server        --
---------------------------------------

-- Scans the game for available vehicles and chairs (like Q menu does)
Star_Trek.IndustrialReplicator.VehicleScanner = {}

-- Get list of all spawnable vehicles from the game
function Star_Trek.IndustrialReplicator.VehicleScanner:GetVehicleList()
	local vehicles = {}
	
	-- Scan the vehicles list (same as Q menu)
	local vehicleList = list.Get("Vehicles")
	
	if vehicleList then
		for className, data in pairs(vehicleList) do
			table.insert(vehicles, {
				class = className,
				name = data.Name or className,
				model = data.Model or "models/error.mdl",
				category = data.Category or "Other",
				isDrivable = true,
				keyValues = data.KeyValues or {}
			})
		end
	end
	
	return vehicles
end

-- Get list of all spawnable chairs from the game
function Star_Trek.IndustrialReplicator.VehicleScanner:GetChairList()
	local chairs = {}
	
	-- Scan the vehicles list for chairs/seats
	local vehicleList = list.Get("Vehicles")
	
	if vehicleList then
		for className, data in pairs(vehicleList) do
			local category = data.Category or ""
			local name = data.Name or className
			
			-- Filter for chairs (usually in "Chairs" category or have "chair"/"seat" in name)
			if string.find(category:lower(), "chair") or 
			   string.find(name:lower(), "chair") or 
			   string.find(name:lower(), "seat") then
				table.insert(chairs, {
					class = className,
					name = name,
					model = data.Model or "models/error.mdl",
					category = category,
					isDrivable = false,
					keyValues = data.KeyValues or {}
				})
			end
		end
	end
	
	return chairs
end

-- Generate formatted list for console output
function Star_Trek.IndustrialReplicator.VehicleScanner:PrintVehicleList()
	local vehicles = self:GetVehicleList()
	
	print("\n========== AVAILABLE VEHICLES ==========")
	print("Total vehicles found: " .. #vehicles)
	print("Format: Class | Name | Model | Category\n")
	
	for _, veh in ipairs(vehicles) do
		print(string.format("%-30s | %-20s | %-40s | %s", 
			veh.class, 
			veh.name, 
			veh.model,
			veh.category
		))
	end
	
	print("========================================\n")
end

-- Generate formatted list for console output
function Star_Trek.IndustrialReplicator.VehicleScanner:PrintChairList()
	local chairs = self:GetChairList()
	
	print("\n========== AVAILABLE CHAIRS ==========")
	print("Total chairs found: " .. #chairs)
	print("Format: Class | Name | Model | Category\n")
	
	for _, chair in ipairs(chairs) do
		print(string.format("%-30s | %-20s | %-40s | %s", 
			chair.class, 
			chair.name, 
			chair.model,
			chair.category
		))
	end
	
	print("========================================\n")
end

-- Auto-add all vehicles to a category
function Star_Trek.IndustrialReplicator.VehicleScanner:AutoAddVehicles(category)
	if not Star_Trek.IndustrialReplicator.Database.Initialized then
		print("[Vehicle Scanner] ERROR: Database not initialized!")
		return false, "Database not initialized"
	end
	
	local vehicles = self:GetVehicleList()
	local addedCount = 0
	local errorCount = 0
	
	category = category or "AUTO-VEHICLES"
	
	print("[Vehicle Scanner] Adding " .. #vehicles .. " vehicles to category: " .. category)
	
	for _, veh in ipairs(vehicles) do
		-- Create vehicle format string
		local vehicleScript = ""
		if veh.keyValues and veh.keyValues.vehiclescript then
			vehicleScript = veh.keyValues.vehiclescript
		end
		
		local vehicleData = "vehicle:" .. veh.class .. ":" .. veh.model .. ":" .. vehicleScript
		
		local success, err = Star_Trek.IndustrialReplicator.Database:AddItem(
			vehicleData,
			veh.name,
			category,
			"vehicle"
		)
		
		if success then
			addedCount = addedCount + 1
			print("[Vehicle Scanner] ✓ Added: " .. veh.name)
		else
			errorCount = errorCount + 1
			print("[Vehicle Scanner] ✗ Failed: " .. veh.name .. " - " .. tostring(err))
		end
	end
	
	print(string.format("[Vehicle Scanner] Complete! Added: %d, Errors: %d", addedCount, errorCount))
	return true, addedCount
end

-- Auto-add all chairs to a category
function Star_Trek.IndustrialReplicator.VehicleScanner:AutoAddChairs(category)
	if not Star_Trek.IndustrialReplicator.Database.Initialized then
		print("[Vehicle Scanner] ERROR: Database not initialized!")
		return false, "Database not initialized"
	end
	
	local chairs = self:GetChairList()
	local addedCount = 0
	local errorCount = 0
	
	category = category or "AUTO-CHAIRS"
	
	print("[Vehicle Scanner] Adding " .. #chairs .. " chairs to category: " .. category)
	
	for _, chair in ipairs(chairs) do
		-- Create chair format string
		local chairData = "vehicle:chair:" .. chair.model .. ":"
		
		local success, err = Star_Trek.IndustrialReplicator.Database:AddItem(
			chairData,
			chair.name,
			category,
			"chair"
		)
		
		if success then
			addedCount = addedCount + 1
			print("[Vehicle Scanner] ✓ Added: " .. chair.name)
		else
			errorCount = errorCount + 1
			print("[Vehicle Scanner] ✗ Failed: " .. chair.name .. " - " .. tostring(err))
		end
	end
	
	print(string.format("[Vehicle Scanner] Complete! Added: %d, Errors: %d", addedCount, errorCount))
	return true, addedCount
end

-- Console commands for easy access
concommand.Add("st_irep_list_vehicles", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then
		ply:ChatPrint("Only superadmins can use this command!")
		return
	end
	
	Star_Trek.IndustrialReplicator.VehicleScanner:PrintVehicleList()
end, nil, "List all spawnable vehicles")

concommand.Add("st_irep_list_chairs", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then
		ply:ChatPrint("Only superadmins can use this command!")
		return
	end
	
	Star_Trek.IndustrialReplicator.VehicleScanner:PrintChairList()
end, nil, "List all spawnable chairs")

concommand.Add("st_irep_auto_add_vehicles", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then
		ply:ChatPrint("Only superadmins can use this command!")
		return
	end
	
	local category = args[1] or "AUTO-VEHICLES"
	Star_Trek.IndustrialReplicator.VehicleScanner:AutoAddVehicles(category)
	
	if IsValid(ply) then
		ply:ChatPrint("[Industrial Replicator] Auto-adding vehicles to category: " .. category)
	end
end, nil, "Auto-add all vehicles to replicator (usage: st_irep_auto_add_vehicles [category])")

concommand.Add("st_irep_auto_add_chairs", function(ply, cmd, args)
	if IsValid(ply) and not ply:IsSuperAdmin() then
		ply:ChatPrint("Only superadmins can use this command!")
		return
	end
	
	local category = args[1] or "AUTO-CHAIRS"
	Star_Trek.IndustrialReplicator.VehicleScanner:AutoAddChairs(category)
	
	if IsValid(ply) then
		ply:ChatPrint("[Industrial Replicator] Auto-adding chairs to category: " .. category)
	end
end, nil, "Auto-add all chairs to replicator (usage: st_irep_auto_add_chairs [category])")

print("[Industrial Replicator] Vehicle Scanner loaded!")
print("Commands available:")
print("  st_irep_list_vehicles - List all spawnable vehicles")
print("  st_irep_list_chairs - List all spawnable chairs")
print("  st_irep_auto_add_vehicles [category] - Auto-add all vehicles")
print("  st_irep_auto_add_chairs [category] - Auto-add all chairs")
