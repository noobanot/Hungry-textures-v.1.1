include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

--ENT.ScreenAngles = Angle(0,0,0)
--ENT.ScreenAngles.r = 270
--ENT.ScreenAngles.y = 30
/*] dev_setentvar ScreenAngles.Y 0
] dev_setentvar ScreenAngles.R 45 
] dev_setentvar ScreenAngles.P 270*/

--ENT.ScreenPos = Vector(-110,0,50)

local OOO = {}
OOO[0] = "Off"
OOO[1] = "On"
OOO[2] = "Overdrive"

function ENT:Initialize()	
	local tab = Environments.GetEntTable(self:EntIndex())
	self.maxresources = tab.maxresources
	self.resources = tab.resources
	self.node = Entity(tab.network) or NULL
end

function ENT:Draw( bDontDrawModel )
	self:DoNormalDraw()

	if (Wire_Render) then
		Wire_Render(self)
	end
end

function ENT:DrawTranslucent( bDontDrawModel )
	if bDontDrawModel then return end
	self:Draw()
end

function ENT:OnRemove()
	Environments.GetEntTable()[self:EntIndex()] = nil
end

function ENT:GetOOO()
	return self:GetNetworkedInt("OOO") or 0
end

function ENT:DoNormalDraw( bDontDrawModel )
	local TR = LocalPlayer():GetEyeTrace()
	if TR.Entity == self and EyePos():Distance( TR.HitPos ) < 512 then
		if not bDontDrawModel then self:DrawModel() end
		
		local Data = EnvX.Resources.Data
		local RNames = EnvX.Resources.Names
		local IDs = EnvX.Resources.Ids
		
		EnvX.MenuCore.RenderWorldTip(self,function(ent)
			--print(tostring(self.node))
			local node = self.node
			local OverlaySettings = list.Get( "LSEntOverlayText" )[self:GetClass()] --replace this
			local resnames = OverlaySettings.resnames
			
			local playername = self:GetPlayerName()
			if playername == "" then
				playername = "World"
			end
		
			local NetWorkStatus = "Not Connected"
			if node and IsValid(node) then NetWorkStatus = tostring(node:EntIndex()) end
			local Return = {}
			table.insert(Return,{Type="Label",Value=self.PrintName})
			table.insert(Return,{Type="Label",Value="Network: "..NetWorkStatus})
			table.insert(Return,{Type="Label",Value=""})
			
			if not node or not IsValid(node) then
				if self.resources and table.Count(self.resources) > 0 then
					for k, v in pairs(self.resources) do
						local ID = IDs[k] or k
						table.insert(Return,{Type="Percentage",Text=(RNames[ID] or k)..": ".. v .."/".. (Net.maxresources[k] or 0) .. ((Data[ID] or {}).MUnit or ""),Value=math.Round(v)/math.Round(self.maxresources[k])})
					end
				else
					table.insert(Return,{Type="Label",Value="No Resources Connected"})
				end
			else
				if resnames and table.Count(resnames) > 0 then
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
								table.insert(Return,{Type="Percentage",Text=(RNames[ID] or k)..": ".. amt .."/".. (Net.maxresources[k] or 0) .. ((Data[ID] or {}).MUnit or ""),Value=math.Round(amt)/math.Round((Net.maxresources[k] or 0))})
							else
								table.insert(Return,{Type="Percentage",Text=(RNames[ID] or k)..": ".. (Net.resources[k] or 0) .."/".. (Net.maxresources[k] or 0) .. ((Data[ID] or {}).MUnit or ""),Value=math.Round((Net.resources[k] or 0))/math.Round((Net.maxresources[k] or 0))})
							end
						else
							table.insert(Return,{Type="Percentage",Text=(RNames[ID] or k)..": ".. 0 .."/".. (Net.maxresources[k] or 0) .. ((Data[ID] or {}).MUnit or ""),Value=0})
						end	
					end
				end
			end
			
			table.insert(Return,{Type="Label",Value=""})
			
			if self.ExtraOverlayData then
				for k,v in pairs(self.ExtraOverlayData) do
					table.insert(Return,{Type="Label",Value=k..": "..v})
				end
			end
			table.insert(Return,{Type="Label",Value="(" .. playername ..")"})
			
			return Return
		end)
	else
		if not bDontDrawModel then self:DrawModel() end
	end
end

if Wire_UpdateRenderBounds then
	function ENT:Think()
		Wire_UpdateRenderBounds(self)
		self:NextThink(CurTime() + 3)
	end
end

EnvX.Utl:HookNet("EnvX_SyncStorage",function(Data)
	local ent = Data.Ent
	
	if not ent or not IsValid(ent) then return end
	
	ent.resources = Data.Resources
	ent.maxresources = Data.ResourceMaxs
end)
