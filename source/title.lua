import 'settings'
import 'scores'
import 'rehearsal'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local geo <const> = pd.geometry
local text <const> = gfx.getLocalizedText

class('title').extends(gfx.sprite) -- Create the scene's class
function title:init(...)
    title.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    gfx.sprite.setAlwaysRedraw(false)

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        if catalog then
            menu:addMenuItem(text('highscores'), function()
                if save.sfx then assets.click:play() end
                scenemanager:switchscene(scores)
            end)
        end
        menu:addMenuItem(text('settings'), function()
            if save.sfx then assets.click:play() end
            scenemanager:switchscene(settings)
        end)
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_title = gfx.image.new('images/title'),
        sasser = gfx.font.new('fonts/sasser'),
        small = gfx.font.new('fonts/small'),
        spotlight = smp.new('audio/sfx/spotlight'),
        click = smp.new('audio/sfx/click'),
    }

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        showtime = false,
        easy = true,
        selections = {},
        selection = 1,
    }

    table.insert(vars.selections, "arcade")
    if save.arcade_plays >= 10 then
        table.insert(vars.selections, "oneshot")
    end
    table.insert(vars.selections, "multi")
    if catalog then
        table.insert(vars.selections, "highscores")
    end
    table.insert(vars.selections, "settings")

    vars.titleHandlers = {
        AButtonDown = function()
            if save.sfx then assets.click:play() end
            if vars.selections[vars.selection] == "highscores" then
                scenemanager:switchscene(scores)
            elseif vars.selections[vars.selection] == "settings" then
                scenemanager:switchscene(settings)
            else
                p1 = true
                scenemanager:transitionscene(rehearsal, 0, {})
                mode = vars.selections[vars.selection]
                easy = true
                fademusic()
            end
        end,

        BButtonDown = function()
            if save.hard then
                if vars.selections[vars.selection] == "highscores" then
                    return
                elseif vars.selections[vars.selection] == "settings" then
                    return
                else
                    if save.sfx then assets.click:play() end
                    scenemanager:transitionscene(rehearsal, 0, {})
                    mode = vars.selections[vars.selection]
                    easy = false
                    fademusic()
                end
            end
        end,

        leftButtonDown = function()
            vars.selection = math.max(1, math.min(#vars.selections, vars.selection - 1))
            gfx.sprite.redrawBackground()
        end,

        rightButtonDown = function()
            vars.selection = math.max(1, math.min(#vars.selections, vars.selection + 1))
            gfx.sprite.redrawBackground()
        end,
    }

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        if vars.showtime then
            assets.image_title:draw(0, 0)
        end
        assets.sasser:drawTextAligned(text(vars.selections[vars.selection]), 227, 160, kTextAlignment.center)
        assets.small:drawTextAligned(text(vars.selections[vars.selection] .. 'desc'), 227, 180, kTextAlignment.center)
        if vars.selections[vars.selection] == "arcade" then
            if save.hard then
                assets.small:drawTextAligned(text('playgamehard'), 370, 220, kTextAlignment.right)
                assets.small:drawTextAligned(text('easy') .. text('colon') .. save.score_arcade_easy .. text('separator') .. text('hard') .. text('colon') .. save.score_arcade_hard, 227, 197, kTextAlignment.center)
            else
                assets.small:drawTextAligned(text('playgame'), 370, 220, kTextAlignment.right)
                assets.small:drawTextAligned(text('high') .. text('colon') .. save.score_arcade_easy, 227, 197, kTextAlignment.center)
            end
        elseif vars.selections[vars.selection] == "oneshot" then
            if save.hard then
                assets.small:drawTextAligned(text('playgamehard'), 370, 220, kTextAlignment.right)
                assets.small:drawTextAligned(text('easy') .. text('colon') .. save.score_oneshot_easy .. text('separator') .. text('hard') .. text('colon') .. save.score_oneshot_hard, 227, 197, kTextAlignment.center)
            else
                assets.small:drawTextAligned(text('playgame'), 370, 220, kTextAlignment.right)
                assets.small:drawTextAligned(text('high') .. text('colon') .. save.score_oneshot_easy, 227, 197, kTextAlignment.center)
            end
        elseif vars.selections[vars.selection] == "multi" then
            if save.hard then
                assets.small:drawTextAligned(text('playgamehard'), 370, 220, kTextAlignment.right)
            else
                assets.small:drawTextAligned(text('playgame'), 370, 220, kTextAlignment.right)
            end
        elseif vars.selections[vars.selection] == "highscores" then
            assets.small:drawTextAligned(text('select'), 370, 220, kTextAlignment.right)
        elseif vars.selections[vars.selection] == "settings" then
            assets.small:drawTextAligned(text('select'), 370, 220, kTextAlignment.right)
        end
    end)

    pd.timer.performAfterDelay(500, function()
        vars.showtime = true
        pd.inputHandlers.push(vars.titleHandlers)
        gfx.sprite.redrawBackground()
        if save.sfx then assets.spotlight:play() end
    end)

    newmusic('audio/music/music1', true)

    -- Set the sprites
    self:add()
end