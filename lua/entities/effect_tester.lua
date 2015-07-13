AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_env_base"
ENT.PrintName		= "Effect Test"
ENT.Author			= "Ludsoe"
ENT.Category		= "Other"

ENT.Spawnable		= true
ENT.AdminOnly		= true

if(SERVER)then

	function ENT:Initialize()
		self:SetModel("models/slyfo_2/gunball.mdl")
		
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
	end

	function ENT:GravGunPunt()
		return false
	end

	function ENT:GravGunPickupAllowed()
		return false
	end
else
	ENT.RenderGroup = RENDERGROUP_OPAQUE
	
	local Size = 15
	
	function ENT:Initialize()
		local Rates = {}
		
		local R = math.random
		for I=1,Size do
			table.insert(Rates,{Vector(R(-1,1),R(-1,1),R(-1,1)),Vector(R(-Size,Size),R(-Size,Size),R(-Size,Size))})
		end
		
		self.RenderRates = Rates
	end
	
	function ENT:Draw()
		self:DrawModel()
		
		local effectdata = EffectData() effectdata:SetEntity(self)
		local Time = CurTime()*100
		
		for I=1,Size do
			local Rot,Vec = self.RenderRates[I][1],self.RenderRates[I][2]
			local Pos = Vector(Vec.x,Vec.y,Vec.z)
			Pos:Rotate(Angle(Rot.x*Time,Rot.y*Time,Rot.z*Time))
			effectdata:SetStart(self:GetPos()+Pos)
			util.Effect( "repair_drone_swarm", effectdata ) 
		end	
	end
end		
