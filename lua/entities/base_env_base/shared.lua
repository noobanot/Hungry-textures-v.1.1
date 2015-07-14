
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName	= "Environments Base Base"
ENT.Author		= "Ludsoe"
ENT.Purpose		= "Base for all RD Bases"
ENT.Instructions	= ""

ENT.Spawnable		= false
ENT.AdminSpawnable	= false

local LDE = LDE --Localise the global table for speed.
local Utl = EnvX.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.
local MC = EnvX.MenuCore

if(SERVER)then
	local T = {} --Create a empty Table
	
	T.Power = function(Device,ply,Data)
		Device:SetActive( nil, ply )
	end
	
	T.Mult = function(Device,ply,Data)
		Device:SetMultiplier(tonumber(Data))
	end
	
	T.Mute = function(Device,ply,Data)
		if (Device.TriggerInput) then
			Device:TriggerInput("Mute", tonumber(Data))//SetMultiplier(tonumber(args[2]))
		end
	end
	
	ENT.Panel=T --Set our panel functions to the table.
else
	ENT.RenderGroup = RENDERGROUP_BOTH

	function ENT:PanelFunc(entID)	
		self.DevicePanel = {
			function() return MC.CreateButton(Parent,{x=90,y=30},{x=0,y=0},"Toggle Power",function() RunConsoleCommand( "envsendpcommand",self:EntIndex(),"Power") end) end,
			function()
				local S = MC.CreateSlider(Parent,{x=150,y=30},{x=0,y=0},{Min=1,Max=100,Dec=0},"Multiplier",function(val) RunConsoleCommand( "envsendpcommand",self:EntIndex(),"Mult",val) end)
				S:SetValue(self:GetNetworkedInt("EnvMultiplier"))
				return S
			end,
			function()
				local S = MC.CreateCheckbox(Parent,{x=0,y=0},"Mute",function(val) RunConsoleCommand( "envsendpcommand",self:EntIndex(),"Mute",val) end)
				S:SetChecked()
				return S
			end
		}
	end
	
	Utl:HookNet("EnvxDevicePanel",function(Data)
		local ID,E = Data.EntID,Data.Entity
		if not E or not IsValid(E) or not E.PanelFunc then return end
		
		E:PanelFunc(ID)
		
		E.Window = vgui.Create( "EnvDeviceGUI")
		E.Window:SetMouseInputEnabled( true )
		E.Window:SetVisible( true )
		E.Window:CompilePanel(E)		
	end)
end		


