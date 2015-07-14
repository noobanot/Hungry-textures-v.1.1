ENT.Type 		= "anim"
ENT.Base 		= "base_env_entity"
ENT.PrintName 	= "Resource Scanner"

list.Set( "LSEntOverlayText" , "resource_scanner", {HasOOO = true, resnames = {"energy"} } )

function ENT:SetupDataTables()
	self:DTVar("Float",0,"Density")
	self:DTVar("Int",0,"Size")
	self:DTVar("Int",1,"Quantity")
	self:DTVar("Int",2,"Range")
	self:DTVar("Int",3,"ScanAngle")
	self:DTVar("Float",1,"Depth")
	self:DTVar("Float",2,"Distance")
	self:DTVar("Angle",0,"TargetAngle")
end

local MC = EnvX.MenuCore

if(SERVER)then
	local T = {} --Create a empty Table
	
	T.Power = function(Device,ply,Data)
		Device:SetActive( nil, ply )
	end
	
	T.Range = function(Device,ply,Data)
		Device:SetRange(tonumber(Data))
	end
	
	T.Angle = function(Device,ply,Data)
		Device:SetScanAngle(tonumber(Data))
	end
	
	ENT.Panel=T --Set our panel functions to the table.
else
	function ENT:PanelFunc(entID)	
		self.DevicePanel = {
			function() return MC.CreateButton(Parent,{x=90,y=30},{x=0,y=0},"Toggle Power",function() RunConsoleCommand( "envsendpcommand",self:EntIndex(),"Power") end) end,
			function()
				local S = MC.CreateSlider(Parent,{x=150,y=30},{x=0,y=0},{Min=50,Max=8000,Dec=0},"Scan Range",function(val) RunConsoleCommand( "envsendpcommand",self:EntIndex(),"Range",val) end)
				S:SetValue(self.dt.Range)
				return S
			end,
			function()
				local S = MC.CreateSlider(Parent,{x=150,y=30},{x=0,y=0},{Min=5,Max=45,Dec=0},"Scan Angle",function(val) RunConsoleCommand( "envsendpcommand",self:EntIndex(),"Angle",val) end)
				S:SetValue(self.dt.ScanAngle)
				return S
			end
		}
	end
end		

