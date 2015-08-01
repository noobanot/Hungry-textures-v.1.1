include("weapons/gmod_tool/envx_tool_base.lua")

TOOL.Category = "Tools"
TOOL.Name = "Resource Nodes"
TOOL.Description = "Used to spawn resource nodes"

TOOL.Models = { 	
["models/props_wasteland/panel_leverBase001a.mdl"] = {},
["models/SBEP_community/d12shieldemitter.mdl"] = {},
["models/slyfo/powercrystal.mdl"] = {},
["models/slyfo/util_tracker.mdl"] = {}				
}

local Models = TOOL.Models --fixes stuph		

TOOL.Entity.Class = "resource_node_env";
TOOL.Entity.Keys = 0
TOOL.Entity.Limit = 20
TOOL.Entity.Angle = Angle(0,0,0)
local name = TOOL.Mode

TOOL.CleanupGroup = "node" --sets what this things count adds from
TOOL.Language["Undone"] = "Resource Node Undone";
TOOL.Language["Cleanup"] = "Resource Nodes";
TOOL.Language["Cleaned"] = "Removed all Resource Nodes";
TOOL.Language["SBoxLimit"] = "Hit the Resource Node limit";

function TOOL.BuildCPanel( CPanel )
	-- Header stuff
	CPanel:ClearControls()
	CPanel:AddControl("Header", { Text = "#tool."..name..".name", Description = "#tool."..name..".desc" })
	
	CPanel:AddControl( "PropSelect", {
		Label = "#Models",
		ConVar = name.."_model",
		Category = "Storages",
		Models = Models
	})
	CPanel:AddControl("CheckBox", { Label = "Weld", Command = name.."_Weld" })
	CPanel:AddControl("CheckBox", { Label = "Nocollide", Command = name.."_NoCollide" })
	CPanel:AddControl("CheckBox", { Label = "Freeze", Command = name.."_Freeze" })
end
	
TOOL:Register()