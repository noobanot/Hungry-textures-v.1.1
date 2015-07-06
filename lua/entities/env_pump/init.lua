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
	self.Weld = nil
	self.FlowRate = 256	--Default
	self.Toggled = false
	self.ReelIn = false
	self.AttachStep = 0
	self.InUse = false
	self.AttachCooldown = CurTime()
end

function ENT:Setup( pump, rate, hoselength )		--for the toolgun
	--self.pump_active = pump or true
	self.FlowRate = rate or 256
	self.hose_length = hoselength or 512
	
	if WireAddon then Wire_TriggerOutput(self, "Rate", self.FlowRate) end
	self:SupplyResource("energy", 0)
end

function ENT:CreateHose()
	if not IsValid(self.MyPlug) then return end
	if IsValid(self.Hose) then self.Hose:Remove() end
	if IsValid(self.rope) then self.rope:Remove() end
	
	local LPos1 = Vector(5,13,10)
	local LPos2 = Vector(10,0,0)
	local width = 3
	local material = "cable/cable2"
		
	self.Hose, self.rope = constraint.Elastic( self, self.MyPlug, 0, 0, LPos1, LPos2, 500, 0, 0, material, width, true )
		local ctable = {
			Type 		= "LSWinch",
			pl			= self:GetPlayer(),
			Ent1		= self,
			Ent2		= self.MyPlug,
			Bone1		= Bone1,
			Bone2		= Bone2,
			LPos1		= LPos1,
			LPos2		= LPos2,
			width		= width,
			material	= material
		}
		self.rope.Type = "" --prevents the duplicator from making this weld
		self.Hose:SetTable( ctable )
		self.MyPlug:DeleteOnRemove( self.Hose )
		self:DeleteOnRemove( self.Hose )
		self.Hose:DeleteOnRemove( self.rope )
		
		local dist = (self.MyPlug:GetPos() - self:GetPos()):Length()
		self.ropelength = math.min(dist+50,self.ropemax)
		
		self.Hose:Fire("SetSpringLength", self.ropelength, 0)
		self.rope:Fire("SetLength", self.ropelength, 0)
		--self.ropemax = (self.hose_length*100)
		
		--print(type(self.Hose).." "..type(self.rope))
end

function ENT:CreatePlug()
	if not IsValid(self.Weld) and not IsValid(self.MyPlug) then
		
		self:EmitSound( "Buttons.snd17" )
		
		--First, we create the plug at a local position
		local LPos1 = Vector(5,13,10)
		local LPos2 = Vector(10,0,0)
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
			phys:SetVelocity(self:GetForward() * 10)
			phys:Wake()
		
		self.MyPlug = plug
		
		--Now we set the plug up and give it a hose
		self.MyPlug.is_plug = true
		self.MyPlug.MySocket = self
		self.MyPlug.TheirSocket = nil
		self.MyPlug.Weld = nil
		self.MyPlug:SetVar('Owner',self:GetPlayer())
		
		self:DeleteOnRemove( self.MyPlug )
		
		self:CreateHose()
		
		--self.nocollide = constraint.NoCollide( self, plug, 0, 0 )
		--self.nocollide.Type = "" --prevents the duplicator from making this weld
		--plug:DeleteOnRemove( self.nocollide )
		--self.Hose:DeleteOnRemove( self.nocollide )

		if WireAddon then Wire_TriggerOutput(self, "Deployed", 1) end
	end
end

function ENT:Disconnect()
	self:EmitSound( "Buttons.snd17" )
	--First, check if we have a plug attached to us, if yep, remove
	local weldremoved = false
	if IsValid(self.Weld) then
		self.Weld:Remove()
		weldremoved = true
	end
		
	--Next, see if their plug exists
	if IsValid(self.TheirPlug) then
			--if we removed a weld, kick plug away
			if weldremoved then
				local phys = self.TheirPlug:GetPhysicsObject()
				phys:EnableGravity( true )
				phys:EnableMotion( true )
				phys:SetVelocity(self:GetForward() * 10)
				phys:Wake()
			end
				
			--Set variables so they don't see us and we don't see them
			self.TheirPlug.TheirSocket = nil
			self.TheirPlug = nil
			self.AttachCooldown = CurTime()+1
		
	--No plug detected, lets see if we have our own plug out and bring it in
	elseif IsValid(self.MyPlug) then
		self.ReelIn=true
	end
end

