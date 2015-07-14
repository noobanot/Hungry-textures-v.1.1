ENT.Type 		= "anim"
ENT.Base 		= "base_env_entity"
ENT.PrintName 	= "Fusion Reactor"

list.Set( "LSEntOverlayText" , "generator_fusion", {HasOOO = true, num = 2, resnames = {"water"}, genresnames={"energy"}} )

local MC = EnvX.MenuCore

if(SERVER)then
	
	local T = {} --Create a empty Table
	
	T.Power = function(Device,ply,Data)
		Device:SetActive( nil, ply )
	end
	
	ENT.Panel=T --Set our panel functions to the table.
	
else 	
	function ENT:PanelFunc(entID)	
		self.DevicePanel = {
			function() return MC.CreateButton(Parent,{x=90,y=30},{x=0,y=0},"Toggle Power",function() RunConsoleCommand( "envsendpcommand",self:EntIndex(),"Power") end) end
		}
	end
end