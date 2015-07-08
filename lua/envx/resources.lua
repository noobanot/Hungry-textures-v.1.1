EnvX.Resources = {Ids={},Names={},Data={},Interactions={}}

function EnvX.RegisterResource(name,data)
	local index = table.Count(EnvX.Resources.Ids) + 1
	EnvX.Resources.Ids[name] = index
	EnvX.Resources.Names[index] = data.DisplayName
	EnvX.Resources.Data[index] = data
	
	print("Registered Resource.. "..data.DisplayName)
end

function EnvX.GetResourceData(name)
	local ID = EnvX.Resources.Ids[name]

	if ID then
		return EnvX.Resources.Data[ID]
	end
end

function EnvX.RegisterInteraction(res1,res2,value)
	local Id1,Id2 = EnvX.Resources.Ids[res1], EnvX.Resources.Ids[res2]
	
	if not Id1 or not Id2 then print("You can't register interactions for resources before you register the resources themselfs! "..res1.."|"..res2) return end
	
	EnvX.Resources.Interactions[Id1] = EnvX.Resources.Interactions[Id1] or {}
	EnvX.Resources.Interactions[Id1][Id2] = value

	EnvX.Resources.Interactions[Id2] = EnvX.Resources.Interactions[Id2] or {}
	EnvX.Resources.Interactions[Id2][Id1] = value
end

EnvX.RegisterResource("energy",{
	MUnit = " kJ", --Measurement Unit.
	DisplayName = "Energy", --Display Name for clientside.
	Volatality = 0, --How Explosive a resource is.
	MaintainCost = {} --Resource costs to maintain a storage of this resource.
})

----------Base Resources--------------
--Not Volatile
EnvX.RegisterResource("water",{MUnit = " L", DisplayName = "Water", Volatality = -1, MaintainCost = {}})
EnvX.RegisterResource("nitrogen",{MUnit = " L", DisplayName = "Nitrogen", Volatality = 0, MaintainCost = {}})
EnvX.RegisterResource("steam",{MUnit = " L", DisplayName = "Steam", Volatality = -0.2, MaintainCost = {}})
EnvX.RegisterResource("carbon dioxide",{MUnit = " L", DisplayName = "CO2", Volatality = -0.2, MaintainCost = {}})

--Volatile
EnvX.RegisterResource("hydrogen",{MUnit = " L", DisplayName = "Hydrogen", Volatality = 1, MaintainCost = {}})
EnvX.RegisterResource("oxygen",{MUnit = " L", DisplayName = "Oxygen", Volatality = 0.2, MaintainCost = {}})

----------Mining Resources--------------
--Not Volatile
EnvX.RegisterResource("Raw Ore",{MUnit = " kg", DisplayName = "Raw Ore", Volatality = 0, MaintainCost = {}})
EnvX.RegisterResource("Refined Ore",{MUnit = " kg", DisplayName = "Refined Ore", Volatality = 0, MaintainCost = {}})
EnvX.RegisterResource("Hardened Ore",{MUnit = " kg", DisplayName = "Hardened Ore", Volatality = 0, MaintainCost = {}})
EnvX.RegisterResource("Carbon",{MUnit = " kg", DisplayName = "Carbon", Volatality = 0, MaintainCost = {}})

--Volatile
EnvX.RegisterResource("Crystalised Polylodarium",{MUnit = " kg", DisplayName = "Crystalised Polylodarium", Volatality = 4, MaintainCost = {}})
EnvX.RegisterResource("Liquid Polylodarium",{MUnit = " L", DisplayName = "Liquid Polylodarium", Volatality = 6, MaintainCost = {}})
EnvX.RegisterResource("AntiMatter",{MUnit = " g", DisplayName = "AntiMatter", Volatality = 80, MaintainCost = {energy={1,100}}})

----------Ammounition Resources--------------
--Not Volatile
EnvX.RegisterResource("Casings",{MUnit = "", DisplayName = "Casings", Volatality = 0, MaintainCost = {}})
EnvX.RegisterResource("Missile Parts",{MUnit = "", DisplayName = "Missile Parts", Volatality = 0, MaintainCost = {}})

--Volatile
EnvX.RegisterResource("Basic Rounds",{MUnit = "", DisplayName = "Basic Rounds", Volatality = 1, MaintainCost = {}})

EnvX.RegisterResource("Basic Shells",{MUnit = "", DisplayName = "Basic Shells", Volatality = 4, MaintainCost = {}})
EnvX.RegisterResource("Heavy Shells",{MUnit = "", DisplayName = "Heavy Shells", Volatality = 8, MaintainCost = {}})

EnvX.RegisterResource("Plasma",{MUnit = " L", DisplayName = "Plasma", Volatality = 10, MaintainCost = {}})
EnvX.RegisterResource("BlackHolium",{MUnit = "", DisplayName = "Plasma", Volatality = -900, MaintainCost = {}})



















