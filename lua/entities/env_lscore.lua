AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_env_entity"
ENT.PrintName = "LS Core"
ENT.Author = "Ludsoe"
ENT.Category = "Environments"

ENT.Spawnable = false

list.Set( "LSEntOverlayText" , "env_lscore", {HasOOO = true, resnames ={ "oxygen", "energy", "water"} } )

util.PrecacheSound( "apc_engine_start" )
util.PrecacheSound( "apc_engine_stop" )
util.PrecacheSound( "common/warning.wav" )

if(SERVER)then
	function ENT:Initialize()
		self.BaseClass.Initialize(self)
		
		//self:SetModel( "models/SBEP_community/d12airscrubber.mdl" ) --setup stuff
		self:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,
		self:SetMoveType( MOVETYPE_VPHYSICS )   -- after all, gmod is a physics
		self:SetSolid( SOLID_VPHYSICS )         -- Toolbox
		
		self.gravity = 1
		self.Debugging = false
		self.Active = 0
		self.env = {}
		
		self.energy = 0
		self.coolant = 0
		self.coolant2 = 0
		
		self.pressure = 1
		
		self.mino2 = 10.5

		self.air = {}
		self.air.o2per = 0
		self.air.o2 = 0
		
		local phys = self:GetPhysicsObject() --reset physics
		if (phys:IsValid()) then
			phys:Wake()
		end
		self.Entities = {}
		
		if not (WireAddon == nil) then
			self.WireDebugName = self.PrintName
			self.Inputs = Wire_CreateInputs(self, { "On", "Gravity", "Max O2 level" })
			self.Outputs = Wire_CreateOutputs(self, { "On", "Oxygen-Level", "Temperature", "Gravity" })
		else
			self.Inputs = {{Name="On"},{Name="Gravity"},{Name="Max O2 level"}}
		end
		
		self:SetNetworkedInt( "EnvMaxO2",11 )
		self:NextThink(CurTime() + 1)
	end

	function ENT:TurnOn()
		if (self.Active == 0) then
			self:EmitSound( "apc_engine_start" )
			self:Check()
			self.Active = 1
			--self.gravity = 1
			if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", self.Active) end
			self:SetOOO(1)
		end
	end

	function ENT:TurnOff()
		if (self.Active == 1) then
			self:StopSound( "apc_engine_start" )
			self:EmitSound( "apc_engine_stop" )
			self.Active = 0
			--self.gravity = 0.00001
			if not (WireAddon == nil) then Wire_TriggerOutput(self, "On", self.Active) end
			self:SetOOO(0)
		end
	end

	function ENT:SetActive( value )
		if not value == nil then
			if value ~= 0 and self.Active == 0 then
				self:TurnOn()
			elseif value == 0 and self.Active == 1 then
				self:TurnOff()
			end
		else
			if self.Active == 0 then
				self:TurnOn()
			else
				self:TurnOff()
			end
		end
	end

	function ENT:TriggerInput(iname, value)
		if iname == "On" then
			self:SetActive(value)
		elseif iname == "Gravity" then
			local gravity = value
			if value <= 0 then
				gravity = 0
			end
			self.gravity = gravity
		elseif iname == "Max O2 level" then
			--local level = 100
			self.mino2 = math.Clamp(value, 0, 100)
			self:SetNetworkedInt( "EnvMaxO2", self.mino2 )
		end
	end

	function ENT:Check()
		local size = 0
		local constrainedents = constraint.GetAllConstrainedEntities( self )
		local world = game.GetWorld()
		for k,ent in pairs(constrainedents) do
			if ent == world then continue end --no more welding to world hax
			if ent.IsLS
			or ent:GetModel() == "models/props_canal/canal_bridge03a.mdl" 
			or ent:GetModel() == "models/props_canal/canal_bridge03b.mdl" 
			or ent:GetModel() == "models/props_canal/canal_bridge03c.mdl" then
			
			else
				local vec = ent:OBBMaxs() - ent:OBBMins()
				local volume = (vec.x * vec.y * vec.z)
				size = size + volume
			end
			ent.env = self
		end
		self.env.size = math.Round(size/100000)
		self.maxair = self.env.size*100
		MsgAll("Ship Atmosphere Size: "..self.maxair.."\n")
	end

	function ENT:OnRemove()
		local constrainedents = constraint.GetAllConstrainedEntities( self )
		local size = 0
		for k,ent in pairs(constrainedents) do
			ent.env = nil
		end
		self.BaseClass.OnRemove(self)
	end

	function ENT:Breathe()
		if self.air.o2 >= 10 then
			self.air.o2 = self.air.o2 - 10
			self.air.o2per = (self.air.o2/self.maxair)*100
		else
			self.air.o2 = 0
			self.air.o2per = 0
		end
	end

	local mintemp,maxtemp,mino2,maxsize = 284,305,11,512
	function ENT:Regulate()
		if not self.environment then
			self.environment = Space()
		end
		
		local temperature = self.environment.temperature or 0
		local pressure = self.environment.pressure
		--Msg("Temperature: "..tostring(temperature)..", pressure: " ..tostring(pressure).."\n")
		
		local energy = self:GetResourceAmount("energy")
		if energy == 0 then
			self:TurnOff()
			if self.temperature == nil then
				self.temperature = temperature
			end
			return
		else
			if not self.temperature then self.temperature = temperature end
			
			if temperature < self.temperature then
				self.temperature = self.temperature - math.ceil(self.temperature - temperature/ 100) //Change temperature depending on the outside temperature, 5° difference does a lot less then 10000° difference
			elseif temperature > self.temperature then
				self.temperature = self.temperature + math.ceil(self.temperature - temperature/ 100) //Change temperature depending on the outside temperature, 5° difference does a lot less then 10000° difference
			end
			
			if self.temperature > maxtemp then
				local mult = math.ceil(self.env.size/maxsize)
				local mult2 = math.ceil(maxsize/1024)
				
				if self.temperature - 60 > maxtemp then --is it above the comfortable range?
					--print("Cooling Down")
					self.coolant = self:GetResourceAmount("water")
					self.coolant2 = self:GetResourceAmount("nitrogen")
					--self:ConsumeResource("energy", 100 * math.ceil(self.env.size/maxsize))
					if self.coolant2 > mult * 12 * mult2 then
						--Msg("Enough Coolant\n")
						self.temperature = self.temperature - 20
						self:ConsumeResource("nitrogen", mult * 12 * mult2)
					elseif self.coolant > mult * 60 * mult2 then
						--Msg("Enough Coolant\n")
						self.temperature = self.temperature - 20
						self:ConsumeResource("water", mult * 60 * mult2)
					else
						--Msg("Not enough coolant\n")
						if self.coolant2 > 0 then
							self.temperature = self.temperature - math.ceil((self.coolant2/mult * 12 * mult2)*60)
							self.coolant = 0
						elseif self.coolant > 0 then
							self.temperature = self.temperature - math.ceil((self.coolant/mult * 60 * mult2)*60)
							self.coolant = 0
						end
					end
				elseif self.temperature - 30 > maxtemp then --is it above the comfortable range?
					--print("Cooling Down")
					self.coolant = self:GetResourceAmount("water")
					self.coolant2 = self:GetResourceAmount("nitrogen")
					--self:ConsumeResource("energy", 100 * math.ceil(self.env.size/maxsize))
					if self.coolant2 > math.ceil(self.env.size / maxsize) * 6 * mult2 then
						--Msg("Enough Coolant\n")
						self.temperature = self.temperature - 10
						self:ConsumeResource("nitrogen", mult * 6 * mult2)
					elseif self.coolant > mult * 30 * mult2 then
						--Msg("Enough Coolant\n")
						self.temperature = self.temperature - 10
						self:ConsumeResource("water", mult * 30 * mult2)
					else
						--Msg("Not enough coolant\n")
						if self.coolant2 > 0 then
							self.temperature = self.temperature - math.ceil((self.coolant2/mult * 6 * mult2))
							self.coolant = 0
						elseif self.coolant > 0 then
							self.temperature = self.temperature - math.ceil((self.coolant/mult * 30 * mult2))
							self.coolant = 0
						end
					end
				else--if self.temperature - 15 > maxtemp then --is it above the comfortable range?
					--print("Cooling Down")
					self.coolant = self:GetResourceAmount("water")
					self.coolant2 = self:GetResourceAmount("nitrogen")
					--self:ConsumeResource("energy", 100 * math.ceil(self.env.size/maxsize))
					if self.coolant2 > mult * 3 * mult2 then
						--Msg("Enough Coolant\n")
						self.env.temperature = self.env.temperature - 5
						self:ConsumeResource("nitrogen", mult * 3 * mult2)
					elseif self.coolant > mult * 15 * mult2 then
						--Msg("Enough Coolant\n")
						self.temperature = self.temperature - 5
						self:ConsumeResource("water", mult * 15 * mult2)
					else
						--Msg("Not enough coolant\n")
						if self.coolant2 > 0 then
							self.temperature = self.temperature - math.ceil((self.coolant2/mult * 3 * mult2))
							self.coolant = 0
						elseif self.coolant > 0 then
							self.temperature = self.temperature - math.ceil((self.coolant/mult * 15 * mult2))
							self.coolant = 0
						end
					end
				end
			end
			
			if self.temperature < mintemp then
				local mult = math.ceil(self.env.size/maxsize)
				local mult2 = math.ceil(maxsize/1024)
				
				self.energy = self:GetResourceAmount("energy")
				if self.temperature + 60 < mintemp then --is it below the comfortable range?
					--print("Heating Up 60")
					if self.energy > (mult * 60 * mult2) then
						--Msg("Enough energy\n")
						self.temperature = self.temperature + 20
						self:ConsumeResource("energy", mult * 60 * mult2)
					else
						--Msg("Not Enough energy\n")
						self:ConsumeResource("energy", self.energy)
						self.temperature = self.temperature + math.ceil((self.energy/mult * 60 * mult2))
						self.energy = 0
					end
				elseif self.temperature + 30 < mintemp then --is it below the comfortable range?
					--print("Heating Up 30")
					if self.energy > (mult * 30 * mult2) then
						--Msg("Enough energy\n")
						self.temperature = self.temperature + 10
						self:ConsumeResource("energy", mult * 30 * mult2)
					else
						--Msg("Not Enough energy\n")
						self:ConsumeResource("energy", self.energy)
						self.temperature = self.temperature + math.ceil((self.energy/mult * 30 * mult2))
						self.energy = 0
					end
				else--if self.temperature + 15 < mintemp then --is it below the comfortable range?
					--print("Heating Up 15")
					if self.energy > (mult * 15 * mult2) then
						--Msg("Enough energy\n")
						self.temperature = self.temperature + 5
						self:ConsumeResource("energy", mult * 15 * mult2)
					else
						--Msg("Not Enough energy\n")
						self:ConsumeResource("energy", self.energy)
						self.temperature = self.temperature + math.ceil((self.energy/mult * 15 * mult2))
						self.energy = 0
					end
				end
			end
			
			if self.air.o2per <= self.mino2 then
				local needed = math.Round((self.mino2/100)*(self.maxair/100))

				self.air.o2 = self.air.o2 + self:ConsumeResource("oxygen", needed)
				self.air.o2per = (self.air.o2/self.maxair)*100
				--print(tostring(self.air.o2per))
				self:SetNetworkedInt( "EnvAirO2Per", self.air.o2per )
			end
			
			if WireAddon then
				Wire_TriggerOutput(self, "Oxygen-Level", tonumber(self.air.o2per))
				Wire_TriggerOutput(self, "Temperature", tonumber(self.temperature))
				Wire_TriggerOutput(self, "Gravity", tonumber(self.gravity))
			end
		end
	end

	function ENT:Affect()
		if not self.environment then return end
		local temperature = self.environment.temperature or 0
		if self.temperature == nil then self.temperature = temperature end
		if temperature < self.temperature then
			local dif = self.temperature - temperature
			dif = math.ceil(dif / 100) //Change temperature depending on the outside temperature, 5° difference does a lot less then 10000° difference
			self.temperature = self.temperature - dif
		elseif temperature > self.temperature then
			local dif = temperature - self.temperature
			dif = math.ceil(dif / 100)
			self.temperature = self.temperature + dif
		end
		--Msg("Temperature: "..tostring(temperature).."\n")
	end

	function ENT:Think()
		if self.Entities == {} or nil then return end
		if self.Active == 1 then
			self:Regulate()
			--print("Energy:"..self.energy.." Coolant:"..self.coolant.." Temp:"..self.env.temperature)
		else
			self:Affect()
		end
		self:NextThink(CurTime() + 1)
		return true
	end

	--Environment functions
	
	function ENT:GetTemperature() return self.temperature end
	function ENT:IsSpace() return false end
	function ENT:IsEnvironment() return true end
	function ENT:IsPlanet() return false end
	function ENT:GetGravity() return self.gravity end
	function ENT:GetO2Percentage() return self.air.o2per end
	function ENT:GetCO2Percentage() return 0 end
	function ENT:GetNPercentage() return 0 end
	function ENT:GetHPercentage() return 0 end
	function ENT:GetEmptyAirPercentage() return 100 - self.air.o2per end

	--Pop Up Panel
	local T = {} --Create a empty Table
	
	T.Power = function(Device,ply,Data)
		Device:SetActive( nil, ply )
	end
	
	T.O2Per = function(Device,ply,Data)
		if (Device.TriggerInput) then
			Device:TriggerInput("Max O2 level", tonumber(Data))//SetMultiplier(tonumber(args[2]))
		end
	end
	
	T.Gravity = function(Device,ply,Data)
		if (Device.TriggerInput) then
			Device:TriggerInput("Gravity", tonumber(Data))//SetMultiplier(tonumber(args[2]))
		end
	end
	
	ENT.Panel=T --Set our panel functions to the table.
	
