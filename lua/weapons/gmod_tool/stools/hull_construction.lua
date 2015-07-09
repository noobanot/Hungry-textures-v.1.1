TOOL.Category = "Tools"
TOOL.Name = "Hull Construction"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.Tab = "Environments"

if CLIENT then
    language.Add("Tool.hull_construction.name", "Hull Construction Tool")
    language.Add("Tool.hull_construction.desc", "Easy Ship Construction")
    language.Add("Tool.hull_construction.0", "Left click to perform an action.")
    language.Add("undone_Hull Segment", "Undone Hull Segment")
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
    panel:SetName("Hull Construction")
	
	local list = vgui.Create( "DListLayout",panel )
	list:SetSize( 280,400 )
	
	local SkinTable = {"Advanced","SlyBridge","MedBridge2","Jaanus","Scrappers"}
	
	local SkinSelector = vgui.Create( "DComboBox", panel )
	SkinSelector:Dock(TOP)
	SkinSelector:DockMargin( 2,2,2,2 )
	SkinSelector:SetValue( SkinTable[GetConVar("hull_construction_skin"):GetInt()] or SkinTable[1] )
	SkinSelector.OnSelect = function( index, value, data )
		RunConsoleCommand( "hull_construction_skin", value )
	end
	for k,v in pairs( SkinTable ) do
		SkinSelector:AddChoice( v )
	end
	
	local GlassButton = vgui.Create( "DCheckBoxLabel", panel )
	GlassButton:Dock(TOP)
	GlassButton:DockMargin(2,2,2,2)
	GlassButton:SetValue( GetConVar( "hull_construction_glass" ):GetBool() )
	GlassButton:SetText( "Glass:" )
	GlassButton:SetConVar( "hull_construction_glass" )
		
	function list:SetupLists()		
		local sheet = vgui.Create( "DPropertySheet", self )
		sheet:SetSize( self:GetWide(), 400 )
				
		for Tab,v  in pairs( EnvX.PartList ) do
			local tabpan = vgui.Create( "DScrollPanel", sheet )
			tabpan:SetSize( self:GetWide(), 400 )
			
			local tablist = vgui.Create( "DListLayout",tabpan )
			tablist:SetSize( self:GetWide(), 400 )
			
			for Category, models in pairs( v ) do
				local catPanel = vgui.Create( "DCollapsibleCategory" )
				catPanel:SetLabel(Category)
				catPanel:SetExpanded(false)
				catPanel.category = Category

				local grid = vgui.Create( "DIconLayout" )
				grid:SetSize( self:GetWide(), 400 )
				grid:SetSpaceY( 5 ) //Sets the space in between the panels on the X Axis by 5
				grid:SetSpaceX( 5 ) //Sets the space in between the panels on the Y Axis by 5
				
				for key, modelpath in pairs( models ) do
					local icon = vgui.Create( "SpawnIcon" )
					icon:SetModel( modelpath )
					icon:SetToolTip( modelpath )
					icon.DoClick = function( self )
						RunConsoleCommand( "hull_construction_model", modelpath )
					end
					grid:Add( icon )
					
				end
				catPanel:SetContents(grid)
				tablist:Add(catPanel)
			end
			
			sheet:AddSheet( Tab, tabpan, "icon16/bricks.png" )
		end
		
		self:Add(sheet)
	end
	
	panel:AddPanel(list)
	list:SetupLists()
end