function ENT:PumpCheck()
	if IsValid(self.MyPlug) and IsValid(self.MyPlug.TheirSocket) then -- If we are connected, try to transfer resources
		if IsValid(self.MyPlug.Weld) and IsValid(self.node) then
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
		end
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	--Weld checking, if we see their plug but don't see their weld, run disconnect
	if IsValid(self.TheirPlug) and (not IsValid(self.TheirPlug.Weld) or not IsValid(self.Weld)) and self.AttachStep==0 then self:Disconnect() end
	
	--If we have a plug out, lets do stuff
	if IsValid(self.MyPlug) then
		
		-- First, if we have a plug out and it was disconnected from a socket, make sure other socket cleaned up variables
		if IsValid(self.MyPlug.TheirSocket) and not IsValid(self.MyPlug.Weld) then
			self.MyPlug.TheirSocket = nil
		end
		
		self:PumpCheck() --Pump Resources if we can
		
		--Not connected yet, lets play with the hoses!
		if not self.ReelIn and not IsValid(self.MyPlug.Weld) and self.AttachStep == 0 then		
			local dist = (self:GetPos() - self.MyPlug:GetPos()):Length()
			if (self.ropelength <= self.ropemax) and (dist > self.ropelength - 32 ) then
				self.ropelength = self.ropelength + 100
				if IsValid(self.Hose) then
					self.Hose:Fire("SetSpringLength", self.ropelength, 0)
				else
					self.ropemax = 0
					self.ropelength = 0
				end
				if IsValid(self.rope) then
					self.rope:Fire("SetLength", self.ropelength, 0)
				else
					self.ropemax = 0
					self.ropelength = 0
				end
			end
		elseif self.ReelIn and self.AttachStep == 0 then
			if IsValid(self.MyPlug.Weld) then
				self.MyPlug.Weld:Remove()
			end
			if (self.ropelength > 0) then
				if (self.ropelength > 80) then --reel in faster
					self.ropelength = self.ropelength - 40
				elseif (self.ropelength > 0) then
					self.ropelength = self.ropelength - 20
					if self.ropelength < 0 then self.ropelength = 0 end
				else
					self.ropelength = 0
				end
				if IsValid(self.Hose) and IsValid(self.rope) then
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
	
	if WireAddon then
		local validmyplug = IsValid(self.MyPlug)
		local validtheirplug = IsValid(self.TheirPlug)
		if (validmyplug or validtheirplug) and not self.InUse then
			Wire_TriggerOutput(self, "InUse", 1)
			self.InUse = true
		elseif not validmyplug and not validtheirplug and self.InUse then
			Wire_TriggerOutput(self, "InUse", 0)
			self.InUse = false
		end
	end
	
	self:NextThink( CurTime() + 1 )
	return true
end

function ENT:AttachPlug(plug)
	if not IsValid(plug) or self.AttachCooldown >= CurTime() then return end
	if IsValid(self.MyPlug) then
		if plug == self.MyPlug then return end
	end
	
	if self.AttachStep==0 then
		--First, set variables so we know we have a plug we're working with and so their plug can see us
		self.TheirPlug = plug
		self.TheirPlug.TheirSocket = self
		
		--Next, delete their hose so it doesn't break things later
		if IsValid(self.TheirPlug.MySocket.Hose) then self.TheirPlug.MySocket.Hose:Remove() end
		if IsValid(self.TheirPlug.MySocket.rope) then self.TheirPlug.MySocket.rope:Remove() end
		
		--Now we create a delay before moving the pump, so the physics engine will ignore the hose and not rip a hole in time space, then rerun ourselves
		self.AttachStep=1
		timer.Simple(0.15,function() self:AttachPlug(plug) end)
		return
		
	elseif self.AttachStep==1 then
		--Second run, now we can safely move and attach the plug
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
		
	
		-- Prepare cleanup incase one is removed
		plug:DeleteOnRemove( self.Weld )
		self:DeleteOnRemove( self.Weld )
		
		--Now we create a delay again, so we can tell them to remake their hose
		self.AttachStep=2
		timer.Simple(0.15,function() self:AttachPlug(plug) end)
		return
		
	elseif self.AttachStep==2 then
		--Last run, tell them to remake their hose and run away before something breaks again
		if not IsValid(self.TheirPlug.MySocket) then
			timer.Simple(0.15,function() self:AttachPlug(plug) end)
			return
		end
		self.AttachStep=0
		self.TheirPlug.MySocket:CreateHose()
		if WireAddon then Wire_TriggerOutput(self, "InUse", 1) end
	end
	
	--[[if (self.TheirPlug.MySocket.Hose:IsValid() and self.TheirPlug.MySocket.rope:IsValid())then
		local dist = (self.TheirPlug:GetPos() - self.TheirPlug.MySocket:GetPos()):Length()
		self.TheirPlug.MySocket.ropelength = math.min(dist+100,self.TheirPlug.MySocket.ropemax)
		
		self.TheirPlug.MySocket.Hose:Fire("SetSpringLength", self.ropelength, 0)
		self.TheirPlug.MySocket.rope:Fire("SetLength", self.ropelength, 0)
	end]]--	
	
end

function ENT:AcceptInput(name,activator,caller)
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
		if self.ReelIn then
			self.ReelIn = false
		elseif not IsValid(self.Weld) and not IsValid(self.MyPlug) then
			self:CreatePlug()
		elseif not self.ReelIn then
			self:Disconnect()
		end
	end
end

function ENT:TriggerInput(iname, value)
	if iname == "Toggle" then
		if not self.Toggled and value > 0 then
			if self.ReelIn then
				self.ReelIn = false
			elseif not IsValid(self.Weld) and not IsValid(self.MyPlug) then
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

function ENT:Touch( plug )
	if not IsValid(self.TheirPlug) then	--skip if we have a plug already
		if IsValid(plug) and plug.is_plug and not IsValid(plug.TheirSocket) and plug:IsPlayerHolding() == false then --found a plug and not it's not in another socket --player isn't holding the plug spamming connections
			self:AttachPlug(plug)
		end
	end
end



duplicator.RegisterEntityClass("env_pump", Environments.DupeFix, "Data" )
