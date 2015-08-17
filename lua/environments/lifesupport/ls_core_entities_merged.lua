//Core Environments LS Entities/Devices
 
--Register the storage types.
Environments.RegisterLSStorage("Steam Storage", "env_steam_storage", {[3600] = "steam"}, 4084, 300, 50)
Environments.RegisterLSStorage("Water Storage", "env_water_storage", {[3600] = "water"}, 4084, 400, 500)
Environments.RegisterLSStorage("Energy Storage", "env_energy_storage", {[3600] = "energy"}, 6021, 200, 50)
Environments.RegisterLSStorage("Oxygen Storage", "env_oxygen_storage", {[4600] = "oxygen"}, 4084, 100, 20)
Environments.RegisterLSStorage("Hydrogen Storage", "env_hydrogen_storage", {[4600] = "hydrogen"}, 4084, 100, 20)
Environments.RegisterLSStorage("Nitrogen Storage", "env_nitrogen_storage", {[4600] = "nitrogen"}, 4084, 100, 20)
Environments.RegisterLSStorage("CO2 Storage", "env_co2_storage", {[4600] = "carbon dioxide"}, 4084, 100, 20)
Environments.RegisterLSStorage("Resource Cache", "env_cache_storage", {[1601] = "carbon dioxide",[1600] = "oxygen",[1602] = "hydrogen",[1603] = "nitrogen",[1599] = "water",[1598] = "steam",[1604] = "energy"}, 4084, 100, 10)

Environments.RegisterLSEntity("Water Heater","env_water_heater",{"water","energy"},{"steam"},
function(self) 
	local mult = self:GetSizeMultiplier()*self.multiplier 
	local amt = self:ConsumeResource("water", 200) or 0 
	amt = self:ConsumeResource("energy",amt*1.5)  
	self:SupplyResource("steam", amt) 
end, 70000, 300, 300)

//Generator Tool
--Autogen
Environments.RegisterDevice("Generators", "Resource Management", "R01 Automatic Resource Manager", "env_autogen", "models/rawr/minispire.mdl")

--Fusion Reactors
Environments.RegisterDevice("Generators", "Fusion Generator", "Small SBEP Reactor", "generator_fusion", "models/punisher239/punisher239_reactor_small.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Large SBEP Reactor", "generator_fusion", "models/punisher239/punisher239_reactor_big.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Small Pallet Reactor", "generator_fusion", "models/slyfo/forklift_reactor.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Large Crate Reactor", "generator_fusion", "models/slyfo/crate_reactor.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Classic Reactor", "generator_fusion", "models/props_c17/substation_circuitbreaker01a.mdl")
Environments.RegisterDevice("Generators", "Fusion Generator", "Rotary Reactor", "generator_fusion", "models/cerus/modbridge/misc/ls/ls_gen11a.mdl")

--Fission Reactor
--Environments.RegisterDevice("Generators", "Fission Generator", "Basic Fission Reactor", "generator_fission", "models/SBEP_community/d12siesmiccharge.mdl")

--WaterPumps
Environments.RegisterDevice("Generators", "Water Pump", "Small Water Pump", "generator_water", "models/maxofs2d/thruster_propeller.mdl")
Environments.RegisterDevice("Generators", "Water Pump", "Large Water Pump", "generator_water", "models/maxofs2d/hover_propeller.mdl")
Environments.RegisterDevice("Generators", "Water Pump", "Industrial Water Pump", "generator_water", "models/environmentsx/liquidpump.mdl")

--Atmospheric Water Generator
Environments.RegisterDevice("Generators", "Atmospheric Water Generator", "Atmospheric Water Generator Basic", "generator_water_tower", "models/Slyfo/moisture_condenser.mdl")
Environments.RegisterDevice("Generators", "Atmospheric Water Generator", "Atmospheric Water Generator", "generator_water_tower", "models/props_phx/life_support/rau_small.mdl")

