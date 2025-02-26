import 'title'
import 'rehearsal'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local text <const> = gfx.getLocalizedText

class('results').extends(gfx.sprite) -- Create the scene's class
function results:init(...)
    results.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    gfx.sprite.setAlwaysRedraw(false)

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem(text('slideagain'), function()
            if p1 then
                scenemanager:transitionscene(rehearsal, 0, {})
            else
                scenemanager:transitionscene(pass, 0, {})
            end
            pd.timer.performAfterDelay(650, function()
                p1 = true
            end)
            if save.sfx then assets.click:play() end
            fademusic()
        end)
        menu:addMenuItem(text('slidetitle'), function()
            if save.sfx then assets.click:play() end
            scenemanager:switchscene(title)
        end)
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        sasser = gfx.font.new('fonts/sasser'),
        small = gfx.font.new('fonts/small'),
        spotlight = smp.new('audio/sfx/spotlight'),
        click = smp.new('audio/sfx/click'),
    }

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        score = args[1],
        showtime = false,
        image = math.random(1, 4),
    }
    vars.resultsHandlers = {
        AButtonDown = function()
            if p1 then
                scenemanager:transitionscene(rehearsal, 0, {})
            else
                scenemanager:transitionscene(pass, 0, {})
            end
            pd.timer.performAfterDelay(400, function()
                p1 = true
            end)
            if save.sfx then assets.click:play() end
            fademusic()
        end,

        BButtonDown = function()
            scenemanager:switchscene(title)
            if save.sfx then assets.click:play() end
        end,
    }

    save.multi_plays += 1

    if p1 then
        assets.image_results = gfx.image.new('images/bg_p2')
    else
        assets.image_results = gfx.image.new('images/bg_p1')
    end

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        if vars.showtime then
            assets.image_results:draw(0, 0)
        end
        if p1 then
            assets.sasser:drawTextAligned(text('p2wins'), 200, 10, kTextAlignment.center)
        else
            assets.sasser:drawTextAligned(text('p1wins'), 200, 10, kTextAlignment.center)
        end
        assets.small:drawTextAligned(text('gameoverprompts'), 200, 220, kTextAlignment.center)
    end)

    pd.timer.performAfterDelay(1200, function()
        vars.showtime = true
        pd.inputHandlers.push(vars.resultsHandlers)
        gfx.sprite.redrawBackground()
        if save.sfx then assets.spotlight:play() end
    end)

    newmusic('audio/music/music1', true)

	updatecheevos()

    -- Set the sprites
    self:add()
end