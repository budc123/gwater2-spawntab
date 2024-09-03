AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Category		= "GWater2"
ENT.PrintName		= "Extension Sphere (10)"
ENT.Author			= "Meetric / Jn"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable 		= true

-- send cloth data to the client
function ENT:SpawnFunction(ply, tr, class, type)
	local add = tr.HitNormal * 100
	gwater2.AddSphere(gwater2.quick_matrix(tr.HitPos + add), 10)	-- network

	local effect = EffectData()
	effect:SetStart(ply:EyePos())
	effect:SetOrigin(tr.HitPos + add)
	util.Effect("ToolTracer", effect)

	return false
end