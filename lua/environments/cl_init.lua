
local scripted_ents = scripted_ents
local table = table
local util = util
local timer = timer
local ents = ents
local duplicator = duplicator
local math = math
local tostring = tostring
local MeshQuad = MeshQuad
local Vector = Vector
local type = type
local tonumber = tonumber
local pairs = pairs

local nettable = {}
local ent_table = {}
//New Networking System, sorry RD3
local function CreateNetTable(netid)
	nettable[netid] = {}
	local index = nettable[netid]
	index.resources = {}
	index.maxresources = {}
	index.cons = {}
	
	index.resources_last = {}
	index.last_update = {};
	
	return index
end

function Environments.GetNetTable(id)
	if !id then
		return nettable
	end
	return nettable[id] or CreateNetTable(id)
end

local function CreateEntTable(id)
	ent_table[id] = {}
	local index = ent_table[id]
	index.network = 0
	index.resources = {}
	index.maxresources = {}
	return index
end

function Environments.GetEntTable(id)
	if not id then return ent_table end
	return ent_table[id] or CreateEntTable(id)
end

EnvX.Utl:HookNet("EnvX_SyncStorage",function(Data)
	local ent = Data.Ent
	
	if not ent or not IsValid(ent) then return end
	
	ent.resources = Data.Resources
	ent.maxresources = Data.ResourceMaxs
end)

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
		net.maxresources[res.name]=res.value
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
	--print("SetNode!")
	for nodeId, nodelinks in pairs(Data.Nodes) do
		local node = Entity(nodeId)
		--print(tostring(node))
		for _, entId in pairs(nodelinks) do
			local ent = Entity(entId)
			--print(tostring(ent))
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
