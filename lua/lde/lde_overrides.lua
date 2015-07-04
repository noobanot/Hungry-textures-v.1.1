function LDE:Normalise(Vec)
	local Length = Vec:Length()
	return Vec/Length
end

local metaent = FindMetaTable("Entity")
local metaply = FindMetaTable("Player")

metaent.LDE = {MetaWorked = true}	
		
if SERVER then
	duplicator.RegisterEntityClass("gyropod_advanced", Environments.DupeFix, "Data" )
	duplicator.RegisterEntityClass("sbep_base_door", Environments.DupeFix, "Data" )
	duplicator.RegisterEntityClass("sbep_base_door_controller", Environments.DupeFix, "Data" )
	duplicator.RegisterEntityClass("sbep_base_docking_clamp", Environments.DupeFix, "Data" )
end