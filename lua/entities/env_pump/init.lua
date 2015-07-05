AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

util.PrecacheSound( "Buttons.snd17" )

ENT.OverlayDelay = 0

--Settings
local Ground = 1 + 0 + 2 + 8 + 32
local PLUG_IN_SOCKET_CONSTRAINT_POWER = 1000
local PLUG_IN_ATTACH_RANGE = 13
local Energy_Increment = 10

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	if not (WireAddon == nil) then
		self.Inputs = Wire_CreateInputs(self, { "Toggle", "FlowRate" })
		self.Outputs = Wire_CreateOutputs(self, { "Deployed","InUse", "Rate" })
	end
	self:SetModel("models/props_lab/tpplugholder_single.mdl")
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self.damaged = 0
	self.ropelength = 500		--Default
	self.hoselength = 512		--Default
	self.ropemax = 10000	--Clamp
	self.Hose = nil
	self.rope = nil
	
	self.MyPlug = nil
	self.TheirPlug = nil
	self.Pumping = false
	self.Receiving = false
	self.FlowRate = 256	--Default
	self.Toggled = false
	self.ReelIn = false
end

function ENT:Setup( pump, rate, hoselength )		--for the toolgun
	--self.pump_active = pump or true
	self.FlowRate = rate or 256
	self.hose_length = hoselength or 512
	
	if WireAddon then Wire_TriggerOutput(self, "Rate", self.FlowRate) end
	self:SupplyResource("energy", 0)
end

function ENT:CreatePlug()
	if not self.Receiving and not IsValid(self.MyPlug) then
		
		self:EmitSound( "Buttons.snd17" )
		
		--First, we create the plug at a local position
		local LPos1 = Vector(5,13,10)
		local LPos2 = Vector(10,0,0)
		local width = 3
		local material = "cable/cable2"
		local pos = self:LocalToWorld( Vector(15,13,10) )
		local ang = self:GetAngles() + Angle(180,0,0)
	
		local plug = ents.Create( "prop_physics" )
		plug:SetModel( "models/props_lab/tpplug.mdl" )
		plug:SetPos( pos )
		plug:SetAngles( ang )
		plug:SetColor( Color(255, 255, 255, 255) )
		plug:Spawn()
		
		local phys = plug:GetPhysicsObject()
			phys:EnableGravity( true )
			phys:EnableMotion( true )
			phys:SetVelocity(self:GetForward() * 50)
			phys:Wake()
		
		self.MyPlug = plug
		
		--Now we set the plug up and give it ropes
		self.MyPlug.is_plug = true
		self.MyPlug.MySocket = self
		self.MyPlug.TheirSocket = nil
		self.MyPlug.Weld = nil
		self.MyPlug:SetVar('Owner',self:GetPlayer())
		
		--self.nocollide = constraint.NoCollide( self, plug, 0, 0 )
		self.Hose, self.rope = constraint.Elastic( self, plug, 0, 0, LPos1, LPos2, 500, 0, 0, material, width, true )
		local ctable = {
			Type 		= "LSWinch",
			pl			= self:GetPlayer(),
			Ent1		= self,
			Ent2		= plug,
			Bone1		= Bone1,
			Bone2		= Bone2,
			LPos1		= LPos1,
			LPos2		= LPos2,
			width		= width,
			material	= material
		}
		self.rope.Type = "" --prevents the duplicator from making this weld
		--self.nocollide.Type = "" --prevents the duplicator from making this weld
		self.Hose:SetTable( ctable )
	
		plug:DeleteOnRemove( self.Hose )
		--plug:DeleteOnRemove( self.nocollide )
		self:DeleteOnRemove( self.Hose )
		self:DeleteOnRemove( self.MyPlug )
		--self.Hose:DeleteOnRemove( self.nocollide )
		self.Hose:DeleteOnRemove( self.rope )
	
		self.ropelength = 50
		self.ropemax = (self.hose_length*100)
	
		--print(type(self.Hose).." "..type(self.rope))
		if WireAddon then Wire_TriggerOutput(self, "Deployed", 1) end
	end
end

