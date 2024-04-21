import 'title'
import 'play'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer

class('rehearsal').extends(gfx.sprite) -- Create the scene's class
function rehearsal:init(...)
    rehearsal.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
        buttony = gfx.font.new('fonts/buttony'),
        lines = gfx.imagetable.new('images/lines'),
        small = gfx.font.new('fonts/small'),
        paper1 = smp.new('audio/sfx/paper1'),
        paper2 = smp.new('audio/sfx/paper2'),
    }
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        score = args[1],
        buttons = {pd.kButtonUp, pd.kButtonDown, pd.kButtonLeft, pd.kButtonRight, pd.kButtonA, pd.kButtonB},
        button_texts = {'U', 'D', 'L', 'R', 'A', 'B'},
        button_string = {},
        button_text_string = '(',
        anim_lines = pd.timer.new(0, 475, 475),
        anim_lines_frames = pd.timer.new(0, 1, 1),
        paper_rand = math.random(1, 2),
        showtime = false,
    }
    vars.rehearsalHandlers = {
        AButtonDown = function()
            self:leave()
        end,
    }
    pd.inputHandlers.push(vars.rehearsalHandlers)

    vars.anim_lines.discardOnCompletion = false
    vars.anim_lines_frames.discardOnCompletion = false

    vars.string_length = math.min(4 + vars.score, 24)
    for i = 1, vars.string_length do
        vars.rand = math.random(1, 6)
        table.insert(vars.button_string, vars.buttons[vars.rand])
        if i % 5 == 0 and i ~= 0 then vars.button_text_string = vars.button_text_string .. '\n' end
        vars.button_text_string = vars.button_text_string .. vars.button_texts[vars.rand]
        if i ~= vars.string_length then
            vars.button_text_string = vars.button_text_string .. ', '
        else
            vars.button_text_string = vars.button_text_string .. ')'
        end
    end

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
    end)
    
    class('rehearsal_lines').extends(gfx.sprite)
    function rehearsal_lines:init()
        rehearsal_lines.super.init(self)
        self:setSize(362, 221)
        self:setCenter(0.5, 1)
        self:moveTo(200, 240)
        self:add()
    end
    function rehearsal_lines:draw()
        assets.lines[math.floor(vars.anim_lines_frames.value)]:draw(0, 0)
        assets.buttony:drawTextAligned(vars.button_text_string, 172, 95 + (vars.anim_lines_frames.value * -20), kTextAlignment.center)
    end
    function rehearsal_lines:update()
        if vars.anim_lines ~= nil then
            self:moveTo(200, vars.anim_lines.value)
        end
    end

    class('rehearsal_showtime').extends(gfx.sprite)
    function rehearsal_showtime:init()
        rehearsal_showtime.super.init(self)
        self:setSize(150, 30)
        self:moveTo(315, 215)
    end
    function rehearsal_showtime:draw()
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, 0, 150, 30)
        gfx.setColor(gfx.kColorBlack)
        gfx.setLineWidth(2)
        gfx.drawRect(3, 3, 144, 24)
        assets.small:drawTextAligned('@ showtime!', 75, 7, kTextAlignment.center)
    end

    pd.timer.performAfterDelay(1000, function()
        assets.paper2:play()
        vars.anim_lines:resetnew(400, 475, 240, pd.easingFunctions.outCubic)
        vars.anim_lines_frames:resetnew(300, 1, 3)
    end)

    pd.timer.performAfterDelay(2500, function()
        vars.showtime = true
        self.showtime:add()
    end)

    -- Set the sprites
    self.lines = rehearsal_lines()
    self.showtime = rehearsal_showtime()
    self:add()
end

function rehearsal:leave()
    if vars.showtime then
        vars.showtime = false
        self.showtime:remove()
        vars.anim_lines:resetnew(200, 240, 475, pd.easingFunctions.inSine)
        vars.anim_lines_frames:resetnew(0, 2, 2)
        assets.paper1:play()
        pd.timer.performAfterDelay(500, function()
            scenemanager:transitionscene(play, vars.score, vars.button_string)
        end)
    end
end