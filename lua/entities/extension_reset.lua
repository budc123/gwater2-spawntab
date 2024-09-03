AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Category		= "GWater2"
ENT.PrintName		= "Extension Quick Reset"
ENT.Author			= "Meetric / Jn"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable 		= true
ENT.ClassName 		= "extension_reset"

-- send cloth data to the client
function ENT:SpawnFunction(ply, tr, class, type)
	gwater2.Reset()	-- network

	return false
end
