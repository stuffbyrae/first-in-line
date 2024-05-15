import 'title'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local text <const> = gfx.getLocalizedText

class('scores').extends(gfx.sprite) -- Create the scene's class
function scores:init(...)
    scores.super.init(self)
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
        board = "arcade_easy",
        mode = "arcade",
        hard = false,
        result = {},
        best = {},
        loading = true,
    }
    vars.scoresHandlers = {
        AButtonDown = function()
            if save.hard and not vars.loading then
                vars.hard = not vars.hard
                self:refreshboards()
            end
        end,

        BButtonDown = function()
            scenemanager:switchscene(title)
            if save.sfx then assets.click:play() end
        end,

        leftButtonDown = function()
            if vars.mode == "oneshot" and not vars.loading then
                vars.mode = "arcade"
                self:refreshboards()
            end
        end,

        rightButtonDown = function()
            if save.arcade_plays >= 10 and vars.mode == "arcade" and not vars.loading then
                vars.mode = "oneshot"
                self:refreshboards()
            end
        end,
    }

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        if vars.showtime then
            assets.image_bg:draw(0, 0)
            gfx.setImageDrawMode(gfx.kDrawModeNXOR)
            assets.sasser:drawTextAligned(text(vars.mode), 200, 10, kTextAlignment.center)
            if save.hard then
                if vars.hard then
                    assets.small:drawTextAligned(text('hardscores'), 200, 25, kTextAlignment.center)
                else
                    assets.small:drawTextAligned(text('easyscores'), 200, 25, kTextAlignment.center)
                end
            else
                assets.small:drawTextAligned(text('globalscores'), 200, 25, kTextAlignment.center)
            end
            if vars.result.scores ~= nil then
                for _, v in ipairs(vars.result.scores) do
                    assets.small:drawTextAligned(v.rank .. '. ' .. v.player:lower() .. ' - ' .. v.value, 200, 50 + (15 * (v.rank - 1)), kTextAlignment.center)
                end
            elseif vars.result == "fail" then
                assets.small:drawTextAligned(text('failedglobalscores'), 200, 110, kTextAlignment.center)
            else
                if vars.loading then
                    assets.small:drawTextAligned(text('loadingglobalscores'), 200, 110, kTextAlignment.center)
                else
                    assets.small:drawTextAligned(text('emptyglobalscores'), 200, 110, kTextAlignment.center)
                end
            end
            if vars.best[1] ~= nil then
                assets.sasser:drawTextAligned(text('yourank') .. ordinal(vars.best.value) .. '!', 200, 180, kTextAlignment.center)
            end
            if save.hard then
                if not vars.loading then
                    if vars.hard then
                        assets.small:drawTextAligned(text('geteasyscores'), 370, 220, kTextAlignment.right)
                    else
                        assets.small:drawTextAligned(text('gethardscores'), 370, 220, kTextAlignment.right)
                    end
                else
                    assets.small:drawTextAligned(text('back'), 370, 220, kTextAlignment.right)
                end
            else
                assets.small:drawTextAligned(text('back'), 370, 220, kTextAlignment.right)
            end
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
    end)

    pd.timer.performAfterDelay(500, function()
        vars.showtime = true
        pd.inputHandlers.push(vars.scoresHandlers)
        gfx.sprite.redrawBackground()
        self:refreshboards()
        if save.sfx then assets.spotlight:play() end
    end)

    -- Set the sprites
    self:add()
end

function scores:refreshboards()
    vars.result = {}
    vars.best = {}
    vars.loading = true
    gfx.sprite.redrawBackground()
    vars.board = vars.mode
    if vars.hard then
        vars.board = vars.board .. '_hard'
    else
        vars.board = vars.board .. '_easy'
    end
    pd.scoreboards.getScores(vars.board, function(status, result)
        printTable(status)
        printTable(result)
        if status.code == "OK" then
            vars.result = result
        else
            vars.result = "fail"
        end
        vars.loading = false
        gfx.sprite.redrawBackground()
    end)
    pd.scoreboards.getPersonalBest(vars.board, function(status, result)
        if status.code == "OK" then
            vars.best = result
        end
    end)
end