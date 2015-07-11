AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_env_base"

ENT.PrintName	= "Environments Storage Core"
ENT.Author		= "CmdrMatthew,Ludsoe"
ENT.Purpose		= "Base for all RD Storages"
ENT.Instructions	= ""

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

if(SERVER)then

else
	ENT.RenderGroup = RENDERGROUP_BOTH
end		
