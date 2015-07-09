include('shared.lua')

 
function ENT:Draw( )

	entFactoryEnt = self
	
	if entID == nil then
		entID = 0
	end
		
	self:DrawModel();

end


