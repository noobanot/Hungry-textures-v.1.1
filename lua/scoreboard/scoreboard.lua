local t = {}
t.font = "coolvetica"
t.size = 28
t.weight = 500
t.additive = true
t.antialias = false
surface.CreateFont("ScoreboardHeader",t )
t.size = 20
surface.CreateFont("ScoreboardSubtitle",t )
t.size=75
surface.CreateFont("ScoreboardLogotext",t )
t.font="verdana"
t.size=12
t.weight=400
surface.CreateFont("ScoreboardSctext",t )

local texGradient 	= surface.GetTextureID( "gui/center_gradient" )

local function ColorCmp( c1, c2 )
	if( !c1 || !c2 ) then return false end
	
	return (c1.r == c2.r) && (c1.g == c2.g) && (c1.b == c2.b) && (c1.a == c2.a)
end

local PANEL = {}

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Init()

	SCOREBOARD = self

	self.Hostname = vgui.Create( "DLabel", self )
	self.Hostname:SetText( GetGlobalString( "ServerName" ) )

	self.Logog = vgui.Create( "DLabel", self )
	self.Logog:SetText( "E" )

	self.Sc = vgui.Create( "DLabel", self )
	self.Sc:SetText( "EnvironmentX ScoreBoard" )
	
	self.Description = vgui.Create( "DLabel", self )
	self.Description:SetText( GAMEMODE.Name .. " - " .. GAMEMODE.Author )
	
	self.PlayerFrame = vgui.Create( "PlayerFrame", self )
	
	self.PlayerRows = {}

	self:UpdateScoreboard()
	
	// Update the scoreboard every 1 second
	//timer.Create( "ScoreboardUpdater", 1, 0, function() self.UpdateScoreboard(true) end )
	LDE.Utl:SetupThinkHook("ScoreboardUpdater",1,0,function() 
		 self.UpdateScoreboard(true) 
	end)
	
	self.lblPing = vgui.Create( "DLabel", self )
	self.lblPing:SetText( "Ping" )

	self.lblTeam = vgui.Create( "DLabel", self )
	self.lblTeam:SetText( "Team" )

	self.lblMoney = vgui.Create( "DLabel", self )
	self.lblMoney:SetText( "Money" )
end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:AddPlayerRow( ply )

	local button = vgui.Create( "ScorePlayerRow", self.PlayerFrame:GetCanvas() )
	button:SetPlayer( ply )
	self.PlayerRows[ ply ] = button

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:GetPlayerRow( ply )

	return self.PlayerRows[ ply ]

end

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()

	draw.RoundedBox( 10, 0, 0, self:GetWide(), self:GetTall(), Color( 50, 50, 50, 205 ) )
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 100, 100, 100, 155 )
	surface.DrawTexturedRect( 0, 0, self:GetWide(), self:GetTall() ) 
	
	// White Inner Box
	draw.RoundedBox( 6, 15, self.Description.y - 8, self:GetWide() - 30, self:GetTall() - self.Description.y - 6, Color( 230, 230, 230, 100 ) )
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 50 )
	surface.DrawTexturedRect( 15, self.Description.y - 8, self:GetWide() - 30, self:GetTall() - self.Description.y - 8 )
	
	// Sub Header
	draw.RoundedBox( 6, 108, self.Description.y - 4, self:GetWide() - 128, self.Description:GetTall() + 8, Color( 100, 100, 100, 155 ) )
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 255, 255, 255, 50 )
	surface.DrawTexturedRect( 108, self.Description.y - 4, self:GetWide() - 128, self.Description:GetTall() + 8 ) 
	
	// Logo!
	if( ColorCmp( team.GetColor(21), Color( 255, 255, 100, 255 ) ) ) then
		tColor = Color( 255, 155, 0, 255 )
	else
  		tColor = team.GetColor(21) 		
 	end
	
	if (tColor.r < 255) then
		tColorGradientR = tColor.r + 15
	else 
		tColorGradientR = tColor.r
	end
	if (tColor.g < 255) then
		tColorGradientG = tColor.g + 15
	else 
		tColorGradientG = tColor.g
	end
	if (tColor.b < 255) then
		tColorGradientB = tColor.b + 15
	else 
		tColorGradientB = tColor.b
	end
	draw.RoundedBox( 8, 24, 12, 80, 80, Color( tColor.r, tColor.g, tColor.b, 200 ) )
	surface.SetTexture( texGradient )
	surface.SetDrawColor( tColorGradientR, tColorGradientG, tColorGradientB, 225 )
	surface.DrawTexturedRect( 24, 12, 80, 80 ) 
