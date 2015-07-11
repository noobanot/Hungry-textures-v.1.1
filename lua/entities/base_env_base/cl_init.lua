include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	local tab = Environments.GetEntTable(self:EntIndex())
	self.maxresources = tab.maxresources
	self.resources = tab.resources
	self.node = Entity(tab.network) or NULL
end

function ENT:OnRemove()
	Environments.GetEntTable()[self:EntIndex()] = nil
end

function ENT:DrawTranslucent( bDontDrawModel )
	if bDontDrawModel then return end
	self:Draw()
end

function ENT:GetOOO()
	return self:GetNetworkedInt("OOO") or 0
end

function ENT:GetBaseInfo(Info)	
	table.insert(Info,{Type="Label",Value=self.PrintName})
	
	local NetWorkStatus = "Not Connected"
	if self.IsNode then
		NetWorkStatus = tostring(self:EntIndex())
	else
		local node = self.node
		if node and IsValid(node) then 
			NetWorkStatus = tostring(node:EntIndex()) 
		end
	end
	
	table.insert(Info,{Type="Label",Value="Network: "..NetWorkStatus})
	
	return true
end

local OOO = {}
OOO[0] = "Off"
OOO[1] = "On"
OOO[2] = "Overdrive"

function ENT:GetStatusInfo(Info) --Entities overwrite this to show stuff above resources.
	local OverlaySettings = list.Get( "LSEntOverlayText" )[self:GetClass()] --replace this
	local HasOOO = OverlaySettings.HasOOO or false
	if HasOOO then
		local runmode = "UnKnown"
		if self:GetOOO() >= 0 and self:GetOOO() <= 2 then
			runmode = OOO[self:GetOOO()]
		end
		table.insert(Info,{Type="Label",Value="Mode: "..runmode})
		return true
	end
	return false 
end 

function ENT:LoopResInfo(Info,Res)
	local Data = EnvX.Resources.Data
	local RNames = EnvX.Resources.Names
	local IDs = EnvX.Resources.Ids
	
	local Net
	
	local node = self.node
	
	if node and IsValid(node) then
		Net = Environments.GetNetTable(node:EntIndex())
	else
		if not self.IsNode then
			local network = Environments.GetEntTable(self:EntIndex()).network
			
			if network ~= 0 then
				node = Entity(network)
				
				if node and IsValid(node) then
					self.node = node
				end
			end
		end
	end
	
	for _, k in pairs(Res) do
		local ID = IDs[k] or k
		local ND = RNames[ID] or k
		local MU = (Data[ID] or {}).MUnit or ""
		
		if Net then
			local Max = math.Round(Net.maxresources[k] or 0)
			local amt = math.Round(Net.resources[k] or 0)
			if Net.resources_last[k] and amt then
				local diff = CurTime() - Net.last_update[k]
				if diff > 1 then
					diff = 1
				end
				
				amt = math.Round(Net.resources_last[k] + (amt - Net.resources_last[k])*diff)
				table.insert(Info,{Type="Percentage",Text=ND..": ".. amt .."/".. Max .. MU,Value=amt/Max})
			else
				table.insert(Info,{Type="Percentage",Text=ND..": ".. amt .."/".. Max .. MU,Value=amt/Max})
			end
		else
			table.insert(Info,{Type="Percentage",Text=ND..": ".. 0 .."/".. 0 .. MU,Value=0})
		end	
	end	
end

function ENT:GetResInfo(Info)
	local Data = EnvX.Resources.Data
	local RNames = EnvX.Resources.Names
	local IDs = EnvX.Resources.Ids
	
	local node = self.node
	
	if (self.IsNode or not node or not IsValid(node)) and not self.NodeOver then
		if self.maxresources and table.Count(self.maxresources) > 0 then
			for k, v in pairs(self.maxresources) do
				if v>0 then
					local ID = IDs[k] or k
					local Amt = math.Round((self.resources or {})[k] or 0)
					local Max = math.Round(v or 0)
					
					table.insert(Info,{Type="Percentage",Text=(RNames[ID] or k)..": ".. Amt .."/".. Max .. ((Data[ID] or {}).MUnit or ""),Value=Amt/Max})
				else
					self.maxresources[k]=nil
				end
			end
		else
			table.insert(Info,{Type="Label",Value="No Resources Connected"})
		end	
	else
		local OverlaySettings = list.Get( "LSEntOverlayText" )[self:GetClass()] --replace this
		local resnames = OverlaySettings.resnames or {}
		local genresnames = OverlaySettings.genresnames or {}
		
		if resnames and table.Count(resnames) > 0 then
			self:LoopResInfo(Info,resnames)
		end
		
		if genresnames and table.Count(genresnames) > 0 then
			table.insert(Info,{Type="Label",Value=""})
			table.insert(Info,{Type="Label",Value="Generates:"})
			table.insert(Info,{Type="Label",Value=""})
			
			self:LoopResInfo(Info,genresnames)
		end
	end
	
	return true
end

function ENT:ExtraData(Info) return false end -- This Appears after the resources.

function ENT:PlayerData(Info)
	local playername = self:GetPlayerName()
	if playername == "" then
		playername = "World"
	end
	
	table.insert(Info,{Type="Label",Value="(" .. playername ..")"})
end

function ENT:DoNormalDraw() 
	local TR = LocalPlayer():GetEyeTrace()
	if TR.Entity == self and EyePos():Distance( TR.HitPos ) < 512 then
		EnvX.MenuCore.RenderWorldTip(self,function(ent)
			local Info = {}
			
			self:GetBaseInfo(Info) 
			table.insert(Info,{Type="Label",Value=""})
			
			if self:GetStatusInfo(Info) then table.insert(Info,{Type="Label",Value=""}) end
			if self:GetResInfo(Info) then table.insert(Info,{Type="Label",Value=""}) end	
			if self:ExtraData(Info) then table.insert(Info,{Type="Label",Value=""}) end
			
			self:PlayerData(Info)
			
			return Info
		end)
	end
end

function ENT:Draw( DrawModel )	
	self:DoNormalDraw()
		
	if DrawModel then self:DrawModel() end
	
	if Wire_Render then
		Wire_Render(self)
	end
end


if Wire_UpdateRenderBounds then
	function ENT:Think()
		Wire_UpdateRenderBounds(self)
		self:NextThink(CurTime() + 3)
	end
end
