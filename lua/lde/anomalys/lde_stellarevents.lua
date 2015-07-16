
--Spore Cloud
local Int = function(self) 
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
	if self:GetPhysicsObject():IsValid() then
		self:GetPhysicsObject():Wake()
	end
	
	local spores = math.random(5,10)
	local Genes = LDE.SporeAI.GetNewGenes()
	local i = 0
	for i=1, spores do
		local pos = self:GetPos()+Vector(math.random(-768,768),math.random(-768,768),math.random(-768,768))
		spore = ents.Create("lde_spore")
		spore:SetPos(pos)
		spore:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
		spore:Spawn()
		while true do
			if spore:IsInWorld() then
				spore:GetPhysicsObject():Sleep()
				spore.Genetics=Genes
				spore:CPPISetOwnerless(true)
				break
			end
			pos = self:GetPos()+Vector(math.random(-512,512),math.random(-512,512),math.random(-512,512))
			spore:SetPos(pos)
		end
	end
	self:Remove()
end
local Data={name="SporeCloud Spawner",class="lde_spore_cloud",Type="Spawner",Startup=Int,Dist={Min=800,Max=1200}}
LDE.Anons.GenerateAnomaly(Data)

--Secret satellite
local Spawn = function() 		
	rock = ents.Create("space_satellite")
	local Point = LDE.Anons:PointInOrbit(rock.Data,rock)
	if(not Point)then return end	
	rock:SetPos(Point)
	rock:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
	rock:Spawn()
end

local Think = function(self) end

local Int = function(self)			
	local models = {"models/Slyfo/probe1.mdl","models/Slyfo/sat_platform.mdl","models/Slyfo/sat_relay.mdl"} 
	self.Sounds = {"music/radio1.mp3"}
	self:SetModel(models[math.random(1,table.Count(models))])
	
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	
end

local Client = function(self)
	function ENT:Initialize()
		self:EmitSound("ambient/machines/wall_ambient_loop1.wav",80,math.Rand(90,110) )
	end
end

local Data={name="Satellite",class="space_satellite",Type="Orbit",Client=Client,Think=Think,Startup=Int,ThinkSpeed=0.01,SpawnMe=Spawn,minimal=1}
LDE.Anons.GenerateAnomaly(Data)
