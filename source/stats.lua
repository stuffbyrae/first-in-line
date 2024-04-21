import 'title'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer

class('stats').extends(gfx.sprite) -- Create the scene's class
function stats:init(...)
    stats.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    gfx.sprite.setAlwaysRedraw(false)
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem('return to title', function()
            assets.click:play()
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
    }
    vars.statsHandlers = {
        BButtonDown = function()
            scenemanager:switchscene(title)
            assets.click:play()
        end
    }

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        if vars.showtime then
            assets.image_bg:draw(0, 0)
        end
        assets.sasser:drawTextAligned('Stats', 200, 10, kTextAlignment.center)
        assets.small:drawTextAligned('high score (easy):      ' .. save.score_easy, 200, 30, kTextAlignment.center)
        assets.small:drawTextAligned('high score (hard):      ' .. save.score_hard, 200, 45, kTextAlignment.center)
        assets.small:drawTextAligned('total plays:             ' .. save.plays, 200, 60, kTextAlignment.center)
        assets.small:drawTextAligned('total misses:             ' .. save.misses, 200, 75, kTextAlignment.center)
        assets.sasser:drawTextAligned('Credits', 200, 100, kTextAlignment.center)
        assets.small:drawTextAligned('music - kevin macleod', 200, 120, kTextAlignment.center)
        assets.small:drawTextAligned('sfx - pixabay.com', 200, 135, kTextAlignment.center)
        assets.small:drawTextAligned('tanuk code lib - toad & schyzo', 200, 150, kTextAlignment.center)
        assets.small:drawTextAligned('thanx - voxy, mag, toad', 200, 165, kTextAlignment.center)
        assets.small:drawTextAligned('2024, made by rae', 200, 200, kTextAlignment.center)
        assets.small:drawTextAligned('for playjam 5', 200, 215, kTextAlignment.center)
        assets.small:drawText('B back', 30, 215)
    end)

    pd.timer.performAfterDelay(500, function()
        vars.showtime = true
        pd.inputHandlers.push(vars.statsHandlers)
        gfx.sprite.redrawBackground()
        assets.spotlight:play()
    end)

    -- Set the sprites
    self:add()
end