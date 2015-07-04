function LDE:Normalise(Vec)
	local Length = Vec:Length()
	return Vec/Length
end

local metaent = FindMetaTable("Entity")
local metaply = FindMetaTable("Player")

--metaent.LDE = {MetaWorked = true}
		
duplicator.Allow("gyropod_advanced")
duplicator.Allow("sbep_base_door")
duplicator.Allow("sbep_base_door_controller")
duplicator.Allow("sbep_base_docking_clamp")