--Compressors
--Environments.RegisterDevice("Generators", "Oxygen Compressor", "Oxygen Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "oxygen")
--Environments.RegisterDevice("Generators", "Nitrogen Compressor", "Nitrogen Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "nitrogen")
--Environments.RegisterDevice("Generators", "Hydrogen Compressor", "Hydrogen Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "hydrogen")
--Environments.RegisterDevice("Generators", "CO2 Compressor", "CO2 Compressor", "env_air_compressor", "models/props_outland/generator_static01a.mdl", nil, "carbon dioxide")

--SolarPanels
Environments.RegisterDevice("Generators", "Solar Panel", "Mounted Solar Panels", "generator_solar", "models/Slyfo_2/miscequipmentsolar.mdl")
Environments.RegisterDevice("Generators", "Solar Panel", "Small Mounted Solar Panel", "generator_solar", "models/Slyfo_2/acc_sci_spaneltanks.mdl")
Environments.RegisterDevice("Generators", "Solar Panel", "Micro Solar Panel Plate", "generator_solar", "models/environmentsx/solarsmall.mdl")
Environments.RegisterDevice("Generators", "Solar Panel", "Small Solar Panel Plate", "generator_solar", "models/environmentsx/solarmedium.mdl")

--Hydroponics
Environments.RegisterDevice("Life Support", "HydroPonics","Hydroponics Bush", "generator_plant", "models/props_foliage/tree_deciduous_03b.mdl",1)
Environments.RegisterDevice("Life Support", "HydroPonics","Hydroponics Tree", "generator_plant", "models/props_foliage/tree_deciduous_03a.mdl",1)
Environments.RegisterDevice("Life Support", "HydroPonics","Hydroponics Large Tree", "generator_plant", "models/props_foliage/tree_deciduous_01a.mdl",1)
Environments.RegisterDevice("Life Support", "HydroPonics","Hydroponics Potted plant", "generator_plant", "models/props/cs_office/plant01.mdl")

--WaterSplitters
Environments.RegisterDevice("Generators", "Water Splitter", "Electrolysis Generator", "generator_water_to_air", "models/slyfo/electrolysis_gen.mdl")
Environments.RegisterDevice("Generators", "Water Splitter", "Electrolysis Generator Compact", "generator_water_to_air", "models/sbep_community/d12airscrubber.mdl")

--HydrogenFuel Cells
Environments.RegisterDevice("Generators", "Hydrogen Fuel Cell", "Small Fuel Cell", "generator_hydrogen_fuel_cell", "models/slyfo/electrolysis_gen.mdl")
Environments.RegisterDevice("Generators", "Hydrogen Fuel Cell","Tiny Fuel Cell", "generator_hydrogen_fuel_cell", "models/Slyfo/crate_watersmall.mdl")

--Microwave Emitters
Environments.RegisterDevice("Generators", "Microwave Emitter", "Emitter", "generator_microwave", "models/slyfo/finfunnel.mdl")
Environments.RegisterDevice("Generators", "Microwave Emitter", "Small Reciever", "reciever_microwave", "models/slyfo_2/miscequipmentradiodish.mdl")
Environments.RegisterDevice("Generators", "Microwave Emitter", "Large Reciever", "reciever_microwave", "models/spacebuild/nova/recieverdish.mdl")
Environments.RegisterDevice("Generators", "Microwave Emitter", "Massive Reciever", "reciever_microwave", "models/props_spytech/satellite_dish001.mdl")

--SpaceGas Collectors
--Environments.RegisterDevice("Generators", "Space Gas Collectors", "Gas Collector", "generator_space_gas", "models/spacebuild/medbridge2_missile_launcher.mdl")

//Life Support Tool
--Suit Dispener
Environments.RegisterDevice("Life Support", "Suit Dispenser", "Suit Dispenser", "suit_dispenser", "models/props_combine/combine_emitter01.mdl")

--Medical Dispenser
Environments.RegisterDevice("Life Support", "Medical Dispenser", "Delux Dispenser", "env_health", "models/Items/HealthKit.mdl")

--LS Cores
Environments.RegisterDevice("Life Support", "LS Core", "LS Core", "env_lscore", "models/sbep_community/d12airscrubber.mdl")
Environments.RegisterDevice("Life Support", "LS Core","SmallBridge LS Core", "env_lscore","models/smallbridge/life support/sbclimatereg.mdl")

--AtmosProbe
Environments.RegisterDevice("Life Support", "Atmospheric Probe", "Atmospheric Probe", "env_probe", "models/props_combine/combine_mine01.mdl")
Environments.RegisterDevice("Life Support", "Atmospheric Probe", "Atmospheric Probe", "env_probe", "models/environmentsx/atmosensor.mdl")

--Trade Console
Environments.RegisterDevice("Life Support", "TradeConsoles","Deluxe TradeConsole", "env_tradeconsole", "models/SBEP_community/errject_smbwallcons.mdl")
Environments.RegisterDevice("Life Support", "TradeConsoles","Compact TradeConsole", "env_tradeconsole", "models/props_lab/reciever_cart.mdl")

--Item Fabricator
Environments.RegisterDevice("Life Support", "Fabricators","Item Materialiser", "env_factory", "models/slyfo/swordreconlauncher.mdl")

//Mining Devices...
Environments.RegisterEnt("mining_laser", 800, 500, 12)
Environments.RegisterEnt("resource_drill", 1500, 850, 14)
Environments.RegisterEnt("resource_scanner", 1200, 350, 10)

--# Mining Laser
Environments.RegisterDevice("Mining Devices","Mining Laser","Standard Mining Laser","mining_laser","models/Slyfo_2/pss_missilepod.mdl")

--# Surface Drills
Environments.RegisterDevice("Mining Devices","Mining Drills","Offset Drill Rig","resource_drill","models/Slyfo/rover_drillbase.mdl",0,1)
Environments.RegisterDevice("Mining Devices","Mining Drills","Standrd Drill Platform","resource_drill","models/Slyfo/drillplatform.mdl",0,2)
Environments.RegisterDevice("Mining Devices","Mining Drills","Basic Drill Rig","resource_drill","models/Slyfo/drillbase_basic.mdl",0,3)

--# Resource Scanners
Environments.RegisterDevice("Mining Devices","Detection","Huge Resource Scanner","resource_scanner","models/Slyfo_2/sattelite_doomray.mdl",1,12000)
Environments.RegisterDevice("Mining Devices","Detection","Large Resource Scanner","resource_scanner","models/Slyfo/sat_relay.mdl",1,8192)
Environments.RegisterDevice("Mining Devices","Detection","Medium Resource Scanner","resource_scanner","models/Slyfo/searchlight.mdl",1,2000)
Environments.RegisterDevice("Mining Devices","Detection","Small Resource Scanner","resource_scanner","models/Slyfo/rover1_spotlight.mdl",1,1000)

//Storage Tool
--Water
Environments.RegisterDevice("Storages", "Water Storage", "Massive Water Tank", "env_water_storage", "models/props/de_nuke/storagetank.mdl")
Environments.RegisterDevice("Storages", "Water Storage", "Water Shipping Tank", "env_water_storage", "models/slyfo/crate_resource_large.mdl")
Environments.RegisterDevice("Storages", "Water Storage", "Small Water Tank", "env_water_storage", "models/slyfo/crate_watersmall.mdl")

--Energy
Environments.RegisterDevice("Storages", "Energy Storage", "Substation Capacitor", "env_energy_storage", "models/props_c17/substation_stripebox01a.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Substation Backup Battery", "env_energy_storage", "models/props_c17/substation_transformer01a.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Large Capacitor", "env_energy_storage", "models/mandrac/energy_cell/large_cell.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Medium Capacitor", "env_energy_storage", "models/mandrac/energy_cell/medium_cell.mdl")
Environments.RegisterDevice("Storages", "Energy Storage", "Small Capacitor", "env_energy_storage", "models/mandrac/energy_cell/small_cell.mdl")

--Oxygen 
Environments.RegisterDevice("Storages", "Oxygen Storage", "Large Oxygen Storage", "env_oxygen_storage", "models/props_wasteland/coolingtank02.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Oxygen Shipping Tank", "env_oxygen_storage", "models/slyfo/crate_resource_large.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Large Compressed Oxygen Crate", "env_oxygen_storage", "models/mandrac/oxygen_tank/oxygen_tank_large.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Medium Compressed Oxygen Crate", "env_oxygen_storage", "models/mandrac/oxygen_tank/oxygen_tank_medium.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Small Compressed Oxygen Crate", "env_oxygen_storage", "models/mandrac/oxygen_tank/oxygen_tank_small.mdl")
Environments.RegisterDevice("Storages", "Oxygen Storage", "Compact Oxygen Tank", "env_oxygen_storage", "models/environmentsx/gastank.mdl")

--Nitrogen 
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Large Nitrogen Storage", "env_nitrogen_storage", "models/props_wasteland/coolingtank02.mdl")
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Nitrogen Shipping Tank", "env_nitrogen_storage", "models/slyfo/crate_resource_large.mdl")
Environments.RegisterDevice("Storages", "Nitrogen Storage", "Compact Nitrogen Tank", "env_nitrogen_storage", "models/environmentsx/gastank.mdl")

--Hydrogen 
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Large Hydrogen Storage", "env_hydrogen_storage", "models/props_wasteland/coolingtank02.mdl")
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Hydrogen Shipping Tank", "env_hydrogen_storage", "models/slyfo/crate_resource_large.mdl")
Environments.RegisterDevice("Storages", "Hydrogen Storage", "Compact Hydrogen Tank", "env_hydrogen_storage", "models/environmentsx/gastank.mdl")

--Co2
Environments.RegisterDevice("Storages", "CO2 Storage", "Large CO2 Storage", "env_co2_storage", "models/props_wasteland/coolingtank02.mdl")
Environments.RegisterDevice("Storages", "CO2 Storage", "Compact CO2 Tank", "env_co2_storage", "models/environmentsx/gastank.mdl")

--Resource Cache
Environments.RegisterDevice("Storages", "Resource Cache","Modular Unit X-01","env_cache_storage","models/Spacebuild/milcock4_multipod1.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","Slyfo Tank 1","env_cache_storage","models/slyfo/t-eng.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","Slyfo Power Crystal","env_cache_storage","models/Slyfo/powercrystal.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge Small Wall Cache","env_cache_storage","models/SmallBridge/Life Support/SBwallcacheS.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge Large Wall Cache","env_cache_storage","models/SmallBridge/Life Support/SBwallcacheL.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge External Wall Cache","env_cache_storage","models/SmallBridge/Life Support/SBwallcacheE.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge Small Wall Cache (half length)","env_cache_storage","models/smallbridge/Life Support/SBwallcacheS05.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge Large Wall Cache (half length)","env_cache_storage","models/smallbridge/Life Support/SBwallcacheL05.mdl")
Environments.RegisterDevice("Storages", "Resource Cache","SmallBridge Hull Cache","env_cache_storage","models/smallbridge/life support/sbhullcache.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Mandrac Cargo Cache", "env_cache_storage", "models/mandrac/resource_cache/cargo_cache.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Mandrac Huge Cache", "env_cache_storage", "models/mandrac/resource_cache/colossal_cache.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Mandrac Hanger Container", "env_cache_storage", "models/mandrac/resource_cache/hangar_container.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Mandrac Large Cache", "env_cache_storage", "models/mandrac/resource_cache/huge_cache.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Mandrac Medium Cache", "env_cache_storage", "models/mandrac/resource_cache/large_cache.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Mandrac Small Cache", "env_cache_storage", "models/mandrac/resource_cache/medium_cache.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Mandrac Tiny Cache", "env_cache_storage", "models/mandrac/resource_cache/small_cache.mdl")
Environments.RegisterDevice("Storages", "Resource Cache", "Mandrac Levy Cache", "env_cache_storage", "models/mandrac/nitrogen_tank/nitro_large.mdl")

//Ship Utilities
--Extra
Environments.RegisterDevice("Ship Utilities", "Extra","Vehicle Exit Point", "EPoint", "models/jaanus/wiretool/wiretool_range.mdl")
Environments.RegisterDevice("Ship Utilities", "Extra","Matter Transporter", "wep_transporter", "models/SBEP_community/d12shieldemitter.mdl")
Environments.RegisterDevice("Ship Utilities", "Extra","WarpDrive", "WarpDrive", "models/Slyfo/ftl_drive.mdl")
Environments.RegisterDevice("Ship Utilities", "Extra","Cloning Device", "envx_clonetube", "models/TwinbladeTM/cryotubemkii.mdl")

//BaseBuilding Prototype
Environments.RegisterDevice("Base Construction", "CoreModules","Base Node", "lde_basecore", "models/Cerus/Modbridge/Misc/LS/ls_gen11a.mdl")