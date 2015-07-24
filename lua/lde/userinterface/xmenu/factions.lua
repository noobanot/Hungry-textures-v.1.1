local LDE = LDE --Localise the global table for speed.
local Utl = EnvX.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.
local Factions = LDE.Factions

if(SERVER)then
	Utl:HookNet("EnvxFactionsJoinRequest",function(Data,ply)
		Factions.Factions[Data.Faction]:AddMember(ply)
	end)
else
	local MC = EnvX.MenuCore

	hook.Add("LDEFillCatagorys","Factions", function()
		local PDA = MC.PDA.Menu.Catagorys
		
		local base = vgui.Create( "DPanel", PDA ) base.Paint = function() end
		base:SizeToContents()
		PDA:AddSheet( "Factions", base, "icon16/group.png", false, false, "View/Manage Factions" )
		
		Factions.PDAPage = base --Tell the faction module where we are.
		
		function base:OnFactionSync()
			local FL = base.FactionList
			FL:Clear()--Remove old data.
			
			for k,v in pairs(Factions.Factions) do
				FL:AddLine(v.Info.Name)
			end
		end
		
		local x,y = PDA:GetWide(),PDA:GetTall()
		local Sheet = EnvX.MenuCore.CreatePSheet(base,{x=x-25,y=y-50 },{x=5,y=5})		

		NDat.AddData({Name="EnvxFactionsSyncRequest",Val=1,Dat={}})
		local panel = vgui.Create( "DPanel", PDA ) panel.Paint = function() end
		Sheet:AddSheet( "View Factions", panel, "icon16/eye.png", false, false, "View Factions" )
		
		local FL = MC.CreateList(panel,{x=240,y=y-90},{x=0,y=0},false,function(V)
			local Faction = Factions.Factions[V]
			
			base.FactionName:SetText("Name: "..Faction.Info.Name)
			base.FactionDesc:SetText("Description: "..Faction.Info.Desc)
			base.JoinButton:SetText("Join: "..Faction.Info.Name)
			
			base.JoinButton.SelectedFaction = Faction
		
			base.FactionInfo:DisplayFactionInfo(Faction)
		end)
		FL:AddColumn("Faction") -- Add column
		
		base.FactionList = FL
		base.FactionName = MC.CreateText(panel,{x=250,y=5},"Name: Select an faction!")		
		base.FactionDesc = MC.CreateAdvText(panel,{x=500,y=160},{x=245,y=30},"Description: Select an faction!")		
		base.JoinButton = MC.CreateButton(panel,{x=500,y=20},{x=245,y=200},"Join: Select an faction!",function(self)
			--Make pop up for when faction has a password.
			if self.SelectedFaction ~= nil then
				NDat.AddData({Name="EnvxFactionsJoinRequest",Val=1,Dat={Faction=self.SelectedFaction.Info.Name}})
			end
		end)
		
		local FSheet = EnvX.MenuCore.CreatePSheet(panel,{x=500,y=250},{x=245,y=225})		
		base.FactionInfo = FSheet
		
		function FSheet:DisplayFactionInfo(Faction)
			local ML,AL,SL,RL = self.MemberList,self.AllianceList,self.StatisticList,self.RankList
			ML:Clear() RL:Clear()
			
			for k,v in pairs(Faction.Members) do
				ML:AddLine(v.Nick,v.Rank)
			end
			
			for k,v in pairs(Faction.Ranks) do
				RL:AddLine(v.Name)
			end
		end
		
		local panel = vgui.Create( "DPanel", FSheet ) panel.Paint = function() end
		FSheet:AddSheet( "Members", panel, "icon16/group.png", false, false, "View Members" )
		
		local L = MC.CreateList(panel,{x=500,y=200},{x=0,y=0},false,function(V) end)
		L:AddColumn("Player") L:AddColumn("Rank")
		FSheet.MemberList = L
		
		local panel = vgui.Create( "DPanel", FSheet ) panel.Paint = function() end
		FSheet:AddSheet( "Alliances", panel, "icon16/calendar.png", false, false, "View Alliances" )
		
		local L = MC.CreateList(panel,{x=500,y=200},{x=0,y=0},false,function(V) end)
		L:AddColumn("Faction") L:AddColumn("Relation")
		FSheet.AllianceList = L
		
		local panel = vgui.Create( "DPanel", FSheet ) panel.Paint = function() end
		FSheet:AddSheet( "Statistics", panel, "icon16/chart_curve.png", false, false, "View Statistics" )
		
		local L = MC.CreateList(panel,{x=500,y=200},{x=0,y=0},false,function(V) end)
		L:AddColumn("Statistic") L:AddColumn("Value")
		FSheet.StatisticList = L
		
		local panel = vgui.Create( "DPanel", FSheet ) panel.Paint = function() end
		FSheet:AddSheet( "Ranks", panel, "icon16/layout.png", false, false, "View Ranks" )
		
		local L = MC.CreateList(panel,{x=500,y=200},{x=0,y=0},false,function(V) end)
		L:AddColumn("Rank")
		FSheet.RankList = L
		
		local panel = vgui.Create( "DPanel", PDA ) panel.Paint = function() end
		Sheet:AddSheet( "Manage My Faction", panel, "icon16/bullet_wrench.png", false, false, "Manage your Factions" )
		
		local FSheet = EnvX.MenuCore.CreatePSheet(panel,{x=740,y=465},{x=5,y=5})
		
		local panel = vgui.Create( "DPanel", FSheet ) panel.Paint = function() end
		FSheet:AddSheet( "Members", panel, "icon16/group.png", false, false, "Manage Members" )
		
		local panel = vgui.Create( "DPanel", FSheet ) panel.Paint = function() end
		FSheet:AddSheet( "Settings", panel, "icon16/bullet_wrench.png", false, false, "Manage Settings" )
		
		local panel = vgui.Create( "DPanel", FSheet ) panel.Paint = function() end
		FSheet:AddSheet( "Ranks", panel, "icon16/layout.png", false, false, "Manage Ranks" )
	end)
end		
	