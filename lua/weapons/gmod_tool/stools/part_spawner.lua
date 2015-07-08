TOOL.Category = "Tools"
TOOL.Name = "#Part Spawner"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Tab = "Environments"

if CLIENT then
    language.Add("Tool.part_spawner.name", "Ship Construction Tool")
    language.Add("Tool.part_spawner.desc", "Spawn SBEP props.")
    language.Add("Tool.part_spawner.0", "Left click to perform an action.")
    language.Add("undone_SBEP Part", "Undone SBEP Part")
end

TOOL.ClientConVar["model"] = "models/SmallBridge/Hulls_SW/sbhulle1.mdl"
TOOL.ClientConVar["skin"] = 0
TOOL.ClientConVar["glass"] = 0

function TOOL:LeftClick(trace)

    if CLIENT then return end

    local model = self:GetClientInfo("model")
    local skin = self:GetClientNumber("skin")
    local glass = self:GetClientNumber("glass")
    local pos = trace.HitPos

    SMBProp = ents.Create("prop_physics")

    SMBProp:SetModel(model)
	
    local skincount = SMBProp:SkinCount()
    local skinnum = nil
    if skincount > 5 then
        skinnum = skin * 2 + glass
    else
        skinnum = skin
    end
    SMBProp:SetSkin(skinnum)

    SMBProp:SetPos(pos - Vector(0, 0, SMBProp:OBBMins().z))

    SMBProp:Spawn()
    SMBProp:Activate()
	SMBProp:CPPISetOwner(self:GetOwner()) -- Just adding this here
	
    undo.Create("Hull Segment")
    undo.AddEntity(SMBProp)
    undo.SetPlayer(self:GetOwner())
    undo.Finish()

    return true
end

function TOOL:RightClick(trace)
    -- CC_GMOD_Tool(self:GetOwner(), "", { "sbep_part_assembler" })
end

function TOOL:Reload(trace)
end

function TOOL.BuildCPanel(panel)
    panel:SetSpacing(10)
    panel:SetName("EnvX Part Spawner")
	
	local list = vgui.Create( "DListLayout",panel )
	list:SetTall( 400 )
	list.OldLists = {}
	
	function list:SetupLists()
		for k,v in pairs(self.OldLists) do
			if v and IsValid(v)then				
				v:Remove()
			end
			self.OldLists[k]=nil
		end
		
		local SkinTable = {"Advanced","SlyBridge","MedBridge2","Jaanus","Scrappers"}
		
		local SkinSelector = vgui.Create( "DComboBox", self )
		SkinSelector:Dock(TOP)
		SkinSelector:DockMargin( 2,2,2,2 )
		SkinSelector:SetValue( SkinTable[GetConVar("part_spawner_skin"):GetInt()] or SkinTable[1] )
		SkinSelector.OnSelect = function( index, value, data )
			RunConsoleCommand( "part_spawner_skin", value )
		end
		for k,v in pairs( SkinTable ) do
			SkinSelector:AddChoice( v )
		end
		table.insert(self.OldLists,SkinSelector)
		
		local GlassButton = vgui.Create( "DCheckBoxLabel", self )
		GlassButton:Dock(TOP)
		GlassButton:DockMargin(2,2,2,2)
		GlassButton:SetValue( GetConVar( "part_spawner_glass" ):GetBool() )
		GlassButton:SetText( "Glass:" )
		GlassButton:SetConVar( "part_spawner_glass" )
		table.insert(self.OldLists,GlassButton)
		
		local sheet = vgui.Create( "DPropertySheet", self )
		sheet:Dock(TOP)
		sheet:SetSize( self:GetWide(), 400 )
		table.insert(self.OldLists,sheet)
		
		for Tab,v  in pairs( EnvX.PartList ) do
			local tabpan = vgui.Create( "DPanel", sheet )
			tabpan:SetSize( self:GetWide(), 400 )
			
			local tablist = vgui.Create( "DListLayout",tabpan )
			tablist:SetSize( self:GetWide(), 400 )
			
			for Category, models in pairs( v ) do
				local catPanel = vgui.Create( "DCollapsibleCategory" )
				catPanel:SetLabel(Category)
				catPanel:SetExpanded(false)
				self.Category = Category
				table.insert(self.OldLists,catPanel)

				local grid = vgui.Create( "DIconLayout" )
				grid:SetSize( self:GetWide(), 400 )
				grid:SetSpaceY( 5 ) //Sets the space in between the panels on the X Axis by 5
				grid:SetSpaceX( 5 ) //Sets the space in between the panels on the Y Axis by 5
				
				for key, modelpath in pairs( models ) do
					local icon = vgui.Create( "SpawnIcon" )
					icon:SetModel( modelpath )
					icon:SetToolTip( modelpath )
					icon.DoClick = function( self )
						RunConsoleCommand( "part_spawner_model", modelpath )
					end
					grid:Add( icon )
					
				end
				catPanel:SetContents(grid)
				tablist:Add(catPanel)
			end

			sheet:AddSheet( Tab, tabpan, "icon16/cross.png" )
		end
		self:Add(sheet)
	end
	
	panel:AddPanel(list)
	list:SetupLists()
	
	table.insert(Environments.ToolMenus,list)
end