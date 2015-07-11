AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

util.PrecacheSound( "Buttons.snd17" )

include('shared.lua')

local Energy_Increment = 4
local BeepCount = 3
local running = 0

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.damaged = 0
	if not (WireAddon == nil) then
		self.WireDebugName = self.PrintName
		self.Inputs = Wire_CreateInputs(self, { "On" })
		self.Outputs = Wire_CreateOutputs(self, { "O2 Level", "CO2 Level", "Nitrogen Level", "Hydrogen Level", "Pressure", "Temperature", "Gravity", "On" })
	else
		self.Inputs = {{Name="On"}}
	end
	--self:ShowOutput()
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
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive( value )
	end
end

function ENT:Sense()
	if (self:GetResourceAmount("energy") <= 0) then
		self:EmitSound( "common/warning.wav" )
		self:TurnOff(true)
		return
	else
		if (BeepCount > 0) then
			BeepCount = BeepCount - 1
		else
			self:EmitSound( "Buttons.snd17" )
			BeepCount = 20 --30 was a little long, 3 times a minute is ok
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
	
	if (self.Active == 1) then
		self:Sense()
		self:ShowOutput()
	end
	
	self:NextThink(CurTime() + 1)
	return true
end

