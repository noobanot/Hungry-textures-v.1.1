
--- Library for creating and manipulating physics-less models AKA "Props".
-- @server
local constraint_library, constraint_library_metamethods = SF.Libraries.Register("constraint")

local ents_metatable = SF.Entities.Metatable
local vunwrap = SF.UnwrapObject
local eunwrap = SF.Entities.Unwrap
local vwrap = SF.WrapObject
local ewrap = SF.Entities.Wrap
local isValid = SF.Entities.IsValid

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege( "constraints.weld", "Weld", "Allows the user to weld two entities" )
	P.registerPrivilege( "constraints.axis", "Axis", "Allows the user to axis two entities" )
	P.registerPrivilege( "constraints.ballsocket", "Ballsocket", "Allows the user to ballsocket two entities" )
	P.registerPrivilege( "constraints.ballsocketadv", "BallsocketAdv", "Allows the user to advanced ballsocket two entities" )
	P.registerPrivilege( "constraints.slider", "Slider", "Allows the user to slider two entities" )
	P.registerPrivilege( "constraints.rope", "Rope", "Allows the user to rope two entities" )
	P.registerPrivilege( "constraints.elastic", "Elastic", "Allows the user to elastic two entities" )
	P.registerPrivilege( "constraints.nocollide", "Nocollide", "Allows the user to nocollide two entities" )
	P.registerPrivilege( "constraints.any", "Any", "General constraint functions" )
end

--- Welds two entities
-- @server
function constraint_library.weld(e1, e2, bone1, bone2, force_lim, nocollide)
	SF.CheckType( e1, ents_metatable )
	SF.CheckType( e2, ents_metatable )
	
	local ent1 = eunwrap( e1 )
	local ent2 = eunwrap( e2 )
	
	if not isValid( ent1 ) or not isValid( ent2 ) then return false, "entity not valid" end
	if not SF.Permissions.check( SF.instance.player, ent1, "constraints.weld" ) then SF.throw( "Insufficient permissions", 2 ) end
	if not SF.Permissions.check( SF.instance.player, ent2, "constraints.weld" ) then SF.throw( "Insufficient permissions", 2 ) end

	bone1 = bone1 or 0
	bone2 = bone2 or 0
	force_lim = force_lim or 0
	nocollide = nocollide and true or false
	
	constraint.Weld(ent1, ent2, bone1, bone2, force_lim, nocollide)
end

--- Axis two entities
-- @server
function constraint_library.axis(e1, e2, bone1, bone2, v1, v2, force_lim, torque_lim, friction, nocollide, laxis)
	SF.CheckType( e1, ents_metatable )
	SF.CheckType( e2, ents_metatable )
	SF.CheckType( v1, SF.Types[ "Vector" ] )
	SF.CheckType( v2, SF.Types[ "Vector" ] )
	
	local ent1 = eunwrap( e1 )
	local ent2 = eunwrap( e2 )
	local vec1 = vunwrap( v1 )
	local vec2 = vunwrap( v2 )
	local axis = laxis and vunwrap( laxis ) or nil
	
	if not isValid( ent1 ) or not isValid( ent2 ) then return false, "entity not valid" end
	if not SF.Permissions.check( SF.instance.player, ent1, "constraints.axis" ) then SF.throw( "Insufficient permissions", 2 ) end
	if not SF.Permissions.check( SF.instance.player, ent2, "constraints.axis" ) then SF.throw( "Insufficient permissions", 2 ) end
	
	bone1 = bone1 or 0
	bone2 = bone2 or 0
	force_lim = force_lim or 0
	torque_lim = torque_lim or 0
	friction = friction or 0
	nocollide = nocollide and 1 or 0
	
	constraint.Axis(ent1, ent2, bone1, bone2, vec1, vec2, force_lim, torque_lim, friction, nocollide, axis)
end

--- Ballsocket two entities
-- @server
function constraint_library.ballsocket(e1, e2, bone1, bone2, v1, force_lim, torque_lim, nocollide)
	SF.CheckType( e1, ents_metatable )
	SF.CheckType( e2, ents_metatable )
	SF.CheckType( v1, SF.Types[ "Vector" ] )
	
	local ent1 = eunwrap( e1 )
	local ent2 = eunwrap( e2 )
	local vec1 = vunwrap( v1 )
	
	if not isValid( ent1 ) or not isValid( ent2 ) then return false, "entity not valid" end
	if not SF.Permissions.check( SF.instance.player, ent1, "constraints.ballsocket" ) then SF.throw( "Insufficient permissions", 2 ) end
	if not SF.Permissions.check( SF.instance.player, ent2, "constraints.ballsocket" ) then SF.throw( "Insufficient permissions", 2 ) end
	
	bone1 = bone1 or 0
	bone2 = bone2 or 0
	force_lim = force_lim or 0
	torque_lim = torque_lim or 0
	nocollide = nocollide and 1 or 0
	
	constraint.Ballsocket(ent1, ent2, bone1, bone2, vec1, force_lim, torque_lim, nocollide)
