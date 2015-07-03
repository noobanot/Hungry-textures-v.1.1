local LDE = LDE --Localise the global table for speed.
local Utl = LDE.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.

--Dont touch this. At all. Or I will murder you.
if(SERVER)then
	local ServerIp = tostring(GetConVarString("ip"))
	local TheReturnedHTML = ""; -- Blankness
	local ServerStatus = "Unofficial Server"
	local StatusColor = Color(255,0,0,255)
	ServerLists = {}
	
	http.Fetch( "http://www.mediafire.com/download/6z9wylcew4cn1vz/OfficalServersList.txt",
		function( body, len, headers, code )
			-- The first argument is the HTML we asked for.
			TheReturnedHTML = body;
			
			local Servers = util.JSONToTable(TheReturnedHTML)
			PrintTable(Servers)
			ServerLists = Servers
			
			for k,v in pairs(Servers.Official or {}) do
				if ServerIp==v then
					ServerStatus = "Official Server: "..k
					StatusColor = Color(0,0,255,255)
					break
				end
			end
			
			for k,v in pairs(Servers.Community or {}) do
				if ServerIp==v then
					ServerStatus = "Community Server: "..k
					StatusColor = Color(0,255,0,255)
					break
				end
			end
			
		end,
		function( error )
			
		end
	)

	Utl:HookNet("RequestOfficalStatus",function(Data,ply)
		NDat.AddData({Name="ReplyOfficalStatus",Val=1,Dat={Status = ServerStatus, SColor = StatusColor, Servers = ServerLists}},ply)
	end)

else
	LDE.ServerLists = {}
	
	LDE.OfficalStatus = "Unofficial Server"
	LDE.StatusColor = Color(255,0,0,255)
	
	local function OnSelect(B,N)
		B.SL:Clear() B.PI:Clear()
		local ply = B.Players[N]
		
		B.PI:AddLine("Name",N)
		B.PI:AddLine("Team",team.GetName(ply:Team()))
		B.PI:AddLine("IsAdmin",tostring(ply:IsAdmin() or ply:IsSuperAdmin()))
		
		for k,v in pairs(ply:GetStrings()) do
			B.PI:AddLine(k,v)
		end
		
		for k,v in pairs(ply:GetStats()) do 
			B.SL:AddLine(k,v) 
		end
	end
	
	hook.Add("LDEFillCatagorys","Stats", function()
		local SuperMenu = LDE.UI.SuperMenu.Menu.Catagorys
		
		--Player Stats
		
		local base = vgui.Create( "DPanel", SuperMenu )
		base:SizeToContents()
		base.Paint = function() end
		SuperMenu:AddSheet( "Stats", base, "icon16/chart_bar.png", false, false, "View your stats." ) 
		base.Players = {}
		
		local PL = LDE.UI.CreateList(base,{x=160,y=525},{x=0,y=0},false,function(V) OnSelect(base,V) end)
		PL:AddColumn("Player") -- Add column
		for k,v in pairs(player.GetAll()) do base.Players[v:Name()]=v PL:AddLine(v:Name()) end
		
		base.PL = PL
		
		local PI = LDE.UI.CreateList(base,{x=250,y=140},{x=170,y=0},false,function() end)
		PI:AddColumn("Item") -- Add column
		PI:AddColumn("Value") -- Add colum		
		
		base.PI = PI
		
		local SL = LDE.UI.CreateList(base,{x=250,y=375},{x=170,y=150},false,function() end)
		SL:AddColumn("Item") -- Add column
		SL:AddColumn("Amount") -- Add column
		
		base.SL = SL
		
		OnSelect(base,LocalPlayer():Name())
		
		--Server Stats
		
		local Office = LDE.MenuCore.CreateButton(base,{x=340,y=40},{x=430,y=0},"Awaiting Server Identification",function() end)
		Office.Think = function(self)
			self:SetText(LDE.OfficalStatus)
			self:SetColor(LDE.StatusColor)
		end
		
		--Add connect dialogue on selection.
		local ServerListOffical = LDE.UI.CreateList(base,{x=340,y=230},{x=430,y=50},false,function() end)
		ServerListOffical:AddColumn("Official Servers") -- Add column
		ServerListOffical:AddColumn("IP") -- Add column		
		for k,v in pairs(LDE.ServerLists.Official or {}) do ServerListOffical:AddLine(k,v.IP) end
		
		--Add connect dialogue on selection.
		local ServerListCommunity = LDE.UI.CreateList(base,{x=340,y=235},{x=430,y=290},false,function() end)
		ServerListCommunity:AddColumn("Community Servers") -- Add column
		ServerListCommunity:AddColumn("IP") -- Add column		
		for k,v in pairs(LDE.ServerLists.Community or {}) do ServerListCommunity:AddLine(k,v.IP) end
		
		NDat.AddData({Name="RequestOfficalStatus",Val=1,Dat={}})
	end)
		
	Utl:HookNet("ReplyOfficalStatus",function(Data)
		LDE.OfficalStatus = Data.Status
		LDE.StatusColor = Data.SColor
		LDE.ServerLists = Data.Servers
	end)
end		
	