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
-- Industrial Replicator | Server    --
---------------------------------------

function Star_Trek.IndustrialReplicator:GetReplicatorList(ent)
	local override = hook.Run("Star_Trek.IndustrialReplicator.GetReplicatorList", ent)
	if override then
		return override
	end

	local categories = table.Copy(Star_Trek.IndustrialReplicator.Categories)
	
	return categories
end
