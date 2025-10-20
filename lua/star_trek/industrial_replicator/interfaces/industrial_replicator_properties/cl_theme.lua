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

if SERVER then return end

-- Dark Gold Gaming Theme
local THEME = {}

-- Color Palette
THEME.PrimaryGold = Color(214, 177, 64)
THEME.SecondaryGold = Color(235, 205, 95, 110)
THEME.GoldSeparator = Color(214, 177, 64, 90)
THEME.BackgroundOuter = Color(15, 15, 18, 180)
THEME.BackgroundInner = Color(26, 26, 30, 185)
THEME.HeaderBackground = Color(35, 30, 18, 170)
THEME.PanelLight = Color(35, 35, 35)
THEME.PanelDark = Color(48, 48, 48)
THEME.TextPrimary = Color(230, 230, 230)
THEME.TextSecondary = Color(185, 185, 185)
THEME.TextTertiary = Color(200, 200, 200)
THEME.TextEmphasized = Color(220, 220, 220)
THEME.Overlay = Color(0, 0, 0, 150)

-- Typography
THEME.Fonts = {
	LargeHeader = "Coolvetica52",
	MediumHeader = "Coolvetica44",
	WindowTitle = "Trebuchet24",
	BodyText = "Lato18",
	SmallText = "TahomaBold12",
	ButtonText = "Trebuchet19"
}

-- Create fonts if they don't exist
surface.CreateFont("IRep_LargeHeader", {
	font = "Coolvetica",
	size = 52,
	weight = 600
})

surface.CreateFont("IRep_MediumHeader", {
	font = "Coolvetica",
	size = 30,
	weight = 500
})

surface.CreateFont("IRep_WindowTitle", {
	font = "Trebuchet MS",
	size = 19,
	weight = 700
})

surface.CreateFont("IRep_BodyText", {
	font = "Lato",
	size = 16,
	weight = 400
})

surface.CreateFont("IRep_SmallText", {
	font = "Tahoma",
	size = 12,
	weight = 700
})

surface.CreateFont("IRep_ButtonText", {
	font = "Trebuchet MS",
	size = 22,
	weight = 700
})

surface.CreateFont("IRep_Label", {
	font = "Trebuchet MS",
	size = 16,
	weight = 600
})

-- Layout Constants
THEME.CornerRadius = 8
THEME.Margin = 8
THEME.Padding = 16
THEME.ListItemHeight = 30
THEME.ButtonHeight = 30
THEME.SeparatorHeight = 2

-- Helper Functions
function THEME.DrawRoundedBox(x, y, w, h, color)
	draw.RoundedBox(THEME.CornerRadius, x, y, w, h, color)
end

function THEME.DrawSeparator(x, y, w)
	surface.SetDrawColor(THEME.GoldSeparator)
	surface.DrawRect(x, y, w, THEME.SeparatorHeight)
end

function THEME.PaintFrame(panel, w, h, title)
	-- Outer background
	THEME.DrawRoundedBox(0, 0, w, h, THEME.BackgroundOuter)
	
	-- Header bar
	THEME.DrawRoundedBox(0, 0, w, 40, THEME.HeaderBackground)
	
	-- Gold separator under header
	THEME.DrawSeparator(0, 40, w)
	
	-- Inner content area
	THEME.DrawRoundedBox(THEME.Margin, 42 + THEME.Margin, w - THEME.Margin * 2, h - 42 - THEME.Margin * 2, THEME.BackgroundInner)
	
	-- Title text
	draw.SimpleText(title, "IRep_WindowTitle", w / 2, 20, THEME.PrimaryGold, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function THEME.PaintButton(panel, w, h, text, hovered, pressed)
	local bgColor = THEME.PanelDark
	local textColor = THEME.TextSecondary
	
	if pressed then
		bgColor = THEME.PrimaryGold
		textColor = Color(0, 0, 0)
	elseif hovered then
		bgColor = Color(214, 177, 64, 150)
		textColor = THEME.TextPrimary
	end
	
	THEME.DrawRoundedBox(0, 0, w, h, bgColor)
	draw.SimpleText(text, "IRep_ButtonText", w / 2, h / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function THEME.PaintListItem(panel, w, h, isAlt, isSelected, isHovered)
	local bgColor = isAlt and THEME.PanelLight or THEME.PanelDark
	
	if isSelected or isHovered then
		bgColor = THEME.SecondaryGold
	end
	
	surface.SetDrawColor(bgColor)
	surface.DrawRect(0, 0, w, h)
end

function THEME.PaintComboBox(panel, w, h)
	-- Background
	THEME.DrawRoundedBox(0, 0, w, h, THEME.PanelDark)
	
	-- Border
	surface.SetDrawColor(THEME.PrimaryGold)
	surface.DrawOutlinedRect(0, 0, w, h, 1)
	
	-- Text
	local text = panel:GetValue() or ""
	draw.SimpleText(text, "Trebuchet18", THEME.Padding / 2, h / 2, THEME.PrimaryGold, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	-- Down arrow
	draw.SimpleText("▼", "Trebuchet18", w - 15, h / 2, THEME.PrimaryGold, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function THEME.PaintTextEntry(panel, w, h)
	-- Background
	THEME.DrawRoundedBox(0, 0, w, h, THEME.PanelDark)
	
	-- Border
	local borderColor = panel:IsEditing() and THEME.PrimaryGold or Color(214, 177, 64, 100)
	surface.SetDrawColor(borderColor)
	surface.DrawOutlinedRect(0, 0, w, h, 1)
	
	-- Draw the text manually
	panel:DrawTextEntryText(THEME.PrimaryGold, THEME.SecondaryGold, THEME.PrimaryGold)
end

function THEME.PaintListView(panel, w, h)
	-- Background
	THEME.DrawRoundedBox(0, 0, w, h, THEME.PanelDark)
	
	-- Border
	surface.SetDrawColor(THEME.PrimaryGold)
	surface.DrawOutlinedRect(0, 0, w, h, 1)
end

-- Store globally
Star_Trek = Star_Trek or {}
Star_Trek.IndustrialReplicator = Star_Trek.IndustrialReplicator or {}
Star_Trek.IndustrialReplicator.Theme = THEME

print("[Industrial Replicator] Theme loaded")

