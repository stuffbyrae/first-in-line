import 'stats'
import 'scores'
import 'rehearsal'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local geo <const> = pd.geometry

class('title').extends(gfx.sprite) -- Create the scene's class
function title:init(...)
    title.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    gfx.sprite.setAlwaysRedraw(false)

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        if catalog then
            menu:addMenuItem('global scores', function()
                assets.click:play()
                scenemanager:switchscene(scores)
            end)
        end
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_title = gfx.image.new('images/title'),
        small = gfx.font.new('fonts/small'),
        spotlight = smp.new('audio/sfx/spotlight'),
        click = smp.new('audio/sfx/click'),
    }

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        showtime = false,
        easy = true,
    }
    vars.titleHandlers = {
        AButtonDown = function()
            if vars.easy then
                easy = true
            else
                easy = false
            end
            scenemanager:transitionscene(rehearsal, 0, {})
            assets.click:play()
            fademusic()
        end,

        BButtonDown = function()
            scenemanager:switchscene(stats)
            assets.click:play()
        end,

        upButtonDown = function()
            if save.hard then
                vars.easy = not vars.easy
                gfx.sprite.redrawBackground()
            end
        end,

        downButtonDown = function()
            if save.hard then
                vars.easy = not vars.easy
                gfx.sprite.redrawBackground()
            end
        end,
    }

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        if vars.showtime then
            assets.image_title:draw(0, 0)
        end
        if not save.hard then
            assets.small:drawText('A play easy game', 120, 170)
        else
            assets.small:drawText('A play               game', 120, 170)
            gfx.setLineWidth(2)
            gfx.drawRect(192, 169, 77, 20)
            gfx.fillPolygon(geo.polygon.new(201, 171, 206, 178, 196, 178, 201, 171))
            gfx.fillPolygon(geo.polygon.new(206, 179, 196, 179, 201, 186, 206, 179))
            if vars.easy then
                assets.small:drawTextAligned('easy', 235, 170, kTextAlignment.center)
            else
                assets.small:drawTextAligned('hard', 235, 170, kTextAlignment.center)
            end
        end
        assets.small:drawText('B stats n\' credits', 160, 190)
        assets.small:drawTextAligned('v' .. pd.metadata.version, 370, 220, kTextAlignment.right)
    end)

    pd.timer.performAfterDelay(500, function()
        vars.showtime = true
        pd.inputHandlers.push(vars.titleHandlers)
        gfx.sprite.redrawBackground()
        assets.spotlight:play()
    end)

    newmusic('audio/music/music1', true)

    -- Set the sprites
    self:add()
end