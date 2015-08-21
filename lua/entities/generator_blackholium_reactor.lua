AddCSLuaFile()

ENT.Type 			= "anim"
ENT.Base 			= "base_env_base"
ENT.PrintName		= "Blackholium Reactor"
ENT.Author			= "Ludsoe"
ENT.Category		= "Environments"

ENT.Spawnable		= false
ENT.AdminSpawnable	= true

list.Set( "LSEntOverlayText" , "generator_blackholium_reactor", {HasOOO = true, resnames ={"energy","Blackholium"} } )

if(SERVER)then
	function ENT:Initialize()
		self.BaseClass.Initialize(self)
		
		self:AddResource("energy",10000)
		self:AddResource("Blackholium",200)
	end
else

end		
