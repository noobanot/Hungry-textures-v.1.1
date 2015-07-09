if(SERVER)then


else
	local MC = EnvX.MenuCore
	
	function BugReport()
		local PDA = MC.PDA.Menu.Catagorys

		local base = vgui.Create( "DPanel", PDA )
		base:SizeToContents()
		base.Paint = function() end
		PDA:AddSheet( "Report A Bug", base, "icon16/bug_edit.png", false, false, "Report a Bug!" ) 
		
		MC.LoadWebpage(base,{x=770,y=530},"https://github.com/ludsoe/Environments-X/issues")
		
	end

	hook.Add("LDEFillCatagorys","BugReporter",BugReport)	
end		
	