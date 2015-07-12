--[[---------------------------------------------------
		        Jupiter Variable Cache
---------------------------------------------------]]--
/*    Stores all the Global Variables for Jupiter    */

local EnvX = EnvX --Gonna Need all the speed we can get.

EnvX.DefaultSuitData = { --Default settings on the spacesuit used for spacebuild maps.
	fuel=200, maxfuel = 4000,
	energy=200, maxenergy = 4000*5,
	temperature = 255, recover=0
}


if CLIENT then
	EnvX.GradientTex = surface.GetTextureID( "gui/center_gradient" )

	EnvX.GuiThemeColor = {
		BG = Color(50,50,50,150), --BackGround Color
		FG = Color(0,0,0,150), --ForeGround Color
		GC = Color(255, 255, 255, 15), --Gradient Color
		GHO = Color(0,40,150,10),--Gradient Hover Over Color
		Text = Color(0,140,220,200) --Text Color
	}
end










