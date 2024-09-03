AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Category		= "GWater2"
ENT.PrintName		= "Extension Drain"
ENT.Author			= "Mee / Jn"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable   	= true
ENT.Editable		= true

function ENT:Initialize()
	if CLIENT then return end

    self:SetModel( "models/hunter/blocks/cube05x05x05.mdl")
    self:PhysicsInit( SOLID_VPHYSICS ) -- Initializes physics for the entity, making it solid and interactable.
    self:SetMoveType( MOVETYPE_VPHYSICS ) -- Sets how the entity moves, using physics.
    self:SetSolid( SOLID_VPHYSICS )-- Makes the entity solid, allowing for collisions.
    local phys = self:GetPhysicsObject()
	if (WireLib~=nil) then
		WireLib.CreateInputs(self,{"Active"})
	end
end

function ENT:TriggerInput(name,val)
	if ((name=="Active") and (val>0)) then self:SetOn(true) end
	if ((name=="Active") and (val<1)) then self:SetOn(false) end
end

if CLIENT then
	function ENT:Draw()
		render.DrawWireframeBox(self:GetPos(), Angle(), -Vector(12,12,12), Vector(12,12,12), Color(255, 0, 0), true)

		render.DrawWireframeSphere(self:GetPos(), self:GetRadius(), 15, 15, Color(255, 0, 0), true)
	end
end

function ENT:SpawnFunction(ply, tr, class)
	if not tr.Hit then return end
	local ent = ents.Create(class)
	ent:SetPos(tr.HitPos + Vector(0, 5, 0))
	ent:Spawn()
	ent:Activate()

	ent:SetRadius(20)
	ent:SetOn(true)
	ent:SetCollisionGroup(COLLISION_GROUP_WORLD)

	return ent
end

function ENT:SetupDataTables()
	self:NetworkVar("Float", 1, "Radius", {KeyName = "Radius", Edit = {type = "Float", order = 2, min = 0, max = 500}})
	self:NetworkVar("Bool", 0, "On", {KeyName = "On", Edit = {type = "Bool", order = 3}})

	if SERVER then return end

	-- runs per client FleX frame, this may be different per client.
	-- more particles might be spawned depending on the client, but this setup allows for laminar flow, which I think looks better
	-- The alternative is running a gwater2.AddCylinder in a serverside Think hook, however with that setup different clients may see different results
	hook.Add("gwater2_posttick", self, function()
		if !self:GetOn() then return end
		gwater2.solver:RemoveSphere(gwater2.quick_matrix(self:GetPos(), nil, self:GetRadius() * 2))
	end)
end

function ENT:OnRemove()
	hook.Remove("gwater2_posttick", self)
end
