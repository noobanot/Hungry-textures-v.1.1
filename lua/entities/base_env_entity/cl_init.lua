include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

local params = {
	["$basetexture"] = "",
	["$model"] = 1,
	["$color"] = "{255 255 255}",
	["$vertexcolor"] = 1,
}
local cablemat = CreateMaterial("3DCableMaterial","UnlitGeneric",params);
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
	/*
	local info = nil
	if Environments.GetScreenInfo then
		info = Environments.GetScreenInfo(self:GetModel())
	end
	if info then
		self.ScreenMode = true
		self.ScreenAngles = info.Angle
		self.ScreenPos = info.Offset
	end
	*/
	local tab = Environments.GetEntTable(self:EntIndex())
	self.maxresources = tab.maxresources
	self.resources = tab.resources
	self.node = Entity(tab.network) or NULL
end

function ENT:OnRemove()
	Environments.GetEntTable()[self:EntIndex()] = nil
end

function ENT:Draw( bDontDrawModel )

	entDeviceEnt = self
	
	if entID == nil then
		entID = 0
	end
	
	self:DoNormalDraw()

	if Wire_Render then
		Wire_Render(self)
	end
end

function ENT:DrawTranslucent( bDontDrawModel )
	if bDontDrawModel then return end
	self:Draw()
end

function ENT:GetOOO()
	return self:GetNetworkedInt("OOO") or 0
end

