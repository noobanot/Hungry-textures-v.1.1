if(SERVER)then


else

	function BugReport()
		local SuperMenu = LDE.UI.SuperMenu.Menu.Catagorys

		local base = vgui.Create( "DPanel", SuperMenu )
		base:SizeToContents()
		base.Paint = function() end
		SuperMenu:AddSheet( "Report A Bug", base, "icon16/bug_edit.png", false, false, "Report a Bug!" ) 
		
		LDE.UI.LoadWebpage(base,{x=770,y=530},"https://github.com/ludsoe/Environments-X/issues")
		
	end

	hook.Add("LDEFillCatagorys","BugReporter",BugReport)	
end		
	