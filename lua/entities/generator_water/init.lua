AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "Airboat_engine_idle" )
util.PrecacheSound( "Airboat_engine_stop" )
util.PrecacheSound( "apc_engine_start" )
include('shared.lua')
local Pressure_Increment = 80
local Energy_Increment = 10

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.overdrive = 0
	self.damaged = 0
	self.lastused = 0
	self.sequence = -1
	self.thinkcount = 0
	
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	
	self.Mute = 0
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On", "Overdrive", "Mute", "Multiplier" })
		self.Outputs = Wire_CreateOutputs(self, {"On", "Overdrive", "EnergyUsage", "WaterProduction" })
	else
		self.Inputs = {{Name="On"},{Name="Overdrive"}}
	end
end

function ENT:TurnOn()
	if (self.Active == 0) then
	
		self:PlayDeviceSound( "Airboat_engine_idle" )
		
		self.Active = 1
		if WireAddon then Wire_TriggerOutput(self, "On", self.Active) end
		--self.sequence = self.Entity:LookupSequence("walk")
		if self.sequence and self.sequence != -1 then
			self:SetSequence(self.sequence)
			self:ResetSequence(self.sequence)
			self:SetPlaybackRate( 1 )
		end
		self:SetOOO(1)
	elseif ( self.overdrive == 0 ) then
		self:TurnOnOverdrive()
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
	
		self:StopDeviceSound( "Airboat_engine_idle" )
		self:PlayDeviceSound( "Airboat_engine_stop" )
		self:StopDeviceSound( "apc_engine_start" )
		
		self.Active = 0
		self.overdrive = 0
		if WireAddon then Wire_TriggerOutput(self, "On", self.Active) end
		self:SetOOO(0)
		--self.sequence = self.Entity:LookupSequence("idle")
		if self.sequence and self.sequence != -1 then
			self:SetSequence(self.sequence)
			self:ResetSequence(self.sequence)
			self:SetPlaybackRate( 1 )
		end
	end
end

function ENT:TurnOnOverdrive()
	if ( self.Active == 1 ) then
	
		self:StopDeviceSound( "Airboat_engine_idle" )
		self:PlayDeviceSound( "Airboat_engine_idle" )
		self:PlayDeviceSound( "apc_engine_start" )
			
		self:SetOOO(2)
		self.overdrive = 1
		if WireAddon then Wire_TriggerOutput(self, "Overdrive", self.overdrive) end
	end
end

function ENT:TurnOffOverdrive()
	if ( self.Active == 1 and self.overdrive == 1) then
		self:StopDeviceSound( "Airboat_engine_idle" )
		self:PlayDeviceSound( "Airboat_engine_idle" )
		self:StopDeviceSound( "apc_engine_start" )
		
		self:SetOOO(1)
		self.overdrive = 0
		if WireAddon then Wire_TriggerOutput(self, "Overdrive", self.overdrive) end
	end	
end

function ENT:SetActive( value )
	if (value) then
		if (value != 0 and self.Active == 0 ) then
			self:TurnOn()
		elseif (value == 0 and self.Active == 1 ) then
			self:TurnOff()
		end
	else
		if ( self.Active == 0 ) then
			self.lastused = CurTime()
			self:TurnOn()
		else
			if ((( CurTime() - self.lastused) < 2 ) and ( self.overdrive == 0 )) then
				self:TurnOnOverdrive()
			else
				self.overdrive = 0
				self:TurnOff()
			end
		end
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	elseif (iname == "Overdrive") then
		if (value ~= 0) then
			self:TurnOnOverdrive()
		else
			self:TurnOffOverdrive()
		end
	end
	if (iname == "Mute") then
		if (value > 0) then
			self:SetDeviceMute(1)
		else
			self:SetDeviceMute(0)
		end
	end
	if (iname == "Multiplier") then
		self:SetMultiplier(value)
	end
end

function ENT:Pump_Water()
	local energy = self:GetResourceAmount("energy")
	local einc = Energy_Increment + (self.overdrive*Energy_Increment*3)
	local waterlevel = 0
	waterlevel = self:WaterLevel()

	einc = (math.ceil(einc * self:GetSizeMultiplier())) * self:GetMultiplier()
	if WireAddon then Wire_TriggerOutput(self, "EnergyUsage", math.Round(einc)) end
	if (waterlevel > 0 and energy >= einc) then //seems to be problem when welding(/freezing when not with CAF)
		local winc = (math.ceil(Pressure_Increment * (waterlevel / 3))) * self:GetMultiplier() --Base water generation on the amount it is in the water
		
		if ( self.overdrive == 1 ) then
			winc = winc * 3
			einc = einc * 2
		end
		winc = math.ceil(winc * self:GetSizeMultiplier())
		self:ConsumeResource("energy", einc)
		self:SupplyResource("water", winc)
		if WireAddon then Wire_TriggerOutput(self, "WaterProduction", math.Round(winc)) end
	else
		self:TurnOff()
	end
end

function ENT:Think()
	self.BaseClass.Think(self)

	if ( self.Active == 1 ) then self:Pump_Water() end

	self:NextThink( CurTime() + 1 )
	return true
end

