AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_env_base"

ENT.PrintName	= "Resource Node"
ENT.Author		= "CmdrMatthew"
ENT.Purpose		= "Base for node all RD Sents"
ENT.Instructions	= ""

ENT.IsNode = true
ENT.NoEnvPanel = true

list.Set( "LSEntOverlayText" , "resource_node_env", {resnames = {}} )

if(SERVER)then
	local EnvX = EnvX --Localise the global table for speed.
	local Utl = EnvX.Utl --Makes it easier to read the code.
	local NDat = Utl.NetMan --Ease link to the netdata table.
	
	ENT.NoSpaceAfterEndTouch = true
	ENT.IsNode = true

	function ENT:Initialize()
		//self.BaseClass.Initialize(self) --use this in all ents
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		
		//rd table
		self.resources = {}
		self.connected = {}
		self.maxresources = {}
		
		self:Think()
	end

	function ENT:Link(ent, delay)
		if ent == self or ent.IsNode then return end
		
		self.connected[ent:EntIndex()] = ent
		if ent.maxresources then
			local Sync = {}
			for name,max in pairs(ent.maxresources) do
				local curmax = self.maxresources[name]
				if curmax then
					self.maxresources[name] = curmax + max
				else
					self.maxresources[name] = max
				end
				Sync[name]={name=name,value=self.maxresources[name]}
			end

			if delay then
				timer.Simple(0.12, function()
					NDat.AddDataAll({Name="EnvX_NodeSyncStorage",Val=1,Dat={Debug=tostring(ent),Node=self:EntIndex(),ResourceMaxs=Sync}})
				end)
			else
				NDat.AddDataAll({Name="EnvX_NodeSyncStorage",Val=1,Dat={Node=self:EntIndex(),ResourceMaxs=Sync}})
			end
		end
		
		if ent.resources then
			for name,amt in pairs(ent.resources) do
				local curmax = self.maxresources[name]
				if self.resources[name] then
					local cur = self.resources[name].value
					if cur and (cur + amt) <= curmax then
						self.resources[name].value = cur + amt
					elseif cur then
						self.resources[name].value = curmax
					end
				else
					self.resources[name] = {}
					self.resources[name].value = amt
				end
				self.resources[name].haschanged = true
			end
		end
	end

	function ENT:Unlink(ent)
		if ent then
			self.connected[ent:EntIndex()] = nil
			if ent.maxresources then
				local Sync = {}
				for name,max in pairs(ent.maxresources) do
					local curmax = self.maxresources[name]
					if curmax then
						self.maxresources[name] = curmax - max
						if self.resources[name] then
							self.resources[name].haschanged = true
						end
						Sync[name]={name=name,value=self.maxresources[name]}
					end
				end
				NDat.AddDataAll({Name="EnvX_NodeSyncStorage",Val=1,Dat={Node=self:EntIndex(),ResourceMaxs=Sync}})
			end
		end
	end

	function ENT:LinkCheck()
		local curpos = self:GetPos()
		for k,v in pairs(self.connected) do
			if v and v:IsValid() then
				if v:GetPos():Distance(curpos) > 2048 then
					v:Unlink()
					self:EmitSound( Sound( "weapons/stunstick/spark" .. tostring( math.random( 1, 3 ) ) .. ".wav" ) )
					v:EmitSound( Sound( "weapons/stunstick/spark" .. tostring( math.random( 1, 3 ) ) .. ".wav" ) )
				end
			else
				self.connected[k] = nil
			end
		end
	end

	function ENT:Think()
		self:LinkCheck()
		
		self:NextThink(CurTime() + 5)
		return true
	end

	function ENT:DoUpdate(res1, res2, ply) --todo make cheaper
		local R1,R2 = false,false
		
		if res1 then
			local Sync = {}
			for k,name in pairs(res1) do
				local v = self.resources[name]	
				if v and v.haschanged then
					Sync[name] = {name=EnvX.Resources.Ids[name] or name,value=v.value}	
					v.haschanged = false
				end
			end
			if table.Count(Sync)>0 then
				NDat.AddData({Name="EnvX_NodeSyncResource",Val=1,Dat={Node=self:EntIndex(),Resources=Sync}},ply)
				R1 = true
			end
		end
		
		if res2 then 
			local Sync = {}
			for k,name in pairs(res2) do
				local v = self.resources[name]
				if v and v.haschanged then
					Sync[name] = {name=EnvX.Resources.Ids[name] or name,value=v.value}	
					v.haschanged = false
				end
			end
			if table.Count(Sync)>0 then
				NDat.AddData({Name="EnvX_NodeSyncResource",Val=1,Dat={Node=self:EntIndex(),Resources=Sync}},ply)
				R2 = true
			end
		end
		
		--Because we didnt sync anything before, assume its a request to update ALL the data
		if not R1 and not R2 then
			local Sync = {}
			for k,v in pairs(self.resources) do
				if v and v.haschanged then
					Sync[k] = {name=EnvX.Resources.Ids[k] or k,value=v.value}
					v.haschanged = false
				end
			end
			if table.Count(Sync)>0 then
				NDat.AddData({Name="EnvX_NodeSyncResource",Val=1,Dat={Node=self:EntIndex(),Resources=Sync}},ply)
			end
		end
	end

	function ENT:GenerateResource(name, amt)
		amt = math.Round(amt) -- :(
		
		local max = self.maxresources[name]
		if not max then return 0 end
		if self.resources[name] then
			local res = self.resources[name].value
			if res + amt < max then
				self.resources[name].value = self.resources[name].value + amt
				self.resources[name].haschanged = true
				return 0//amt
			else
				self.resources[name].value = max
				self.resources[name].haschanged = true
				return amt - (max - res)
			end
		else
			self.resources[name] = {}
			self.resources[name].value = amt
			self.resources[name].haschanged = true
			return 0//amt
		end
		return amt
	end

	function ENT:ConsumeResource(name, amt)
		amt = math.Round(amt) -- :(
		if self.resources[name] then
			local res = self.resources[name].value
			if res >= amt then
				self.resources[name].value = res - amt
				self.resources[name].haschanged = true
				return amt
			elseif res != 0 then
				res = self.resources[name].value
				self.resources[name].value = 0
				self.resources[name].haschanged = true
				return res
			else
				return 0
			end
		else
			return 0
		end
	end

	function ENT:OnRemove()	
		if self.connected then
			for k,v in pairs(self.connected) do
				if v and IsValid(v) then
					v:Unlink()
				end
			end
		end
		if WireAddon then Wire_Remove(self) end
	end

	function ENT:GetResourceAmount(resource)
		if self.resources[resource] then
			return self.resources[resource].value
		end
		return 0
	end
else
	ENT.RenderGroup = RENDERGROUP_BOTH

	function ENT:Initialize()
		local nettable = Environments.GetNetTable(self:EntIndex()) --yay synced table
		self.resources = nettable.resources
		self.maxresources = nettable.maxresources
		//self.data = nettable.data
		self.resources_last = nettable.resources_last
		self.last_update = nettable.last_update
	end
end		
