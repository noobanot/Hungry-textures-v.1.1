AddCSLuaFile()

ENT.Type 		= "anim"
ENT.Base 		= "base_env_entity"
ENT.PrintName 	= "Atmospheric Probe"
ENT.Author			= "Ludsoe"
ENT.Category		= "Environments"

ENT.Spawnable		= false
ENT.AutomaticFrameAdvance = true

util.PrecacheSound( "Buttons.snd17" )
list.Set( "LSEntOverlayText" , "env_probe", {HasOOO = true, resnames ={"energy"} } )

if(SERVER)then
	
	local T = {} --Create a empty Table
	
	T.Power = function(Device,ply,Data)
		Device:SetActive( nil, ply )
	end
	
	ENT.Panel=T --Set our panel functions to the table.
	
else 
	function ENT:PanelFunc(um,e,entID)
	
		e.Functions={}
		
		e.DevicePanel = [[
		@<Button>Toggle Power</Button><N>PowerButton</N><Func>Power</Func>
		]]

		e.Functions.Power = function()
			RunConsoleCommand( "envsendpcommand",entID,"Power")
		end
	end
end

if(SERVER)then
	local Energy_Increment = 1
	local BeepCount = 3
	local running = 0
	
	function ENT:SpawnFunction(ply, tr) -- Spawn function needed to make it appear on the spawn menu
		local ent = ents.Create("env_probe") -- Create the entity
		ent:SetPos(tr.HitPos + Vector(0, 0, 1) ) -- Set it to spawn 50 units over the spot you aim at when spawning it
		ent:SetModel("models/props_combine/combine_mine01.mdl")
		ent:Spawn() -- Spawn it
	 
		return ent -- You need to return the entity to make it work
	end
 
	function ENT:Initialize()
		self.Active = 0
		self.damaged = 0
				
		if not (WireAddon == nil) then
			self.WireDebugName = self.PrintName
			self.Inputs = Wire_CreateInputs(self, { "On" })
			self.Outputs = Wire_CreateOutputs(self, { "O2 Level", "CO2 Level", "Nitrogen Level", "Hydrogen Level", "Pressure", "Temperature", "Gravity", "On" })
		else
			self.Inputs = {{Name="On"}}
		end
		
		self.ActAnim = self.Entity:LookupSequence("activate") -- Activate
		self.DeactAnim = self.Entity:LookupSequence("deactivate") -- Deactivate
		self.IdleAnim = self.Entity:LookupSequence("idle") -- Idle ( do nothin? )
		self.RunAnim = self.Entity:LookupSequence("run") -- simple pumping animation
		
		self.BaseClass.Initialize(self)
	end

	function ENT:AcceptInput(name,activator,caller)
		if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
			self:SetActive( nil, caller )
		end
	end

	function ENT:TurnOn()
		self:EmitSound( "Buttons.snd17" )
		self.Active = 1
		self:SetOOO(1)
		self:Sense()
		self:ShowOutput()
		if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", 1) end

		self:AnimateCorePlay(self.ActAnim)
		timer.Simple(0.01,function() if not IsValid(self)then return end self:AnimateCorePlay(self.RunAnim) end)
	end

	function ENT:TurnOff(warn)
		if (!warn) then self:EmitSound( "Buttons.snd17" ) end
		self.Active = 0
		self:SetOOO(0)
		self:ShowOutput()
		if not (WireAddon == nil) then
			Wire_TriggerOutput(self, "On", 0)
			Wire_TriggerOutput(self, "O2 Level", 0)
			Wire_TriggerOutput(self, "CO2 Level", 0)
			Wire_TriggerOutput(self, "Nitrogen Level", 0)
			Wire_TriggerOutput(self, "Hydrogen Level", 0)
			Wire_TriggerOutput(self, "Pressure", 0)
			Wire_TriggerOutput(self, "Temperature", 0)
			Wire_TriggerOutput(self, "Gravity", 0)
		end
		
		self:AnimateCorePlay(self.DeactAnim)
		timer.Simple(0.01,function() if not IsValid(self)then return end self:AnimateCorePlay(self.IdleAnim) end)
	end

	function ENT:TriggerInput(iname, value)
		if (iname == "On") then
			self:SetActive( value )
		end
	end

	function ENT:Sense()
		if self:GetResourceAmount("energy") <= 0 then
			self:EmitSound( "common/warning.wav" )
			self:TurnOff(true)
			return
		else
			if (BeepCount > 0) then
				BeepCount = BeepCount - 1
			else
				self:EmitSound( "Buttons.snd17" )
				BeepCount = 200 --30 was a little long, 3 times a minute is ok
			end
		end
		if not (WireAddon == nil) then
			if self.environment then
				Wire_TriggerOutput(self, "O2 Level", self.environment:GetO2Percentage())
				Wire_TriggerOutput(self, "CO2 Level", self.environment:GetCO2Percentage())
				Wire_TriggerOutput(self, "Nitrogen Level", self.environment:GetNPercentage())
				Wire_TriggerOutput(self, "Hydrogen Level", self.environment:GetHPercentage())
				Wire_TriggerOutput(self, "Pressure", self.environment:GetPressure())
				Wire_TriggerOutput(self, "Temperature", self.environment:GetTemperature(self))
				Wire_TriggerOutput(self, "Gravity", self.environment.gravity or 0)
			end
		end
		self:ConsumeResource("energy", Energy_Increment)
	end

	function ENT:ShowOutput()
		self:SetNetworkedInt( 1, self.environment:GetO2Percentage() or 0 )
		self:SetNetworkedInt( 2, self.environment:GetCO2Percentage() or 0)
		self:SetNetworkedInt( 3, self.environment:GetNPercentage() or 0 )
		self:SetNetworkedInt( 4, self.environment:GetHPercentage() or 0)
		self:SetNetworkedInt( 5, self.environment:GetPressure() or 0)
		self:SetNetworkedInt( 6, self.environment:GetTemperature(self) or 0)
		self:SetNetworkedInt( 7, self.environment:GetGravity() or 0)
		self:SetNetworkedString( 8, self.environment:GetEnvironmentName() or "")
	end
	
	function ENT:Think()
		self.BaseClass.Think(self)
		
		if self.NextSense or 0 <= CurTime() then
			if (self.Active == 1) then
				self:Sense()
				self:ShowOutput()
			end
			self.NextSense = CurTime()+0.5
		end
		
		self:AnimateThink()
		
		self:NextThink(CurTime() + 0.001)
		
		return true
	end
