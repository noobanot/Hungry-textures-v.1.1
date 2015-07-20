--Link to global tables here.
local LDE = LDE --Localise the global table for speed.
local Utl = EnvX.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.
local Factions = LDE.Factions

---Lets define the actual class here.
local Class = {
	Members = {},
	Diplomacy = {},
	Info = {Name="Error",Desc="This faction hasn't provided a description yet!"},
	Settings = {Password="",Permanent=false}
}

--Players will create and manage their own ranks, this is just to get them started...
Class["Ranks"]={
	{Name="Owner",Permissions={EditInfo=true,EditSettings=true,EditRanks=true,EditDiplomacy=true,EditMembers=true}},
	{Name="Member",Permissions={EditInfo=false,EditSettings=false,EditRanks=false,EditDiplomacy=false,EditMembers=false}}
}

--
function Class:Setup(Info,Members,Settings)
	self.Members = Members or {}
	
	for k,v in pairs(Info) do
		self.Info[k]=v
	end
	
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

function Class:AlertMembers(str)
	for k,v in pairs(self.Members) do
		local ply = Utl:GetPlayerbyID(k)
		if ply and IsValid(ply) then
			ply:SendColorChat("Faction",EnvX.GuiThemeColor.Text,str)
		end
	end
end

function Class:ChangeSetting(setting,value)
	self.Settings[setting]=value
	self:AlertMembers("Faction Setting: "..tostring(setting).." Changed to "..tostring(value))
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