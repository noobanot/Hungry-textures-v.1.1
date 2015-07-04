-- Line 159 and 174 Infocard disabled TBI
local t = {}
t.font = "verdana"
t.size = 16
t.weight = 400
t.additive = true
t.antialias = false
surface.CreateFont("ScoreboardPlayerName", t )

local texGradient = surface.GetTextureID( "gui/center_gradient" )

local PANEL = {}


/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Paint()

	local color = Color( 155, 100, 155, 255 )

	if ( self.Armed ) then
		color = Color( 125, 125, 125, 255 )
	end
	
	if ( self.Selected ) then
		color = Color( 125, 125, 125, 255 )
	end
	
	if IsValid( self.Player:Team() == TEAM_CONNECTING ) then
		color = Color( 100, 100, 100, 155 )
	elseif ( self.Player:IsValid() ) then
		if ( team.GetName(self.Player:Team() ) == "Unassigned") then
		//if ( tostring(self.Player:Team()) == tostring("1001") ) then
			color = Color( 155, 0, 155, 255 )
		else	
			tcolor = team.GetColor(self.Player:Team())
			color = Color(tcolor.r,tcolor.g,tcolor.b,225)
		end
	elseif ( self.Player:IsAdmin() ) then
		color = Color( 0, 155, 0, 255 )
	end
	
	if ( self.Player == LocalPlayer() ) then
	
		tcolor = team.GetColor(self.Player:Team())
		color = Color(tcolor.r,tcolor.g,tcolor.b,255)
	
	end

	if ( self.Open || self.Size != self.TargetSize ) then
	
		draw.RoundedBox( 4, 18, 16, self:GetWide()-36, self:GetTall() - 16, color )
		draw.RoundedBox( 4, 20, 16, self:GetWide()-40, self:GetTall() - 16 - 2, Color( 225, 225, 225, 150 ) )
		
		surface.SetTexture( texGradient )
		surface.SetDrawColor( 0, 0, 0, 100 )
		surface.DrawTexturedRect( 20, 16, self:GetWide()-40, self:GetTall() - 16 - 2 ) 
	
	end
	
	draw.RoundedBox( 4, 18, 0, self:GetWide()-36, 38, color )
	
	surface.SetTexture( texGradient )
	surface.SetDrawColor( 0, 0, 0, 150 )
	surface.DrawTexturedRect( 0, 0, self:GetWide()-36, 38 ) 
	
	//surface.SetTexture( self.texRating )
	//surface.SetDrawColor( 255, 255, 255, 255 )
	//surface.DrawTexturedRect( 20, 4, 16, 16 ) 
	
	return true

end

/*---------------------------------------------------------
   Name: SetPlayer
---------------------------------------------------------*/
function PANEL:SetPlayer( ply )

	self.Player = ply
	
	self.infoCard:SetPlayer( ply )
	self.infoCard:SetPlayer( ply )
	
	self:UpdatePlayerData()
	
	self.imgAvatar:SetPlayer( ply )

end

/*---------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------*/
function PANEL:UpdatePlayerData()

	if ( !self.Player ) then return end
	if ( !self.Player:IsValid() ) then return end

	// self.lblName:SetText( team.GetName(self.Player:Team()) .." - ".. self.Player:Nick()  )
	self.lblName:SetText( self.Player:Nick() )
	self.lblTeam:SetText( team.GetName(self.Player:Team()) )
	self.lblPing:SetText( self.Player:Ping() )
	self.lblMoney:SetText( math.floor(self.Player:GetLDEStat("Cash")))

end

/*---------------------------------------------------------
   Name: Init
---------------------------------------------------------*/
function PANEL:Init()

	self.Size = 38
	self:OpenInfo( false )
	
	self.infoCard	= vgui.Create( "ScorePlayerInfoCard", self )
	
	self.lblName 	= vgui.Create( "DLabel", self )
	self.lblTeam 	= vgui.Create( "DLabel", self )
	self.lblPing 	= vgui.Create( "DLabel", self )
	self.lblMoney   = vgui.Create( "DLabel", self )
		
	// If you don't do this it'll block your clicks
	self.lblName:SetMouseInputEnabled( false )
	self.lblTeam:SetMouseInputEnabled( false )
	self.lblPing:SetMouseInputEnabled( false )	
	self.lblMoney:SetMouseInputEnabled( false )
	
	self.imgAvatar = vgui.Create("AvatarImage", self)
