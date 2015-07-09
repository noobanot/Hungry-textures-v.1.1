include('shared.lua')
language.Add("other_probe", "Environment Probe")

local OOO = {}
OOO[0] = "Off"
OOO[1] = "On"
OOO[2] = "Overdrive"

function ENT:DoNormalDraw( bDontDrawModel )
	if ( LocalPlayer():GetEyeTrace().Entity == self.Entity and EyePos():Distance( self.Entity:GetPos() ) < 256) then
		local Data = EnvX.Resources.Data
		local RNames = EnvX.Resources.Names
		local IDs = EnvX.Resources.Ids
		
		EnvX.MenuCore.RenderWorldTip(self,function(ent)
			--print(tostring(self.node))
			local node = self.node
			local OverlaySettings = list.Get( "LSEntOverlayText" )[self:GetClass()] --replace this
			local resnames = OverlaySettings.resnames
			local HasOOO = OverlaySettings.HasOOO or false
			local genresnames = OverlaySettings.genresnames or {}
			
			local playername = self:GetPlayerName()
			if playername == "" then
				playername = "World"
			end
		
			local Return = {}
			table.insert(Return,{Type="Label",Value=self.PrintName})
			table.insert(Return,{Type="Label",Value="Network: "..self:EntIndex()})
			
			if self:GetOOO() == 1 then
				table.insert(Return,{Type="Label",Value=""})
				
				table.insert(Return,{Type="Label",Value="Environment Info:"})
				table.insert(Return,{Type="Label",Value="Name:"..tostring(self:GetNetworkedString(8))})
				table.insert(Return,{Type="Label",Value="O2 Level: " .. string.format("%g",self:GetNetworkedInt( 1 )).."%"})
				table.insert(Return,{Type="Label",Value="CO2 Level: " .. string.format("%g",self:GetNetworkedInt( 2 )).."%"})
				table.insert(Return,{Type="Label",Value="Nitrogen Level: " .. string.format("%g",self:GetNetworkedInt( 3 )).."%"})
				table.insert(Return,{Type="Label",Value="Hydrogen Level: " .. string.format("%g",self:GetNetworkedInt( 4 )).."%"})
				table.insert(Return,{Type="Label",Value="Pressure: " .. tostring(self:GetNetworkedInt( 5 ))})
				table.insert(Return,{Type="Label",Value="Temperature: " .. tostring(self:GetNetworkedInt( 6 ))})
				table.insert(Return,{Type="Label",Value="Gravity: " .. tostring(self:GetNetworkedInt( 7 ))})
			end
			
			if resnames and table.Count(resnames) > 0 then
				table.insert(Return,{Type="Label",Value=""})
				
				if not node or not IsValid(node) then
					if self.resources and table.Count(self.resources) > 0 then
						for k, v in pairs(self.resources) do
							local ID = IDs[k] or k
							table.insert(Return,{Type="Percentage",Text=(RNames[ID] or k)..": ".. v .."/".. self.maxresources[k] .. ((Data[ID] or {}).MUnit or ""),Value=math.Round(v)/math.Round(self.maxresources[k])})
						end
					else
						table.insert(Return,{Type="Label",Value="No Resources Connected"})
					end
				else
					local Net = Environments.GetNetTable(node:EntIndex())
					for _, k in pairs(resnames) do
						local ID = IDs[k] or k
						local MD = Data[ID] or {}
						local ND = RNames[ID] or k
						
						if Net then
							if Net.resources_last[k] and Net.resources[k] then
								local diff = CurTime() - Net.last_update[k]
								if diff > 1 then
									diff = 1
								end
								
								local amt = math.Round(Net.resources_last[k] + (Net.resources[k] - Net.resources_last[k])*diff)
								table.insert(Return,{Type="Percentage",Text=ND..": ".. amt .."/".. Net.maxresources[k] .. (MD.MUnit or ""),Value=math.Round(amt)/math.Round(Net.maxresources[k])})
							else
								table.insert(Return,{Type="Percentage",Text=ND..": ".. (Net.resources[k] or 0) .."/".. Net.maxresources[k] .. (MD.MUnit or ""),Value=math.Round((Net.resources[k] or 0))/math.Round(Net.maxresources[k])})
							end
						else
							table.insert(Return,{Type="Percentage",Text=ND..": ".. 0 .."/".. 0 .. (MD.MUnit or ""),Value=0})
						end	
					end
				end
			end
			
			if self.ExtraOverlayData then
				table.insert(Return,{Type="Label",Value=""})
				for k,v in pairs(self.ExtraOverlayData) do
					table.insert(Return,{Type="Label",Value=k..": "..v})
				end
			end
			
			table.insert(Return,{Type="Label",Value=""})
			table.insert(Return,{Type="Label",Value="(" .. playername ..")"})
			
			return Return
		end)
	else
		
	end
	if not bDontDrawModel then self:DrawModel() end
end