else 
	language.Add("generator_gas", "Gas Generator")
	
	function ENT:ExtraData(Info)
		local Max = self:GetNetworkedInt("EnvMaxO2") or 11
		local amt = self:GetNetworkedInt("EnvAirO2Per") or 0
		table.insert(Info,{Type="Percentage",Text="O2 Percentage: ".. amt .."/".. Max,Value=amt/Max})

		return true 
	end
	
	local MC = EnvX.MenuCore

	function ENT:PanelFunc(entID)	
		self.DevicePanel = {
			function() return MC.CreateButton(Parent,{x=90,y=30},{x=0,y=0},"Toggle Power",function() RunConsoleCommand( "envsendpcommand",self:EntIndex(),"Power") end) end,
			function()
				local S = MC.CreateSlider(Parent,{x=150,y=30},{x=0,y=0},{Min=1,Max=100,Dec=0},"O2 Percent",function(val) RunConsoleCommand( "envsendpcommand",self:EntIndex(),"O2Per",val) end)
				S:SetValue(self:GetNetworkedInt("EnvMaxO2") or 11)
				return S
			end,
			function()
				local S = MC.CreateCheckbox(Parent,{x=0,y=0},"Gravity",function(val) RunConsoleCommand( "envsendpcommand",self:EntIndex(),"Gravity",val) end)
				S:SetChecked()
				return S
			end
		}
	end
end
