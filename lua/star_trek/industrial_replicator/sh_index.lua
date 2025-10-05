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
--  Industrial Replicator | Index    --
---------------------------------------

Star_Trek:RequireModules("util", "lcars", "replicator")

Star_Trek.IndustrialReplicator = Star_Trek.IndustrialReplicator or {}

if SERVER then
	include("sv_config.lua")
	include("sv_industrial_replicator.lua")
end
