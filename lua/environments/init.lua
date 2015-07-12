
local scripted_ents = scripted_ents
local table = table
local util = util
local player = player
local umsg = umsg
local list = list
local timer = timer
local ents = ents
local duplicator = duplicator
local math = math
local tostring = tostring
local MeshQuad = MeshQuad
local Vector = Vector
local type = type
local tonumber = tonumber
local pairs = pairs

local EnvX = EnvX --Localise the global table for speed.
local Utl = EnvX.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.

if SERVER then
	local function CheckRD() --make not call for update all the time
		for k,ply in pairs(player.GetAll()) do
			local ent = ply:GetEyeTrace().Entity
			if ent and IsValid(ent) then
				if ent.node and IsValid(ent.node) or ent.IsNode then --its a RD entity, send the message!
					--list.Set( "LSEntOverlayText" , class, {HasOOO = true, resnames = In, genresnames = Out} )
					local dat = list.Get("LSEntOverlayText")[ent:GetClass()] --get the resources
					if dat then
						if not ent.IsNode then
							ent.node:DoUpdate(dat.resnames, dat.genresnames, ply)
						else
							ent:DoUpdate({}, {}, ply)
						end
					else --no list data? SG? CAP?
					
					end
				elseif ent.maxresources and not ent.IsNode then
					if not ent.client_updated then
						NDat.AddData({Name="EnvX_SyncStorage",Val=5,Dat={Ent=ent,Resources=ent.resources,ResourceMaxs=ent.maxresources}},ply)
						ent.client_updated = true
					end
				end
			end
		end
	end
	timer.Create("RDChecker", 0.5, 0, CheckRD) --adjust rate perhaps?
end 

local function SaveGravPlating( Player, Entity, Data )
	if not SERVER then return end
	if Data.GravPlating and Data.GravPlating == 1 then
		Entity.grav_plate = 1
		if ( SERVER ) then
			Entity.EntityMods = Entity.EntityMods or {}
			Entity.EntityMods.GravPlating = Data
		end
	else
		Entity.grav_plate = nil
		if ( SERVER ) then
			if Entity.EntityMods then Entity.EntityMods.GravPlating = nil end
		end	
	end
	duplicator.StoreEntityModifier( Entity, "gravplating", Data )
end

//need to add dupe support
local function RegisterVehicle(ply, ent)
	RD_Register(ent, false)
end
hook.Add( "PlayerSpawnedVehicle", "ENV_vehicle_spawn", RegisterVehicle )

function Environments.BuildDupeInfo( ent ) --need to add duping for cables
	local info = {}
	if ent.IsNode then
		return
	elseif ent:GetClass() == "env_pump" then
		local info = {}
		info.pump = ent.pump_active
		info.rate = ent.pump_rate
		info.hoselength = ent.hose_length
	end
	
	if ent.node then
		info.Node = ent.node:EntIndex()
	end
	
	info.extra = ent.env_extra
	
	info.LinkMat = ent:GetNWString("CableMat", nil)
	info.LinkPos = ent:GetNWVector("CablePos", nil)
	info.LinkForw = ent:GetNWVector("CableForward", nil)
	info.LinkColor = ent:GetNWVector("CableColor", nil)
	
	duplicator.StoreEntityModifier( ent, "EnvDupeInfo", info )
end

//apply the DupeInfo
function Environments.ApplyDupeInfo( ent, CreatedEntities, Player ) --add duping for cables
	if ent.EntityMods and ent.EntityMods.EnvDupeInfo then
		if ent.AdminOnly and !Player:IsAdmin() then //stops people from pasting admin only stuff
			ent:Remove()
			Player:ChatPrint("This device is admin only!")
		else
			local DupeInfo = ent.EntityMods.EnvDupeInfo
			if ent.IsNode then
				return
			elseif ent:GetClass() == "env_pump" then
				ent:Setup( DupeInfo.pump, DupeInfo.rate, DupeInfo.hoselength )
			end
			Environments.MakeFunc(ent) --yay
			if DupeInfo.Node then
				local node = CreatedEntities[DupeInfo.Node]
				ent:Link(node, true)
				node:Link(ent, true)
			end
			
			ent.env_extra = DupeInfo.extra
			
			ent.EntityMods.EnvDupeInfo = nil
			
			//set the player/owner
			ent:SetPlayer(Player)
		end
	end
