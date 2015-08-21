/*
----------------------------------------------
----------------Faction Core------------------
----------------------------------------------
*/
local LDE = LDE --Localise the global table for speed.
local Utl = EnvX.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.
local Persist = EnvX.Persist

LDE.PlayerData = LDE.PlayerData or {PlayerData={}}
local PlayerData = LDE.PlayerData

local BasePlayerData = {Stats={Stats={Cash=100,Bounty=0,Mined=0,Trades=0,Kills=0},Strings={Faction="",Role="Civilian"}},Mutations={},Unlocks={}}
	
function PlayerData.GetData(ply)
	local Data = PlayerData.PlayerData[ply:SteamID()]
	if Data then
		return Data
	else
		PlayerData.PlayerData[ply:SteamID()] = BasePlayerData
		return PlayerData.PlayerData[ply:SteamID()]
	end
end

if SERVER then
	local FilePath = Persist.FileLocalPath()
	local FileName = "player_data_persist"
	
	function PlayerData.LoadPersistData()
		local Loaded = Persist.LoadPersist(FilePath,FileName,{Version=0,PlayerData={}})
		
		if Version == 1 then
			PlayerData.PlayerData = PlayerData.PlayerData
		end
	end
	PlayerData:LoadPersistData()
	
	function PlayerData.SavePersistData()
		local SaveData = {Version=1,PlayerData=PlayerData.PlayerData}
		Persist.SavePersist(FilePath,FileName,SaveData)
	end
	concommand.Add("lde_saveplypersist",PlayerData.SavePersistData)
	
	--Detect players joining and make sure they have data setup.
	Utl:HookHook("PlayerInitialSpawn","EnvxPlayerPersist",function(ply)
		local ID = ply:SteamID()
		PlayerData.PlayerData[ID] = PlayerData.PlayerData[ID] or BasePlayerData
	end,1)
	
	Utl:HookHook("PlayerDisconnected","EnvxPlayerPersist",function(ply)
		PlayerData.SavePersistData()
	end,1)
	
	function PlayerData.SetData(ply,data,value) 
		local Table = PlayerData.PlayerData[ply:SteamID()]
		Table[data] = value
	end
	
	function PlayerData.SyncData(ply)
		local SyncData = {}
		
		--Only Sync Connected Players.
		local plys = player.GetAll()
		for k,v in pairs(plys) do
			SyncData[v:SteamID()]=PlayerData.GetData(v)
		end
		
		NDat.AddData({Name="EnvxPlayerPersistSync",Val=5,Dat={PlayerData=SyncData}},ply)
	end
	
	function PlayerData.SyncDataAll() 
		local SyncData = {}
		
		--Only Sync Connected Players.
		local plys = player.GetAll()
		for k,v in pairs(plys) do
			SyncData[v:SteamID()]=PlayerData.GetData(v)
		end
		
		NDat.AddDataAll({Name="EnvxPlayerPersistSyncAll",Val=5,Dat={PlayerData=SyncData}})
		PlayerData.SavePersistData()
	end
	
	Utl:SetupThinkHook("EnvxPlayerPersistThink",5,0,function() PlayerData:SyncDataAll() end)
	
	function PlayerData.HandleMutations(ply,Event,Extra)
		if not ply or not IsValid(ply) or not ply:IsPlayer() then return end --Y U DO THIS!
		for _, mutation in pairs( ply:GetMutations() ) do
			if mutation.start+mutation.time<=CurTime()and not mutation.Removed then
				if(mutation.Data["OnTimeEnd"])then
					mutation.Data["OnTimeEnd"](ply)
				end
				ply:RemoveMutation(mutation.name)
			else
				if(mutation.Data[Event])then
					mutation.Data[Event](ply,Extra)
				end
			end
		end
	end
	
	Utl:SetupThinkHook("LDEPlayerMutationOnTick",1,0,function() 
		local players = player.GetAll()
		
		for _, ply in ipairs( players ) do
			if ply and ply:IsConnected() then
				PlayerData.HandleMutations(ply,"Tick")
			end
		end		
	end)
else
	Utl:HookNet("EnvxPlayerPersistSyncAll",function(Data)
		PlayerData.PlayerData = Data.PlayerData
	end)
	
	Utl:HookNet("EnvxPlayerPersistSync",function(Data)
		PlayerData.GetData(Data.ply)[Data.Type]=Data.Dat
	end)
end

---Player functions	
local meta = FindMetaTable( "Player" )
if not meta then return end

function meta:PersistSyncData(Type)
	NDat.AddDataAll({Name="EnvxPlayerPersistSync",Val=2.5,Dat={ply=self,Type=Type,Dat=PlayerData.GetData(self)[Type]}})
end

function meta:GetStats() return ((PlayerData.GetData(self) or {}).Stats or {}).Stats or {} end
function meta:GetStrings() return ((PlayerData.GetData(self) or {}).Stats or {}).Strings or {} end
function meta:GetUnlocks() return (PlayerData.GetData(self) or {}).Unlocks or {} end
function meta:GetMutations() return (PlayerData.GetData(self) or {}).Mutations or {} end
function meta:UnlockItem(Item) self:GetUnlocks()[Item] = true end

function meta:ClearMutations()
	local Muta = self:GetMutations()
	for _, mutation in pairs( Muta ) do
		self:RemoveMutation(mutation.name)
	end
	Muta={}	--Clear the mutations table.
	self:PersistSyncData("Mutations") --Sync the mutations changes.
end

function meta:RemoveMutation(Name)
	local Muta = self:GetMutations()
	if Muta[Name] then
		Muta[Name].Removed = true
		PlayerData.HandleMutations(self,"OnRemove")
		Muta[Name]=nil	--Remove the mutation from the table.
		self:PersistSyncData("Mutations") --Sync the mutations changes.
	end
end

function meta:GiveMutation(Name,Duration,Data,Stacks,Lock)
	local Muta = self:GetMutations()
	local Table = {name = Name,time = Duration,start=CurTime(),Data = Data}--Format the mutation.
	local mutation = Muta[Name]
	if Stacks and mutation and mutation.start+mutation.time<=CurTime() then
		Table = {name = Name,time = mutation.time+Duration,start=mutation.start,Data = Data}--Merge the mutation tables.
	elseif mutation then
		if Stacks or Lock then
			return
		end
	end
	Muta[Name]=Table --Add it to the players mutations list.
	self:PersistSyncData("Mutations") --Sync the mutations changes.
	PlayerData.HandleMutations(self,"OnStart") --Call the startup hook for mutations.
end

function meta:GiveLDEStat(stat,num)
	self:SetLDEStat( stat, self:GetLDEStat(stat)+tonumber(num) or 0 )
end

function meta:TakeLDEStat(stat,num)
	self:SetLDEStat( stat, self:GetLDEStat(stat)-tonumber(num) or 0)
end

function meta:SetLDEStat(stat,num) --Modular stat system.
	self:GetStats()[stat]=num
	self:PersistSyncData("Stats")
end

function meta:GetLDEStat(stat) --Modular stat system.
	return self:GetStats()[stat] or 0
end

function meta:SetLDEString(name,str)
	self:GetStrings()[name] = str or ""
	self:PersistSyncData("Stats")
end

function meta:GetLDEString(name)
	return self:GetStrings()[name] or "Error"
end

function meta:SetLDERole(role)
	self:SetLDEString("Role",role)
end

function meta:GetLDERole()
	return self:GetLDEString("Role")
end
