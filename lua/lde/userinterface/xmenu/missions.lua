if(SERVER)then


else
	local MC = EnvX.MenuCore
	
	function ECDTab()
		local PDA = MC.PDA.Menu.Catagorys

		local base = vgui.Create( "DPanel", PDA )
		base:SizeToContents()
		base.Paint = function() end
		PDA:AddSheet( "Missions", base, "icon16/book_open.png", false, false, "Complete Missions" ) 
		
		local List = MC.CreateList(base,{x=300,y=200},{x=0,y=0},false,function() end)
		List:AddColumn("Mission") -- Add column

		--[[for k,v in pairs(LocalPlayer():GetStats()) do
			List:AddLine(k,v)
		end]]
	end

	hook.Add("LDEFillCatagorys","Missions",ECDTab)	
end		
	