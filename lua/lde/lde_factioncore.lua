/*
----------------------------------------------
----------------Faction Core------------------
----------------------------------------------
*/
local LDE = LDE --Localise the global table for speed.
local Utl = EnvX.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.
local Persist = EnvX.Persist

LDE.Factions = LDE.Factions or {Factions={},Players={}}
local Factions = LDE.Factions

if SERVER then
	Utl:HookHook("PlayerInitialSpawn","EnvxFactionPlayer",function(ply)
		local ID = ply:SteamID()
		local Faction = Factions.Players[ID]
		if not Faction then
			Factions.Players[ID]=""
		else
			Factions.PlayerSetFaction(ply,Factions.Factions[Faction])
		end
	end,1)
	
	function Factions.PlayerSetFaction(ply,Faction)
		local ID,FName = ply:SteamID(),Faction.Info.Name
		Factions.Players[ID] = FName
		ply.EnvxFaction = FName
	end
	
	function Factions.CreateFaction(Info,Members,Settings)
		local Faction = table.Copy(Factions.BaseFaction)
		
		Faction:Setup(Info,Members,Settings)
		
		LDE.Factions.Factions[Info.Name] = Faction
	end
	concommand.Add("lde_generatefactiontest",function() Factions.CreateFaction({Name="Test"}) end)
	
	local FilePath = Persist.FileLocalPath().."envx_factions/"
	local FileName = "factions"
	
	function Factions.SaveFactions()
		local SaveData = {Version=1,Factions={},Players={}}
		for k,v in pairs(LDE.Factions.Factions) do
			SaveData.Factions[k]={Info=v.Info,Members=v.Members,Settings=v.Settings}
		end
		
		SaveData.Players = Factions.Players
		
		Persist.SavePersist(FilePath,FileName,SaveData)
	end
	Utl:SetupThinkHook("EnvxFactionsAutoSave",10,0,function() Factions.SaveFactions() end)
	
	function Factions.LoadFactions() 
		local Loaded = Persist.LoadPersist(FilePath,FileName,{Version=0,Factions={},Players={}})
		
		if Version == 1 then
			for k,v in pairs(Loaded.Factions) do
				Factions.CreateFaction(v.Info,v.Members,v.Settings)
			end
			
			Factions.Players = Loaded.Players		
		end
	end
	
	Factions.LoadFactions()
	
	---Networking side of things.
	
	function Factions.SyncToClients(client)
		local Data = {Factions={}}
		
		--Sync the factions over using the same format as the save system.
		for k,v in pairs(LDE.Factions.Factions) do
			Data.Factions[k]={Info=v.Info,Members=v.Members,Settings=v.Settings}
		end
		
		if client and IsValid(client) then
			NDat.AddData({Name="EnvxFactionsSync",Val=3,Dat=Data},client)
		else
			NDat.AddDataAll({Name="EnvxFactionsSync",Val=3,Dat=Data})
		end
	end
	
	Utl:HookNet("EnvxFactionsSyncRequest",function(Data,ply)
		Factions.SyncToClients(ply)
	end)
	
	Utl:SetupThinkHook("EnvxFactionsAutoSync",10,0,function() Factions.SyncToClients() end)
else
	Utl:HookNet("EnvxFactionsSync",function(Data)
		Factions.Factions = Data.Factions
		
		if Factions.PDAPage and IsValid(Factions.PDAPage) then
			Factions.PDAPage:OnFactionSync()
		end
	end)
end






















