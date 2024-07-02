import 'title'
import 'rehearsal'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local text <const> = gfx.getLocalizedText

class('pass').extends(gfx.sprite) -- Create the scene's class
function pass:init(...)
	pass.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here
	gfx.sprite.setAlwaysRedraw(false)

	function pd.gameWillPause() -- When the game's paused...
		local menu = pd.getSystemMenu()
		menu:removeAllMenuItems()
	end

	assets = { -- All assets go here. Images, sounds, fonts, etc.
		sasser = gfx.font.new('fonts/sasser'),
		small = gfx.font.new('fonts/small'),
		click = smp.new('audio/sfx/click'),
		bg = gfx.image.new('images/pass'),
	}

	vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
		score = args[1],
		button_string = args[2],
		image = math.random(1, 4)
	}
	vars.passHandlers = {
		AButtonDown = function()
			scenemanager:transitionscene(rehearsal, vars.score, vars.button_string)
			if save.sfx then assets.click:play() end
		end,
	}
	pd.inputHandlers.push(vars.passHandlers)

	gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
		assets.bg:draw(0, 0)
		if p1 then
			assets.sasser:drawTextAligned(text('p1_pass'), 200, 40, kTextAlignment.center)
		else
			assets.sasser:drawTextAligned(text('p2_pass'), 200, 40, kTextAlignment.center)
		end
		assets.small:drawTextAligned(text('ready'), 370, 220, kTextAlignment.right)
	end)

	-- Set the sprites
	self:add()
end