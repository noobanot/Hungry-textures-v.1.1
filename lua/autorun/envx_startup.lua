------------------------------------------
//  Jupiter Engine GameMode System      //
------------------------------------------
local start = SysTime()

EnvX = {}
local EnvX = EnvX --MAH SPEED

EnvX.Version = "InDev V:68"
EnvX.Gamemode = "SandBox"
EnvX.EnableMenu = true --Debug Menu
EnvX.DebugMode = "Verbose" 
/*Print to console Debugging variable. 
Types: 
"Verbose" -Prints All Debugging messages.
"Basic"-Prints Basic Debugging messages.
"None"-Doesnt print to console at all.
*/ 
print("==============================================")
print("==       Environments X    Loading...       ==")
print("==============================================")

include("envx/load.lua")
if SERVER then AddCSLuaFile("envx/load.lua") end
local LoadFile = EnvX.LoadFile --Lel Speed.

Environments = Environments or {}

LoadFile("envx/sh_debug.lua",1)
LoadFile("envx/sh_utility.lua",1)
LoadFile("envx/sh_networking.lua",1)

LoadFile("envx/sh_envxload.lua",1)

--Lets Load our configs....
local Loaded = util.JSONToTable(file.Read("envx.txt","DATA") or "") or {Config={},GlobalConfig={}}

EnvX.Config = Loaded.Config
EnvX.GlobalConfig = Loaded.GlobalConfig

function EnvX.Save()
	file.Write("envx.txt", util.TableToJSON({Config = EnvX.Config, GlobalConfig=EnvX.GlobalConfig}))
end

hook.Add("Shutdown","EnvX SaveSettings",EnvX.Save)

concommand.Add("envx_saveconfig", function(ply,cmd,args) 
	if ply:IsValid() and not ply:IsAdmin() then return end
	
	EnvX.Save()
end)

--Set Default configs.
for k,v in pairs({scoreboard=false}) do
	if EnvX.Config[k] == nil then EnvX.Config[k] = v end
end
--Run Config
--Yay scoreboard can go fuck itself repeatedly
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

if !SinglePlayer then
	SinglePlayer = game.SinglePlayer
end

if file.Open then
	local oldex = file.Exists
	function file.Exists(path, sub)
		if sub then
			if type(sub) == "boolean" and sub == true then
				return oldex(path, "GAME");
			else
				return oldex(path, sub);
			end
		else
			return oldex(path, "DATA");
		end
	end
end

print("==============================================")
print("==        Environments X    Installed       ==")
print("==============================================")
print("EnvironmentsX Load Time: "..(SysTime() - start))
