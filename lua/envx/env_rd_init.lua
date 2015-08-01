//Creates Tools
AddCSLuaFile("weapons/gmod_tool/envx_tool_base.lua")

if not Environments then
	Environments = {}
end

local LoadFile = EnvX.LoadFile --Lel Speed.
local P = "environments/"

LoadFile(P.."init.lua",2)

LoadFile(P.."cl_init.lua",0)

LoadFile(P.."userinterface.lua",1)
LoadFile(P.."shared.lua",1)
LoadFile(P.."easecreation.lua",1)
LoadFile(P.."entregister.lua",1)

print("==============================================")
print("== Environments Life Support Ents Installed ==")
print("==============================================")

local P = "environments/lifesupport/"
LoadFile(P.."autorun_ludtech.lua",1)
LoadFile(P.."ls_core_entities_merged.lua",1)
LoadFile(P.."ls3_reversecompatability.lua",1)

//Load devices and stuff from addons --Disabled to increase performance. (And other reasons)
--[[
local Files
if file.FindInLua then
	Files = file.FindInLua( "environments/lifesupport/*.lua" )
else//gm13
	Files = file.Find("environments/lifesupport/*.lua", "LUA")
end

for k, File in ipairs(Files) do
	Msg("Loading: "..File.."...\n")
	local ErrorCheck, PCallError = pcall(include, "environments/lifesupport/"..File)
	ErrorCheck, PCallError = pcall(AddCSLuaFile, "environments/lifesupport/"..File)
	if !ErrorCheck then
		Msg(PCallError.."\n")
	else
		Msg("Loaded: Successfully\n")
	end
end]]
