AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

util.PrecacheSound( "explode_9" )
util.PrecacheSound( "ambient/levels/labs/electric_explosion4.wav" )
util.PrecacheSound( "ambient/levels/labs/electric_explosion3.wav" )
util.PrecacheSound( "ambient/levels/labs/electric_explosion1.wav" )
util.PrecacheSound( "ambient/explosions/exp2.wav" )
util.PrecacheSound( "k_lab.ambient_powergenerators" )
util.PrecacheSound( "ambient/machines/thumper_startup1.wav" )
util.PrecacheSound( "coast.siren_citizen" )
util.PrecacheSound( "common/warning.wav" )

include('shared.lua')
-- Was 2200, increased
local Energy_Increment = 5000
local Coolant_Increment = 100 --WATER NOW -- 15 nitrogen produced per 150 energy, so 45 is about 450 energy , 2000 - 450 = 1550 energy left - the requirements to generate the N
local HW_Increment = 1

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.Active = 0
	self.damaged = 0
	self.critical = 0
	self.hwcount = 0
	self.time = 0
	if WireLib then
		self.WireDebugName = self.PrintName
		self.Inputs = WireLib.CreateInputs(self, { "On" })
		self.Outputs = WireLib.CreateOutputs(self, { "On", "Output" })
	else
		self.Inputs = {{Name="On"}}
	end
end

function ENT:TurnOn()
	if (self.Active == 0) then
		self.Active = 1
		self:PlayDeviceSound( "k_lab.ambient_powergenerators" )
		self:PlayDeviceSound( "ambient/machines/thumper_startup1.wav" )
		if WireLib then WireLib.TriggerOutput(self, "On", 1) end
		self:SetOOO(1)
	end
end

function ENT:TurnOff()
	if (self.Active == 1) then
		self.Active = 0
		self:StopDeviceSound( "k_lab.ambient_powergenerators" )
		self:StopDeviceSound( "coast.siren_citizen" )
		if WireLib then 
			WireLib.TriggerOutput(self, "On", 0)
			WireLib.TriggerOutput(self, "Output", 0)
		end
		self:SetOOO(0)
	end
end

function ENT:TriggerInput(iname, value)
	if (iname == "On") then
		self:SetActive(value)
	end
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self:SetColor(Color(255, 255, 255, 255))
	self.damaged = 0
	self.critical = 0
	self:StopDeviceSound( "coast.siren_citizen" )
end

function ENT:Extract_Energy()
	local inc = Energy_Increment
	
	if (self.critical == 1) then
		local ang = self:GetAngles()
		local pos = (self:GetPos() + (ang:Up() * self:BoundingRadius()))
		local test = math.random(1, 10)
		zapme = Environments.ZapMe
		if (test <= 2) then
			if zapme then
				zapme((pos + (ang:Right() * 90)), 5)
				zapme((pos - (ang:Right() * 90)), 5)
			end
			self:PlayDeviceSound( "ambient/levels/labs/electric_explosion3.wav" )
			inc = 0
		elseif (test <= 4) then
			if zapme then
				zapme((pos + (ang:Right() * 90)), 3)
				zapme((pos - (ang:Right() * 90)), 3)
			end
			self:PlayDeviceSound( "ambient/levels/labs/electric_explosion4.wav" )
			inc = math.ceil(inc / 4)
		elseif (test <= 6) then
			if zapme then
				zapme((pos + (ang:Right() * 90)), 2)
				zapme((pos - (ang:Right() * 90)), 2)
			end
			self:PlayDeviceSound( "ambient/levels/labs/electric_explosion1.wav" )
			inc = math.ceil(inc / 2)
		end
	end
	
	
	local HeatAmount = 10 * self:GetSizeMultiplier()
	local required_water = math.ceil(Coolant_Increment * self:GetSizeMultiplier())
	if self:GetResourceAmount("water") < required_water then
		if (self.critical == 0) then
			if self.time > 3 then 
				self:PlayDeviceSound( "common/warning.wav" )
				self.time = 0
			else
				self.time = self.time + 1
			end
		else
			if self.time > 1 then 
				self:StopDeviceSound( "coast.siren_citizen" )
				self:PlayDeviceSound( "coast.siren_citizen" )
				self.time = 0
			else
				self.time = self.time + 1
			end
		end

		--only supply 5-25% of the normal amount
		if (inc > 0) then inc = math.ceil(inc/math.random(12 - math.ceil(8 * ( self:GetResourceAmount("water")/math.ceil(Coolant_Increment * self:GetSizeMultiplier()))),20)) end
	else
		local consumed = self:ConsumeResource("water", required_water)
		--self:SupplyResource("steam", math.ceil(consumed * 0.92))
		self:SupplyResource("water", math.ceil(consumed * 0.08))
		HeatAmount=HeatAmount/2 --Properly Cooled fusion reactors generate less excess heat.
	end
	
	LDE.HeatSim.ApplyHeat(self,HeatAmount)
	
	--the money shot!
	if (inc > 0) then 
		inc = math.ceil(inc * self:GetSizeMultiplier())
		self:SupplyResource("energy", inc)
	end
	if WireLib then WireLib.TriggerOutput(self, "Output", inc) end
end

function ENT:Leak() --leak cause this is like with storage, make be it could leak radation?
	if self:GetResourceAmount("energy") >= 500*self:GetSizeMultiplier() then
		if self.critical == 0 then
			self.critical = 1 
		end
	else
		if self.critical == 1 then
			self:StopDeviceSound( "coast.siren_citizen" )
			self.critical = 0
		end
	end
end

function ENT:Think()
	self.BaseClass.Think(self)
	
	if (self.Active == 1) then
		self:Extract_Energy()
	end
	
	if (self.damaged == 1) then
		self:Leak()
	end
	
	self:NextThink(CurTime() + 1)
	return true
end