function ENT:Disconnect()
	if IsValid(self.MyPlug) then
		self:EmitSound( "Buttons.snd17" )
		self.ReelIn=true
	else
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	--If we have a plug out, lets do stuff
	if IsValid(self.MyPlug) then
		
		
		--First, some weld checking to make sure nothing disconnected
		if IsValid(self.MyPlug.TheirSocket) and not IsValid(self.MyPlug.Weld) then
			self.MyPlug.TheirSocket = nil
			self.Pumping = false
		end
		if IsValid(self.TheirPlug) and not IsValid(self.TheirPlug.Weld) then
			self.TheirPlug = nil
		end
		
			
		--See if we are connected to a socket
		if IsValid(self.MyPlug.TheirSocket) then
			self.Pumping = true
			--First see if we have the energy to power the pump
			local energyneeded = math.abs(math.floor(self.FlowRate / 100 * Energy_Increment))
			if energyneeded > 0 and self.FlowRate > 0 and self:GetResourceAmount("energy") >= energyneeded then
				if self:ConsumeResource( "energy", energyneeded ) == energyneeded then
					--We have power, send resources!
					for res,v in pairs(self.node.resources) do --actually send it
						if self.MyPlug.TheirSocket:GetNetworkCapacity(res) > (self.MyPlug.TheirSocket:GetResourceAmount(res) + self.FlowRate) then
							local amt = self:ConsumeResource(res, self.FlowRate)
							self.MyPlug.TheirSocket:SupplyResource(res, amt)	
						else
							local amt = self.MyPlug.TheirSocket:GetNetworkCapacity(res) - self.MyPlug.TheirSocket:GetResourceAmount(res)
							amt = self:ConsumeResource(res, amt)
							self.MyPlug.TheirSocket:SupplyResource(res, amt)	
						end	
					end
				end
			end
		else
			self.Pumping = false
		end
		
		--Not connected yet, lets play with the hoses!
		if not self.ReelIn and not self.Pumping then		
			local dist = (self:GetPos() - self.MyPlug:GetPos()):Length()
			if (self.ropelength <= self.ropemax) and (dist > self.ropelength - 32 ) then
				self.ropelength = self.ropelength + 50
				if (self.Hose and self.Hose:IsValid()) then
					self.Hose:Fire("SetSpringLength", self.ropelength, 0)
				else
					self.ropemax = 0
					self.ropelength = 0
				end
				if (self.rope and self.rope:IsValid()) then
					self.rope:Fire("SetLength", self.ropelength, 0)
				else
					self.ropemax = 0
					self.ropelength = 0
				end
			end
		elseif self.ReelIn then
			if IsValid(self.MyPlug.Weld) then
				self.MyPlug.Weld:Remove()
			end
			if (self.ropelength > 0) then
				if (self.ropelength > 200) then --reel in faster
					self.ropelength = self.ropelength - 20
				elseif (self.ropelength > 0) then
					self.ropelength = self.ropelength - 10
					if self.ropelength < 0 then self.ropelength = 0 end
				else
					self.ropelength = 0
				end
				if (self.Hose:IsValid() and self.rope:IsValid())then
					self.Hose:Fire("SetSpringLength", self.ropelength, 0)
					self.rope:Fire("SetLength", self.ropelength, 0)
				else
					self.ropelength = 0
				end
			else
				if IsValid(self.MyPlug) then self.MyPlug:Remove() end
				self.Hose = nil
				self.rope = nil
				self.MyPlug = nil
				self.ReelIn = false
				if WireAddon then Wire_TriggerOutput(self, "Deployed", 0) end
			end
		end
	elseif not IsValid(self.TheirPlug) then
		-- Search for plugs to attach to us
		local sockCenter = self:LocalToWorld( Vector(5,13,10) )
		local local_ents = ents.FindInSphere( sockCenter, PLUG_IN_ATTACH_RANGE )
		for key, plug in pairs(local_ents) do
			if not IsValid(self.TheirPlug) then	--skip if the last loop found a plug
				if IsValid(plug) and plug.is_plug and not IsValid(plug.TheirSocket) and plug:IsPlayerHolding() == false then --found a plug and not it's not in another socket --player isn't holding the plug spamming connections
					self:AttachPlug(plug)
				end
			end
		end
	end
	
	if IsValid(self.MyPlug) and IsValid(self.MyPlug.TheirSocket) then -- If we are connected, transfer resources
		if (self.OtherSocket and self.OtherSocket:IsValid()) then
			if self.pump_active == 1 then --pump it
				local energyneeded = math.abs(math.floor(256 / 100 * Energy_Increment))
				if (energyneeded >= 0) then
					if (self:GetResourceAmount("energy") >= energyneeded) then
						local used = self:ConsumeResource( "energy", energyneeded )
						self.OtherSocket.pump_status = PUMP_ACTIVE
					elseif (energyneeded > 0) then
						self.OtherSocket.pump_status = PUMP_NO_POWER
						rate = 0
					end
				end
			end
			if rate == 0 then return end
			for res,v in pairs(self.node.resources) do --actually send it
				if self.OtherSocket:GetNetworkCapacity(res) > (self.OtherSocket:GetResourceAmount(res) + self.FlowRate) then
					local amt = self:ConsumeResource(res, self.FlowRate)
					self.OtherSocket:SupplyResource(res, amt)	
				else
					local amt = self.OtherSocket:GetNetworkCapacity(res) - self.OtherSocket:GetResourceAmount(res)
					amt = self:ConsumeResource(res, amt)
					self.OtherSocket:SupplyResource(res, amt)	
				end	
			end
		end
	end
	
	if WireAddon then
		if self.Pumping or IsValid(self.TheirPlug) then
			Wire_TriggerOutput(self, "InUse", 1)
		else
			Wire_TriggerOutput(self, "InUse", 0)
		end
	end
	
	self:NextThink( CurTime() + 1 )
	return true
