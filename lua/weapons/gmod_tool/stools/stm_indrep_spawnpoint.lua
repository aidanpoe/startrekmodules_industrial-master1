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

if not istable(TOOL) then Star_Trek:LoadAllModules() return end

TOOL.Category = "ST:RP"
TOOL.Name = "Ind Rep Spawn Point"
TOOL.ConfigName = ""

if CLIENT then
	TOOL.Information = {
		{ name = "left" },
		{ name = "right" },
		{ name = "reload" }
	}

	language.Add("tool.stm_indrep_spawnpoint.name", "Industrial Replicator Spawn Point")
	language.Add("tool.stm_indrep_spawnpoint.desc", "Set or reset the spawn point for industrial replicators")
	language.Add("tool.stm_indrep_spawnpoint.left", "Set spawn point at crosshair")
	language.Add("tool.stm_indrep_spawnpoint.right", "Remove custom spawn point (revert to default)")
	language.Add("tool.stm_indrep_spawnpoint.reload", "Show current spawn point")

	-- Visual feedback for spawn points (adapted from transport_relay)
	local function renderSpawnPoint(ent, isSelected)
		if not IsValid(ent) then return end
		local pos = ent:GetReplicatePos()
		if not pos then return end
		
		local ang = ent:GetReplicateAng() or Angle(0, 0, 0)
		
		-- Use brighter red for selected replicator
		local colorMult = isSelected and 1.0 or 0.6
		local redColor = Color(255 * colorMult, 50 * colorMult, 50 * colorMult)
		
		-- Calculate height for the beam
		local height = 50
		
		-- Draw a beam of red light above the spawn point
		render.DrawLine(pos, pos + Vector(0, 0, height), redColor)
		render.DrawLine(pos + Vector(5, 0, 0), pos + Vector(5, 0, height), redColor)
		render.DrawLine(pos + Vector(-5, 0, 0), pos + Vector(-5, 0, height), redColor)
		render.DrawLine(pos + Vector(0, 5, 0), pos + Vector(0, 5, height), redColor)
		render.DrawLine(pos + Vector(0, -5, 0), pos + Vector(0, -5, height), redColor)
		
		-- Draw a ring at the top
		local ringPos = pos + Vector(0, 0, height)
		for i = 0, 12 do
			local a1 = math.rad((i / 12) * 360)
			local a2 = math.rad(((i + 1) / 12) * 360)
			local p1 = ringPos + 15 * Vector(math.sin(a1), math.cos(a1), 0)
			local p2 = ringPos + 15 * Vector(math.sin(a2), math.cos(a2), 0)
			render.DrawLine(p1, p2, redColor)
		end
		
		-- Draw forward direction arrow at ground level
		local forward = ang:Forward() * 25
		local right = ang:Right() * 8
		local arrowEnd = pos + forward
		local arrowColor = Color(255 * colorMult, 200 * colorMult, 0)
		render.DrawLine(pos, arrowEnd, arrowColor)
		render.DrawLine(arrowEnd, arrowEnd - forward * 0.3 + right * 0.3, arrowColor)
		render.DrawLine(arrowEnd, arrowEnd - forward * 0.3 - right * 0.3, arrowColor)
		
		-- If selected, draw text label with spawn point info
		if isSelected then
			local dy = EyeAngles():Up()
			local dx = -EyeAngles():Right()
			local textAng = dx:AngleEx(dx:Cross(-dy))
			textAng:RotateAroundAxis(EyeAngles():Forward(), 180)
			
			cam.Start3D2D(ringPos + Vector(0, 0, 10), textAng, 0.1)
				draw.SimpleText("SPAWN POINT", "DermaLarge", 0, -20, Color(255, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(string.format("X: %.2f  Y: %.2f  Z: %.2f", pos.x, pos.y, pos.z), "DermaDefault", 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				draw.SimpleText(string.format("Yaw: %.2f°", ang.y), "DermaDefault", 0, 15, Color(255, 200, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			cam.End3D2D()
			
			-- Draw text label on the replicator entity
			cam.Start3D2D(ent:GetPos() + Vector(0, 0, 30), textAng, 0.12)
				draw.SimpleText("◄ SELECTED REPLICATOR ►", "DermaLarge", 0, 0, Color(255, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			cam.End3D2D()
		end
	end

	-- Track selected replicator on client
	local selectedReplicator = nil
	
	-- Render spawn point when tool is active
	hook.Add("PostDrawTranslucentRenderables", "IndRepSpawnPoint.Render", function()
		local toolSwep = LocalPlayer():GetActiveWeapon()
		if not IsValid(toolSwep) or toolSwep:GetClass() ~= "gmod_tool" then
			selectedReplicator = nil
			return
		end

		local toolTable = LocalPlayer():GetTool()
		if not istable(toolTable) or toolTable.Mode ~= "stm_indrep_spawnpoint" then
			selectedReplicator = nil
			return
		end

		-- Update selected replicator based on what player is looking at
		local tr = LocalPlayer():GetEyeTrace()
		if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "industrial_replicator_entity" then
			selectedReplicator = tr.Entity
			
			-- Draw preview point at crosshair for left-click placement
			if tr.HitPos:Distance(tr.Entity:GetPos()) > 50 then -- Only show if not too close to replicator
				local previewPos = tr.HitPos
				render.DrawSphere(previewPos, 5, 16, 16, Color(100, 255, 255, 200))
				
				-- Draw preview label
				local dy = EyeAngles():Up()
				local dx = -EyeAngles():Right()
				local textAng = dx:AngleEx(dx:Cross(-dy))
				textAng:RotateAroundAxis(EyeAngles():Forward(), 180)
				
				cam.Start3D2D(previewPos + Vector(0, 0, 15), textAng, 0.12)
					draw.SimpleText("New Spawn Point", "DermaDefault", 0, 0, Color(100, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
				cam.End3D2D()
			end
		end

		-- Find all industrial replicators and render their spawn points
		for _, ent in ipairs(ents.FindByClass("industrial_replicator_entity")) do
			if IsValid(ent) then
				local isSelected = (ent == selectedReplicator)
				renderSpawnPoint(ent, isSelected)
			end
		end
	end)
end

if SERVER then
	-- Left click: Set spawn point at crosshair
	function TOOL:LeftClick(tr)
		local ent = self.SelectedReplicator
		if not IsValid(ent) then
			if IsValid(self:GetOwner()) then
				self:GetOwner():ChatPrint("First select an industrial replicator by looking at it.")
			end
			return false
		end

		if not tr.Hit then
			if IsValid(self:GetOwner()) then
				self:GetOwner():ChatPrint("Aim at a valid surface to set the spawn point.")
			end
			return false
		end

		-- Set the spawn point to where the player is aiming
		local pos = tr.HitPos
		local ang = self:GetOwner():EyeAngles()
		ang.p = 0 -- Keep horizontal
		ang.r = 0

		local success = ent:SetSpawnPoint(pos, ang)
		
		if success then
			if IsValid(self:GetOwner()) then
				self:GetOwner():ChatPrint(string.format("Spawn point set to: %.2f, %.2f, %.2f", pos.x, pos.y, pos.z))
			end
		else
			if IsValid(self:GetOwner()) then
				self:GetOwner():ChatPrint("Failed to save spawn point!")
			end
		end

		return true
	end

	-- Right click: Remove custom spawn point (revert to default)
	function TOOL:RightClick(tr)
		local ent = self.SelectedReplicator
		if not IsValid(ent) then
			if IsValid(self:GetOwner()) then
				self:GetOwner():ChatPrint("First select an industrial replicator by looking at it.")
			end
			return false
		end

		-- Remove custom spawn point from database
		local success = ent:RemoveSpawnPoint()
		
		if success then
			if IsValid(self:GetOwner()) then
				self:GetOwner():ChatPrint("Custom spawn point removed. Using default spawn point.")
			end
		else
			if IsValid(self:GetOwner()) then
				self:GetOwner():ChatPrint("Failed to remove spawn point!")
			end
		end

		return true
	end

	-- Reload: Select replicator and show current spawn point
	function TOOL:Reload(tr)
		if not tr.Hit then return false end
		
		local ent = tr.Entity
		if not IsValid(ent) or ent:GetClass() ~= "industrial_replicator_entity" then
			self.SelectedReplicator = nil
			if IsValid(self:GetOwner()) then
				self:GetOwner():ChatPrint("Aim at an industrial replicator to select it.")
			end
			return false
		end

		self.SelectedReplicator = ent

		-- Show current spawn point
		local pos = ent:GetReplicatePos() or ent.DefaultReplicatePos or Vector(0, 0, 0)
		local ang = ent:GetReplicateAng() or ent.DefaultReplicateAng or Angle(0, 0, 0)
		
		if IsValid(self:GetOwner()) then
			self:GetOwner():ChatPrint(string.format("Selected replicator. Current spawn point: %.2f, %.2f, %.2f (yaw: %.2f)", 
				pos.x, pos.y, pos.z, ang.y))
		end

		return true
	end

	function TOOL:Think()
		-- Auto-select replicator when looking at it
		local tr = self:GetOwner():GetEyeTrace()
		if tr.Hit and IsValid(tr.Entity) and tr.Entity:GetClass() == "industrial_replicator_entity" then
			self.SelectedReplicator = tr.Entity
		end
	end
end

function TOOL:BuildCPanel()
	if SERVER then return end

	self:AddControl("Header", {
		Text = "#tool.stm_indrep_spawnpoint.name",
		Description = "#tool.stm_indrep_spawnpoint.desc"
	})

	self:AddControl("Label", {
		Text = "How to use:"
	})

	self:AddControl("Label", {
		Text = "1. Reload (R): Look at a replicator and press Reload to select it"
	})

	self:AddControl("Label", {
		Text = "2. Left Click: Aim where you want items to spawn and click"
	})

	self:AddControl("Label", {
		Text = "3. Right Click: Remove custom spawn point (revert to default)"
	})

	self:AddControl("Label", {
		Text = ""
	})

	self:AddControl("Label", {
		Text = "Custom spawn points are saved to database and persist."
	})
	
	self:AddControl("Label", {
		Text = "Right-clicking removes the database entry entirely."
	})
end
