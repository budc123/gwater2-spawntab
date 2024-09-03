AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Category		= "GWater2"
ENT.PrintName		= "Extension Bathtub"
ENT.Author			= "Mee / Jn"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable   	= true

function ENT:Initialize()
	if CLIENT then return end

    self:SetModel( "models/props_interiors/BathTub01a.mdl")
    self:PhysicsInit( SOLID_VPHYSICS ) -- Initializes physics for the entity, making it solid and interactable.
    self:SetMoveType( MOVETYPE_VPHYSICS ) -- Sets how the entity moves, using physics.
    self:SetSolid( SOLID_VPHYSICS )-- Makes the entity solid, allowing for collisions.
    local phys = self:GetPhysicsObject()
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
		--local vectorr =  Vector(-38, 6.85, 15)
		--vectorr:Rotate(self:GetAngles())
		--render.DrawWireframeBox(self:GetPos() + vectorr, self:GetAngles(), -Vector(1,1,1), Vector(1,1,1), Color(0,0,0))
	end
end

function ENT:SpawnFunction(ply, tr, class)
	if not tr.Hit then return end
	local ent = ents.Create(class)
	ent:SetPos(tr.HitPos + Vector(0, 5, 0))
	ent:Spawn()
	ent:Activate()

	ent:SetOnOff(false)
	ent:SetUseType(SIMPLE_USE)

	return ent
end

function ENT:Use()
	self:SetOnOff(!self:GetOnOff())
	if self:GetOnOff() then
		self:EmitSound("/weapons/crowbar/crowbar_impact1.wav", 100, 100, 0.2)
	else
		self:EmitSound("/weapons/crowbar/crowbar_impact2.wav", 100, 100, 0.2)
	end
end


function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "OnOff")

	if SERVER then return end

	-- runs per client FleX frame, this may be different per client.
	-- more particles might be spawned depending on the client, but this setup allows for laminar flow, which I think looks better
	-- The alternative is running a gwater2.AddCylinder in a serverside Think hook, however with that setup different clients may see different results
	hook.Add("gwater2_posttick", self, function()
		if self:GetOnOff() then
			local vectorr =  Vector(-38, 6.85, 15)
			vectorr:Rotate(self:GetAngles())
			gwater2.solver:AddSphere(gwater2.quick_matrix(vectorr + self:GetPos()), 3)
		end
	end)
end

function ENT:OnRemove()
	hook.Remove("gwater2_posttick", self)
end