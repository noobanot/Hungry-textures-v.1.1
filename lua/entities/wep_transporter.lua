AddCSLuaFile( "wep_transporter.lua" )

ENT.Type 			= "anim"
ENT.Base 			= "base_env_entity"
ENT.PrintName		= "Matter Transporter"
ENT.Author			= "Ludsoe"

list.Set( "LSEntOverlayText" , "wep_transporter", {HasOOO = true ,resnames = {"energy"}, genresnames={}} )

if(SERVER)then
	function ENT:Initialize()
		self:SetModel( "models/SBEP_community/d12shieldemitter.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:DrawShadow( false )
		self.CoolDown = CurTime()

		if WireAddon then
			local V,N,A,E = "VECTOR","NORMAL","ANGLE","ENTITY"
			self.Inputs = WireLib.CreateSpecialInputs( self,
					{"Send","Target","Destination"},
					{N,E,V}
					)
		end
	end

	function ENT:TriggerInput(iname, value)         
		if iname == "Send" then
			if value > 0 then
				self:Send()
			end
		elseif iname == "Target" then
			if value then
				self.Target = value
			end
		elseif iname == "Destination" then
			if value then
				self.Destination = value
			end
		end
	end

	function ENT:Send()
		if CurTime()<self.CoolDown then return end
		if not IsEntity(e) or LDE:IsImmune(e) then return end
		
		local e = self.Target
		
		
		local constraints = constraint.GetAllConstrainedEntities(e)
		if table.Count(constraints)>1 then return end
		
		local start = e:GetPos()
		local dest = self.Destination + Vector(0,0,1)
		local dist,dist2 = start:Distance(dest),self:GetPos():Distance(start)
		local consume = 1
		
		if e:IsPlayer() then
			consume = ((dist/100)*dist2/100)*20
		else
			consume = ((dist/100)*dist2/100)*(e:GetPhysicsObject():GetMass()*6)
		end
		if self:GetResourceAmount("energy")<consume then return end
		
		self:ConsumeResource("energy",consume)
		e:SetPos(self.Destination)--The Acual Teleport
		e:GetPhysicsObject():SetVelocityInstantaneous(Vector(0,0,0))
		self.CoolDown = CurTime()+1.5
	end
	
	/* --Make transportation not instantaneous?
	function ENT:Think()
		self.BaseClass.Think(self)
				


		self.Entity:NextThink( CurTime() + 0.6 )
		return true
	end
	*/
end		
