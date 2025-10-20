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
-- Industrial Replicator | Database  --
---------------------------------------

Star_Trek.IndustrialReplicator.Database = Star_Trek.IndustrialReplicator.Database or {}
Star_Trek.IndustrialReplicator.Database.Initialized = false

-- Initialize the database
function Star_Trek.IndustrialReplicator.Database:Initialize()
	if not sql then
		ErrorNoHalt("[Industrial Replicator] SQL module not available!\n")
		return false
	end

	-- Create the indrepprops2025 table if it doesn't exist
	local query = [[
		CREATE TABLE IF NOT EXISTS indrepprops2025 (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			item_path TEXT NOT NULL,
			item_name TEXT NOT NULL,
			category TEXT NOT NULL,
			item_type TEXT NOT NULL,
			is_visible INTEGER DEFAULT 1,
			is_hardcoded INTEGER DEFAULT 0,
			created_at INTEGER DEFAULT 0
		)
	]]
	
	local result = sql.Query(query)
	if result == false then
		ErrorNoHalt("[Industrial Replicator] Failed to create database table: " .. sql.LastError() .. "\n")
		return false
	end

	-- Create the categories table
	local catQuery = [[
		CREATE TABLE IF NOT EXISTS indreppcategories2025 (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			category_name TEXT NOT NULL UNIQUE,
			is_hardcoded INTEGER DEFAULT 0,
			created_at INTEGER DEFAULT 0
		)
	]]
	
	local catResult = sql.Query(catQuery)
	if catResult == false then
		ErrorNoHalt("[Industrial Replicator] Failed to create categories table: " .. sql.LastError() .. "\n")
		return false
	end

	-- Pre-populate hardcoded categories
	local hardcodedCategories = {"FURNITURE", "EQUIPMENT", "CARGO", "MEDICAL", "ENG", "AWAY MISSION", "TOOLS", "MISC"}
	for _, catName in ipairs(hardcodedCategories) do
		local checkQuery = string.format("SELECT id FROM indreppcategories2025 WHERE category_name = %s", sql.SQLStr(catName))
		local exists = sql.Query(checkQuery)
		
		if not exists then
			sql.Query(string.format(
				"INSERT INTO indreppcategories2025 (category_name, is_hardcoded, created_at) VALUES (%s, 1, %d)",
				sql.SQLStr(catName),
				os.time()
			))
		end
	end

	-- Create the spawn points table
	local spawnQuery = [[
		CREATE TABLE IF NOT EXISTS indrepspawnpoints2025 (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			entity_id INTEGER NOT NULL UNIQUE,
			pos_x REAL NOT NULL,
			pos_y REAL NOT NULL,
			pos_z REAL NOT NULL,
			ang_p REAL NOT NULL,
			ang_y REAL NOT NULL,
			ang_r REAL NOT NULL,
			created_at INTEGER DEFAULT 0,
			updated_at INTEGER DEFAULT 0
		)
	]]
	
	local spawnResult = sql.Query(spawnQuery)
	if spawnResult == false then
		ErrorNoHalt("[Industrial Replicator] Failed to create spawn points table: " .. sql.LastError() .. "\n")
		return false
	end

	print("[Industrial Replicator] Database initialized successfully")
	Star_Trek.IndustrialReplicator.Database.Initialized = true
	return true
end

-- Add a new category
-- @param categoryName: Name of the category
-- @return success, error
function Star_Trek.IndustrialReplicator.Database:AddCategory(categoryName)
	if not categoryName or categoryName == "" then
		return false, "Category name is required"
	end

	local query = sql.Query(string.format(
		"INSERT INTO indreppcategories2025 (category_name, is_hardcoded, created_at) VALUES (%s, 0, %d)",
		sql.SQLStr(categoryName),
		os.time()
	))

	if query == false then
		return false, sql.LastError()
	end

	return true
end

-- Delete a category (only custom categories can be deleted)
-- @param categoryName: Name of the category to delete
-- @return success, error
function Star_Trek.IndustrialReplicator.Database:DeleteCategory(categoryName)
	if not categoryName then
		return false, "Category name is required"
	end

	-- Check if it's hardcoded
	local checkQuery = string.format(
		"SELECT is_hardcoded FROM indreppcategories2025 WHERE category_name = %s",
		sql.SQLStr(categoryName)
	)
	local result = sql.Query(checkQuery)

	if result and #result > 0 and tonumber(result[1].is_hardcoded) == 1 then
		return false, "Cannot delete hardcoded category"
	end

	-- Delete the category
	local query = sql.Query(string.format(
		"DELETE FROM indreppcategories2025 WHERE category_name = %s AND is_hardcoded = 0",
		sql.SQLStr(categoryName)
	))

	if query == false then
		return false, sql.LastError()
	end

	-- Also delete all items in this category
	sql.Query(string.format(
		"DELETE FROM indrepprops2025 WHERE category = %s",
		sql.SQLStr(categoryName)
	))

	return true
