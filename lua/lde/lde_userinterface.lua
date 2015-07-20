
local Utl = EnvX.Utl
local NDat = Utl.NetMan

if(CLIENT)then
	local MC = EnvX.MenuCore
	MC.PDA = {Menu={}}
	local PDA = MC.PDA
	
	function EnvX.MenuCore.PDA.MenuOpen()
		local PDM = PDA.Menu
		
		MC.CheckOpenFrame(true) --Check for any open guis and remove them.
		
		PDM.Base = EnvX.MenuCore.CreateFrame({x=800,y=600},true,true,false,true)
		PDM.Base:Center()
		PDM.Base:SetTitle( "Environments X PDA V:"..EnvX.Version )
		PDM.Base:MakePopup()
		
		MC.SetOpenFrame(PDM.Base)
		
		PDM.Catagorys = EnvX.MenuCore.CreatePSheet(PDM.Base,{x=790,y=565 },{x=5,y=30})		
		hook.Call("LDEFillCatagorys")
	end
	concommand.Add( "ldepdaopen", EnvX.MenuCore.PDA.MenuOpen )
else
----Server side-----
	print("UserInterface Loading!")
	
	hook.Add( "ShowSpare1", "bindtoSpare1", function(ply) ply:ConCommand( "ldepdaopen" ) end)

	hook.Add( "PlayerSay", "OpenInterface", function( ply, text, public )
		local Chat = string.Explode(" ",text)
		if Chat[1] == "/pda" then
			ply:ConCommand( "ldepdaopen" )
		end
	end)
end

local LoadFile = EnvX.LoadFile --Lel Speed.
local P = "lde/userinterface/"
LoadFile(P.."xmenu/account.lua",1)
LoadFile(P.."xmenu/rttab.lua",1)
LoadFile(P.."xmenu/help.lua",1)
LoadFile(P.."xmenu/debug.lua",1)
LoadFile(P.."xmenu/unlocks.lua",1)
LoadFile(P.."xmenu/stats.lua",1)
LoadFile(P.."xmenu/bugreport.lua",1)
LoadFile(P.."xmenu/factions.lua",1)

LoadFile(P.."factorymenu.lua",1)
LoadFile(P.."missingmodels.lua",1)
LoadFile(P.."motd.lua",1)
LoadFile(P.."trademarkmenu.lua",1)
LoadFile(P.."vendingmenu.lua",1)




