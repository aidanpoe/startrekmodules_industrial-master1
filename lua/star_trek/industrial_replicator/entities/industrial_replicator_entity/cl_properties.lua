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

-- Make sure the Panels table exists
Star_Trek.IndustrialReplicator = Star_Trek.IndustrialReplicator or {}
Star_Trek.IndustrialReplicator.Panels = Star_Trek.IndustrialReplicator.Panels or {}

-- Load theme
include("star_trek/industrial_replicator/interfaces/industrial_replicator_properties/cl_theme.lua")
local THEME = Star_Trek.IndustrialReplicator.Theme

-- Function to open main management menu
function Star_Trek.IndustrialReplicator.Panels.OpenManagementMenu()
	-- Safety check
	if not Star_Trek.IndustrialReplicator.Panels.OpenAddPanel then
		print("[Industrial Replicator] ERROR: Panel functions not loaded!")
		chat.AddText("Error: Panel functions not loaded. Please reconnect to the server.")
		return
	end
	
	local frame = vgui.Create("DFrame")
	frame:SetSize(500, 500)
	frame:Center()
	frame:SetTitle("")
	frame:ShowCloseButton(false)
	frame:MakePopup()
	frame:SetDraggable(true)
	
	-- Custom paint
	frame.Paint = function(self, w, h)
		THEME.PaintFrame(self, w, h, "INDUSTRIAL REPLICATOR - MANAGEMENT")
	end
	
	-- Close button
	local closeBtn = vgui.Create("DButton", frame)
	closeBtn:SetSize(24, 24)
	closeBtn:SetPos(frame:GetWide() - 32, 8)
	closeBtn:SetText("✕")
	closeBtn:SetFont("IRep_WindowTitle")
	closeBtn:SetTextColor(THEME.TextSecondary)
	closeBtn.Paint = function(self, w, h)
		local hovered = self:IsHovered()
		local bgColor = hovered and THEME.PrimaryGold or Color(0, 0, 0, 0)
		local textColor = hovered and Color(0, 0, 0) or THEME.TextSecondary
		
		THEME.DrawRoundedBox(0, 0, w, h, bgColor)
		draw.SimpleText("✕", "IRep_WindowTitle", w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
	closeBtn.DoClick = function()
		frame:Close()
	end
	
	-- Title label
	local titleLabel = vgui.Create("DLabel", frame)
	titleLabel:SetPos(THEME.Padding, 60)
	titleLabel:SetSize(frame:GetWide() - THEME.Padding * 2, 40)
	titleLabel:SetText("Select a management function:")
	titleLabel:SetFont("IRep_MediumHeader")
	titleLabel:SetTextColor(THEME.PrimaryGold)
	
	local y = 120
	local btnWidth = frame:GetWide() - THEME.Padding * 4
	local btnX = THEME.Padding * 2
	
	-- Helper function to create themed buttons
	local function CreateThemedButton(text, callback, yPos)
		local btn = vgui.Create("DButton", frame)
		btn:SetPos(btnX, yPos)
		btn:SetSize(btnWidth, 45)
		btn:SetText("")
		
		btn.Paint = function(self, w, h)
			THEME.PaintButton(self, w, h, text, self:IsHovered(), self:IsDown())
		end
		
		btn.DoClick = function()
			frame:Close()
			callback()
		end
		
		return btn
	end
	
	-- ADD button
	CreateThemedButton("Add New Item", function()
		Star_Trek.IndustrialReplicator.Panels.OpenAddPanel()
	end, y)
	
	y = y + 55
	
	-- BROWSE button (vehicles and chairs combined)
	CreateThemedButton("Browse Vehicles & Chairs", function()
		Star_Trek.IndustrialReplicator.Panels.OpenBrowseAllPanel()
	end, y)
	
	y = y + 55
	
	-- REMOVE button
	CreateThemedButton("Remove Item", function()
		Star_Trek.IndustrialReplicator.Panels.OpenRemovePanel()
	end, y)
	
	y = y + 55
	
	-- HIDE button
	CreateThemedButton("Hide/Show Item", function()
		Star_Trek.IndustrialReplicator.Panels.OpenHidePanel()
	end, y)
	
	y = y + 55
	
	-- MODIFY button
	CreateThemedButton("Modify Item", function()
		Star_Trek.IndustrialReplicator.Panels.OpenModifyPanel()
	end, y)
	
	y = y + 55
	
	-- MANAGE CATEGORIES button
	CreateThemedButton("Manage Categories", function()
		Star_Trek.IndustrialReplicator.Panels.OpenManageCategoriesPanel()
	end, y)
end

-- Register property menu option
properties.Add("industrial_replicator_edit", {
	MenuLabel = "Edit Replicator Items",
	Order = 999,
	MenuIcon = "icon16/wrench.png",
	
	Filter = function(self, ent, ply)
		if not IsValid(ent) then return false end
		if ent:GetClass() ~= "industrial_replicator_entity" then return false end
		if not gamemode.Call("CanProperty", ply, "industrial_replicator_edit", ent) then return false end
		return true
	end,
	
	Action = function(self, ent)
		print("[Industrial Replicator] Opening management menu")
		Star_Trek.IndustrialReplicator.Panels.OpenManagementMenu()
	end
})