end

function ENT:AttachPlug(plug)
	if not IsValid(plug) then return end
	
	-- Set references between them
	self.TheirPlug = plug
	self.TheirPlug.TheirSocket = self
	
	-- Position plug
	local phys = plug:GetPhysicsObject()
		phys:EnableMotion( true )
		plug:SetPos( self:LocalToWorld( Vector(5,13,10) ) )
		plug:SetAngles( self:GetAngles() )
	phys:Wake() --force plug to update
	
	-- Constrain together
	self.Weld = constraint.Weld( self, plug, 0, 0, PLUG_IN_SOCKET_CONSTRAINT_POWER, true, false )
	self.Weld.Type = "" --prevents the duplicator from making this weld
	if not IsValid(self.Weld) then
		self.TheirPlug = nil
		self.TheirPlug.TheirSocket = nil
		return
	end
	self.TheirPlug.Weld = self.Weld
	
	-- Prepare clearup incase one is removed
	plug:DeleteOnRemove( self.Weld )
	self:DeleteOnRemove( self.Weld )
	
	if (self.TheirPlug.MySocket.Hose:IsValid() and self.TheirPlug.MySocket.rope:IsValid())then
		local dist = (self.TheirPlug:GetPos() - self.TheirPlug.MySocket:GetPos()):Length()
		self.TheirPlug.MySocket.ropelength = math.min(dist+100,self.TheirPlug.MySocket.ropemax)
		
		self.TheirPlug.MySocket.Hose:Fire("SetSpringLength", self.ropelength, 0)
		self.TheirPlug.MySocket.rope:Fire("SetLength", self.ropelength, 0)
	end
	
	if WireAddon then Wire_TriggerOutput(self, "InUse", 1) end
end

function ENT:AcceptInput(name,activator,caller)
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
		if not self.Receiving and not IsValid(self.MyPlug) then
			self:CreatePlug()
		elseif not self.ReelIn then
			self:Disconnect()
		end
	end
end

function ENT:TriggerInput(iname, value)
	if iname == "Toggle" then
		if not self.Toggled and value > 0 then
			if not self.Receiving and not IsValid(self.MyPlug) then
				self:CreatePlug()
				self.Toggled = true
			elseif not self.ReelIn then
				self:Disconnect()
				self.Toggled = true
			end
		elseif self.Toggled and value == 0 then
			self.Toggled = false
		end
	elseif iname=="FlowRate" then
		if value>0 then
			self.FlowRate = value
			if WireAddon then Wire_TriggerOutput(self, "Rate", self.FlowRate) end
		end
	end
end

function ENT:OnRemove()
	if IsValid(self.MyPlug) then
		self.MyPlug:Remove()
	end
	self.BaseClass.OnRemove(self)
end



duplicator.RegisterEntityClass("env_pump", Environments.DupeFix, "Data" )
