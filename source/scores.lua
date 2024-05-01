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
        
    }
    vars.scoresHandlers = {
        AButtonDown = function()
            vars.hard = not vars.hard
            gfx.sprite.redrawBackground()
            assets.click:play()
        end,

        BButtonDown = function()
            scenemanager:switchscene(title)
            assets.click:play()
        end,
    }

    -- TODO: if this gets on the catalog, flesh out the leaderboard situation after boards are set up
    -- If you're not me and you're seeing this ... let a moth future-proof okay!
    vars.result = {
        scores = {
            { player = "ScenicRouteSoftware", rank = 1, value = 6000 },
            { player = "elephanteater", rank = 2, value = 5000 },
            { player = "fatnosegaming", rank = 3, value = 4000 },
            { player = "Poe", rank = 5, value = 2599 },
            { player = "kmchipman", rank = 4, value = 2800 },
            { player = "ledbetter", rank = 7, value = 2390 },
            { player = "pixelghost", rank = 6, value = 2400 },
            { player = "yessclara", rank = 8, value = 2200 },
            { player = "emre", rank = 9, value = 2199 },
            { player = "callmesteam", rank = 5293, value = 30 }
        }
    }

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        if vars.showtime then
            assets.image_bg:draw(0, 0)
        end
        if vars.result ~= nil then
            for _, v in ipairs(vars.result.scores) do
                assets.small:drawTextAligned(v.rank .. '. ' .. v.player:lower() .. ' - ' .. v.value, 200, 30 + (15 * (v.rank - 1)), kTextAlignment.center)
            end
        else
            assets.small:drawTextAligned('loading global scores...', 200, 120, kTextAlignment.center)
        end
        assets.sasser:drawTextAligned('You rank... 12th!', 200, 180, kTextAlignment.center)
        assets.small:drawTextAligned('your high score: 200', 200, 195, kTextAlignment.center)
        assets.small:drawText('B - back', 30, 215)
        if vars.hard then
            assets.sasser:drawTextAligned('Hard - Global Scores', 200, 10, kTextAlignment.center)
            assets.small:drawTextAligned('A - view easy scores', 370, 215, kTextAlignment.right)
        else
            assets.sasser:drawTextAligned('Easy - Global Scores', 200, 10, kTextAlignment.center)
            assets.small:drawTextAligned('A - view hard scores', 370, 215, kTextAlignment.right)
        end
    end)

    pd.timer.performAfterDelay(500, function()
        vars.showtime = true
        pd.inputHandlers.push(vars.scoresHandlers)
        gfx.sprite.redrawBackground()
        assets.spotlight:play()
    end)

    -- Set the sprites
    self:add()
end