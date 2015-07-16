local EnvX = EnvX --Gonna Need all the speed we can get.

print("-----Loading DataManagement Module-----")

EnvX.Persist = EnvX.Persist or {}
local Persist = EnvX.Persist

Persist.DataFolder = "envxdata"

--Make sure we have persist folders.
function Persist.CheckFolderExist()
	if not file.IsDir(Persist.DataFolder,"data") then
		print(Persist.DataFolder.." not found, creating.")
		file.CreateDir(Persist.DataFolder)
	end
	
	if SERVER then
		local Path = Persist.DataFolder.."/server"
		if not file.IsDir(Path,"data") then
			file.CreateDir(Path)
		end
	end
	
	if CLIENT then
		local Path = Persist.DataFolder.."/client"
		if not file.IsDir(Path,"data") then
			file.CreateDir(Path)
		end
	end
end
Persist.CheckFolderExist()

--Setups the file path to save data. Based on if its server or client saving.
function Persist.FilePath()
	if SERVER then
		return Persist.DataFolder.."/server/"
	else
		return Persist.DataFolder.."/client/"
	end
end

--This Function attempts to load data from file, and if it fails returns default data.
function Persist.LoadPersist(File,Default)
	local Data = {}

	--Check if the file exists.
	local FPath = Persist.FilePath()..File..".txt"
	if file.Exists(FPath,"data") then
		local Read = file.Read(FPath) or ""
		Data = util.JSONToTable(Read) --Load the data from the file.
	else
		print("File: "..FPath.." doesn't exist.")
	end
	
	--Load the default values into the data table if they dont exist.
	for k, x in pairs(Default) do
		if not Data[k] then
			Data[k] = x
		end
	end
	
	return Data
end

--Save our data to file.
function Persist.SavePersist(File,Data)
	file.Write(Persist.FilePath()..File..".txt", util.TableToJSON(Data))
end



