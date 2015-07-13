function EFFECT:Init( data )
	
	local ent = data:GetEntity()
	local Mod,Pos = ent:GetModel(),data:GetStart()

	self:SetModel(Mod)
	self:SetPos(Pos)
	
	self:DrawModel()
end 

function EFFECT:Think( ) 
	return false
end 

function EFFECT:Render() 
end  