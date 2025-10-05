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
--  Industrial Replicator | Shared   --
---------------------------------------

if not istable(ENT) then Star_Trek:LoadAllModules() return end

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Industrial Replicator"
ENT.Author = "Oninoni"

ENT.Category = "Star Trek"

ENT.Spawnable = true
ENT.Editable = true

function ENT:SetupDataTables()
end
