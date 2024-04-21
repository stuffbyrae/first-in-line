import 'stats'
import 'rehearsal'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer

class('title').extends(gfx.sprite) -- Create the scene's class
function title:init(...)
    title.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_title = gfx.image.new('images/title'),
        small = gfx.font.new('fonts/small'),
        spotlight = smp.new('audio/sfx/spotlight'),
        click = smp.new('audio/sfx/click'),
    }
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        showtime = false,
    }
    vars.titleHandlers = {
        AButtonDown = function()
            scenemanager:transitionscene(rehearsal, 0)
            assets.click:play()
            fademusic()
        end,

        BButtonDown = function()
            scenemanager:switchscene(stats)
            assets.click:play()
        end,
    }
    
    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        if vars.showtime then
            assets.image_title:draw(0, 0)
        end
        assets.small:drawText('@ play game', 120, 170)
        assets.small:drawText('B stats n\' credits', 160, 190)
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