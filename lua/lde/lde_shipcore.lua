LDE.CoreSys = {}

LDE.CoreSys.Cores = {}
LDE.CoreSys.Shields = {}

LDE.CoreSys.ShieldAge = function(self,Data)
	if(not Data)then return false end
	if(Data.ShieldAge<0)then
		if(self.LDE.CanRecharge==1)then
			if(self.LDE.CoreShield>self.LDE.CoreMaxShield)then
				self.LDE.CoreShield=self.LDE.CoreMaxShield
			elseif(self.LDE.CoreShield>self.LDE.CoreMaxShield*Data.ShieldAge)then
				self.LDE.CoreShield = self.LDE.CoreShield - self.LDE.CoreMaxShield*Data.ShieldAge
			elseif(self.LDE.CoreShield<self.LDE.CoreMaxShield*Data.ShieldAge)then
				self.LDE.CoreShield = 0
			end			
		end
	else
		if(self.LDE.CoreShield>self.LDE.CoreMaxShield)then
			self.LDE.CoreShield=self.LDE.CoreMaxShield
		elseif(self.LDE.CoreShield>self.LDE.CoreMaxShield*Data.ShieldAge)then
			self.LDE.CoreShield = self.LDE.CoreShield - self.LDE.CoreMaxShield*Data.ShieldAge
		elseif(self.LDE.CoreShield<self.LDE.CoreMaxShield*Data.ShieldAge)then
			self.LDE.CoreShield = 0
		end
	end
	
	if(self.LDE.CoreShield>self.LDE.CoreMaxShield)then
		self.LDE.CoreShield=self.LDE.CoreMaxShield
	end
end

LDE.CoreSys.Radiate = function(self,Data)
	if(not self.LDE or not self.LDE.CoreTemp)then return false end
	if(self.LDE.CoreTemp>0)then
		local Resist = self.LDE.CoreMaxTemp*(0.1*Data.CoolBonus)
		if(self.LDE.CoreTemp>Resist)then
			self.LDE.CoreTemp = self.LDE.CoreTemp - Resist
		elseif(self.LDE.CoreTemp<Resist)then
			self.LDE.CoreTemp = 0
		end
	else
		--Add Heating logic here.
	end
end

local ShipClasses = {
	"Heavy - Fighter / Bomber / Interceptor",
	"Corvette",
	"Frigate",
	"Heavy Frigate",
	"Destroyer",
	"Cruiser",
	"Battle-Cruiser",
	"Battleship",
	"Dreadnaught",
	"Super Battleship",
	"Class 1 Leviathon",
	"Class 2 Leviathon",
	"Class 3 Leviathon",
	"Class 1 Titan",
	"Class 2 Titan",
	"Battle-Barge",
	"Super Dreadnaught",
	"Leviathon Destroyer",
	"Mega Titan",
	"Super Leviathon",
	"Titan Destroyer",
	"Eversor Regalis",
	"That's No Moon!",
	"Mecha Planet",
	"Galactic Vengeance",
	"HOLY FUCKING JESUS"
}

/*
for i, cls in pairs( ShipClasses ) do
	local Scale = 50000*(i*((i/5)+(i/10)))
	print("Class: "..cls.." V: "..Scale) 
end
*/
LDE.CoreSys.CoreClass = function(self)
	local T = self.LDE.CoreMaxShield+self.LDE.CoreMaxHealth
	self.LDE.TotalHealth = T
	local Classification = "Fighter / Bomber / Interceptor"
	
	for i, cls in pairs( ShipClasses ) do
		local Scale = 50000*(i*((i/5)+(i/10)))
		if T > Scale then
			Classification = cls
		else
			break
		end
	end

	self.ShipClass = Classification
	self:SetNWInt("LDECoreClass", Classification)
end

