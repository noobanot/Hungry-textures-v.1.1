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
		--overlaysettings
		local node = self.node
		local OverlaySettings = list.Get( "LSEntOverlayText" )[self:GetClass()] or {} --replace this
		local HasOOO = OverlaySettings.HasOOO or false
		local resnames = OverlaySettings.resnames or {}
		local genresnames = OverlaySettings.genresnames or {}
		--End overlaysettings
		
		if !bDontDrawModel then self:DrawModel() end
		
		local playername = self:GetPlayerName()
		if playername == "" then
			playername = "World"
		end
		
		local Data = EnvX.Resources.Data
		local RNames = EnvX.Resources.Names
		local IDs = EnvX.Resources.Ids
		
		--if not self.ScreenMode then
			local OverlayText = ""
			OverlayText = OverlayText ..self.PrintName.."\n"
			if !node or !node:IsValid() then
				OverlayText = OverlayText .. "Not Connected\n"
			else
				OverlayText = OverlayText .. "Network " .. tostring(node:EntIndex()) .."\n"
			end
			if HasOOO then
				local runmode = "UnKnown"
				if self:GetOOO() >= 0 and self:GetOOO() <= 2 then
					runmode = OOO[self:GetOOO()]
				end
				OverlayText = OverlayText .. "Mode: " .. runmode .."\n"
			end
			OverlayText = OverlayText.."\n"
			local resources = self.resources
			if resnames and table.Count(resnames) > 0 then
				for _, k in pairs(resnames) do
					local ID = IDs[k] or k
					local MD = Data[ID] or {}
					local ND = RNames[ID] or k
					
					if node and IsValid(node) then
						if node.resources_last[k] and node.resources[k] then
							local diff = CurTime() - node.last_update[k]
							if diff > 1 then
								diff = 1
							end
							
							local amt = math.Round(node.resources_last[k] + (node.resources[k] - node.resources_last[k])*diff)
							OverlayText = OverlayText ..ND..": ".. (amt) .."/".. (node.maxresources[k] or 0) .. (MD.MUnit or "") .."\n"
						else
							OverlayText = OverlayText ..ND..": ".. (node.resources[k] or 0) .."/".. (node.maxresources[k] or 0) .. (MD.MUnit or "") .."\n"
						end
					else
						OverlayText = OverlayText ..ND..": 0/".. (self.maxresources[k] or 0) .."\n"
					end
				end
			end
			if genresnames and table.Count(genresnames) > 0 then
				OverlayText = OverlayText.."\nGenerates:\n"
				for _, k in pairs(genresnames) do
					if node and node:IsValid() then
						if node.resources_last[k] and node.resources[k] then
							local diff = CurTime() - node.last_update[k]
							if diff > 1 then
								diff = 1
							end
							
							local amt = math.Round(node.resources_last[k] + (node.resources[k] - node.resources_last[k])*diff)
							OverlayText = OverlayText ..(RNames[k] or k)..": ".. (amt) .."/".. (node.maxresources[k] or 0) .. ((Data[k] or {}).MUnit or "") .."\n"
						else
							OverlayText = OverlayText ..(RNames[k] or k)..": ".. (node.resources[k] or 0) .."/".. (node.maxresources[k] or 0) .. ((Data[k] or {}).MUnit or "") .."\n"
						end
					else
						OverlayText = OverlayText ..(RNames[k] or k)..": 0/0\n"
					end
				end
			end
			if self.ExtraOverlayData then
				for k,v in pairs(self.ExtraOverlayData) do
					OverlayText = OverlayText..k..": "..v.."\n"
				end
			end
			
			OverlayText = OverlayText .. math.Round(self:GetNWInt("LDEMinTemp",0)).."/("..math.Round(self:GetNWInt("LDEEntTemp",0))..")/"..math.Round(self:GetNWInt("LDEMaxTemp",0)).."\n"
			OverlayText = OverlayText .. "(" .. playername ..")"
			AddWorldTip( self:EntIndex(), OverlayText, 0.5, self:GetPos(), self  )
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
	else
		if not bDontDrawModel then self:DrawModel() end
	end
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
