local ScorF = "scoreboard/"
local LoadFile = EnvX.LoadFile

LoadFile(ScorF.."player_frame.lua",0)
LoadFile(ScorF.."player_infocard.lua",0)
LoadFile(ScorF.."player_row.lua",0)
LoadFile(ScorF.."scoreboard.lua",0)

if CLIENT then
	EnvironmentXBoard = nil
	
	timer.Simple( 1.5, function()
		
		function GAMEMODE:CreateScoreboard()
		
			if ( ScoreBoard ) then
			
				ScoreBoard:Remove()
				ScoreBoard = nil
				
			end
			
			EnvironmentXBoard = vgui.Create( "EnvironmentXBoard" )
			
			return true

		end
		
		function GAMEMODE:ScoreboardShow()
		
			if not EnvironmentXBoard then
				self:CreateScoreboard()
			end

			GAMEMODE.ShowScoreboard = true
			gui.EnableScreenClicker( true )

			EnvironmentXBoard:SetVisible( true )
			EnvironmentXBoard:UpdateScoreboard( true )
			
			return true

		end
		
		function GAMEMODE:ScoreboardHide()
		
			GAMEMODE.ShowScoreboard = false
			gui.EnableScreenClicker( false )

			EnvironmentXBoard:SetVisible( false )
			
			return true
			
		end
		
	end )
end		