import 'title'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer

class('scores').extends(gfx.sprite) -- Create the scene's class
function scores:init(...)
    scores.super.init(self)
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
        hard = false,
        result = {},
        best = {},
    }
    vars.scoresHandlers = {
        AButtonDown = function()
            if save.hard then
                vars.hard = not vars.hard
                self:refreshboards(vars.hard)
                assets.click:play()
            end
        end,

        BButtonDown = function()
            scenemanager:switchscene(title)
            assets.click:play()
        end,
    }

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        if vars.showtime then
            assets.image_bg:draw(0, 0)
        gfx.setImageDrawMode(gfx.kDrawModeNXOR)
        if vars.result[1] ~= nil then
            for _, v in ipairs(vars.result.scores) do
                assets.small:drawTextAligned(v.rank .. '. ' .. v.player:lower() .. ' - ' .. v.value, 200, 30 + (15 * (v.rank - 1)), kTextAlignment.center)
            end
        elseif vars.result == "fail" then
            assets.small:drawTextAligned('failed to get scores.', 200, 100, kTextAlignment.center)
        else
            assets.small:drawTextAligned('loading global scores...', 200, 100, kTextAlignment.center)
        end
        if vars.best[1] ~= nil then
            assets.sasser:drawTextAligned('You rank... ' .. ordinal(vars.best.value) .. '!', 200, 180, kTextAlignment.center)
        end
        assets.small:drawText('B - back', 30, 215)
        if vars.hard then
            assets.sasser:drawTextAligned('Hard - Global Scores', 200, 10, kTextAlignment.center)
            assets.small:drawTextAligned('A - view easy scores', 370, 215, kTextAlignment.right)
            assets.small:drawTextAligned('your high score: ' .. save.score_hard, 200, 195, kTextAlignment.center)
        else
            assets.sasser:drawTextAligned('Easy - Global Scores', 200, 10, kTextAlignment.center)
            if save.hard then
                assets.small:drawTextAligned('A - view hard scores', 370, 215, kTextAlignment.right)
            end
            assets.small:drawTextAligned('your high score: ' .. save.score_easy, 200, 195, kTextAlignment.center)
        end
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
    end)

    pd.timer.performAfterDelay(500, function()
        vars.showtime = true
        pd.inputHandlers.push(vars.scoresHandlers)
        gfx.sprite.redrawBackground()
        self:refreshboards()
        assets.spotlight:play()
    end)

    -- Set the sprites
    self:add()
end

function scores:refreshboards(hard)
    vars.result = {}
    vars.best = {}
    if hard then
        pd.scoreboards.getScores('hard', function(status, result)
            if status.code == "OK" then
                vars.result = result
            else
                vars.result = "fail"
            end
            gfx.sprite.redrawBackground()
        end)
        pd.scoreboards.getPersonalBest('hard', function(status, result)
            if status.code == "OK" then
                vars.best = result
            end
        end)
    else
        pd.scoreboards.getScores('easy', function(status, result)
            if status.code == "OK" then
                vars.result = result
            else
                vars.result = "fail"
            end
            gfx.sprite.redrawBackground()
        end)
        pd.scoreboards.getPersonalBest('easy', function(status, result)
            if status.code == "OK" then
                vars.best = result
            end
        end)
    end
end