end

--- Advanced Ballsocket two entities
-- @server
function constraint_library.ballsocketadv(e1, e2, bone1, bone2, v1, v2, force_lim, torque_lim, minv, maxv, frictionv, rotateonly, nocollide)
	SF.CheckType( e1, ents_metatable )
	SF.CheckType( e2, ents_metatable )
	SF.CheckType( v1, SF.Types[ "Vector" ] )
	SF.CheckType( v2, SF.Types[ "Vector" ] )
	
	local ent1 = eunwrap( e1 )
	local ent2 = eunwrap( e2 )
	local vec1 = vunwrap( v1 )
	local vec2 = vunwrap( v2 )
	local mins = vunwrap( minv ) or Vector ( 0, 0, 0 )
	local maxs = vunwrap( maxv ) or Vector ( 0, 0, 0 )
	local frictions = vunwrap( frictionv ) or Vector ( 0, 0, 0 )
	
	if not isValid( ent1 ) or not isValid( ent2 ) then return false, "entity not valid" end
	if not SF.Permissions.check( SF.instance.player, ent1, "constraints.ballsocketadv" ) then SF.throw( "Insufficient permissions", 2 ) end
	if not SF.Permissions.check( SF.instance.player, ent2, "constraints.ballsocketadv" ) then SF.throw( "Insufficient permissions", 2 ) end
	
	bone1 = bone1 or 0
	bone2 = bone2 or 0
	force_lim = force_lim or 0
	torque_lim = torque_lim or 0
	rotateonly = rotateonly and 1 or 0
	nocollide = nocollide and 1 or 0
	
	constraint.AdvBallsocket(ent1, ent2, bone1, bone2, vec1, vec2, force_lim, torque_lim, mins.x, mins.y, mins.z, maxs.x, maxs.y, maxs.z, frictions.x, frictions.y, frictions.z, rotateonly, nocollide)
end

--- Elastic two entities
-- @server 
function constraint_library.elastic(index, e1, e2, bone1, bone2, v1, v2, const, damp, rdamp, width, strech)
	SF.CheckType( e1, ents_metatable )
	SF.CheckType( e2, ents_metatable )
	SF.CheckType( v1, SF.Types[ "Vector" ] )
	SF.CheckType( v2, SF.Types[ "Vector" ] )
	
	local ent1 = eunwrap( e1 )
	local ent2 = eunwrap( e2 )
	local vec1 = vunwrap( v1 )
	local vec2 = vunwrap( v2 )
	
	if not isValid( ent1 ) or not isValid( ent2 ) then return false, "entity not valid" end
	if not SF.Permissions.check( SF.instance.player, ent1, "constraints.elastic" ) then SF.throw( "Insufficient permissions", 2 ) end
	if not SF.Permissions.check( SF.instance.player, ent2, "constraints.elastic" ) then SF.throw( "Insufficient permissions", 2 ) end
	
	bone1 = bone1 or 0
	bone2 = bone2 or 0
	const = const or 1000
	damp = damp or 100
	rdamp = rdamp or 0
	width = math.Clamp( width or 0, 0, 50)
	strech = strech and true or false
	
	e1.Elastics = e1.Elastics or {}
	e2.Elastics = e2.Elastics or {}
	
	local e = constraint.Elastic( ent1, ent2, bone1, bone2, vec1, vec2, const, damp, rdamp, "cable/cable2", width, strech )
	
	e1.Elastics[index] = e
	e2.Elastics[index] = e
end

--- Ropes two entities
-- @server 
function constraint_library.rope(index, e1, e2, bone1, bone2, v1, v2, length, addlength, force_lim, width, rigid)
	SF.CheckType( e1, ents_metatable )
	SF.CheckType( e2, ents_metatable )
	SF.CheckType( v1, SF.Types[ "Vector" ] )
	SF.CheckType( v2, SF.Types[ "Vector" ] )
	
	local ent1 = eunwrap( e1 )
	local ent2 = eunwrap( e2 )
	local vec1 = vunwrap( v1 )
	local vec2 = vunwrap( v2 )
	
	if not isValid( ent1 ) or not isValid( ent2 ) then return false, "entity not valid" end
	if not SF.Permissions.check( SF.instance.player, ent1, "constraints.rope" ) then SF.throw( "Insufficient permissions", 2 ) end
	if not SF.Permissions.check( SF.instance.player, ent2, "constraints.rope" ) then SF.throw( "Insufficient permissions", 2 ) end


	bone1 = bone1 or 0
	bone2 = bone2 or 0
	length = length or 0
	addlength = addlength or 0
	force_lim = force_lim or 0
	width = math.Clamp( width or 0, 0, 50)
	rigid = rigid and true or false
	
	e1.Ropes = e1.Ropes or {}
	e2.Ropes = e2.Ropes or {}
	
	local e = constraint.Rope( ent1, ent2, bone1, bone2, vec1, vec2, length, addlength, force_lim, width, "cable/cable2", rigid )
	
	e1.Ropes[index] = e
	e2.Ropes[index] = e
