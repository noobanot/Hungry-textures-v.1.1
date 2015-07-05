/*
----------LudOS Core Logic-------------
Created by ludsoe.
*/

local low = string.lower

--Create the Core.
LudCore = {Names={"ludos","server","los","os"}}
local LudCore = LudCore

function LudCore.Initialize()
	LudCore.LudOS = {Version="Offline",Commands={},Functions={},ClassAlias={}}
	LudCore.LoadFunctions()
	LudCore.DownloadUpdate()
end

function LudCore.IsAdmin(ply)
	return false
end

--Response system. Delayed so its after the players chat.
function LudCore.Response(Text)
	timer.Simple(0.01,function() LDE:NotifyPlayers("LudOS",Text,{r=0,g=180,b=180}) end)
end

function LudCore.IsForLudOS(str)
	local lower = low(str)
	for _, name in ipairs( LudCore.Names ) do
		if low(name) == lower then
			return true
		end
	end
	return false
end

function LudCore.FindPlayerByName(name)
	if not name then return end
	
	for k,v in pairs(player.GetAll()) do 
		local ply = low(v:Name())
		if ply == name then
			return v
		else
			if string.find(ply,name) then
				return v
			end
		end
	end
end

function LudCore.RegisterClassAlias(Alias,Class) end

function LudCore.RegisterCommand(Name,KeyWords,Function)
	table.insert(LudCore.LudOS.Commands,{Name=Name,KeyWords=KeyWords,Function=Function})
end

function LudCore.ParseString(str,key,args)
	--print(tostring(key))
	if type(key) == "string" then
		--print("Comparing.. "..str.." and "..key)
		if key == "(varg)" then
			table.insert(args,str)
			return true
		else
			return str==low(key)
		end
	else
		for _, alias in ipairs( key ) do
			if LudCore.ParseString(str,alias,args) then
				return true
			end
		end
	end
	
	return false
end

function LudCore.ProcessCommand(ply,cmd,teamchat)
	--print("Chat Detected!")
	--Don't return anything it will override the players text.
	local explode = string.Explode(" ",cmd)
	if not LudCore.IsForLudOS(explode[1]) then return end --chat wasnt directed at ludos
	
	for i, exstr in pairs( explode ) do
		explode[i]=low(exstr)
	end
	--print("Chat is for LudOS")
	
	for _, cmd in ipairs( LudCore.LudOS.Commands ) do
		local Args = {}
		local IsCommand = true
		--PrintTable(cmd)
		--print("checking command: "..tostring(cmd.Name))
		for i, exstr in ipairs( explode ) do
			--print(tostring(exstr))
			if i == 1 then continue end
			
			--print("true")
			
			if not LudCore.ParseString(exstr,cmd.KeyWords[i-1],Args) then
				--print("not a command")
				IsCommand = false
				break
			end
		end
		
		if IsCommand then
			cmd.Function(ply,Args)
			return
		end
	end
	LudCore.Response("I don't know what you want..")
end
EnvX.Utl:HookHook("PlayerSay","ludoscommandcheck",LudCore.ProcessCommand,1)

function LudCore.LoadFunctions()
	LudCore.RegisterCommand("Kill",{{"kill","slay"},"(varg)"},function(ply,args)
		local target = args[1]
		
		if not target then return end
		
		if target == "me" then
			if ply:Alive() then
				LudCore.Response("Here you go.")
				ply:Kill()
			else
				LudCore.Response("But you're already dead....")
			end
		else
			if LudCore.IsAdmin(ply) then
				local find = LudCore.FindPlayerByName(target)
				if not IsValid(find) then 
					LudCore.Response("Couldn't Find em.")
				end
				
				if not LudCore.IsAdmin(find) then
					if find:Alive() then
						find:Kill()
						LudCore.Response("Killing "..find:Name())
					else
						LudCore.Response("They are already dead.")
					end
				else
					LudCore.Response("Nope.")
				end
			else
				LudCore.Response("Sorry, I can't do that for you.")
			end
		end
	end)

	LudCore.RegisterCommand("PropCount",{{"how","count"},{"many","the"},{"props","entities","entitys"},{"are","in"},{"this","in","that"},{"this","that"}},function(ply,args)
		local looking = ply:GetEyeTrace()
		if looking.Hit then
			if looking.HitNonWorld then
				if looking.Entity then
					local Cons = constraint.GetAllConstrainedEntities(looking.Entity)
					LudCore.Response("That is made up of "..table.Count(Cons).." Props/Entities.")
				end
			else
				LudCore.Response("That's the world.")
			end
		else
			LudCore.Response("You're not looking at anything!")
		end
	end)
	
	LudCore.RegisterCommand("VersionCheck",{{"version","ver","vers"}},function(ply,args)
		LudCore.Response("I'm Running on Version: "..LudCore.LudOS.Version)
	end)

	LudCore.RegisterCommand("Update",{{"update"}},function(ply,args)
		LudCore.Response("Alright, Updating My Core files.")
		LudCore.Initialize()
	end)
end

function LudCore.DownloadUpdate()
	http.Fetch( "http://www.mediafire.com/download/ki42z2ldlus18ar/LudOsOnlineLibrary.txt",
		function( body, len, headers, code )
			CompileString(body,"ludosupdate")()
		end,
		function( error )
			--Update Unsuccessfull....
			print("No Update...")
		end
	)	
end

LudCore.Initialize()














