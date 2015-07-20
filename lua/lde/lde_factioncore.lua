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
		local ID = ply:SteamID()
		Factions.Players[ID] = Faction.Name
		ply.EnvxFaction = Faction.Name
	end
	
	function Factions.CreateFaction(Name,Members,Settings)
		local Faction = table.Copy(Factions.BaseFaction)
		
		Faction:Setup(Name,Members,Settings)
		
		LDE.Factions.Factions[Name] = Faction
	end

	local FilePath = Persist.FileLocalPath().."envx_factions/"
	local FileName = "factions"
	
	function Factions.SaveFactions()
		local SaveData = {Version=1,Factions={},Players={}}
		for k,v in pairs(LDE.Factions.Factions) do
			SaveData.Factions[k]={Name=v.Name,Members=v.Members,Settings=v.Settings}
		end
		
		SaveData.Players = Factions.Players
		
		Persist.SavePersist(FilePath,FileName,SaveData)
	end
	Utl:SetupThinkHook("EnvxFactionsAutoSave",10,0,function() Factions.SaveFactions() end)
	
	function Factions.LoadFactions() 
		local Loaded = Persist.LoadPersist(FilePath,FileName,{Version=0,Factions={},Players={}})
		
		if Version == 1 then
			for k,v in pairs(Loaded.Factions) do
				Factions.CreateFaction(v.Name,v.Members,v.Settings)
			end
			
			Factions.Players = Loaded.Players
		end
	end
	
	Factions.LoadFactions()
else

end