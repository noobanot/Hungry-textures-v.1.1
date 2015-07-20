local LDE = LDE --Localise the global table for speed.
local Utl = EnvX.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.

if(SERVER)then

else
	local MC = EnvX.MenuCore

	hook.Add("LDEFillCatagorys","Factions", function()
		local PDA = MC.PDA.Menu.Catagorys
		
		local base = vgui.Create( "DPanel", PDA ) base.Paint = function() end
		base:SizeToContents()
		PDA:AddSheet( "Factions", base, "icon16/group.png", false, false, "View/Manage Factions" )
		
		
		local x,y = PDA:GetWide(),PDA:GetTall()
		local Sheet = EnvX.MenuCore.CreatePSheet(base,{x=x-25,y=y-50 },{x=5,y=5})		

		local panel = vgui.Create( "DPanel", PDA ) panel.Paint = function() end
		Sheet:AddSheet( "View Factions", panel, "icon16/eye.png", false, false, "View Factions" )
		
		local FL = MC.CreateList(panel,{x=240,y=y-70},{x=0,y=0},false,function(V) end)
		FL:AddColumn("Faction") -- Add column
		
		local Name = MC.CreateText(panel,{x=250,y=5},"Name: Select an faction!")		
		local Desc = MC.CreateAdvText(panel,{x=500,y=160},{x=245,y=30},"Description: Select an faction!")		
		local JoinButton = MC.CreateButton(panel,{x=500,y=20},{x=245,y=200},"Join: Select an faction!",function() end)
		
		local FSheet = EnvX.MenuCore.CreatePSheet(panel,{x=500,y=250},{x=245,y=225})		
		
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
	