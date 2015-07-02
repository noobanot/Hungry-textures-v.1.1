local LDE = LDE --Localise the global table for speed.
local Utl = LDE.Utl --Makes it easier to read the code.
local NDat = Utl.NetMan --Ease link to the netdata table.

--Dont touch this. At all. Or I will murder you.
if(SERVER)then
	local ServerIp = tostring(GetConVarString("ip"))
	local TheReturnedHTML = ""; -- Blankness
	local IsOfficalServer = false
	OfficalServers = {}
	
	http.Fetch( "http://www.mediafire.com/download/6z9wylcew4cn1vz/OfficalServersList.txt",
		function( body, len, headers, code )
			-- The first argument is the HTML we asked for.
			TheReturnedHTML = body;
			
			local Servers = util.JSONToTable(TheReturnedHTML)
			PrintTable(Servers)
			OfficalServers = Servers
			
			for k,v in pairs(Servers) do
				if ServerIp==v then
					IsOfficalServer = true
					break
				end
			end
			
		end,
		function( error )
			
		end
	)

	--Add support for multiple servers being offical.
	Utl:HookNet("RequestOfficalStatus",function(Data,ply)
		print("Got Request from "..tostring(ply))
		NDat.AddData({Name="ReplyOfficalStatus",Val=1,Dat={Status = IsOfficalServer,Servers = OfficalServers}},ply)
	end)

else
	LDE.OfficalStatus = false
	LDE.OfficalServers = {}
	
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
		
		local Office = LDE.MenuCore.CreateText(base,{x=430,y=0},"Awaiting Server Identification",Color(0,0,0,255))
		Office.Think = function(self)
			if LDE.OfficalStatus then
				self:SetText("Server Certified Official!")
			else
				self:SetText("Unofficial Server!")
			end
		end
		
		--Add connect dialogue on selection.
		local ServerList = LDE.UI.CreateList(base,{x=250,y=375},{x=430,y=150},false,function() end)
		ServerList:AddColumn("Name") -- Add column
		ServerList:AddColumn("IP") -- Add column
		
		print("Servers!")
		PrintTable(LDE.OfficalServers)
		
		for k,v in pairs(LDE.OfficalServers) do 
			ServerList:AddLine(k,v.IP) 
		end

	end)
			
	Utl:HookNet("ReplyOfficalStatus",function(Data)
		print("Data")
		PrintTable(Data)
		LDE.OfficalStatus = Data.Status
		LDE.OfficalServers = Data.Servers
	end)
	NDat.AddData({Name="RequestOfficalStatus",Val=1,Dat={}})
end		
	