end

/*---------------------------------------------------------
   Name: ApplySchemeSettings
---------------------------------------------------------*/
function PANEL:ApplySchemeSettings()
	self.lblName:SetFont( "ScoreboardPlayerName" )
	self.lblTeam:SetFont( "ScoreboardPlayerName" )
	self.lblPing:SetFont( "ScoreboardPlayerName" )
	self.lblMoney:SetFont( "ScoreboardPlayerName" )	
	
	self.lblName:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblTeam:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblPing:SetFGColor( Color( 0, 0, 0, 255 ) )
	self.lblMoney:SetFGColor( Color( 0, 0, 0, 255 ) )
end

/*---------------------------------------------------------
   Name: DoClick
---------------------------------------------------------*/
function PANEL:DoClick()

	if ( self.Open ) then
		surface.PlaySound( "ui/buttonclickrelease.wav" )
	else
		surface.PlaySound( "ui/buttonclick.wav" )
	end

	self:OpenInfo( !self.Open )

end

/*---------------------------------------------------------
   Name: OpenInfo
   ---------------------------------------------------------*/
function PANEL:OpenInfo( bool )
	/* Infocard disabled TBI
	if ( bool ) then
		self.TargetSize = 154
	else
		self.TargetSize = 38     //*********************************************
	end
	
	self.Open = bool
	*/
end

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function PANEL:Think()
	/* Infocard disabled TBI
	if ( self.Size != self.TargetSize ) then
	
		self.Size = math.Approach( self.Size, self.TargetSize, (math.abs( self.Size - self.TargetSize ) + 1) * 10 * FrameTime() )
		self:PerformLayout()
		SCOREBOARD:InvalidateLayout()
	//	self:GetParent():InvalidateLayout()
	
	end
	*/
	if ( !self.PlayerUpdate || self.PlayerUpdate < CurTime() ) then
	
		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()
		
	end

end

/*---------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------*/
function PANEL:PerformLayout()

	self:SetSize( self:GetWide(), self.Size )        //***************************************************************************
	
	self.lblName:SizeToContents()
	self.lblName:SetPos( 60, 3 )
	
	self.imgAvatar:SetPos( 21, 4 ) 
 	self.imgAvatar:SetSize( 32, 32 )
	//self.lblBounty:SizeToContents()
	local COLUMN_SIZE = 45
	
	self.lblPing:SetPos( self:GetWide() - COLUMN_SIZE * 1, 0 )
	self.lblTeam:SizeToContents()
	self.lblTeam:SetPos( self:GetWide() - COLUMN_SIZE * 8.5, 3 )
	
	self.lblMoney:SizeToContents()
	self.lblMoney:SetPos( self:GetWide() - COLUMN_SIZE * 10.4, 3 )
	
	if ( self.Open || self.Size != self.TargetSize ) then
		self.infoCard:SetVisible( true )
		self.infoCard:SetPos( 18, self.lblName:GetTall() + 27 )
		self.infoCard:SetSize( self:GetWide() - 36, self:GetTall() - self.lblName:GetTall() + 5 )
	
	else
	
		self.infoCard:SetVisible( false )
	
	end

	

end

/*---------------------------------------------------------
   Name: HigherOrLower
---------------------------------------------------------*/
function PANEL:HigherOrLower( row )

	if ( self.Player:Team() == TEAM_CONNECTING ) then return false end
	if ( row.Player:Team() == TEAM_CONNECTING ) then return true end
	
	if ( self.Player:Team() ~= row.Player:Team() ) then
		return self.Player:Team() < row.Player:Team()
	end
	
	if ( self.Player:Frags() == row.Player:Frags() ) then
	
		return self.Player:Deaths() < row.Player:Deaths()
	
	end

	return self.Player:Frags() > row.Player:Frags()

end

vgui.Register( "ScorePlayerRow", PANEL, "Button" )