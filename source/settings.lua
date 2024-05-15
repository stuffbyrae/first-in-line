import 'title'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local text <const> = gfx.getLocalizedText

class('settings').extends(gfx.sprite) -- Create the scene's class
function settings:init(...)
	settings.super.init(self)
	local args = {...} -- Arguments passed in through the scene management will arrive here
	gfx.sprite.setAlwaysRedraw(false)

	function pd.gameWillPause() -- When the game's paused...
		local menu = pd.getSystemMenu()
		menu:removeAllMenuItems()
		menu:addMenuItem(text('slidetitle'), function()
			if save.sfx then assets.click:play() end
			scenemanager:switchscene(title)
		end)
	end

	assets = { -- All assets go here. Images, sounds, fonts, etc.
		image_bg = gfx.image.new('images/bg'),
		sasser = gfx.font.new('fonts/sasser'),
		small = gfx.font.new('fonts/small'),
		spotlight = smp.new('audio/sfx/spotlight'),
		click = smp.new('audio/sfx/click'),

	}

	vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
		showtime = false,
		selections = {'music', 'sfx', 'crank', 'shaking', 'mic', 'credits'},
		selection = 1
	}
	vars.settingsHandlers = {
		AButtonDown = function()
			if save.sfx then assets.click:play() end
			if vars.selections[vars.selection] == "music" then
				save.music = not save.music
				if save.music then
					newmusic('audio/music/music1', true)
				else
					fademusic(1)
				end
			elseif vars.selections[vars.selection] == "sfx" then
				save.sfx = not save.sfx
			elseif vars.selections[vars.selection] == "crank" then
				save.crank = not save.crank
			elseif vars.selections[vars.selection] == "shaking" then
				save.shaking = not save.shaking
			elseif vars.selections[vars.selection] == "mic" then
				save.mic = not save.mic
			elseif vars.selections[vars.selection] == "credits" then
				scenemanager:switchscene(credits)
			end
			gfx.sprite.redrawBackground()
		end,

		BButtonDown = function()
			scenemanager:switchscene(title)
			if save.sfx then assets.click:play() end
		end,

		upButtonDown = function()
			vars.selection = math.max(1, math.min(#vars.selections, vars.selection - 1))
			gfx.sprite.redrawBackground()
		end,

		downButtonDown = function()
			vars.selection = math.max(1, math.min(#vars.selections, vars.selection + 1))
			gfx.sprite.redrawBackground()
		end,
	}

	gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
		if vars.showtime then
			assets.image_bg:draw(0, 0)
			assets.small:drawText('v' .. pd.metadata.version, 30, 220)
		end
		assets.sasser:drawTextAligned(text('settings'), 200, 10, kTextAlignment.center)
		if vars.selections[vars.selection] == "music" then
			assets.small:drawTextAligned('| ' .. text('music') .. text('separator') .. text(tostring(save.music)), 200, 40, kTextAlignment.center)
			assets.small:drawTextAligned(text('sfx') .. text('separator') .. text(tostring(save.sfx)), 200, 60, kTextAlignment.center)
			assets.small:drawTextAligned(text('crank') .. text('separator') .. text(tostring(save.crank)), 200, 90, kTextAlignment.center)
			assets.small:drawTextAligned(text('shaking') .. text('separator') .. text(tostring(save.shaking)), 200, 110, kTextAlignment.center)
			assets.small:drawTextAligned(text('mic') .. text('separator') .. text(tostring(save.mic)), 200, 130, kTextAlignment.center)
			assets.small:drawTextAligned(text('viewcredits'), 200, 170, kTextAlignment.center)
			assets.small:drawTextAligned(text('back') .. text('separator') .. text('toggle'), 370, 220, kTextAlignment.right)
		elseif vars.selections[vars.selection] == "sfx" then
			assets.small:drawTextAligned(text('music') .. text('separator') .. text(tostring(save.music)), 200, 40, kTextAlignment.center)
			assets.small:drawTextAligned('| ' .. text('sfx') .. text('separator') .. text(tostring(save.sfx)), 200, 60, kTextAlignment.center)
			assets.small:drawTextAligned(text('crank') .. text('separator') .. text(tostring(save.crank)), 200, 90, kTextAlignment.center)
			assets.small:drawTextAligned(text('shaking') .. text('separator') .. text(tostring(save.shaking)), 200, 110, kTextAlignment.center)
			assets.small:drawTextAligned(text('mic') .. text('separator') .. text(tostring(save.mic)), 200, 130, kTextAlignment.center)
			assets.small:drawTextAligned(text('viewcredits'), 200, 170, kTextAlignment.center)
			assets.small:drawTextAligned(text('back') .. text('separator') .. text('toggle'), 370, 220, kTextAlignment.right)
		elseif vars.selections[vars.selection] == "crank" then
			assets.small:drawTextAligned(text('music') .. text('separator') .. text(tostring(save.music)), 200, 40, kTextAlignment.center)
			assets.small:drawTextAligned(text('sfx') .. text('separator') .. text(tostring(save.sfx)), 200, 60, kTextAlignment.center)
			assets.small:drawTextAligned('| ' .. text('crank') .. text('separator') .. text(tostring(save.crank)), 200, 90, kTextAlignment.center)
			assets.small:drawTextAligned(text('shaking') .. text('separator') .. text(tostring(save.shaking)), 200, 110, kTextAlignment.center)
			assets.small:drawTextAligned(text('mic') .. text('separator') .. text(tostring(save.mic)), 200, 130, kTextAlignment.center)
			assets.small:drawTextAligned(text('viewcredits'), 200, 170, kTextAlignment.center)
			assets.small:drawTextAligned(text('back') .. text('separator') .. text('toggle'), 370, 220, kTextAlignment.right)
		elseif vars.selections[vars.selection] == "shaking" then
			assets.small:drawTextAligned(text('music') .. text('separator') .. text(tostring(save.music)), 200, 40, kTextAlignment.center)
			assets.small:drawTextAligned(text('sfx') .. text('separator') .. text(tostring(save.sfx)), 200, 60, kTextAlignment.center)
			assets.small:drawTextAligned(text('crank') .. text('separator') .. text(tostring(save.crank)), 200, 90, kTextAlignment.center)
			assets.small:drawTextAligned('| ' .. text('shaking') .. text('separator') .. text(tostring(save.shaking)), 200, 110, kTextAlignment.center)
			assets.small:drawTextAligned(text('mic') .. text('separator') .. text(tostring(save.mic)), 200, 130, kTextAlignment.center)
			assets.small:drawTextAligned(text('viewcredits'), 200, 170, kTextAlignment.center)
			assets.small:drawTextAligned(text('back') .. text('separator') .. text('toggle'), 370, 220, kTextAlignment.right)
		elseif vars.selections[vars.selection] == "mic" then
			assets.small:drawTextAligned(text('music') .. text('separator') .. text(tostring(save.music)), 200, 40, kTextAlignment.center)
			assets.small:drawTextAligned(text('sfx') .. text('separator') .. text(tostring(save.sfx)), 200, 60, kTextAlignment.center)
			assets.small:drawTextAligned(text('crank') .. text('separator') .. text(tostring(save.crank)), 200, 90, kTextAlignment.center)
			assets.small:drawTextAligned(text('shaking') .. text('separator') .. text(tostring(save.shaking)), 200, 110, kTextAlignment.center)
			assets.small:drawTextAligned('| ' .. text('mic') .. text('separator') .. text(tostring(save.mic)), 200, 130, kTextAlignment.center)
			assets.small:drawTextAligned(text('viewcredits'), 200, 170, kTextAlignment.center)
			assets.small:drawTextAligned(text('back') .. text('separator') .. text('toggle'), 370, 220, kTextAlignment.right)
		elseif vars.selections[vars.selection] == "credits" then
			assets.small:drawTextAligned(text('music') .. text('separator') .. text(tostring(save.music)), 200, 40, kTextAlignment.center)
			assets.small:drawTextAligned(text('sfx') .. text('separator') .. text(tostring(save.sfx)), 200, 60, kTextAlignment.center)
			assets.small:drawTextAligned(text('crank') .. text('separator') .. text(tostring(save.crank)), 200, 90, kTextAlignment.center)
			assets.small:drawTextAligned(text('shaking') .. text('separator') .. text(tostring(save.shaking)), 200, 110, kTextAlignment.center)
			assets.small:drawTextAligned(text('mic') .. text('separator') .. text(tostring(save.mic)), 200, 130, kTextAlignment.center)
			assets.small:drawTextAligned('| ' .. text('viewcredits'), 200, 170, kTextAlignment.center)
			assets.small:drawTextAligned(text('back') .. text('separator') .. text('select'), 370, 220, kTextAlignment.right)
		end
	end)

	pd.timer.performAfterDelay(500, function()
		vars.showtime = true
		pd.inputHandlers.push(vars.settingsHandlers)
		gfx.sprite.redrawBackground()
		if save.sfx then assets.spotlight:play() end
	end)

	-- Set the sprites
	self:add()
end