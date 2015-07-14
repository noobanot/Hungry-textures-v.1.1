
ENT.Type = "anim"
ENT.Base = "base_env_entity"
ENT.PrintName = "LS Core"
ENT.Author = "CmdrMatthew"
ENT.Purpose = "To Test"
ENT.Instructions = "Eat up!" 
ENT.Category = "Environments"


list.Set( "LSEntOverlayText" , "env_lscore", {HasOOO = true, resnames ={ "oxygen", "energy", "water", "nitrogen"} } )

local MC = EnvX.MenuCore

if(SERVER)then
	
	local T = {} --Create a empty Table
	
	T.Power = function(Device,ply,Data)
		Device:SetActive( nil, ply )
	end
	
	T.O2Per = function(Device,ply,Data)
		if (Device.TriggerInput) then
			Device:TriggerInput("Max O2 level", tonumber(Data))//SetMultiplier(tonumber(args[2]))
		end
	end
	
	T.Gravity = function(Device,ply,Data)
		if (Device.TriggerInput) then
			Device:TriggerInput("Gravity", tonumber(Data))//SetMultiplier(tonumber(args[2]))
		end
	end
	
	ENT.Panel=T --Set our panel functions to the table.
	
else 

	function ENT:PanelFunc(entID)	
		self.DevicePanel = {
			function() return MC.CreateButton(Parent,{x=90,y=30},{x=0,y=0},"Toggle Power",function() RunConsoleCommand( "envsendpcommand",self:EntIndex(),"Power") end) end,
			function()
				local S = MC.CreateSlider(Parent,{x=150,y=30},{x=0,y=0},{Min=1,Max=100,Dec=0},"O2 Percent",function(val) RunConsoleCommand( "envsendpcommand",self:EntIndex(),"O2Per",val) end)
				S:SetValue(self:GetNetworkedInt("EnvMaxO2") or 11)
				return S
			end,
			function()
				local S = MC.CreateCheckbox(Parent,{x=0,y=0},"Gravity",function(val) RunConsoleCommand( "envsendpcommand",self:EntIndex(),"Gravity",val) end)
				S:SetChecked()
				return S
			end
		}
	end
end
