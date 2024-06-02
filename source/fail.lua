import 'title'
import 'rehearsal'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local text <const> = gfx.getLocalizedText

class('fail').extends(gfx.sprite) -- Create the scene's class
function fail:init(...)
    fail.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    gfx.sprite.setAlwaysRedraw(false)

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem(text('slideagain'), function()
            if save.sfx then assets.click:play() end
            scenemanager:transitionscene(rehearsal, 0, {})
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
        draw = 'high',
        inputs = 0,
    }
    vars.failHandlers = {
        AButtonDown = function()
            p1 = true
            scenemanager:transitionscene(rehearsal, 0, {})
            if save.sfx then assets.click:play() end
            fademusic()
        end,

        BButtonDown = function()
            scenemanager:switchscene(title)
            if save.sfx then assets.click:play() end
        end,
    }

    save[mode .. '_plays'] += 1

    if vars.score >= 25 then
        assets.image_fail = gfx.image.new('images/fail_good_' .. vars.image)
    else
        assets.image_fail = gfx.image.new('images/fail_bad_' .. vars.image)
    end

    if save.crank and not save.shaking and not save.mic then
        vars.inputs = 1
    elseif not save.crank and save.shaking and not save.mic then
        vars.inputs = 2
    elseif not save.crank and not save.shaking and save.mic then
        vars.inputs = 3
    elseif save.crank and save.shaking and not save.mic then
        vars.inputs = 4
    elseif save.crank and not save.shaking and save.mic then
        vars.inputs = 5
    elseif not save.crank and save.shaking and save.mic then
        vars.inputs = 6
    elseif save.crank and save.shaking and save.mic then
        vars.inputs = 7
    end

    if easy then
        if vars.score > save['score_' .. mode .. '_easy'] and vars.score > 0 then
            if mode == "arcade" and vars.score >= 25 and not save.hard then
                vars.draw = 'hard'
                save.hard = true
            else
                vars.draw = 'new'
            end
            save['score_' .. mode .. '_easy'] = vars.score
            if catalog then
                pd.scoreboards.addScore(mode .. 'easy', vars.score .. vars.inputs, function(status, result)
                    if pd.isSimulator == 1 then
                        printTable(status)
                        printTable(result)
                    end
                end)
            end
        end
    else
        if vars.score > save['score_' .. mode .. '_hard'] and vars.score > 0 then
            vars.draw = 'new'
            save['score_' .. mode .. '_hard'] = vars.score
            if catalog then
                pd.scoreboards.addScore(mode .. 'hard', vars.score .. vars.inputs, function(status, result)
                    if pd.isSimulator == 1 then
                        printTable(status)
                        printTable(result)
                    end
                end)
            end
        end
    end

    if mode == "arcade" then
        if save.arcade_plays == 10 then
            vars.draw = 'oneshot'
        end
    end

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        if vars.showtime then
            assets.image_fail:draw(0, 0)
        end
        assets.sasser:drawTextAligned(text('gameover'), 200, 10, kTextAlignment.center)
        assets.small:drawTextAligned(text('yourscore') .. vars.score, 200, 30, kTextAlignment.center)
        if vars.draw == 'hard' then
            assets.small:drawTextAligned(text('hardunlocked'), 200, 50, kTextAlignment.center)
        elseif vars.draw == 'oneshot' then
            assets.small:drawTextAligned(text('oneshotunlocked'), 200, 50, kTextAlignment.center)
        elseif vars.draw == 'new' then
            assets.small:drawTextAligned(text('newhigh'), 200, 50, kTextAlignment.center)
        elseif vars.draw == 'high' then
            if easy then
                assets.small:drawTextAligned(text('highscore') .. save['score_' .. mode .. '_easy'], 200, 50, kTextAlignment.center)
            else
                assets.small:drawTextAligned(text('highscore') .. save['score_' .. mode .. '_hard'], 200, 50, kTextAlignment.center)
            end
        end
        assets.small:drawTextAligned(text('gameoverprompts'), 200, 220, kTextAlignment.center)
    end)

    pd.timer.performAfterDelay(1200, function()
        vars.showtime = true
        pd.inputHandlers.push(vars.failHandlers)
        gfx.sprite.redrawBackground()
        if save.sfx then assets.spotlight:play() end
    end)

    newmusic('audio/music/music1', true)

    -- Set the sprites
    self:add()
end