LDE.CoreSys.CoreHealth = function(self,Data)
	-- Get all constrained props
	self.Props = constraint.ShipCoreDetect(self.Entity)
				
	-- Loop through all props
	local hp = self.LDE.CoreHealth
	local maxhp = 1
	local maxsd = 1
	local sinkers = 0
	local meltp	= 1
	local freezep=-1
	local temp = 0
	local CPS = 0
	for _, ent in pairs( self.Props ) do
		if ent and LDE:CheckValid( ent ) then
			if not ent.LDE then ent.LDE = {} end

			if not self.PropHealth then self.PropHealth={} end --Make sure we have the prop health table.		
			if not ent.LDEHealth or not ent.LDEMaxMass then LDE:CalcHealth( ent ) end
			local entcore = ent.LDE.Core
			local capacity = ent.LDE.HeatCapacity or 0
			local maxheat = ent.LDE.MeltingPoint or 0
			local minheat = ent.LDE.FreezingPoint or 0
			local temper = ent.LDE.Temperature or 0
			local health = self.PropHealth[ent:EntIndex()] or 0
			local enthealth = LDE:GetHealth(ent)*Data.HealthRate
			local Calcedhealth = LDE:CalcHealth(ent)
			local maxhealth = (Calcedhealth)*Data.HealthRate
			local entshield = (Calcedhealth)*Data.ShieldRate
			local entpoints = Calcedhealth*Data.CPSRate
			
			LDE.HeatSim.SetTemperature(ent,0)
			
			if string.find(ent:GetClass(),"spore") then 
				continue
				--health,enthealth,entshield,entpoints=0,0,0,0  --Spores dont get any treatment
			else
				if not entcore or not IsValid(entcore) then -- if the entity has no core
					ent.LDE.Core = self
					ent.Shield = self --Environments Damage Override Compatability
					self.PropHealth[ent:EntIndex()] = enthealth
					self:CoreLink(ent) --Link it to our core :)
					hp = hp + enthealth
				elseif (entcore and entcore == self and enthealth != health) then -- if the entity's health has changed
					hp = hp - health -- subtract the old health
					hp = hp + enthealth -- add the new health
					self.PropHealth[ent:EntIndex()] = enthealth
				elseif (entcore and entcore != self) then -- if the entity already has a core
					continue --Guess we dont get that prop :(
				end
			end
			maxhp=(maxhp+maxhealth)
			maxsd=maxsd+entshield
			sinkers=sinkers+capacity
			meltp=meltp+maxheat
			freezep=freezep+minheat
			temp=temp+temper
			CPS=CPS+entpoints
		end
	end
	
	-- Set health
	self.LDE.CoreHealth = hp
	self.LDE.CoreMaxHealth = maxhp
	self.LDE.CoreMaxShield = maxsd
	self.LDE.CoreTemp = self.LDE.CoreTemp+temp
	self.LDE.CoreMaxTemp = meltp*Data.TempResist
	self.LDE.CoreMinTemp =  freezep*Data.TempResist
	self.LDE.MaxCorePoints=CPS
	
	if (self.LDE.CoreHealth > self.LDE.CoreMaxHealth) then 
		self.LDE.CoreHealth = self.LDE.CoreMaxHealth
	end
	
	-- Wire Output
	WireLib.TriggerOutput( self, "Health", self.LDE.CoreHealth or 0 )
	WireLib.TriggerOutput( self, "Total Health", self.LDE.CoreMaxHealth or 0 )
	WireLib.TriggerOutput( self, "Shields", self.LDE.CoreShield or 0 )
	WireLib.TriggerOutput( self, "Max Shields", self.LDE.CoreMaxShield or 0 )
	WireLib.TriggerOutput( self, "Temperature", self.LDE.CoreTemp)
	WireLib.TriggerOutput( self, "Freezing Point", self.LDE.CoreMinTemp or 0 )
	WireLib.TriggerOutput( self, "Melting Point", self.LDE.CoreMaxTemp or 0 )	
	WireLib.TriggerOutput( self, "OverHeating", self.OverHeating or 0 )
	WireLib.TriggerOutput( self, "Mount Points", self.LDE.CorePoints or 0)	
	WireLib.TriggerOutput( self, "Mount Capacity", self.LDE.MaxCorePoints or 0 )	
end

LDE.CoreSys.CoreModels = {
	"models/props_wasteland/panel_leverBase001a.mdl",
	"models/Slyfo_2/miscequipmentfieldgen.mdl",
	"models/Cerus/Modbridge/Misc/LS/ls_gen11a.mdl",
	"models/SmallBridge/Life Support/sbfusiongen.mdl",
	"models/Slyfo_2/rocketpod_bigrockethalf.mdl",
	"models/Slyfo_2/miscequipmentmount.mdl",
	"models/props_lab/reciever01b.mdl",
	"models/SBEP_community/d12shieldemitter.mdl"
}

//Base Device Code we will inject the functions into.
function LDE.CoreSys.RegisterCore(Data)
	local Description = Data.name.." \n ShieldRate: "..Data.ShieldRate.." \n HealthRate: "..Data.HealthRate.." \n HeatSinks: "..Data.TempResist.." \n CoolantBonus: "..Data.CoolBonus.." \n ShieldDecay: "..Data.ShieldAge

	for k,v in pairs(LDE.CoreSys.CoreModels) do
		Environments.RegisterDevice("Ship Core", Data.name, v, Data.class , v, 1, 1, v,Description)
	end
	local ENT = {}
	ENT.Type = "anim"
	ENT.Base = "base_env_entity"
	ENT.PrintName = Data.name
	ENT.Data = Data
	ENT.IsLDEC = 1
	ENT.IsCore = true
	ENT.NoEnvPanel = true
	
	if SERVER then
		function ENT:Initialize()   
			self:PhysicsInit( SOLID_VPHYSICS )  	
			self:SetMoveType( MOVETYPE_VPHYSICS )
			self:SetSolid( SOLID_VPHYSICS )      
			
            local V,N,A,E = "VECTOR","NORMAL","ANGLE","ENTITY"
            self.Outputs = WireLib.CreateSpecialOutputs( self,
                 { "Health", "Total Health" ,"Shields" ,"Max Shields", "Mount Points", "Mount Capacity" , "Temperature","Freezing Point",  "Melting Point", "OverHeating", "Attacker" },
                {N,N,N,N,N,N,N,N,N,N,E}
                )
			self.Inputs = Wire_CreateInputs(self, { "SelfDestruct","Vent Shields","UnLink All" })
			
			--Setup all of our variables.
			self.OverHeating= 0 self.Thinkz= 0
			self.LDE = {CorePoints=0,MaxCorePoints=1,CoreHealth=1,CoreMaxHealth=1,CoreShield=0,CoreMaxShield=0,TotalHealth=1,CanRecharge=1,Flashing=1,CoreTemp=0,CoreMinTemp=-1,CoreMaxTemp=1,DeathSeq=false,Core=self}
			self.Props ={} self.Weapons ={} self.CoreLinked ={} self.PropHealth ={} self.Shielded ={} 
			self.ShipClass = "Calculating"
			
			self:CoreLink(self)
			
			LDE.CoreSys.CoreHealth(self,self.Data)
			
			self.LDE.CoreHealth = self.LDE.CoreMaxHealth
			self.LDE.CorePoints = self.LDE.MaxCorePoints
			
			WireLib.TriggerOutput( self, "Health", self.LDE.CoreHealth or 0 )
			WireLib.TriggerOutput( self, "Total Health", self.LDE.CoreMaxHealth or 0 )
			WireLib.TriggerOutput( self, "Shields", self.LDE.CoreShield or 0 )
			WireLib.TriggerOutput( self, "Max Shields", self.LDE.CoreMaxShield or 0 )
			WireLib.TriggerOutput( self, "Temperature", self.LDE.CoreTemp)
			WireLib.TriggerOutput( self, "Freezing Point", self.LDE.CoreMinTemp or 0 )
			WireLib.TriggerOutput( self, "Melting Point", self.LDE.CoreMaxTemp or 0 )	
			WireLib.TriggerOutput( self, "Mount Points", self.LDE.CorePoints or 0 )
			WireLib.TriggerOutput( self, "Mount Capacity", self.LDE.MaxCorePoints or 0 )
			
			self:SetNWInt("LDECoreType", self.Data.name)
			self:SetNWInt("LDECoreClass", "Registering")
			
			self:NextThink( CurTime() + 1 )
			return true
		end
		
		function ENT:SetOptions( ply )
			self.Owner = ply
		end

		function ENT:ClearProp( Entity )
			for key, ent in pairs( self.Props ) do
				if Entity == ent then
					table.remove( self.Props, key )
					self.Prophealth[ent:EntIndex()] = nil
					return --Stop the loop there.
				end
			end
		end

		function ENT:CoreLink(Entity)
			if(Entity.LDE.Core and not Entity.LDE.Core == self)then
				Entity.LDE.Core:CoreUnLink(Entity)
			end
			self.CoreLinked[Entity:EntIndex()]=Entity
			Entity.LDE.Core = self
			if Entity.IsLDEWeapon or Entity.PointCost then
				self.Weapons[Entity:EntIndex()] = Entity
				if Entity.HasPoints == false and Entity.PointCost <= self.LDE.CorePoints then
					self.LDE.CorePoints=self.LDE.CorePoints-Entity.PointCost
					Entity.HasPoints=true
				end
			end
		end

		function ENT:CoreUnLink( Entity )
			for key, ent in pairs( self.CoreLinked ) do
				if Entity == ent then
					table.remove( self.CoreLinked, key )
					Entity.LDE.Core = nil
					if Entity.IsLDEWeapon or Entity.PointCost then
						if Entity.HasPoints == true then
							self.Weapons[Entity:EntIndex()] = nil
							self.LDE.CorePoints=self.LDE.CorePoints+Entity.PointCost
							Entity.HasPoints=false
						end
					end
					return --Stop the loop there.
				end
			end
		end

		function ENT:ShieldDamage(DmgInfo) --Environments Damage Override Hack
		//	LDE:DamageCore( self, DmgInfo )
		end
		
		function ENT:UnLinkAll()
			if not self.CoreLinked then return end
			for _, ent in pairs( self.CoreLinked ) do
				if ent and IsValid(ent) then
					ent.LDE.Core = nil
					ent.Shield = nil
				end
			end
			self.CoreLinked={}
		end
		
		function ENT:TriggerInput(iname, value)
			if (iname == "SelfDestruct") then
				if (value > 0) then
					self.LDE.DeathSeq = true
				else
					self.LDE.DeathSeq = false
				end	
			elseif(iname=="Vent Shields")then
				if (value > 0) then
					self.LDE.CoreShield=0
				end
			elseif(iname=="UnLink All")then
				if (value > 0) then
					self:UnLinkAll()
				end
			end
		end

		function ENT:Think() 
			if(not self.Thinkz)then return end--WOT
			if(self.LDE.DeathSeq)then
				LDE:ExplodeCore(self)
			end
			self.Thinkz=self.Thinkz+1
			if(self.Thinkz>=5)then
				self.Thinkz=0
				LDE.CoreSys.CoreHealth(self,self.Data)
				
				self.LDE.CorePoints = self.LDE.MaxCorePoints --Set the points to max.
				
				for key, ent in pairs( self.Weapons ) do
					if ent and IsValid(ent) then
						if ent.PointCost <= self.LDE.CorePoints then
							self.LDE.CorePoints=self.LDE.CorePoints-ent.PointCost
							ent.HasPoints=true
						else
							ent.HasPoints=false
						end
					else
						table.remove( self.Weapons, key )
					end
				end
				
				if(self.Data.Think)then
					self.Data.Think(self)
				end
								
				LDE.CoreSys.CoreClass(self)
			end
						
			if (self.LDE.CoreTemp > self.LDE.CoreMaxTemp) then 
				self.OverHeating=1
				LDE:DealDamage(self, math.abs(self.LDE.CoreTemp-self.LDE.CoreMaxTemp)*3, self, self,true)
			else
				self.OverHeating=0
			end
				
			local Networked = {
				CoreMaxHealth 	= "LDEMaxHealth",
				CoreHealth		= "LDEHealth",
				CoreMaxShield	= "LDEMaxShield",
				CoreShield		= "LDEShield",
				CoreMaxTemp		= "LDEMaxTemp",
				CoreMinTemp		= "LDEMinTemp",
				CoreTemp		= "LDETemp",
				MaxCorePoints	= "MaxCorePoints",
				CorePoints		= "CorePoints"
			}
				
			-- Set NW ints
			for DV, NW in pairs(Networked) do
				local hp = self:GetNWInt(NW)
				if not hp or hp ~= self.LDE[DV] then
					--   print("Synced "..NW.." as "..DV.." for "..self.LDE[DV])
					self:SetNWInt(NW, self.LDE[DV])
				end				
			end

			self:NextThink( CurTime() + 1 )
			return true
		end
		
		function ENT:OnRemove()
			self:UnLinkAll()
		end

		function ENT:ChangeTemp(Amount)
		//	print("Temperature Changing, "..Amount)
			if(Amount==0)then return end
			self.LDE.CoreTemp=self.LDE.CoreTemp+Amount
			WireLib.TriggerOutput( self, "Temperature", self.LDE.CoreTemp)
		end

		function ENT:BuildDupeInfo()
			local info = self.BaseClass.BuildDupeInfo(self) or {}
			return info
		end

		function ENT:ApplyDupeInfo( ply, ent, info, GetEntByID )
			self.BaseClass.ApplyDupeInfo( self, ply, ent, info, GetEntByID )
		end

	else --Lets do client side shit! :D
		function ENT:Draw()      
			self:DrawDisplayTip()
			self:DrawModel()
		end
 
		local TipColor = Color( 250, 250, 200, 255 )

		surface.CreateFont("GModWorldtip", {font = "coolvetica", size = 24, weight = 500})
			
		function ENT:DrawDisplayTip()		
			
			if ( LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance( self:GetPos() ) < 512) then
				EnvX.MenuCore.RenderWorldTip(self,function(self)
					return {
						{Type="Label",Value="Type: "..self:GetNWString("LDECoreType")},
						{Type="Label",Value="Class: "..self:GetNWString("LDECoreClass")},
						{Type="Percentage",
							Value=math.Round(self:GetNWInt("LDEHealth"))/math.Round(self:GetNWInt("LDEMaxHealth")),
							Text="Health: "..math.Round(self:GetNWInt("LDEHealth")).." / "..math.Round(self:GetNWInt("LDEMaxHealth"))
						},
						{Type="Percentage",
							Value=math.Round(self:GetNWInt("LDEShield"))/math.Round(self:GetNWInt("LDEMaxShield")),
							Text="Shields: "..math.Round(self:GetNWInt("LDEShield")).." / "..math.Round(self:GetNWInt("LDEMaxShield"))
						},
						{Type="Percentage",
							Value=math.Round(self:GetNWInt("CorePoints"))/math.Round(self:GetNWInt("MaxCorePoints")),
							Text="Processor: "..math.Round(self:GetNWInt("CorePoints")).." / "..math.Round(self:GetNWInt("MaxCorePoints"))
						},					
						{Type="Label",Value="Heat: "..math.Round(self:GetNWInt("LDEMinTemp")).." / ("..math.Round(self:GetNWInt("LDETemp"))..") / "..math.Round(self:GetNWInt("LDEMaxTemp"))}
					}
				end)
			end
		end
	end
	
	scripted_ents.Register(ENT, Data.class, true, true)
	print("Core Registered: "..Data.class)
end

local Files
if file.FindInLua then
	Files = file.FindInLua( "lde/cores/*.lua" )
else//gm13
	Files = file.Find("lde/cores/*.lua", "LUA")
end

--Get the weapon data from the lifesupport folder.
for k, File in ipairs(Files) do
	Msg("*LDE Core System Loading: "..File.."...\n")
	local ErrorCheck, PCallError = pcall(include, "lde/cores/"..File)
	ErrorCheck, PCallError = pcall(AddCSLuaFile, "lde/cores/"..File)
	if !ErrorCheck then
		Msg(PCallError.."\n")
	end
end
Msg("LDE Core System Loaded: Successfully\n")



