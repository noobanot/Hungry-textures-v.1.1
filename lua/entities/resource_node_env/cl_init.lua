include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH
//surface.CreateFont( "arial", 60, 600, true, false, "ConflictText" )
//surface.CreateFont( "arial", 40, 600, true, false, "Flavour" )

function ENT:Initialize()
	local nettable = Environments.GetNetTable(self:EntIndex()) --yay synced table
	self.resources = nettable.resources
	self.maxresources = nettable.maxresources
	//self.data = nettable.data
	self.resources_last = nettable.resources_last
	self.last_update = nettable.last_update
end

function ENT:Draw( bDontDrawModel )
	self:DoNormalDraw()

	if Wire_Render then
		Wire_Render(self)
	end
end

function ENT:OnRemove()
	Environments.GetNetTable()[self:EntIndex()] = nil
end

function ENT:DrawTranslucent( bDontDrawModel )
	if bDontDrawModel then return end
	self:Draw()
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
		
			local Return = {}
			table.insert(Return,{Type="Label",Value=self.PrintName})
			table.insert(Return,{Type="Label",Value="Network: "..self:EntIndex()})
			
			if HasOOO then
				local runmode = "UnKnown"
				if self:GetOOO() >= 0 and self:GetOOO() <= 2 then
					runmode = OOO[self:GetOOO()]
				end
				table.insert(Return,{Type="Label",Value="Mode: "..runmode})
			end
			
			table.insert(Return,{Type="Label",Value=""})
			if self.resources and table.Count(self.resources) > 0 then
				for k, v in pairs(self.resources) do
					local ID = IDs[k] or k
					table.insert(Return,{Type="Percentage",Text=(RNames[ID] or k)..": ".. v .."/".. self.maxresources[k] .. ((Data[ID] or {}).MUnit or ""),Value=math.Round(v)/math.Round(self.maxresources[k])})
				end
			else
				table.insert(Return,{Type="Label",Value="No Resources Connected"})
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
	end
	if not bDontDrawModel then self:DrawModel() end
end

if Wire_UpdateRenderBounds then
	function ENT:Think()
		Wire_UpdateRenderBounds(self)
		self:NextThink(CurTime() + 3)
	end
end

EnvX.Utl:HookNet("EnvX_NodeSync",function(Data)
	local net = Environments.GetNetTable(Data.Node)

	local Resources = Data.Resources
	for index, res in pairs(Resources) do
		net.resources_last[index] = net.resources[index]
		net.resources[index] = res.value
		net.last_update[index] = CurTime()
	end
	
	local ResourceMaxs = Data.ResourceMaxs
	for index, res in pairs(ResourceMaxs) do
		net.maxresources[index]=res.value
	end
end)

EnvX.Utl:HookNet("EnvX_NodeSyncStorage",function(Data)
	local net = Environments.GetNetTable(Data.Node)
	
	local ResourceMaxs = Data.ResourceMaxs
	for index, res in pairs(ResourceMaxs) do
		net.maxresources[res.name]=res.value
	end
end)

EnvX.Utl:HookNet("EnvX_NodeSyncResource",function(Data)
	local net = Environments.GetNetTable(Data.Node)
		
	local Resources = Data.Resources
	for i, res in pairs(Resources) do
		local index = i
		net.resources_last[index] = net.resources[index]
		net.resources[index] = res.value
		net.last_update[index] = CurTime()
	end
end)

EnvX.Utl:HookNet("EnvX_SetEntNode",function(Data)
	for nodeId, nodelinks in pairs(Data.Nodes) do
		local node = Entity(nodeId)
		for _, entId in pairs(nodelinks) do
			local ent = Entity(entId)
			if IsValid(ent) then
				local node = Entity(nodeId)
				if nodeId == 0 then node = NULL end
				ent.node = node
			else
				local tab = Environments.GetEntTable(entId)
				tab.network = nodeId	
			end			
		end
	end
end)
