
local function AddToolTab()
	-- Add Tab
	local logo;
	--if(file.Exists("..logo")) then logo = "logo" end;
	spawnmenu.AddToolTab("Environments","Environments",logo)
	-- Add Config Category
	spawnmenu.AddToolCategory("Environments","Config"," Config");
	-- Add the admin menu
	spawnmenu.AddToolMenuOption("Environments","Config","Admin Tools","Admin Tools","","",Environments.AdminMenu,{});
	-- Add the entry for Credits and Bugreporting!
	--spawnmenu.AddToolMenuOption("Environments","Config","Credits","Credits and Bugs","","",Environments.Credits);
	-- Add our tools to the tab
	/*local toolgun = weapons.Get("gmod_tool");
	if(toolgun and toolgun.Tool) then
		for k,v in pairs(toolgun.Tool) do
			if(not v.AddToMenu and v.Tab == "Environments") then
				spawnmenu.AddToolMenuOption(
					v.Tab,
					v.Category or "",
					k,
					v.Name or "#"..k,
					v.Command or "gmod_tool "..k,
					v.ConfigName or k,
					v.BuildCPanel
				);
			end
		end
	end*/
end
hook.Add("AddToolMenuTabs", "EnvironmentsAddTabs", AddToolTab);

hook.Add( "PopulateMenuBar", "EnvironmentsAddMenubar", function( menubar )
    local m = menubar:AddOrGetMenu( "Environments" )
	
	//local sub = m:AddSubMenu( "Admin Options")
	
	m:AddOption("Reload Environments", function() RunConsoleCommand("env_server_reload") end)
	m:AddOption("Fully Reload Environments", function() RunConsoleCommand("env_server_full_reload") end)
	
    m:AddSpacer()
    
    m:AddSpacer()
	
	m:AddOption("Reload HUD", function() RunConsoleCommand("env_reload_hud") end)
end )

local function Bool2Num(b)
	if b == true then
		return "1"
	else
		return "0"
	end
end

local Menu = {}
local PlanetData = {}
local function GetData(msg)
	PlanetData["name"] = msg:ReadString()
	PlanetData["gravity"] = msg:ReadFloat()
	PlanetData["unstable"] = msg:ReadBool()
	PlanetData["sunburn"] = msg:ReadBool()
	PlanetData["temperature"] = msg:ReadFloat()
	PlanetData["suntemperature"] = msg:ReadFloat()
	
	Menu.List:Clear()
	for k,v in pairs(PlanetData) do
		Menu.List:AddLine(k,tostring(v))
	end
end
usermessage.Hook("env_planet_data", GetData)