end

-- Get all categories with metadata
-- @return table of categories
function Star_Trek.IndustrialReplicator.Database:GetAllCategories()
	local query = "SELECT * FROM indreppcategories2025 ORDER BY category_name"
	local result = sql.Query(query)

	if result == false then
		ErrorNoHalt("[Industrial Replicator] Failed to query categories: " .. sql.LastError() .. "\n")
		return {}
	end

	if not result then
		return {}
	end

	-- Convert fields
	for _, cat in ipairs(result) do
		cat.id = tonumber(cat.id)
		cat.is_hardcoded = tonumber(cat.is_hardcoded) == 1
		cat.created_at = tonumber(cat.created_at)
	end

	return result
end

-- Check if a category is hardcoded
-- @param categoryName: Name of the category
-- @return boolean
function Star_Trek.IndustrialReplicator.Database:IsCategoryHardcoded(categoryName)
	local query = string.format(
		"SELECT is_hardcoded FROM indreppcategories2025 WHERE category_name = %s",
		sql.SQLStr(categoryName)
	)
	local result = sql.Query(query)

	if result and #result > 0 then
		return tonumber(result[1].is_hardcoded) == 1
	end

	return false
end

-- Add a new item to the database
-- @param itemPath: Model path or entity class (e.g., "models/props/chair.mdl" or {Class = "weapon_physcannon"})
-- @param itemName: Display name for the item
-- @param category: Category name
-- @param itemType: Type of item (prop, entity, weapon, vehicle, chair)
-- @return success, error/id
function Star_Trek.IndustrialReplicator.Database:AddItem(itemPath, itemName, category, itemType)
	if not itemPath or not itemName or not category or not itemType then
		return false, "Missing required parameters"
	end

	-- Convert itemPath to string if it's a table (entity class)
	local pathString = itemPath
	if istable(itemPath) then
		pathString = util.TableToJSON(itemPath)
	end

	local query = sql.Query(string.format(
		"INSERT INTO indrepprops2025 (item_path, item_name, category, item_type, is_visible, created_at) VALUES (%s, %s, %s, %s, 1, %d)",
		sql.SQLStr(pathString),
		sql.SQLStr(itemName),
		sql.SQLStr(category),
		sql.SQLStr(itemType),
		os.time()
	))

	if query == false then
		return false, sql.LastError()
	end

	return true, sql.QueryValue("SELECT last_insert_rowid()")
end

-- Get all items from the database
-- @param includeHidden: Whether to include hidden items
-- @return table of items
function Star_Trek.IndustrialReplicator.Database:GetAllItems(includeHidden)
	local visibilityClause = ""
	if not includeHidden then
		visibilityClause = " WHERE is_visible = 1"
	end

	local query = "SELECT * FROM indrepprops2025" .. visibilityClause .. " ORDER BY category, item_name"
	local result = sql.Query(query)

	if result == false then
		ErrorNoHalt("[Industrial Replicator] Database query failed: " .. sql.LastError() .. "\n")
		return {}
	end

	if not result then
		return {}
	end

	-- Convert item_path back to table if it's JSON
	for _, item in ipairs(result) do
		item.id = tonumber(item.id)
		item.is_visible = tonumber(item.is_visible) == 1
		item.is_hardcoded = tonumber(item.is_hardcoded) == 1
		item.created_at = tonumber(item.created_at)

		-- Try to parse item_path as JSON
		if string.sub(item.item_path, 1, 1) == "{" then
			local parsed = util.JSONToTable(item.item_path)
			if parsed then
				item.item_path = parsed
			end
		end
	end

	return result
end

