ENT.Type                = "anim"
ENT.Base                = "base_env_entity"
ENT.PrintName			= "Resource Pump"

list.Set( "LSEntOverlayText" , "env_pump", {resnames = {}} )

--Allow Duplicators to dupe this class.
duplicator.Allow("env_pump")