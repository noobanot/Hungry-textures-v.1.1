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
	if LocalPlayer():GetEyeTrace().Entity == self and EyePos():Distance( self:GetPos() ) < 512 then
		--overlaysettings
		local node = self.node --self:GetNWEntity("node")
		local OverlaySettings = list.Get( "LSEntOverlayText" )[self:GetClass()] --replace this
		local resnames = OverlaySettings.resnames
		--End overlaysettings

		if ( !bDontDrawModel ) then self:DrawModel() end
		
		local playername = self:GetPlayerName()
		if playername == "" then
			playername = "World"
		end
		
		local Data = EnvX.Resources.Data
		local RNames = EnvX.Resources.Names
		local IDs = EnvX.Resources.Ids
		
		local OverlayText = self.PrintName.."\n"
		
		if not node or not IsValid(node) then
			OverlayText = OverlayText .. "Not Connected\n"
		else
			OverlayText = OverlayText .. "Network " .. tostring(node:EntIndex()) .."\n"
		end
		
		OverlayText = OverlayText.."\n"
		if not node or not IsValid(node) then
			if self.resources and table.Count(self.resources) > 0 then
				for k, v in pairs(self.resources) do
					local ID = IDs[k] or k
					OverlayText = OverlayText ..(RNames[ID] or k)..": ".. v .."/".. self.maxresources[k] .. ((Data[ID] or {}).MUnit or "") .."\n"
				end
			else
				OverlayText = OverlayText .. "No Resources Connected\n"
			end
		else
			if resnames and table.Count(resnames) > 0 then
				for _, k in pairs(resnames) do
					local ID = IDs[k] or k
					local MD = Data[ID] or {}
					local ND = RNames[ID] or k
					
					if node then
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
						OverlayText = OverlayText ..ND..": ".. 0 .."/".. self.maxresources[k] .."\n"
					end
				end
			end
		end
		if self.ExtraOverlayData then
			for k,v in pairs(self.ExtraOverlayData) do
				OverlayText = OverlayText..k..": "..v.."\n"
			end
		end
		OverlayText = OverlayText .. "(" .. playername ..")"
		AddWorldTip( self:EntIndex(), OverlayText, 0.5, self:GetPos(), self  )
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
