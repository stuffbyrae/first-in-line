import 'stats'
import 'rehearsal'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer

class('fail').extends(gfx.sprite) -- Create the scene's class
function fail:init(...)
    fail.super.init(self)
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
        sasser = gfx.font.new('fonts/sasser'),
        small = gfx.font.new('fonts/small'),
        spotlight = smp.new('audio/sfx/spotlight'),
        click = smp.new('audio/sfx/click'),
    }
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        score = args[1],
        showtime = false,
        image = math.random(1, 4),
        draw = 'high'
    }
    vars.failHandlers = {
        AButtonDown = function()
            scenemanager:switchscene(title)
            assets.click:play()
        end,

        BButtonDown = function()
            scenemanager:switchscene(title)
            assets.click:play()
        end,
    }

    save.plays += 1

    if vars.score >= 25 then
        assets.image_fail = gfx.image.new('images/fail_good_' .. vars.image)
    else
        assets.image_fail = gfx.image.new('images/fail_bad_' .. vars.image)
    end

    if easy then
        if vars.score > save.score_easy and vars.score > 0 then
            if vars.score >= 10 and not save.hard then
                vars.draw = 'hard'
                save.hard = true
            else
                vars.draw = 'new'
            end
            save.score_easy = vars.score
        end
    else
        if vars.score > save.score_hard and vars.score > 0 then
            vars.draw = 'new'
            save.score_hard = vars.score
        end
    end
    
    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        if vars.showtime then
            assets.image_fail:draw(0, 0)
        end
        assets.sasser:drawTextAligned('Game Over', 200, 10, kTextAlignment.center)
        assets.small:drawTextAligned('your score: ' .. vars.score, 200, 30, kTextAlignment.center)
        if vars.draw == 'hard' then
            assets.small:drawTextAligned('(hard mode unlocked!)', 200, 50, kTextAlignment.center)
        elseif vars.draw == 'new' then
            assets.small:drawTextAligned('(a new high!)', 200, 50, kTextAlignment.center)
        elseif vars.draw == 'high' then
            if easy then
                assets.small:drawTextAligned('high score: ' .. save.score_easy, 200, 50, kTextAlignment.center)
            else
                assets.small:drawTextAligned('high score: ' .. save.score_hard, 200, 50, kTextAlignment.center)
            end
        end
        assets.small:drawTextAligned('A/B - return to title', 200, 210, kTextAlignment.center)
    end)
    
    pd.timer.performAfterDelay(1200, function()
        vars.showtime = true
        pd.inputHandlers.push(vars.failHandlers)
        gfx.sprite.redrawBackground()
        assets.spotlight:play()
    end)

    newmusic('audio/music/music1', true)

    -- Set the sprites
    self:add()
end