end


/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self:SetSize( ScrW() * 0.75, ScrH() * 0.65 )
	
	self:SetPos( (ScrW() - self:GetWide()) / 2, (ScrH() - self:GetTall()) / 2 )
	
	self.Hostname:SizeToContents()
	self.Hostname:SetPos( 115, 17 )
	
	self.Logog:SetSize( 80, 80 )
	self.Logog:SetPos( 45, 17 )

	self.Sc:SetSize( 400, 15 )
	self.Sc:SetPos( (self:GetWide() - 400), (self:GetTall() - 15) )
	
	self.Description:SizeToContents()
	self.Description:SetPos( 115, 60 )
	
	self.PlayerFrame:SetPos( 5, self.Description.y + self.Description:GetTall() + 20 )
	self.PlayerFrame:SetSize( self:GetWide() - 10, self:GetTall() - self.PlayerFrame.y - 20 )
	
	local y = 0
	
	local PlayerSorted = {}
	
	for k, v in pairs( self.PlayerRows ) do
	
		table.insert( PlayerSorted, v )
		
	end
	
	table.sort( PlayerSorted, function ( a , b) return a:HigherOrLower( b ) end )
	
	for k, v in ipairs( PlayerSorted ) do
	
		v:SetPos( 0, y )	
		v:SetSize( self.PlayerFrame:GetWide(), v:GetTall() )
		
		self.PlayerFrame:GetCanvas():SetSize( self.PlayerFrame:GetCanvas():GetWide(), y + v:GetTall() )
		
		y = y + v:GetTall() + 1
	
	end
	
	self.Hostname:SetText( GetGlobalString( "ServerName" ) )
	
	self.lblPing:SizeToContents()
	self.lblTeam:SizeToContents()
	self.lblMoney:SizeToContents()
	
	self.lblPing:SetPos( self:GetWide() - 45 - self.lblPing:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
	self.lblTeam:SetPos( self:GetWide() - 45*8.2 - self.lblTeam:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
	self.lblMoney:SetPos( self:GetWide() - 45*10.2 - self.lblTeam:GetWide()/2, self.PlayerFrame.y - self.lblPing:GetTall() - 3  )
end

/*---------------------------------------------------------
   Name: ApplySchemeSettings
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()

	self.Hostname:SetFont( "ScoreboardHeader" )
	self.Description:SetFont( "ScoreboardSubtitle" )
	self.Logog:SetFont( "ScoreboardLogotext" )
	self.Sc:SetFont( "ScoreboardSctext" )
	
	if (ColorCmp( team.GetColor(21), Color( 255, 255, 100, 255 ))) then
		tColor = Color( 255, 155, 0, 255 )
	else
  		tColor = team.GetColor(21) 		
 	end 
	
	self.Hostname:SetFGColor( Color( tColor.r, tColor.g, tColor.b, 255 ) )
	self.Description:SetFGColor( Color( 55, 55, 55, 255 ) )
	self.Logog:SetFGColor( Color( 55, 55, 55, 255 ) )
	self.Sc:SetFGColor( Color( 200, 200, 200, 200 ) )
	
	self.lblPing:SetFont( "DefaultSmall" )
	self.lblTeam:SetFont( "DefaultSmall" )
		
	self.lblPing:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblTeam:SetFGColor( Color( 0, 0, 0, 255 ) )
end


function PANEL:UpdateScoreboard( force )
	me=self
	if ( !force or not me:IsVisible() ) then return end

	for k, v in pairs( self.PlayerRows ) do
	
		if ( !k:IsValid() ) then
		
			v:Remove()
			self.PlayerRows[ k ] = nil
			
		end
	
	end
	
	local PlayerList = player.GetAll()	
	for id, pl in pairs( PlayerList ) do
		
		if ( !self:GetPlayerRow( pl ) ) then
		
			self:AddPlayerRow( pl )
		
		end
		
	end
	
	// Always invalidate the layout so the order gets updated
	self:InvalidateLayout()

end
 
vgui.Register( "EnvironmentXBoard", PANEL, "Panel" )
