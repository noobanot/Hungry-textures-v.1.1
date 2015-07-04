
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
