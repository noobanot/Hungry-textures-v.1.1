include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	local nettable = Environments.GetNetTable(self:EntIndex()) --yay synced table
	self.resources = nettable.resources
	self.maxresources = nettable.maxresources
	//self.data = nettable.data
	self.resources_last = nettable.resources_last
	self.last_update = nettable.last_update
end