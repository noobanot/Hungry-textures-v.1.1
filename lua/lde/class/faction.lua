--Link to global tables here.
local LDE = LDE --Localise the global table for speed.
local Utl = EnvX.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.
local Factions = LDE.Factions

---Lets define the actual class here.
local Class = {
	Name="Error",
	Members = {},
	Diplomacy = {},
	Settings = {Password="",Permanent=false}
}

Class["Ranks"]={
	{Name="Owner",Permissions={EditInfo=true,EditSettings=true,EditRanks=true,EditDiplomacy=true,EditMembers=true}},
	{Name="Member",Permissions={EditInfo=false,EditSettings=false,EditRanks=false,EditDiplomacy=false,EditMembers=false}}
}

--
function Class:Setup(Name,Members,Settings)
	self.Name = Name or "Error"
	self.Members = Members or {}
	
	for k,v in pairs(self.Members) do
		local ply = Utl:GetPlayerbyID(k)
		
		if ply and IsValid(ply) then
			Factions.PlayerSetFaction(ply,self)
		end
	end
	
	for k,v in pairs(Settings or {}) do
		self.Settings[k]=v
	end
end

function Class:AddMember(ply) 
	local ID = ply:SteamID()
	self.Members[ID]=true--Just need a value here.
	Factions.PlayerSetFaction(ply,self)
end

function Class:RemoveMember(ply) 
	local ID = ply:SteamID()
	self.Members[ID]=nil
	
	if not self.Settings.Permanent then
		if table.Count(self.Members)<1 then
			Factions.Factions[self.Name]=nil--Self Destruct
		end
	end
end

--Set the access-able link to our class.
Factions.BaseFaction = Class