-- Get items by category
-- @param category: Category name
-- @param includeHidden: Whether to include hidden items
-- @return table of items
function Star_Trek.IndustrialReplicator.Database:GetItemsByCategory(category, includeHidden)
	local visibilityClause = ""
	if not includeHidden then
		visibilityClause = " AND is_visible = 1"
	end

	local query = string.format(
		"SELECT * FROM indrepprops2025 WHERE category = %s%s ORDER BY item_name",
		sql.SQLStr(category),
		visibilityClause
	)
	
	local result = sql.Query(query)

	if result == false then
		ErrorNoHalt("[Industrial Replicator] Database query failed: " .. sql.LastError() .. "\n")
		return {}
	end

	if not result then
		return {}
	end

	-- Convert item_path back to table if it's JSON
	for _, item in ipairs(result) do
		item.id = tonumber(item.id)
		item.is_visible = tonumber(item.is_visible) == 1
		item.is_hardcoded = tonumber(item.is_hardcoded) == 1
		item.created_at = tonumber(item.created_at)

		if string.sub(item.item_path, 1, 1) == "{" then
			local parsed = util.JSONToTable(item.item_path)
			if parsed then
				item.item_path = parsed
			end
		end
	end

	return result
end

-- Update an item
-- @param id: Item ID
-- @param itemPath: New model path or entity class
-- @param itemName: New display name
-- @param category: New category
-- @param itemType: New item type
-- @return success, error
function Star_Trek.IndustrialReplicator.Database:UpdateItem(id, itemPath, itemName, category, itemType)
	if not id then
		return false, "Missing item ID"
	end

	-- Convert itemPath to string if it's a table
	local pathString = itemPath
	if istable(itemPath) then
		pathString = util.TableToJSON(itemPath)
	end

	local query = sql.Query(string.format(
		"UPDATE indrepprops2025 SET item_path = %s, item_name = %s, category = %s, item_type = %s WHERE id = %d",
		sql.SQLStr(pathString),
		sql.SQLStr(itemName),
		sql.SQLStr(category),
		sql.SQLStr(itemType),
		id
	))

	if query == false then
		return false, sql.LastError()
	end

	return true
end

-- Hide/unhide an item
-- @param id: Item ID
-- @param hidden: true to hide, false to show
-- @return success, error
function Star_Trek.IndustrialReplicator.Database:SetItemVisibility(id, visible)
	if not id then
		return false, "Missing item ID"
	end

	local visValue = visible and 1 or 0
	local query = sql.Query(string.format(
		"UPDATE indrepprops2025 SET is_visible = %d WHERE id = %d",
		visValue,
		id
	))

	if query == false then
		return false, sql.LastError()
	end

	return true
end

-- Delete an item
-- @param id: Item ID
-- @return success, error
function Star_Trek.IndustrialReplicator.Database:DeleteItem(id)
	if not id then
		return false, "Missing item ID"
	end

	local query = sql.Query(string.format(
		"DELETE FROM indrepprops2025 WHERE id = %d",
		id
	))

	if query == false then
		return false, sql.LastError()
	end

	return true
end

-- Get all unique categories
-- @return table of category names
function Star_Trek.IndustrialReplicator.Database:GetCategories()
	local categories = {}

	-- Get hardcoded categories
	for _, cat in ipairs(Star_Trek.IndustrialReplicator.Categories) do
		if not table.HasValue(categories, cat.Name) then
			table.insert(categories, cat.Name)
		end
	end

	-- Get database categories
	local query = "SELECT DISTINCT category FROM indrepprops2025 ORDER BY category"
	local result = sql.Query(query)

	if result then
		for _, row in ipairs(result) do
			if not table.HasValue(categories, row.category) then
				table.insert(categories, row.category)
			end
		end
	end

	table.sort(categories)
	return categories
end

-- Hide a hardcoded item by adding it to the database as hidden
-- @param itemPath: Model path or entity class
-- @param itemName: Display name
-- @param category: Category name
-- @param itemType: Type of item
-- @return success, error
function Star_Trek.IndustrialReplicator.Database:HideHardcodedItem(itemPath, itemName, category, itemType)
	-- Convert itemPath to string if it's a table
	local pathString = itemPath
	if istable(itemPath) then
		pathString = util.TableToJSON(itemPath)
	end

	-- Check if this item is already in the database
	local existing = sql.Query(string.format(
		"SELECT id FROM indrepprops2025 WHERE item_path = %s AND category = %s",
		sql.SQLStr(pathString),
		sql.SQLStr(category)
	))

	if existing and #existing > 0 then
		-- Update existing entry
		return self:SetItemVisibility(tonumber(existing[1].id), false)
	else
		-- Create new entry marked as hidden and hardcoded
		local query = sql.Query(string.format(
			"INSERT INTO indrepprops2025 (item_path, item_name, category, item_type, is_visible, is_hardcoded, created_at) VALUES (%s, %s, %s, %s, 0, 1, %d)",
			sql.SQLStr(pathString),
			sql.SQLStr(itemName),
			sql.SQLStr(category),
			sql.SQLStr(itemType),
			os.time()
		))

		if query == false then
			return false, sql.LastError()
		end

		return true
	end
