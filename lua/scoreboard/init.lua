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
	SID.PIRATE["STEAM_0:1:21922427"] = false
	SID.PIRATE["STEAM_0:1:28479052"] = false --Red
	SID.PIRATE["STEAM_0:1:23264416"] = false
	SID.PIRATE["STEAM_0:1:65509848"] = false --Rabbid
	
	--JUST A CONCEPT DONT ADD TO THIS EITHER
	SID.CADM["STEAM_0:1:65509848"] = false --Rabbid
	SID.CADM["STEAM_0:1:28479052"] = false --Red
	
	--ANOTHER CONCEPT DO NOT ENTER TO THIS EITHER
	SID.CSUADM["STEAM_0:1:65509848"] = false --Rabbid
	SID.CSUADM["STEAM_0:1:28479052"] = false --Red
	
	--NDat.AddDataAll({Name="EnvX_ScoreboardData",Val=1,Dat={SID}})	
	Utl:HookNet("RequestScoreboardData",function(Data, ply)
		for k,v in pairs(Data) do --TEMP
			Arg = v[1]
			SID.PIRATE[ply:SteamID()] = false
			SID.CSUADM[ply:SteamID()] = false
			SID.CADM[ply:SteamID()] = false
			
			if SID.PIRATE[ply:SteamID()] ~= nil and Arg == "dev1" then
				if SID.PIRATE[ply:SteamID()] then
					SID.PIRATE[ply:SteamID()] = false
				else
					SID.PIRATE[ply:SteamID()] = true
				end
			elseif SID.CSUADM[ply:SteamID()] ~= nil and Arg == "dev2" then
				if SID.CSUADM[ply:SteamID()] then
					SID.CSUADM[ply:SteamID()] = false
				else
					SID.CSUADM[ply:SteamID()] = true
				end
			elseif SID.CADM[ply:SteamID()] ~= nil and Arg == "dev3" then
				if SID.CADM[ply:SteamID()] then
					SID.CADM[ply:SteamID()] = false
				else
					SID.CADM[ply:SteamID()] = true
				end
			end
		end
		
		NDat.AddDataAll({Name="ReplyScoreboardData",Val=1,Dat={SID}})
	end)
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
