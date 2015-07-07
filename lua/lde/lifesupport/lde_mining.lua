
//Polylodarium
local Base = {Tool="Mining Devices",Type="Polylodarium"}

--Crystalised Polylodarium Refinery
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Crystalised Polylodarium Refinery",class="generator_crys_poly_refine",In={"Crystalised Polylodarium","energy"},Out={"Liquid Polylodarium","AntiMatter"},shootfunc=Func,InUse={1200,10000},OutMake={400,1}}
local Makeup = {name={"Crystalised Polylodarium Refinery"},model={"models/Cerus/Modbridge/Misc/LS/ls_gen11a.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

--Liquid Polylodarium dehydrator
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Liquid Polylodarium Dehydrator",class="generator_poly_dehydrator",In={"Liquid Polylodarium","energy"},Out={"Crystalised Polylodarium"},shootfunc=Func,InUse={10,2000},OutMake={20}}
local Makeup = {name={"Polylodarium Dehydrator"},model={"models/Slyfo_2/acc_sci_coolerator.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

--Polylodarium Hydrator
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Polylodarium Rehydrator",class="generator_poly_hydrator",In={"Liquid Polylodarium","energy"},Out={"water"},shootfunc=Func,InUse={10,800},OutMake={300}}
local Makeup = {name={"Polylodarium Rehydrator"},model={"models/Slyfo_2/acc_sci_coolerator.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

//Plasma
local Base = {Tool="Mining Devices",Type="Plasma"}

--Plasma Heater
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Plasma Heater",class="generator_plasma_heat",In={"energy","hydrogen",},Out={"Plasma"},shootfunc=Func,InUse={800,100},OutMake={10}}
local Makeup = {name={"Plasma Heater","Micro Heater"},model={"models/Punisher239/punisher239_reactor_small.mdl","models/SBEP_community/d12fusionbomb.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

//Ore
local Base = {Tool="Mining Devices",Type="Ore"}

--Ore refinery
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Ore Refinery",class="generator_ore_refinery",In={"Raw Ore","energy"},Out={"Refined Ore","carbon dioxide"},shootfunc=Func,InUse={10,300},OutMake={8,40}}
local Makeup = {name={"Ore Refinery"},model={"models/Slyfo/refinery_small.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

--Ore hardener
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Ore Hardener",class="generator_ore_hardener",In={"Refined Ore","Crystalised Polylodarium","energy"},Out={"Hardened Ore"},shootfunc=Func,InUse={50,40,1000},OutMake={30}}
local Makeup = {name={"Small Ore Hardener","Large Ore Hardener"},model={"models/slyfo_2/acc_sci_coolerator.mdl","models/Cerus/Modbridge/Misc/LS/ls_gen11a.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

//Carbon
local Base = {Tool="Mining Devices",Type="Carbon"}

--Carbon Extractor
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Carbon Extractor",class="generator_carbon_extract",In={"Raw Ore","energy"},Out={"Carbon"},shootfunc=Func,InUse={10,400},OutMake={2}}
local Makeup = {name={"Carbon Extractor"},model={"models/Slyfo_2/acc_sci_hoterator.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

--Carbon Oxidizer
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Carbon Oxidizer",class="generator_carbon_oxidizer",In={"Carbon","oxygen","energy"},Out={"carbon dioxide"},shootfunc=Func,InUse={3,30,600},OutMake={25}}
local Makeup = {name={"Carbon Oxidizer"},model={"models/SBEP_community/d12airscrubber.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

--Scrap Collector
local Base = {Tool="Life Support",Type="Scrap Collection"}
local Func = function(self) end
local Data={name="Scrap Collector",class="generator_scrap_collect",In={"Scrap Bits"},Out={"Recycled Resources"},shootfunc=Func,InUse={0},OutMake={0}}
local Makeup = {name={"Scrap Collector"},model={"models/Slyfo/finfunnel.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)


-------------I will decide if i want to keep this or not later.---------------------
--[[
//Electromium
local Base = {Tool="Mining Devices",Type="Electromium"}

--Electromium Materialiser
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Electromium Materialiser",class="generator_electrom_mat",In={"energy"},Out={"Electromium"},shootfunc=Func,InUse={2000},OutMake={2}}
local Makeup = {name={"Electromium Materialiser"},model={"models/ce_ls3additional/fusion_generator/fusion_generator_large.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)

--Electromium Converter
local Func = function(self) if(self.Active==1)then LDE.LifeSupport.ManageResources(self) end end
local Data={name="Electromium Converter",class="generator_electrom_con",In={"Electromium"},Out={"Liquid Polylodarium"},shootfunc=Func,InUse={20},OutMake={2}}
local Makeup = {name={"Electromium Converter"},model={"models/chipstiks_ls3_models/NitrogenLiquifier/nitrogenliquifier.mdl"},Tool=Base.Tool,Type=Base.Type,class=Data.class}
LDE.LifeSupport.CompileDevice(Data,Makeup)
]]