function Environments.AdminMenu(Panel)
	Panel:ClearControls()
	if LocalPlayer():IsAdmin() then
		Panel:Button("Reset Environments", "env_server_reload")
		
		Panel:Help("Enable Noclip For Everyone?")
		local box = Panel:AddControl("CheckBox", {Label = "Enable Noclip?", Command = ""} )
		box:SetValue(tobool(GetConVarNumber("env_noclip")))
		box.Button.Toggle = function()
			if box.Button:GetChecked() == nil or not box.Button:GetChecked() then 
				box.Button:SetValue( true ) 
			else 
				box.Button:SetValue( false ) 
			end 
			RunConsoleCommand("environments_admin", "noclip", Bool2Num(box.Button:GetChecked()))
		end
		
		local planetmod =  vgui.Create("DCollapsibleCategory", DermaPanel)
		planetmod:SetSize( 100, 50 ) -- Keep the second number at 50
		planetmod:SetExpanded( 0 ) -- Expanded when popped up
		planetmod:SetLabel( "Planet Modification" )
		
		local p = vgui.Create( "DPanelList" )
		p:SetAutoSize( true )
		p:SetSpacing( 5 )
		p:EnableHorizontal( false )
		p:EnableVerticalScrollbar( true )
		 
		planetmod:SetContents( p )
		
		local List = vgui.Create("DListView")
		List:SetSize(100, 100)
		List:SetMultiSelect(false)
		List:AddColumn("Setting")
		List:AddColumn("Value")
		Menu.List = List
		
		for k,v in pairs(PlanetData) do
			List:AddLine(k,v)
		end
		
		List.OnRowSelected = function(self, line)
			line = self:GetLine(line)
			local setting = line:GetValue(1)
			local value = line:GetValue(2)
			Menu.Entry.line = line
			Menu.Entry:SetValue(value)
		end	

		local entry = vgui.Create( "DTextEntry" )
		entry:SetTall( 20 )
		entry:SetWide( 160 )
		entry:SetEnterAllowed( false )
		entry:SetMultiline(false)
		entry.OnTextChanged = function(self) -- Passes a single argument, the text entry object.
			if self.line then
				self.line:SetValue(2, self:GetValue())
			end
		end
		Menu.Entry = entry

		local send = vgui.Create( "DButton" )
		send:SetSize( 100, 30 )
		send:SetText( "Set Value" )
		send.DoClick = function( self )
			if Menu.Entry.line then
				RunConsoleCommand("environments_admin", "planetconfig", Menu.Entry.line:GetValue(1), Menu.Entry.line:GetValue(2))
			else
				LocalPlayer():ChatPrint("Select a value to set first!")
			end
		end
		 
		local get = vgui.Create( "DButton" )
		get:SetSize( 100, 30 )
		get:SetText( "Get Planet Info" )
		get.DoClick = function( self )
			RunConsoleCommand("request_planet_data")
		end
		
		p:AddItem(List)
		p:AddItem(entry)
		p:AddItem(send)
		p:AddItem(get)
		Panel:AddPanel(planetmod)
		
		Panel:Help("WARNING: Resets Saved Data!"):SetTextColor(Color(255,0,0,255))
		Panel:Button("Reload Environments From Map", "env_server_full_reload")
	else
		Panel:Help("You are not an admin!")
	end
end

/*function Environments.Credits(Panel)
	-- The Credits Button
	if(Enviroments.HasInternet) then
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetHelp("credits");
		VGUI:SetTopic("Credits");
		VGUI:SetText("Credits");
		VGUI:SetImage("gui/silkicons/star");
		Panel:AddPanel(VGUI);
		Panel:Help("Here, you can report bugs. If you can't type in the HTML-Formulars, visit "..Environments.HTTP.BUGS.." with your webbrowser");
		local VGUI = vgui.Create("SHelpButton",Panel);
		VGUI:SetTopic("Bugs");
		VGUI:SetText("Bugs");
		VGUI:SetImage("gui/silkicons/exclamation");
		VGUI:SetURL(Environments.HTTP.BUGS);
		Panel:AddPanel(VGUI);
		Panel:Help("");
		
		local HTML = vgui.Create("HTML",self);
		-- Crappy Quicks-HTML for a crappy browser (Internet-Explorer)
		HTML:SetHTML([[
			<html>
				<body margin="0" padding="0">
					<center><img margin="0" padding="0" border="0" alt="Latest Environments BUILD" src="]]..Environments.HTTP.VERSION_LOGO..[["/ ></center>
				</body>
			</html>
		]]);
		HTML:SetSize(128,164);
		Panel:AddPanel(HTML);
		
		-- Tells, if he is out-of-date
		if(Environments.CurrentVersion > Environments.Version) then
			HasLatestVersion(Panel);
		elseif(Environments.CurrentVersion == 0) then
			local ORANGE = Color(255,128,0,255);
			Panel:Help("Couldn't determine latest BUILD. Make sure, you are connected to the Internet."):SetTextColor(ORANGE);
		else
			local GREEN = Color(0,255,0,255);
			Panel:Help("Your Environments BUILD is up-to-date."):SetTextColor(GREEN);
		end
		Panel:Help("BUILD: "..Environments.Version)
	else
		Panel:Help("It seems like, you are not connected to the Internet. Therefore, the Credits and Bugreport can't be shown. If you are sure, you are connected and have receive this message accidently, you can manually enable the online help below.");
		Panel:CheckBox("Manual Override","cl_has_internet"):SetToolTip("Changes apply after you restarted GMod");
	end
end*/
