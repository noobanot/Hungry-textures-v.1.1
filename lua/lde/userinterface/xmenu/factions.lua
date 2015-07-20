local LDE = LDE --Localise the global table for speed.
local Utl = EnvX.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.
local Factions = LDE.Factions

if(SERVER)then

else
	local MC = EnvX.MenuCore

	hook.Add("LDEFillCatagorys","Factions", function()
		local PDA = MC.PDA.Menu.Catagorys
		
		local base = vgui.Create( "DPanel", PDA ) base.Paint = function() end
		base:SizeToContents()
		PDA:AddSheet( "Factions", base, "icon16/group.png", false, false, "View/Manage Factions" )
		
		Factions.PDAPage = base --Tell the faction module where we are.
		
		function base:OnFactionSync()
			base.FactionList:Clear()--Remove old data.
			
			for k,v in pairs(Factions.Factions) do
				base.FactionList:AddLine(v.Info.Name)
			end
		end
		
		local x,y = PDA:GetWide(),PDA:GetTall()
		local Sheet = EnvX.MenuCore.CreatePSheet(base,{x=x-25,y=y-50 },{x=5,y=5})		

		NDat.AddData({Name="EnvxFactionsSyncRequest",Val=1,Dat={}})
		local panel = vgui.Create( "DPanel", PDA ) panel.Paint = function() end
		Sheet:AddSheet( "View Factions", panel, "icon16/eye.png", false, false, "View Factions" )
		
		local FL = MC.CreateList(panel,{x=240,y=y-70},{x=0,y=0},false,function(V)
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
		base.JoinButton = MC.CreateButton(panel,{x=500,y=20},{x=245,y=200},"Join: Select an faction!",function()
			--Send join request...
		end)
		
		local FSheet = EnvX.MenuCore.CreatePSheet(panel,{x=500,y=250},{x=245,y=225})		
		base.FactionInfo = FSheet
		
		function FSheet:DisplayFactionInfo(Faction)
			
		end
		
		local panel = vgui.Create( "DPanel", FSheet ) base.Paint = function() end
		FSheet:AddSheet( "Members", panel, "icon16/group.png", false, false, "View Members" )

		local panel = vgui.Create( "DPanel", FSheet ) base.Paint = function() end
		FSheet:AddSheet( "Alliances", panel, "icon16/calendar.png", false, false, "View Alliances" )

		local panel = vgui.Create( "DPanel", FSheet ) base.Paint = function() end
		FSheet:AddSheet( "Statistics", panel, "icon16/chart_curve.png", false, false, "View Statistics" )
		
		local panel = vgui.Create( "DPanel", FSheet ) base.Paint = function() end
		FSheet:AddSheet( "Ranks", panel, "icon16/layout.png", false, false, "View Ranks" )
		
		local panel = vgui.Create( "DPanel", PDA )
		panel.Paint = function() end
		Sheet:AddSheet( "Manage My Faction", panel, "icon16/bullet_wrench.png", false, false, "Manage your Factions" )

	end)
end		
	