end

--- Sliders two entities
-- @server 
function constraint_library.slider(e1, e2, bone1, bone2, v1, v2, width)
	SF.CheckType( e1, ents_metatable )
	SF.CheckType( e2, ents_metatable )
	SF.CheckType( v1, SF.Types[ "Vector" ] )
	SF.CheckType( v2, SF.Types[ "Vector" ] )
	
	local ent1 = eunwrap( e1 )
	local ent2 = eunwrap( e2 )
	local vec1 = vunwrap( v1 )
	local vec2 = vunwrap( v2 )
	
	if not isValid( ent1 ) or not isValid( ent2 ) then return false, "entity not valid" end
	if not SF.Permissions.check( SF.instance.player, ent1, "constraints.slider" ) then SF.throw( "Insufficient permissions", 2 ) end
	if not SF.Permissions.check( SF.instance.player, ent2, "constraints.slider" ) then SF.throw( "Insufficient permissions", 2 ) end
	
	bone1 = bone1 or 0
	bone2 = bone2 or 0
	width = math.Clamp( width or 0, 0, 50)

	constraint.Slider(ent1, ent2, bone1, bone2, vec1, vec2, width, "cable/cable2")
end

--- Nocollides two entities
-- @server 
function constraint_library.nocollide(e1, e2, bone1, bone2)
	SF.CheckType( e1, ents_metatable )
	SF.CheckType( e2, ents_metatable )
	
	local ent1 = eunwrap( e1 )
	local ent2 = eunwrap( e2 )
	
	if not isValid( ent1 ) or not isValid( ent2 ) then return false, "entity not valid" end
	if not SF.Permissions.check( SF.instance.player, ent1, "constraints.nocollide" ) then SF.throw( "Insufficient permissions", 2 ) end
	if not SF.Permissions.check( SF.instance.player, ent2, "constraints.nocollide" ) then SF.throw( "Insufficient permissions", 2 ) end
	
	bone1 = bone1 or 0
	bone2 = bone2 or 0
	
	constraint.NoCollide(ent1, ent2, bone1, bone2)
end

--- Sets the length of a rope attached to the entity
-- @server 
function constraint_library.setRopeLength(index, e, length)
	SF.CheckType( e, ents_metatable )
	local ent1 = eunwrap( e )
	
	if not isValid( ent1 ) then return false, "entity not valid" end
	if not SF.Permissions.check( SF.instance.player, ent1, "constraints.rope" ) then SF.throw( "Insufficient permissions", 2 ) end

	length = math.max( length or 0, 0)

	
	if e.Ropes then
		local con = e.Ropes[index]
		if IsValid(con) then
			con:SetKeyValue("addlength", length)
		end
	end
end

--- Sets the length of an elastic attached to the entity
-- @server 
function constraint_library.setElasticLength(index, e, length)
	SF.CheckType( e, ents_metatable )
	local ent1 = eunwrap( e )
	
	if not isValid( ent1 ) then return false, "entity not valid" end
	if not SF.Permissions.check( SF.instance.player, ent1, "constraints.elastic" ) then SF.throw( "Insufficient permissions", 2 ) end

	length = math.max( length or 0, 0)

	if e.Elastics then
		local con = e.Elastics[index]
		if IsValid(con) then
			con:Fire("SetSpringLength", length, 0)
		end
	end
end

--- Breaks all constraints on an entity
-- @server 
function constraint_library.breakAll(e)
	SF.CheckType( e, ents_metatable )
	local ent1 = eunwrap( e )
	
	if not isValid( ent1 ) then return false, "entity not valid" end
	if not SF.Permissions.check( SF.instance.player, ent1, "constraints.any" ) then SF.throw( "Insufficient permissions", 2 ) end
	
	constraint.RemoveAll(ent1)
end

--- Breaks all constraints of a certain type on an entity
-- @server 
function constraint_library.breakType(e, typename)
	SF.CheckType( e, ents_metatable )
    SF.CheckType( typename, "string" )
	
	local ent1 = eunwrap( e )
	
	if not isValid( ent1 ) then return false, "entity not valid" end
	if not SF.Permissions.check( SF.instance.player, ent1, "constraints.any" ) then SF.throw( "Insufficient permissions", 2 ) end
	
	constraint.RemoveConstraints(ent1, typename)
end


--- Creates a table of constraints on an entity
-- @param ent Target entity
-- @return Table of entity constraints
function constraint_library.GetAllConstrained( ent )
	SF.CheckType( ent, ents_metatable )

	ent = eunwrap( ent )
	
	if not isValid( ent ) then return {}, "entity not valid" end
	if not SF.Permissions.check( SF.instance.player, ent, "constraints.any" ) then SF.throw( "Insufficient permissions", 2 ) end

	local constraints = constraint.GetAllConstrainedEntities( ent )
	
	return constraints
end
