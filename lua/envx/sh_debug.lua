--[[----------------------------------------------------
Jupiter Debug Core -Allows Easy Debugging.
----------------------------------------------------]]--

local EnvX = EnvX --Localise the global table for speed.
EnvX.DebugLogs = EnvX.DebugLogs or {}

local DebugTypes = {Verbose=3,Basic=2,None=1}
local DebugMode = DebugTypes["None"]
local DebugLogs = EnvX.DebugLogs

function EnvX.SetDebugMode(Mode)
	if not DebugTypes[Mode] then 
		print("Error! Debug Mode is Invalid! Defaulting to 'None'.") 
		EnvX.DebugMode="None"
		DebugMode = DebugTypes["None"]
		return
	end
	
	EnvX.DebugMode=Mode
	DebugMode = DebugTypes[Mode]
end
EnvX.SetDebugMode(EnvX.DebugMode)

function EnvX.Debug(MSG,Type,Source)
	--print("T: "..tostring(Type).." D: "..tostring(DebugMode))
	if Type <= DebugMode then
		if SERVER then
			print("SD["..tostring(Source or "Error").."]: "..tostring(MSG))
			MsgAll("SD["..tostring(Source or "Error").."]: "..tostring(MSG).."\n")
		else
			print("SD["..tostring(Source or "Error").."]: "..tostring(MSG))
		end
	end
	
	if not SERVER then return end --Add client to server logging later.
	local Log = {C=math.floor(CurTime()),M=MSG}
	if not DebugLogs[Source] then 
		DebugLogs[Source] = {}
	end
	table.insert(DebugLogs[Source],Log)
end




