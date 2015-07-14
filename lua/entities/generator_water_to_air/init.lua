AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "apc_engine_stop" )

include('shared.lua')

local Energy_Increment = 75
local Water_Increment = 250
local Generator_Effect = 1 //Less than one means that this generator "leak" resources

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.overdrive = 0
	self.damaged = 0
	self.lastused = 0
	self.Mute = 0
	if WireAddon then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On", "Overdrive", "Mute", "Multiplier" })
	else
		self.Inputs = {{Name="On"},{Name="Overdrive"}}
	end
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self:PlayDeviceSound( "Airboat_engine_idle" )
		self.Active = 1
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
		self:SetOOO(0)
	end
end

function ENT:TurnOnOverdrive()
	if ( self.Active == 1 ) then
		self:StopDeviceSound( "Airboat_engine_idle" )
		self:PlayDeviceSound( "Airboat_engine_idle" )
		self:PlayDeviceSound( "apc_engine_start" )
		self:SetOOO(2)
		self.overdrive = 1
	end
end

function ENT:TurnOffOverdrive()
	if ( self.Active == 1 and self.overdrive == 1) then
		self:StopDeviceSound( "Airboat_engine_idle" )
		self:PlayDeviceSound( "Airboat_engine_idle" )
		self:StopDeviceSound( "apc_engine_start" )
		self:SetOOO(1)
		self.overdrive = 0
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

function ENT:Proc_Water()
	local energy = self:GetResourceAmount("energy")
	local water = self:GetResourceAmount("water")
	local einc = Energy_Increment + (self.overdrive*Energy_Increment)
	einc = (math.Round(einc * self:GetSizeMultiplier())) * self:GetMultiplier()
	local winc = Water_Increment + (self.overdrive*Water_Increment)
	winc = (math.Round(winc * self:GetSizeMultiplier())) * self:GetMultiplier()

	if (energy >= einc and water >= winc) then
		self:ConsumeResource("energy", einc)
		self:ConsumeResource("water", winc)
		
		winc = math.Round(winc * Generator_Effect)
		
		local supplyO2 = math.Round(winc/2)
		local leftO2 = self:SupplyResource("oxygen", supplyO2)
		
		local supplyH = winc*2
		local leftH = self:SupplyResource("hydrogen",supplyH)
		
		if self.environment then
			self.environment:Convert(-1, 0, leftO2)
			self.environment:Convert(-1, 3, leftH)
		end
		
		LDE.HeatSim.ApplyHeat(self,5 * self:GetSizeMultiplier())
	else
		self:TurnOff()
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if ( self.Active == 1 ) then self:Proc_Water() end
	
	self:NextThink( CurTime() + 1 )
	return true
end

