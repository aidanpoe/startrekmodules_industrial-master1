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

---------------------------------------

---------------------------------------

-- Helper function to spawn vehicles with proper configuration
-- This handles the special vehicle: format created by the client
function Star_Trek.IndustrialReplicator:SpawnVehicle(data, pos, ang)
	print("[Industrial Replicator] SpawnVehicle called with data:", data, "type:", type(data))
	
	if type(data) ~= "string" then
		print("[Industrial Replicator] ERROR: Invalid vehicle data format - not a string")
		return false, "Invalid vehicle data format"
	end
	
	-- Parse vehicle: format
	-- Format: "vehicle:name:model:script"
	if not string.StartWith(data, "vehicle:") then
		print("[Industrial Replicator] ERROR: Not a vehicle format -", data)
		return false, "Not a vehicle format"
	end
	
	local parts = string.Explode(":", data)
	print("[Industrial Replicator] Parsed vehicle parts:", table.concat(parts, " | "))
	
	if #parts < 3 then
		print("[Industrial Replicator] ERROR: Invalid vehicle format - not enough parts")
		return false, "Invalid vehicle format"
	end
	
	local vehicleName = parts[2]
	local vehicleModel = parts[3]
	local vehicleScript = parts[4] or ""
	
	print("[Industrial Replicator] Vehicle config - Name:", vehicleName, "Model:", vehicleModel, "Script:", vehicleScript)
	
	-- Create the vehicle entity
	local vehicle
	
	-- Check if this is a chair (has "chair" in name or is using prisoner_pod script)
	local isChair = string.find(string.lower(vehicleName), "chair") or 
	                string.find(string.lower(vehicleModel), "chair") or
	                vehicleScript == "scripts/vehicles/prisoner_pod.txt"
	
	if isChair then
		-- Chairs use the Seat entity (no wheel attachments needed)
		print("[Industrial Replicator] Detected chair - using Seat entity")
		vehicle = ents.Create("prop_vehicle_prisoner_pod")
		if not IsValid(vehicle) then
			return false, "Failed to create chair entity"
		end
		
		vehicle:SetModel(vehicleModel)
		-- Don't set vehicle script for chairs - they don't need it
		
	elseif vehicleScript ~= "" then
		-- Scripted vehicle (Jeep, Airboat, Jalopy)
		print("[Industrial Replicator] Creating scripted vehicle")
		vehicle = ents.Create("prop_vehicle_jeep")
		if not IsValid(vehicle) then
			return false, "Failed to create vehicle entity"
		end
		
		vehicle:SetModel(vehicleModel)
		vehicle:SetKeyValue("vehiclescript", vehicleScript)
	else
		-- Simple seat vehicle (Pod)
		print("[Industrial Replicator] Creating simple seat vehicle")
		vehicle = ents.Create("prop_vehicle_prisoner_pod")
		if not IsValid(vehicle) then
			return false, "Failed to create vehicle entity"
		end
		
		vehicle:SetModel(vehicleModel)
	end
	
	-- Set position and angle
	vehicle:SetPos(pos)
	vehicle:SetAngles(ang)
	
	-- Spawn the vehicle
	vehicle:Spawn()
	vehicle:Activate()
	
	-- Mark as replicated
	vehicle.Replicated = true
	
	-- Make it physical
	local phys = vehicle:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end
	
	print("[Industrial Replicator] Successfully spawned vehicle: " .. vehicleName)
	
	return true, vehicle
end
