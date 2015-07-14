include("shared.lua")

local OOO = {}
OOO[0] = "Off"
OOO[1] = "Scanning"

function ENT:ExtraData(Info)
	if self:GetOOO() == 1 then
		table.insert(Info,{Type="Label",Value="Resource Density: "..math.Round( self.dt.Density,2)})
		table.insert(Info,{Type="Label",Value="Resource Pool Volume: "..math.Round( ( ( ( self.dt.Size ) * 0.75 ) * 2.54 ) *1e-2,2).." cubic m"})
		table.insert(Info,{Type="Label",Value="Scanner Range: "..self.dt.Range})
		table.insert(Info,{Type="Label",Value="Scanner Beam Angle: "..self.dt.ScanAngle.." deg."})
		table.insert(Info,{Type="Label",Value="Resource Depth: "..math.Round( ( ( ( self.dt.Depth ) * 0.75) * 2.54) * 1e-2,2).." m"})
		table.insert(Info,{Type="Label",Value="Resource Distance: "..tostring( math.Round(self.dt.Distance,2) ).." m"})
		table.insert(Info,{Type="Label",Value="Relative Angle: ("..tostring(self.dt.TargetAngle)..")"})
		table.insert(Info,{Type="Label",Value="Resource Count: "..self.dt.Quantity})
		return true
	end
	return false 
end
