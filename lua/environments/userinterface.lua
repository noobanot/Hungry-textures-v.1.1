
local Environments = Environments --yay speed boost!

Environments.UI = {}
Environments.UI.Panel ={}

local MC = EnvX.MenuCore

if(CLIENT)then

	local VGUI = {}
		function VGUI:Init()
		
			self.GBase = MC.CreateFrame({x=300,y=200},true,true,true,true)
			self.GBase:Center()
			self.GBase:SetTitle( "" )
			self.GBase:MakePopup()
			
			MC.CreateText(self.GBase,{x=10,y=5},"Device Interface")
			
			self.GForm = vgui.Create( "DPanelList", self.GBase )
			self.GForm:SetPos(0,20)
			self.GForm:SetSize(300, 200)-- 545 , 426 
			self.GForm:SetSpacing( 15 )
			self.GForm:SetPadding( 5 )
		end
		
		function VGUI:CompilePanel(E) --Where the magic happens.
			--print("------Compiling Panel------")
			local Data = {}
			
			if not E.DevicePanel then print("Error No Panel Data.") return end
			if E.NoEnvPanel then print("Whoa... This ent doesnt want a panel :/") self.GBase:Remove() return end			
			
			for t,s in pairs(E.DevicePanel) do
				local Derma = s()
				
				self.GForm:AddItem(Derma)
			end
			
			--print("-----------Done-----------")
						
			self.GBase.Device = entID
			self.GBase:SizeToContents()--Resize our Base to hold the new stuff :p
		end
		
	vgui.Register( "EnvDeviceGUI", VGUI ) --Register our custom VGui so devices can use it.

	---------Page Population Functions----------
	local Table = {}

	Table.Display=function(label,D,Parent,Device)
		label = MC.CreateText(Parent,{x=0,y=0},D.Text)
		label.Think = function(self)
			self:SetText(Device.Functions[D.Func]())
		end
		return label
	end
	
	Environments.UI.Panel.Populate = Table

	--------------------------------
else
----Server side-----

	function EnvPanCommand(ply,cmd,args)				
		local Device = Entity( tonumber(args[1]) ) --Get the device out of the command
		if not Device or not IsValid(Device)then return end --Is the device valid?
		---Put can run check here---
		
		local Command = args[2] -- Grab the command were gonna send the device.
		local Data = args[3] --Grab the variable for the command if possible
		
		if(Device.Panel[Command])then --Does the device have the needed function?
			Device.Panel[Command](Device,ply,Data)--Send the command through to the device.
		else
			print("Error: "..Command.." is Invalid on Device "..args[1]) --Somethings wrong here.
		end
	end
	concommand.Add("envsendpcommand", EnvPanCommand)

end