else
	function ENT:ExtraData(Info)
		if self:GetOOO() == 1 then
			table.insert(Info,{Type="Label",Value="Environment Info:"})
			table.insert(Info,{Type="Label",Value="Name:"..tostring(self:GetNetworkedString(8))})
			table.insert(Info,{Type="Label",Value="O2 Level: " .. string.format("%g",self:GetNetworkedInt( 1 )).."%"})
			table.insert(Info,{Type="Label",Value="CO2 Level: " .. string.format("%g",self:GetNetworkedInt( 2 )).."%"})
			table.insert(Info,{Type="Label",Value="Nitrogen Level: " .. string.format("%g",self:GetNetworkedInt( 3 )).."%"})
			table.insert(Info,{Type="Label",Value="Hydrogen Level: " .. string.format("%g",self:GetNetworkedInt( 4 )).."%"})
			table.insert(Info,{Type="Label",Value="Pressure: " .. tostring(self:GetNetworkedInt( 5 ))})
			table.insert(Info,{Type="Label",Value="Temperature: " .. tostring(self:GetNetworkedInt( 6 ))})
			table.insert(Info,{Type="Label",Value="Gravity: " .. tostring(self:GetNetworkedInt( 7 ))})
			return true
		end
		return false 
	end -- This Appears after the resources.
end		
