------------------------------------------
//  Jupiter Engine GameMode System      //
------------------------------------------
print("==============================================")
print("==       Environments X    Loading...       ==")
print("==============================================")

local start = SysTime()

EnvX = {}
local EnvX = EnvX --MAH SPEED

EnvX.Version = "InDev V:75"
EnvX.Gamemode = "SandBox"
EnvX.EnableMenu = true --Debug Menu
EnvX.DebugMode = "Verbose" 
/*Print to console Debugging variable. 
Types: 
"Verbose" -Prints All Debugging messages.
"Basic"-Prints Basic Debugging messages.
"None"-Doesnt print to console at all.
*/ 
 
include("envx/load.lua")
if SERVER then AddCSLuaFile("envx/load.lua") end
local LoadFile = EnvX.LoadFile --Lel Speed.

Environments = Environments or {}

LoadFile("envx/sh_debug.lua",1)
LoadFile("envx/sh_utility.lua",1)
LoadFile("envx/sh_networking.lua",1)
LoadFile("envx/sh_datamanagement.lua",1)

LoadFile("envx/sh_envxload.lua",1)

LoadFile("scoreboard/init.lua",1) 

if CLIENT then
	function Load(msg)
		local Engine = net.ReadFloat()
		if Engine > 0 then
			--include("envx/core/engine/cl_core.lua")
			EnvX.SpaceEngine = true
		else
			EnvX.SpaceEngine = false
		end
		
		local function Reload()
			include("vgui/hud.lua")
			LoadHud()
		end
		concommand.Add("envx_reload_hud", Reload)
        Reload()
	end
	net.Receive( "Jupiter_Init", Load)
	
	language.Add( "worldspawn", "World" )
	language.Add( "trigger_hurt", "Environment" )
else
	hook.Add("GetGameDescription", "EnvironmentsGamemode", function() 
		return "Environments X"
	end)
	
	--Adding Clientside Files.
	AddCSLuaFile("autorun/envx_startup.lua")

	resource.AddFile("resource/fonts/digital-7 (italic).ttf")
end

print("==============================================")
print("==        Environments X    Installed       ==")
print("==============================================")
print("EnvironmentsX Load Time: "..(SysTime() - start))
