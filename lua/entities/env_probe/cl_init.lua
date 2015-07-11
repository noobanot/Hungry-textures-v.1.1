include('shared.lua')
language.Add("other_probe", "Environment Probe")

function ENT:ExtraData(Info)
	if self:GetOOO() == 1 then
		table.insert(Info,{Type="Label",Value="Environment Info:"})
		table.insert(Info,{Type="Label",Value="Name:"..tostring(self:GetNetworkedString(8))})
		table.insert(Info,{Type="Label",Value="O2 Level: " .. string.format("%g",self:GetNetworkedInt( 1 )).."%"})
		table.insert(Info,{Type="Label",Value="CO2 Level: " .. string.format("%g",self:GetNetworkedInt( 2 )).."%"})
		table.insert(Info,{Type="Label",Value="Nitrogen Level: " .. string.format("%g",self:GetNetworkedInt( 3 )).."%"})
		table.insert(Info,{Type="Label",Value="Hydrogen Level: " .. string.format("%g",self:GetNetworkedInt( 4 )).."%"})
		table.insert(Info,{Type="Label",Value="Pressure: " .. tostring(self:GetNetworkedInt( 5 ))})
		table.insert(Info,{Type="Label",Value="Temperature: " .. tostring(self:GetNetworkedInt( 6 ))})
		table.insert(Info,{Type="Label",Value="Gravity: " .. tostring(self:GetNetworkedInt( 7 ))})
		return true
	end
	return false 
end -- This Appears after the resources.
