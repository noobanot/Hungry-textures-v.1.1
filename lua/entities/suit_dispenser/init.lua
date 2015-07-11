AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
util.PrecacheSound( "ambient.steam01" )

include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.damaged = 0
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	if WireAddon then
		self.WireDebugName = self.PrintName
	end
	self.Inputs = Wire_CreateInputs(self.Entity, { "Lock" })
	self.Locked = false
end

function ENT:Damage()
	if (self.damaged == 0) then self.damaged = 1 end
end

function ENT:Repair()
	self.BaseClass.Repair(self)
	self.damaged = 0
end

function ENT:AcceptInput(name,activator,caller)
	if name == "Use" and caller:IsPlayer() and caller:KeyDownLast(IN_USE) == false then
		self:SetActive( nil, caller )
	end
end	
	
function ENT:TriggerInput(iname, value)
	if (iname == "Lock") then
		if (value > 0) then
			self.Locked= true
		else
			self.Locked = false
		end	
	end
end

local function quiet_steam(ent)
	ent:StopSound( "ambient.steam01" )
end

local SuitDat = EnvX.DefaultSuitData
local Multiplier = 1.5
local Divider = 1/Multiplier

function ENT:SetActive( value, caller )
	if not self.node then return end
	if self.Locked then return end
	local energy,water,oxygen,fuel = self:GetResourceAmount("energy"),self:GetResourceAmount("water"),self:GetResourceAmount("oxygen"),self:GetResourceAmount("hydrogen")
	
	local Res_needed = math.ceil((SuitDat.maxenergy - caller.suit.energy) * Divider)
		
	local Reng,Rwat,Rair = 2,8,4
	
	
	local NedEng,NedWat,NedAir = math.floor(Res_needed/Reng), math.floor(Res_needed/Rwat), math.floor(Res_needed/Rair)
	local MaxEng,MaxWat,MaxAir = math.floor(energy/NedEng),math.floor(water/NedWat),math.floor(oxygen/NedAir)

	if MaxEng>=1 and MaxWat>=1 and MaxAir>=1 then
		self:ConsumeResource("energy", NedEng)
		self:ConsumeResource("water", NedWat)
		self:ConsumeResource("oxygen", NedAir)
		
		caller.suit.energy = SuitDat.maxenergy
	else
		local MaxChr = MaxEng
		if MaxChr>MaxWat then MaxChr=MaxWat end
		if MaxChr>MaxAir then MaxChr=MaxAir end
		
		self:ConsumeResource("energy", NedEng*MaxChr)
		self:ConsumeResource("water", NedWat*MaxChr)
		self:ConsumeResource("oxygen", NedAir*MaxChr)
		
		caller.suit.energy = caller.suit.energy + math.floor(MaxChr * Multiplier)
	end
	
	local fuel_needed = math.ceil(((SuitDat.maxfuel) - caller.suit.fuel) * Divider)
	if ( fuel_needed < fuel ) then
		self:ConsumeResource("hydrogen", fuel_needed)
		caller.suit.fuel = SuitDat.maxfuel
	elseif (fuel > 0) then
		caller.suit.fuel = caller.suit.fuel + math.floor(fuel * Multiplier)
		self:ConsumeResource("hydrogen", fuel)
	end
	
	caller:EmitSound( "ambient.steam01" )
	timer.Simple(1.2, function() quiet_steam(caller) end) 
end
