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
-- LCARS Industrial Replicator | Srv --
---------------------------------------

if not istable(INTERFACE) then Star_Trek:LoadAllModules() return end
local SELF = INTERFACE

include("util.lua")

SELF.BaseInterface = "base"

SELF.LogType = "Industrial Replicator"

-- Opens the industrial replicator menu.
function SELF:Open(ent)
	local categories, categoryCount = self:GenerateCategories(ent)

	local success, window = Star_Trek.LCARS:CreateWindow(
		"category_list",
		Vector(0, 0, 0),
		Angle(0, 0, 0),
		nil,
		500,
		500,
		function(windowData, interfaceData, ply, categoryId, buttonId, buttonData)
			if buttonId then
				-- Check for cooldown
				local cooldownKey = "IndustrialReplicator_" .. ent:EntIndex()
				local lastUse = ent.LastReplicateTime or 0
				local currentTime = CurTime()
				
				if currentTime - lastUse < 10 then
					local remainingTime = math.ceil(10 - (currentTime - lastUse))
					if istable(Star_Trek.Logs) then
						Star_Trek.Logs:AddEntry(ent, ply, "Replicator on cooldown: " .. remainingTime .. " seconds remaining", Star_Trek.LCARS.ColorOrange)
					end
					ent:EmitSound("star_trek.lcars_error")
					return false
				end
				
				local selected = windowData.Selected
				local categoryData = windowData.Categories[selected]
				if istable(categoryData) then
					if istable(Star_Trek.Logs) then
						Star_Trek.Logs:AddEntry(ent, ply, "Replicating " .. buttonData.Name)
					end

					-- Use fixed world position from the entity
					local pos = ent.ReplicatePos
					local ang = ent.ReplicateAng

					local replicateSuccess, replicateError = Star_Trek.Replicator:CreateObject(buttonData.Data, pos, ang)
					if not replicateSuccess then
						if istable(Star_Trek.Logs) then
							Star_Trek.Logs:AddEntry(ent, ply, "ERROR: " .. replicateError, Star_Trek.LCARS.ColorRed)
						end

						ent:EmitSound("star_trek.lcars_error")
					else
						ent:EmitSound("star_trek.lcars_beep")
						-- Set cooldown time
						ent.LastReplicateTime = currentTime
					end
				end

				interfaceData:Close()
			else
				if categoryId == categoryCount + 1 then
					windowData:Close()

					return false
				end
			end
		end,
		categories,
		"INDUSTRIAL REPLICATOR",
		"IND-REPL",
		true
	)
	if not success then
		return false, window
	end

	return true, {window}
end
