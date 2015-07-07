local ScorF = "scoreboard/"
local LoadFile = EnvX.LoadFile
local Utl = EnvX.Utl
local NDat = Utl.NetMan

LoadFile(ScorF.."player_frame.lua",0)
LoadFile(ScorF.."player_infocard.lua",0)
LoadFile(ScorF.."player_row.lua",0)
LoadFile(ScorF.."scoreboard.lua",0)

if SERVER then
	local SID = {}
	SID.PIRATE = {}
	SID.CADM = {}
	SID.CSUADM = {}
	--DO NOT ADD STEAMIDS TO THIS LIST THIS IS FOR PIRATE TESTING AND WILL NOT STAY HERE FOR LONG
	--DO NOT CHANGE STEAMIDS ON THIS LIST
	--PIRATE SCOREBOARD IS BUGGY AND CAN CAUSE PROBLEMS IF YOU ADD YOURSELF OR OTHERS
	SID.PIRATE["STEAM_0:1:21922427"] = true
	SID.PIRATE["STEAM_0:1:28479052"] = true
	SID.PIRATE["STEAM_0:1:23264416"] = true
	--SID.PIRATE["STEAM_0:1:65509848"] = true
	
	--JUST A CONCEPT DONT ADD TO THIS EITHER
	--SID.CADM["STEAM_0:1:65509848"] = true
		
	--ANOTHER CONCEPT DO NOT ENTER TO THIS EITHER
	SID.CSUADM["STEAM_0:1:65509848"] = true
	
	NDat.AddDataAll({Name="EnvX_ScoreboardData",Val=1,Dat={SID}})
else
--if CLIENT then
	EnvironmentXBoard = nil

	timer.Simple(1.5, function()	--This is needed. No fucking clue why
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
	end)
end		
