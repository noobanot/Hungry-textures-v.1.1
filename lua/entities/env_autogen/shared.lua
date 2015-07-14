ENT.Type = "anim"
ENT.Base = "base_env_entity"

ENT.PrintName = "R01 Automatic Resource Manager"
ENT.Author = "Mechanos"
ENT.Contact = "can't make me"
ENT.Purpose = "Does anyone read these?"
ENT.Instructions = "Point away from face" 
ENT.Category = "Environments"

ENT.Spawnable = false
ENT.AdminSpawnable = false
--ENT.RenderGroup = RENDERGROUP_BOTH
-- The next line is seriously important don't forget that shiat!  *(( I MEAN IT ))* -- lol old Deep comments
ENT.AutomaticFrameAdvance = true

ENT.ExtraOverlayData = {}
--ENT.ExtraOverlayData[">"] = "D"
ENT.ExtraOverlayData["\nStatus"] = "\n".."Idle"
list.Set( "LSEntOverlayText" , "env_autogen", {HasOOO = true, genresnames ={ "energy", "water", "oxygen", "hydrogen"} } )

local MC = EnvX.MenuCore

if(SERVER)then

else 
	ENT.LastStatus=""
	
	function ENT:PanelFunc(entID)	
		self.DevicePanel = {
			function() return MC.CreateButton(Parent,{x=90,y=30},{x=0,y=0},"Toggle Power",function() RunConsoleCommand( "envsendpcommand",self:EntIndex(),"Power") end) end
		}
	end
	
	function ENT:Initialize()
		--self:SetNWString( "status", "Y U DO DIS" )
		self:NextThink(CurTime() + 1)
	end
	
	function ENT:Think()
		local message = self:GetNWString( "status" )
		if message != self.LastStatus then
			--message = message or ""
			self.ExtraOverlayData["\nStatus"] = "\n" .. message
			self.LastStatus = message
		end
		self:NextThink(CurTime() + 3)
	end

end
