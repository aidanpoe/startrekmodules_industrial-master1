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
--  Industrial Replicator | Server   --
---------------------------------------

if not istable(ENT) then Star_Trek:LoadAllModules() return end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Precache the icon material so it's sent to clients
resource.AddFile("materials/entities/industrial_replicator_entity_v3.vmt")
resource.AddFile("materials/entities/industrial_replicator_entity_v3.vtf")

-- Fixed replication position from the request
ENT.ReplicatePos = Vector(291.29, 61.04, 11714.17)
ENT.ReplicateAng = Angle(0.02, 179.99, -0.00)

function ENT:SpawnFunction(ply, tr, ClassName)
	if not tr.Hit then return end

	local pos = tr.HitPos
	local ang = ply:GetAngles()

	ang.p = 0
	ang.r = 0

	local ent = ents.Create(ClassName)
	ent:SetPos(pos)
	ent:SetAngles(ang)
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:Initialize()
	self:SetModel("models/hunter/plates/plate.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
	end
end

function ENT:Use(ply)
	Star_Trek.LCARS:OpenInterface(ply, self, "industrial_replicator")
end
