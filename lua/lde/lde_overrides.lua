function LDE:Normalise(Vec)
	local Length = Vec:Length()
	return Vec/Length
end

local metaent = FindMetaTable("Entity")
--metaent.LDE = {Temperature=0,MeltingPoint=1,FreezingPoint=-1,OverHeating=false}	

local metaply = FindMetaTable("Player")
metaply.CanGlobalPrint = 1
	
if SERVER then
	duplicator.RegisterEntityClass("gyropod_advanced", Environments.DupeFix, "Data" )
	duplicator.RegisterEntityClass("sbep_base_door", Environments.DupeFix, "Data" )
	duplicator.RegisterEntityClass("sbep_base_door_controller", Environments.DupeFix, "Data" )
	duplicator.RegisterEntityClass("sbep_base_docking_clamp", Environments.DupeFix, "Data" )
end