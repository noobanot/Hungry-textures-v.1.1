include("shared.lua")

local OOO = {}
OOO[0] = "Off"
OOO[1] = "Active"
local Drillstatus = {"Idle","Drilling","Extracting","Shutting Down","OverHeating"}

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self.LastResource = "none"
end

function ENT:ExtraData(Info)

	local mode,status = self:GetOOO(),"Idle"
	if mode >= 0 or mode <2 then status = OOO[mode] end
	table.insert(Info,{Type="Label",Value="Status: "..status})
	table.insert(Info,{Type="Label",Value="Drill Status: [ "..Drillstatus[self.dt.Phase].." ]"})
	table.insert(Info,{Type="Label",Value="Last Resource: [ "..self.LastResource.." ]"})
	
	local lockstatus = "disengaged" if self.dt.Locked >0 then lockstatus = "enaged" end
	table.insert(Info,{Type="Label",Value="Drill Lock: ["..lockstatus.."]"})
	
	table.insert(Info,{Type="Label",Value="Drill Status: [ "..Drillstatus[self.dt.Phase].." ]"})

	if mode == 1 then
		local EMR = LDE.Anons.Resources[self:GetNetworkedString("ResourceDrillResource")]
		local resname,resunit = "none",""
		if EMR and EMR.name then
			resname,resunit = EMR.name,EMR.unit
			self.LastResource = EMR.name
		end		
		table.insert(Info,{Type="Label",Value="Depth: "..math.Round( ( ( ( self.dt.Depth ) * 0.75) * 2.54) * 1e-2,2).." m"})
		table.insert(Info,{Type="Label",Value="Resource: [ "..resname.." ]"})
		table.insert(Info,{Type="Label",Value="Extraction Rate: "..self.dt.ExtractionRate.." "..resunit.."/sec"})
	end
	
	table.insert(Info,{Type="Label",Value="Overheat: "..math.Round(self.dt.Heat,1).." %"})

	return true 
end