end

-- Check if an item is hidden
-- @param itemPath: Model path or entity class (as string or table)
-- @param category: Category name
-- @return boolean
function Star_Trek.IndustrialReplicator.Database:IsItemHidden(itemPath, category)
	-- Convert itemPath to string if it's a table
	local pathString = itemPath
	if istable(itemPath) then
		pathString = util.TableToJSON(itemPath)
	end

	local query = string.format(
		"SELECT is_visible FROM indrepprops2025 WHERE item_path = %s AND category = %s",
		sql.SQLStr(pathString),
		sql.SQLStr(category)
	)
	
	local result = sql.Query(query)

	if result and #result > 0 then
		return tonumber(result[1].is_visible) == 0
	end

	return false
end

-- Save or update a spawn point for a replicator entity
-- @param entityId: The entity index
-- @param pos: Vector position
-- @param ang: Angle orientation
-- @return success, error
function Star_Trek.IndustrialReplicator.Database:SetSpawnPoint(entityId, pos, ang)
	if not entityId or not pos or not ang then
		return false, "Missing required parameters"
	end

	-- Check if spawn point already exists
	local checkQuery = string.format(
		"SELECT id FROM indrepspawnpoints2025 WHERE entity_id = %d",
		entityId
	)
	local existing = sql.Query(checkQuery)

	local timestamp = os.time()

	if existing and #existing > 0 then
		-- Update existing spawn point
		local query = sql.Query(string.format(
			"UPDATE indrepspawnpoints2025 SET pos_x = %f, pos_y = %f, pos_z = %f, ang_p = %f, ang_y = %f, ang_r = %f, updated_at = %d WHERE entity_id = %d",
			pos.x, pos.y, pos.z,
			ang.p, ang.y, ang.r,
			timestamp,
			entityId
		))

		if query == false then
			return false, sql.LastError()
		end
	else
		-- Insert new spawn point
		local query = sql.Query(string.format(
			"INSERT INTO indrepspawnpoints2025 (entity_id, pos_x, pos_y, pos_z, ang_p, ang_y, ang_r, created_at, updated_at) VALUES (%d, %f, %f, %f, %f, %f, %f, %d, %d)",
			entityId,
			pos.x, pos.y, pos.z,
			ang.p, ang.y, ang.r,
			timestamp, timestamp
		))

		if query == false then
			return false, sql.LastError()
		end
	end

	return true
end

-- Get the spawn point for a replicator entity
-- @param entityId: The entity index
-- @return pos (Vector), ang (Angle), or nil if not found
function Star_Trek.IndustrialReplicator.Database:GetSpawnPoint(entityId)
	if not entityId then
		return nil, nil
	end

	local query = string.format(
		"SELECT pos_x, pos_y, pos_z, ang_p, ang_y, ang_r FROM indrepspawnpoints2025 WHERE entity_id = %d",
		entityId
	)
	
	local result = sql.Query(query)

	if result == false then
		ErrorNoHalt("[Industrial Replicator] Failed to query spawn point: " .. sql.LastError() .. "\n")
		return nil, nil
	end

	if not result or #result == 0 then
		return nil, nil
	end

	local data = result[1]
	local pos = Vector(tonumber(data.pos_x), tonumber(data.pos_y), tonumber(data.pos_z))
	local ang = Angle(tonumber(data.ang_p), tonumber(data.ang_y), tonumber(data.ang_r))

	return pos, ang
end

-- Delete the spawn point for a replicator entity
-- @param entityId: The entity index
-- @return success, error
function Star_Trek.IndustrialReplicator.Database:DeleteSpawnPoint(entityId)
	if not entityId then
		return false, "Missing entity ID"
	end

	local query = sql.Query(string.format(
		"DELETE FROM indrepspawnpoints2025 WHERE entity_id = %d",
		entityId
	))

	if query == false then
		return false, sql.LastError()
	end

	return true
end

-- Initialize the database on load
hook.Add("Initialize", "Star_Trek.IndustrialReplicator.InitDatabase", function()
	Star_Trek.IndustrialReplicator.Database:Initialize()
end)

