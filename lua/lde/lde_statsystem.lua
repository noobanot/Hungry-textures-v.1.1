module( "LDEplystats", package.seeall )

LDE.Cash = {}
LDE.Market = {}

--------------------Market------------------------------
LDE.Market.Resources = {
	RefinedOre = {Modes={Buy=false,Sell=true},C=0.4,O="RefinedOre",name="Refined Ore",desc="Refined ore is made by refining raw ore, by taking out impurities."},
	HardenedOre = {Modes={Buy=false,Sell=true},C=0.8,O="HardenedOre",name="Hardened Ore",desc="Hardened ore is made by hardening refined ore with crystal polylodarium."},
	BasicRounds = {Modes={Buy=true,Sell=true},C=0.6,O="BasicRounds",name="Basic Rounds",desc="Basic rounds are self-contained oxidizing explosive charges, thrown out of a gun at very, very high speeds by their explosion."},
	Shells = {Modes={Buy=true,Sell=true},C=1,O="Shells",name="Shells",desc="A larger form of bullets, shells are generally used in ordnance."},
	Plasma = {Modes={Buy=true,Sell=false},C=0.8,O="Plasma",name="Plasma",desc="Super Heated Polylodarium, Most commonly used as ammunition."},
	HeavyShells = {Modes={Buy=true,Sell=true},C=2,O="HeavyShells",name="Heavy Shells",desc="An even larger form of shells, heavy shells are generally used in superordnance."},
	MissileParts = {Modes={Buy=true,Sell=true},C=0.9,O="MissileParts",name="Missile Parts",desc="Missile parts are used by missile launchers to assemble missiles and fire them."},
}

if(SERVER)then	
	function LDE.FindByNamePly(name)
		name = string.lower(name);
		for _,v in ipairs(player.GetHumans()) do
			if(string.find(string.lower(v:Name()),name,1,true) != nil)
				then return v;
			end
		end
	end

	function setstatcon(ply,cmd,args)
			
		local Stat = args[1] -- Grab the stat name were gonna use
		local Data = args[2] or 0 --Grab the variable for the stat if possible
			
		ply:SetLDEStat(Stat,Data)
			
	end
	concommand.Add("LDE_setstat", setstatcon)
	
	function playergivecash(ply,cmd,args)
	
		if (not args[1] or not args[2]) then return end
		
		local target = LDE.FindByNamePly(args[1])
		local amounts = tonumber(args[2]) or 0

		ply:TransferCash(target,amounts)
			
	end
	concommand.Add("LDE_sendfunds", playergivecash)
end

---Player functions	
local meta = FindMetaTable( "Player" )
if not meta then return end

function meta:TakeCash(num)
	local stat = "Cash"
	local cash = self:GetLDEStat(stat)
	if(cash>=num)then
		self:SetLDEStat( stat, cash-tonumber(num) or 0)
		return true
	else
		return false
	end
end

function meta:GiveCash(num)
	local stat = "Cash"
	local cash = self:GetLDEStat(stat)
	self:SetLDEStat( stat, cash+tonumber(num) or 0)
end

function meta:TransferCash(ply,num)
	local stat = "Cash"
	local cash = self:GetLDEStat(stat)
	if(not ply or not ply:IsValid() or not ply:IsPlayer())then return false end
	if(num<=100)then return false end
	if(self:TakeCash(num))then
		--self:ChatPrint("You sent "..ply:Name().." "..num.." Taus.")
		self:SendColorChat("Stats",{r=255,g=0,b=0},"You sent "..ply:Name().." "..num.." Taus.")
		self:SendColorChat("Stats",{r=0,g=255,b=0},self:Name().." sent you "..num.." Taus.")
		--ply:ChatPrint(self:Name().." sent you "..num.." Taus.")
		ply:GiveCash(num)
	end
end