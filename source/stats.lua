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
        AButtonDown = function()
            scenemanager:switchscene(title)
            assets.click:play()
        end,

        BButtonDown = function()
            scenemanager:switchscene(title)
            assets.click:play()
        end,
    }

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        if vars.showtime then
            assets.image_bg:draw(0, 0)
        end
        assets.sasser:drawTextAligned('Stats', 200, 10, kTextAlignment.center)
        if save.hard then
            assets.small:drawTextAligned('high scores:\neasy: ' .. save.score_easy .. '      hard: ' .. save.score_hard, 200, 30, kTextAlignment.center)
            assets.small:drawTextAligned('plays: ' .. save.plays .. '      hints: ' .. save.hints .. '\nheckles: ' .. save.heckles, 200, 75, kTextAlignment.center)
        else
            assets.small:drawTextAligned('high score: ' .. save.score_easy, 200, 45, kTextAlignment.center)
            assets.small:drawTextAligned('plays: ' .. save.plays .. '      hints: ' .. save.hints, 200, 70, kTextAlignment.center)
        end
        assets.sasser:drawTextAligned('Credits', 200, 120, kTextAlignment.center)
        assets.small:drawTextAligned('music - kevin macleod', 200, 140, kTextAlignment.center)
        assets.small:drawTextAligned('sfx - pixabay.com & rae', 200, 155, kTextAlignment.center)
        assets.small:drawTextAligned('tanuk code lib - toad & schyzo', 200, 170, kTextAlignment.center)
        assets.small:drawTextAligned('thanx - paul, voxy, mag, & toad', 200, 185, kTextAlignment.center)
        assets.small:drawTextAligned('2024, made by rae', 370, 215, kTextAlignment.right)
        assets.small:drawText('A/B - back', 30, 215)
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