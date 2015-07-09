if(SERVER)then


else

	function ECDTab()
		local PDA = MC.PDA.Menu.Catagorys

		local base = vgui.Create( "DPanel", PDA.Base )
		base:SizeToContents()
		base.Paint = function() end
		PDA.Base:AddSheet( "Stats", base, "icon16/book_open.png", false, false, "View your stats." ) 
		
	end

	--hook.Add("LDEFillCatagorys","Stats",ECDTab)	
end		
	