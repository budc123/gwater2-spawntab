AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.Category		= "GWater2"
ENT.PrintName		= "Extension BOMB"
ENT.Author			= "Mee / Jn"
ENT.Purpose			= ""
ENT.Instructions	= ""
ENT.Spawnable   	= true
ENT.ClassName 		= "extension_bomb" 
ENT.Editable 		= true
function ENT:Initialize()
	if CLIENT then return end

    self:SetModel( "models/props_c17/oildrum001_explosive.mdl")
    self:PhysicsInit( SOLID_VPHYSICS ) -- Initializes physics for the entity, making it solid and interactable.
    self:SetMoveType( MOVETYPE_VPHYSICS ) -- Sets how the entity moves, using physics.
    self:SetSolid( SOLID_VPHYSICS )-- Makes the entity solid, allowing for collisions.
	self:SetUseType(SIMPLE_USE)
	self:SetColor(Color(0, 100, 255))
    local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()

		if self:GetShowRadius() then
			if self:IsOnFire() then
				render.DrawWireframeSphere(self:GetPos(), self:GetRadius(), 15, 15, Color(255, 0, 0), true)
			else
				render.DrawWireframeSphere(self:GetPos(), self:GetRadius(), 15, 15, Color(0, 255, 0), true)
			end
		end
	end
end

function ENT:SpawnFunction(ply, tr, class)
	if not tr.Hit then return end
	local ent = ents.Create(class)
	ent:SetPos(tr.HitPos + Vector(0, 5, 0))
	ent:Spawn()
	ent:Activate()

	ent:SetRadius(100)
	ent:SetShowRadius(false)
	ent:SetGravity(0)

	return ent
end

function ENT:Explode()
	self:Ignite(100, 0)
	timer.Simple(math.random(1, 3), function()
		if !self:IsValid() then return end
		local rad = self:GetRadius()
		net.Start("EXTENSION_EXPLOSION", false)
		net.WriteVector(self:GetPos())
		net.WriteFloat(rad)
		net.Broadcast()
		if self:WaterLevel() > 1 then
			local effect = EffectData()
			effect:SetOrigin(self:GetPos())
			util.Effect("WaterSurfaceExplosion", effect, false)
		else
			local effect = EffectData()
			effect:SetOrigin(self:GetPos())
			util.Effect("Explosion", effect, false)
		end
		for i, v in pairs(ents.FindByClass("extension_bomb")) do
			if self:GetPos():Distance(v:GetPos()) < rad then
				if v ~= self then
					v:ExplodeChain(self)
				end
			end
		end
		
		self:Remove()
	end)
end

function ENT:Use()
	self:Explode()
end

function ENT:ExplodeChain(orgobj)
	local orad = orgobj:GetRadius()
	local rad = self:GetRadius()
	self:GetPhysicsObject():AddVelocity((orgobj:GetPos() - self:GetPos()):GetNormalized() * -500 * Lerp(self:GetPos():Distance(orgobj:GetPos()) * 1 / orad, orad / 100, 0))
	self:Ignite(100, 0)
	timer.Simple(math.random(1, 1.5), function()
		if !self:IsValid() then return end
		net.Start("EXTENSION_EXPLOSION", false)
		net.WriteVector(self:GetPos())
		net.WriteFloat(rad)
		net.Broadcast()
		local effect = EffectData()
		effect:SetOrigin(self:GetPos())
		
		util.Effect("Explosion", effect, false)
		for i, v in pairs(ents.FindByClass("extension_bomb")) do
			if self:GetPos():Distance(v:GetPos()) < rad then
				if v ~= self then
					v:ExplodeChain(self)
				end
			end
		end
		self:Remove()
	end)
end

function ENT:OnTakeDamage(damage)
	self:Explode()
end

function ENT:PhysicsCollide(data, phys)
	if ( data.Speed > 1000 ) then self:Explode() end
end


function ENT:SetupDataTables()
	self:NetworkVar("Float", 0, "Radius", {KeyName = "Radius", Edit = {type = "Float", order = 1, min = -500, max = 500}})
	self:NetworkVar("Bool", 0, "ShowRadius", {KeyName = "ShowRadius", Edit = {type = "Bool", order = 2, min = -500, max = 500}})

	if SERVER then return end

	-- runs per client FleX frame, this may be different per client.
	-- more particles might be spawned depending on the client, but this setup allows for laminar flow, which I think looks better
	-- The alternative is running a gwater2.AddCylinder in a serverside Think hook, however with that setup different clients may see different results
end