end

if SERVER then
	function Environments.RDPlayerUpdate(ply)
		print("Ply Joined! Syncing!")
		local Nodes = {}
		
		for k,ent in pairs(ents.FindByClass("resource_node_env")) do
			Nodes[ent:EntIndex()]={} --Create Empty Table for this node in our sync data.
			NDat.AddData({Name="EnvX_NodeSync",Val=5,Dat={Node=ent:EntIndex(),Resources=ent.resources,ResourceMaxs=ent.maxresources}},ply)
		end
		
		for k,v in pairs(ents.GetAll()) do
			if v and v.node and IsValid(v.node) then
				table.insert(Nodes[v.node:EntIndex()],v:EntIndex())
			end
		end
		
		if table.Count(Nodes)>0 then
			NDat.AddData({Name="EnvX_SetEntNode",Val=5,Dat={Nodes=Nodes}},ply)
		end
	end
	Utl:HookHook("PlayerInitialSpawn","EnvSyncPlayerJoin",function(ply) timer.Simple(5,function() Environments.RDPlayerUpdate(ply) end) end,1)

	function Environments.ZapMe(pos, magnitude)
		if not (pos and magnitude) then return end
		zap = ents.Create("point_tesla")
		zap:SetKeyValue("targetname", "teslab")
		zap:SetKeyValue("m_SoundName" ,"DoSpark")
		zap:SetKeyValue("texture" ,"sprites/physbeam.spr")
		zap:SetKeyValue("m_Color" ,"200 200 255")
		zap:SetKeyValue("m_flRadius" ,tostring(magnitude*80))
		zap:SetKeyValue("beamcount_min" ,tostring(math.ceil(magnitude)+4))
		zap:SetKeyValue("beamcount_max", tostring(math.ceil(magnitude)+12))
		zap:SetKeyValue("thick_min", tostring(magnitude))
		zap:SetKeyValue("thick_max", tostring(magnitude*8))
		zap:SetKeyValue("lifetime_min" ,"0.1")
		zap:SetKeyValue("lifetime_max", "0.2")
		zap:SetKeyValue("interval_min", "0.05")
		zap:SetKeyValue("interval_max" ,"0.08")
		zap:SetPos(pos)
		zap:Spawn()
		zap:Fire("DoSpark","",0)
		zap:Fire("kill","", 1)
	end
	
	function Environments.LSDestruct( ent, Simple )
		if Simple then
			Explode2( ent )
		else
			timer.Simple(1, function() Explode1( ent) end)
			timer.Simple(1.2, function() Explode1( ent) end)
			timer.Simple(2, function() Explode1( ent) end)
			timer.Simple(2,function()  Explode2( ent) end)
		end
	end
	
	function Explode1( ent )
		if ent:IsValid() then
			local Effect = EffectData()
				Effect:SetOrigin(ent:GetPos() + Vector( math.random(-60, 60), math.random(-60, 60), math.random(-60, 60) ))
				Effect:SetScale(1)
				Effect:SetMagnitude(25)
			util.Effect("Explosion", Effect, true, true)
		end
	end

	function Explode2( ent )
		if ent:IsValid() then
			local Effect = EffectData()
				Effect:SetOrigin(ent:GetPos())
				Effect:SetScale(3)
				Effect:SetMagnitude(100)
			util.Effect("Explosion", Effect, true, true)
			ent:Remove()
		end
	end
	
	function Environments.DupeFix( pl, Data, ... )
		Data.Class = scripted_ents.Get(Data.Class).ClassName
		
		local ent = ents.Create( Data.Class )
		if not IsValid(ent) then return false end
		
		duplicator.DoGeneric( ent, Data )
		ent:Spawn()
		ent:Activate()
		duplicator.DoGenericPhysics( ent, pl, Data ) -- Is deprecated, but is the only way to access duplicator.EntityPhysics.Load (its local)

		ent:SetPlayer(pl)
		
		ent:CPPISetOwner(pl)
		
		return ent
	end
end