function ENT:DoNormalDraw( bDontDrawModel )
	if ( LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance( self:GetPos() ) < 512) then
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
		
			local NetWorkStatus = "Not Connected"
			if node and IsValid(node) then NetWorkStatus = tostring(node:EntIndex()) end
			local Return = {}
			table.insert(Return,{Type="Label",Value=self.PrintName})
			table.insert(Return,{Type="Label",Value="Network: "..NetWorkStatus})
			
			if HasOOO then
				local runmode = "UnKnown"
				if self:GetOOO() >= 0 and self:GetOOO() <= 2 then
					runmode = OOO[self:GetOOO()]
				end
				table.insert(Return,{Type="Label",Value="Mode: "..runmode})
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
		
			if genresnames and table.Count(genresnames) > 0 then
				table.insert(Return,{Type="Label",Value=""})
				table.insert(Return,{Type="Label",Value="Generates:"})
				table.insert(Return,{Type="Label",Value=""})
				for _, k in pairs(genresnames) do
					local ID = IDs[k] or k
					local MD = Data[ID] or {}
					local ND = RNames[ID] or k
					
					if node and IsValid(node) then
						local Net = Environments.GetNetTable(node:EntIndex())
						if node.resources_last[k] and node.resources[k] then
							local diff = CurTime() - node.last_update[k]
							if diff > 1 then
								diff = 1
							end
							
							local amt = math.Round(node.resources_last[k] + (node.resources[k] - node.resources_last[k])*diff)
							table.insert(Return,{Type="Percentage",Text=ND..": ".. (amt) .."/".. (node.maxresources[k] or 0) .. (MD.MUnit or ""),Value=math.Round(amt)/math.Round(Net.maxresources[k])})
						else
							table.insert(Return,{Type="Percentage",Text=ND..": ".. (node.resources[k] or 0) .."/".. (node.maxresources[k] or 0) .. (MD.MUnit or ""),Value=math.Round((Net.resources[k] or 0))/math.Round(Net.maxresources[k])})
						end
					else
						table.insert(Return,{Type="Percentage",Text=ND..": ".. 0 .."/".. 0 .. (MD.MUnit or ""),Value=0})
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
					
		--OverlayText = OverlayText .. math.Round(self:GetNWInt("LDEMinTemp",0)).."/("..math.Round(self:GetNWInt("LDEEntTemp",0))..")/"..math.Round(self:GetNWInt("LDEMaxTemp",0)).."\n"
		/*else
			local rot = Vector(0,0,90)
			local TempY = 0
			local maxvector = self:OBBMaxs()
			local getpos = self:GetPos()
			
			//SetPosition
			local pos = getpos + (self:GetRight() * self.ScreenPos.y) //y-axis
			pos = pos + (self:GetUp() * self.ScreenPos.z) //z-axis
			pos = pos + (self:GetForward() * self.ScreenPos.x) //x-axis
			
			//Set Angles
			local angle = self:GetAngles()
			angle:RotateAroundAxis(self:GetRight(),self.ScreenAngles.p)
			angle:RotateAroundAxis(self:GetForward(),self.ScreenAngles.y)
			angle:RotateAroundAxis(self:GetUp(),self.ScreenAngles.r)

			local textStartPos = -625 --used for centering
			local stringUsage = ""
			cam.Start3D2D(pos,angle,0.03)
				local status, error = pcall(function()
				surface.SetDrawColor(0,0,0,255)
				surface.DrawRect( textStartPos, 0, 1250, 500 )

				surface.SetDrawColor(155,155,155,255)
				surface.DrawRect( textStartPos, 0, -5, 500 )
				surface.DrawRect( textStartPos, 0, 1250, -5 )
				surface.DrawRect( textStartPos, 500, 1250, -5 )
				surface.DrawRect( textStartPos+1250, 0, 5, 500 )
				
				--local x, y = GetMousePos(LocalPlayer():GetEyeTrace().HitPos, pos, 0.03, angle) --test cursor
				--surface.DrawRect( x, y, 50,50)
				
				TempY = TempY + 10
				surface.SetFont("Default")
				surface.SetTextColor(255,255,255,255)
				surface.SetTextPos(textStartPos+15,TempY)
				surface.DrawText(self.PrintName)
				TempY = TempY + 70
				
				if HasOOO then
					local runmode = "UnKnown"
					if self:GetOOO() >= 0 and self:GetOOO() <= 2 then
						runmode = OOO[self:GetOOO()]
					end
					//surface.SetFont("Flavour")
					surface.SetTextColor(155,155,255,255)
					surface.SetTextPos(textStartPos+15,TempY)
					surface.DrawText("Mode: "..runmode)
					TempY = TempY + 50
				end
				
				if #genresnames == 0 and #resnames == 0 then
					//surface.SetFont("Flavour")
					surface.SetTextColor(200,200,255,255)
					surface.SetTextPos(textStartPos+15,TempY)
					surface.DrawText("No resources connected")
					TempY = TempY + 70
				else
					//surface.SetFont("Flavour")
					surface.SetTextColor(200,200,255,255)
					surface.SetTextPos(textStartPos+15,TempY)
					surface.DrawText("Resources: ")
					TempY = TempY + 50
				end
			
				if ( table.Count(resnames) > 0 ) then		
					for k, v in pairs(resnames) do
						if node and node:IsValid() then
							stringUsage = stringUsage.."["..(ResourceNames[v] or v)..": "..(node.resources[v] or 0) .."/".. (node.maxresources[v] or 0).."] "
						else
							stringUsage = stringUsage.."["..(ResourceNames[v] or v)..": ".. 0 .."/".. 0 .."] "
						end
						surface.SetTextPos(textStartPos+15,TempY)
						surface.DrawText("   "..stringUsage)
						TempY = TempY + 50
						stringUsage = ""
					end
				end
				if ( table.Count(genresnames) > 0 ) then
					//surface.SetFont("Flavour")
					surface.SetTextColor(200,200,255,255)
					surface.SetTextPos(textStartPos+15,TempY)
					surface.DrawText("Generates: ")
					TempY = TempY + 50
					for k, v in pairs(genresnames) do
						if node and node:IsValid() then
							stringUsage = stringUsage.."["..(ResourceNames[v] or v)..": "..(node.resources[v] or 0) .."/".. (node.maxresources[v] or 0).."] "
						else
							stringUsage = stringUsage.."["..(ResourceNames[v] or v)..": ".. 0 .."/".. 0 .."] "
						end
						surface.SetTextPos(textStartPos+15,TempY)
						surface.DrawText("   "..stringUsage)
						TempY = TempY + 50
						stringUsage = ""
					end
				end end)
				if error then print(error) end
			cam.End3D2D()
		end*/
	end
	
	if not bDontDrawModel then self:DrawModel() end
end

function GetMousePos(vWorldPos,vPos,vScale,aRot)
    local vWorldPos=vWorldPos-vPos;
    vWorldPos:Rotate(Angle(0,-aRot.y,0));
    vWorldPos:Rotate(Angle(-aRot.p,0,0));
    vWorldPos:Rotate(Angle(0,0,-aRot.r));
    return vWorldPos.x/vScale,(-vWorldPos.y)/vScale;
end

if Wire_UpdateRenderBounds then
	function ENT:Think()
		Wire_UpdateRenderBounds(self)
		self:NextThink(CurTime() + 3)
	end
end
