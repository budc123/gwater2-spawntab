AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Category		= "GWater2"
ENT.PrintName		= "Extension Emitter"
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
		local particle_radius = gwater2.solver:GetParameter("radius")
		local particle_fluid_rest_distance = (gwater2.solver:GetParameter("fluid_rest_distance") * 0.1) + 0
		local ang = nil
		if self:GetRotateWithOrientation() then
			ang = self:GetAngles()
		else
			ang = Angle()
		end

		local size = (Vector(self:GetXSize(), self:GetYSize(), self:GetZSize()) * self:GetSpacing() * 6 * particle_radius / 10) * particle_fluid_rest_distance

		render.DrawWireframeBox(self:GetPos(), ang, -Vector(12,12,12), Vector(12,12,12), Color(0, 255, 0), true)
	end
end

function ENT:SpawnFunction(ply, tr, class)
	if not tr.Hit then return end
	local ent = ents.Create(class)
	ent:SetPos(tr.HitPos + Vector(0, 5, 0))
	ent:Spawn()
	ent:Activate()

	ent:SetXSize(4)
	ent:SetYSize(4)
	ent:SetZSize(4)
	ent:SetWaterVelocity(0)
	ent:SetSpacing(2)
	ent:SetShape(1)
	ent:SetLifetime(10)
	ent:SetOn(true)
	ent:SetDoJitter(true)
	ent:SetHasLifeTime(false)
	ent:SetRotateWithOrientation(true)
	ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	ent:SetMaterial("phoenix_storms/gear")

	return ent
end

function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "XSize", {KeyName = "XSize", Edit = {type = "Float", order = 1, min = 0, max = 200}})
	self:NetworkVar("Float", 1, "YSize", {KeyName = "YSize", Edit = {type = "Float", order = 2, min = 0, max = 200}})
	self:NetworkVar("Float", 2, "ZSize", {KeyName = "ZSize", Edit = {type = "Float", order = 3, min = 0, max = 200}})
	self:NetworkVar("Bool", 0, "HasLifeTime", {KeyName = "HasLifeTime", Edit = {type = "Bool", order = 4}})
	self:NetworkVar("Float", 3, "Lifetime", {KeyName = "Lifetime", Edit = {type = "Float", order = 5, min = 1, max = 100}})
	self:NetworkVar("Float", 4, "Spacing", {KeyName = "Spacing", Edit = {type = "Float", order = 6, min = 1, max = 100}})
	self:NetworkVar("Float", 5, "WaterVelocity", {KeyName = "WaterVelocity", Edit = {type = "Float", order = 7, min = 0, max = 500}})
	self:NetworkVar("Int", 0, "Shape", {KeyName = "Shape", Edit = {type = "Int", order = 8, min = 1, max = 3}})
	self:NetworkVar("Bool", 1, "On", {KeyName = "On", Edit = {type = "Bool", order = 9}})
	self:NetworkVar("Bool", 2, "RotateWithOrientation", {KeyName = "RotateWithOrientation", Edit = {type = "Bool", order = 9}})
	self:NetworkVar("Bool", 3, "DoJitter", {KeyName = "DoJitter", Edit = {type = "Bool", order = 10}})
	self:NetworkVar("Float", 6, "SphereRadius", {KeyName = "SphereRadius", Edit = {type = "Float", order = 11, min = 0, max = 500}})

	if SERVER then return end

	-- runs per client FleX frame, this may be different per client.
	-- more particles might be spawned depending on the client, but this setup allows for laminar flow, which I think looks better
	-- The alternative is running a gwater2.AddCylinder in a serverside Think hook, however with that setup different clients may see different results
	hook.Add("gwater2_posttick", self, function()
		if !self:GetOn() then return end

		local particle_radius = gwater2.solver:GetParameter("radius")
		local strength = self:GetWaterVelocity()

		local mat = Matrix()
		mat:SetScale(Vector(self:GetSpacing(), self:GetSpacing(), self:GetSpacing()))
		if self:GetRotateWithOrientation() then
			local angs = self:GetAngles()
			angs:RotateAroundAxis(self:GetAngles():Right(), 90)
			mat:SetAngles(angs)
		else
			mat:SetAngles(Angle())
		end
		--mat:SetAngles(self:LocalToWorldAngles(Angle(0, CurTime() * 200, 0)))
		if self:GetDoJitter() then
			mat:SetTranslation(self:GetPos() + VectorRand(-1, 1))
		else
			mat:SetTranslation(self:GetPos())
		end

		local pdata = {}
		if self:GetHasLifeTime() then
			pdata = {vel = self:GetAngles():Forward() * strength, lifetime = self:GetLifetime()}
		else
			pdata = {vel = self:GetAngles():Forward() * strength}
		end
		
		if self:GetShape() == 1 then
			gwater2.solver:AddCube(mat, Vector(self:GetXSize(), self:GetYSize(), self:GetZSize()), pdata)
		elseif self:GetShape() == 2 then
			gwater2.solver:AddCylinder(mat, Vector(self:GetXSize(), self:GetYSize(), self:GetZSize()), pdata)
		else
			gwater2.solver:AddSphere(gwater2.quick_matrix(self:GetPos()), self:GetSphereRadius(), pdata)
		end
	end)
end

function ENT:OnRemove()
	hook.Remove("gwater2_posttick", self)
end
