
--Hull Repairer
local Func = function(self) if(self.Active==1)then
	local core = self.LDE.Core
	if(not core or not core:IsValid())then self.LDE.Core = nil return end
	local ore = self:GetResourceAmount("Refined Ore")
	local needed = core.LDE.CoreMaxHealth-core.LDE.CoreHealth
	if(needed>=100)then oreuse=100 else oreuse=needed end
	if(ore>=math.abs((oreuse)*(self:GetSizeMultiplier() or 1)) and oreuse>0) then
		self:ConsumeResource("Refined Ore", math.abs((oreuse)*(self:GetSizeMultiplier() or 1)))
		LDE:RepairCoreHealth( core, (oreuse*10)*(self:GetSizeMultiplier() or 1) )
		WireLib.TriggerOutput( core, "Health", core.LDE.CoreHealth)	
	end end end
local Data={name="Hull Repairer",class="lde_repair",In={"Refined Ore"},shootfunc=Func,InUse={0}}
LDE.LifeSupport.RegisterDevice(Data)

--Shield Recharger
local Func = function(self) 
	if(self.Active==1)then
		if not self.LDE then return end
		local core = self.LDE.Core
		if not core or not IsValid(core) then 
			self.LDE.Core = nil 
			return 
		end
		
		if core.LDE.CanRecharge==0 then return end
		
		local needed = core.LDE.CoreMaxShield-core.LDE.CoreShield
		local rechargerate = math.abs(100*self:GetSizeMultiplier()*self:GetMultiplier())
		local energycost = 1
		
		local recharge = 0
		
		if needed>=rechargerate then recharge=rechargerate else recharge=needed end

		if self:GetResourceAmount("energy")>=math.abs(rechargerate*energycost) and needed>0 then
			WireLib.TriggerOutput( core, "Shields", core.LDE.CoreShield)	
			self:ConsumeResource("energy", rechargerate)
			core.LDE.CoreShield = math.Clamp(core.LDE.CoreShield+rechargerate,0,core.LDE.CoreMaxShield)
			core:SetNWInt("LDEShield", core.LDE.CoreShield)
			WireLib.TriggerOutput( core, "Shields", core.LDE.CoreShield or 0 )
		end 
	end 
end

local Data={name="Shield Recharger",class="lde_recharge",In={"energy"},shootfunc=Func,InUse={0}}
LDE.LifeSupport.RegisterDevice(Data)

Environments.RegisterDevice("Ship Utilities", "Hull Repairer"," Small Repairer", "lde_repair", "models/gibs/airboat_broken_engine.mdl")
Environments.RegisterDevice("Ship Utilities", "Shield Rechargers","Small Charger", "lde_recharge", "models/slyfo_2/acc_sci_coolerator.mdl")

--Heater
local Cool_Rate = 400
local Func = function(self)
	local entcore = self.LDE.Core
	if not entcore or not IsValid(entcore) then	
		self:TurnOff()
	else
		self:TurnOn()
	end
	
	if(self.Active==1)then
		local core = self.LDE.Core
		local water = self:GetResourceAmount("energy")
		local rate = Cool_Rate*self:GetSizeMultiplier()
		if(core.LDE.CoreTemp<rate)then wateruse=rate else wateruse=0 end
		if(water>=math.abs(wateruse) and wateruse<0) then
			WireLib.TriggerOutput( core, "Temperature", core.LDE.CoreTemp)	
			self:ConsumeResource("energy", math.abs(wateruse))
			core.LDE.CoreTemp=core.LDE.CoreTemp+math.abs(wateruse)
		end
	end 
end

local Data={name="Core Temperature Heater",class="lde_heater",In={"energy"},shootfunc=Func,InUse={0}}
LDE.LifeSupport.RegisterDevice(Data)

Environments.RegisterDevice("Ship Utilities", "Heat Management","Basic Heater", "lde_heater", "models/gibs/airboat_broken_engine.mdl")

--Radiator
local Water_Increment = 8 --40 before  --randomize for weather
local Cool_Rate = 40

local Func = function(self)
	self.LDE=self.LDE or {}
	
	local node = self.node
	local core = self.LDE.Core
	
	local water = self:GetResourceAmount("water")
	local Rate = Cool_Rate*self:GetSizeMultiplier()
		
	if not core or not IsValid(core) then
		if node and IsValid(node) then
			self:TurnOn()
			for k,v in pairs(node.connected) do
				if v and v:IsValid() then
					if(not v.LDE)then return end --Wot.... why isnt there a lde
					v.LDE.Temperature = v.LDE.Temperature or 0
					if(v.LDE.Temperature>0)then
						if(v.LDE.Temperature<Rate) then
							Rate=v.LDE.Temperature
						end
						if(water>=Rate and Rate>0) then
							self:ConsumeResource("water", Rate)
							self:SupplyResource("steam",math.Round(Rate/2.5))
							LDE.HeatSim.SetTemperature(v,-Rate)
						end
					end
				end
			end
		else
			self:TurnOff()
		end
	else
		local Rate = Rate*core.Data.CoolBonus
		if(core.LDE.CoreTemp<Rate) then Rate=core.LDE.CoreTemp end
		if(water>=Rate and Rate>0) then
			self:TurnOn()
			WireLib.TriggerOutput( core, "Temperature", core.LDE.CoreTemp or 0 )	
			self:ConsumeResource("water", Rate)
			self:SupplyResource("steam",math.Round(Rate/2.5))
			core.LDE.CoreTemp=core.LDE.CoreTemp-Rate
		else
			self:TurnOff()
		end
	end
end

local Data={name="Core Temperature Heater",class="lde_radiator",In={"energy"},shootfunc=Func,InUse={0}}
LDE.LifeSupport.RegisterDevice(Data)

Environments.RegisterDevice("Ship Utilities", "Heat Management","Basic Radiator", "lde_radiator", "models/props_c17/furnitureradiator001a.mdl")
Environments.RegisterDevice("Ship Utilities", "Heat Management","Cyclic Radiator", "lde_radiator", "models/Slyfo/sat_rfg.mdl")
Environments.RegisterDevice("Ship Utilities", "Heat Management","Singularity Radiator", "lde_radiator", "models/Slyfo/crate_reactor.mdl")
