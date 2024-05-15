import 'title'
import 'play'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local text <const> = gfx.getLocalizedText

class('rehearsal').extends(gfx.sprite) -- Create the scene's class
function rehearsal:init(...)
    rehearsal.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    gfx.sprite.setAlwaysRedraw(false)

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem(text('slidetitle'), function()
            backtotitle(function()
                if vars.showtime_timer ~= nil then
                    vars.showtime_timer:start()
                    assets.timer:setPaused(false)
                end
            end)
            if vars.showtime_timer ~= nil then
                vars.showtime_timer:pause()
                assets.timer:setPaused(true)
            end
        end)
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        buttony = gfx.font.new('fonts/buttony'),
        lines = gfx.imagetable.new('images/lines'),
        roobert = gfx.font.new('fonts/roobert'),
        small = gfx.font.new('fonts/small'),
        paper1 = smp.new('audio/sfx/paper1'),
        paper2 = smp.new('audio/sfx/paper2'),
        image_timer = gfx.image.new('images/timer'),
        timer = smp.new('audio/sfx/timer'),
        ding = smp.new('audio/sfx/ding'),
        click = smp.new('audio/sfx/click'),
    }

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        score = args[1],
        button_texts = {'U', 'D', 'L', 'R', 'A', 'B', 'C', 'W', '[', ']', 'S', 'M'},
        button_text_string = '(',
        button_text_string_length = 0,
        anim_lines = pd.timer.new(0, 475, 475),
        anim_lines_frames = pd.timer.new(0, 1, 1),
        paper_rand = math.random(1, 2),
        showtime = false,
        showtime_timer = pd.timer.new(0, 0, 0),
        anim_lines = pd.timer.new(0, 475, 475),
        anim_lines_frames = pd.timer.new(0, 1, 1),
        startedthething = false,
    }
    vars.rehearsalHandlers = {
        AButtonDown = function()
            self:leave()
        end,
    }
    pd.inputHandlers.push(vars.rehearsalHandlers)

    vars.anim_lines.discardOnCompletion = false
    vars.anim_lines_frames.discardOnCompletion = false

    if save.crank then
        if pd.isCrankDocked() then
            self:startthething()
        else
            local image = gfx.image.new(400, 240)
            gfx.pushContext(image)
                gfx.setColor(gfx.kColorWhite)
                gfx.fillRect(10, 10, 380, 220)
                gfx.setColor(gfx.kColorBlack)
                gfx.drawRect(13, 13, 374, 214)
                assets.small:drawTextAligned(text('dock'), 200, 100, kTextAlignment.center)
            gfx.popContext(image)
            vars.sprite = gfx.sprite.new(image)
            image = nil
            vars.sprite:setCenter(0, 0)
            vars.sprite:moveTo(0, 0)
            vars.sprite:setZIndex(999)
            vars.sprite:setIgnoresDrawOffset(true)
            vars.sprite:add()
        end
    else
        self:startthething()
    end

    if p1 then
        if easy then
            vars.button_string = args[2]
            if vars.button_string[1] == nil then
                vars.string_length = 4
            else
                vars.string_length = 1
            end
            if #vars.button_string + 1 > 24 then
                vars.button_string = {}
                vars.string_length = 4
            end
        else
            vars.string_length = math.min(4 + vars.score, 24)
            vars.button_string = {}
        end
        for i = 1, #vars.button_string do
            if vars.button_string[i] == 9 or vars.button_string[i] == 10 then
                vars.lastdock = vars.button_string[i]
            end
        end
    else
        vars.button_string = args[2]
        vars.string_length = 0
    end

    for i = 1, #vars.button_string do
        if vars.button_string[i] == 3 then
            vars.button_text_string = vars.button_text_string .. 'L'
        elseif vars.button_string[i] == 4 then
            vars.button_text_string = vars.button_text_string .. 'R'
        elseif vars.button_string[i] == 1 then
            vars.button_text_string = vars.button_text_string .. 'U'
        elseif vars.button_string[i] == 2 then
            vars.button_text_string = vars.button_text_string .. 'D'
        elseif vars.button_string[i] == 6 then
            vars.button_text_string = vars.button_text_string .. 'B'
        elseif vars.button_string[i] == 5 then
            vars.button_text_string = vars.button_text_string .. 'A'
        elseif vars.button_string[i] == 7 then
            vars.button_text_string = vars.button_text_string .. 'C'
        elseif vars.button_string[i] == 8 then
            vars.button_text_string = vars.button_text_string .. 'W'
        elseif vars.button_string[i] == 9 then
            vars.button_text_string = vars.button_text_string .. '['
        elseif vars.button_string[i] == 10 then
            vars.button_text_string = vars.button_text_string .. ']'
        elseif vars.button_string[i] == 11 then
            vars.button_text_string = vars.button_text_string .. 'S'
        elseif vars.button_string[i] == 12 then
            vars.button_text_string = vars.button_text_string .. 'M'
        end
        if i ~= #vars.button_string then
            vars.button_text_string = vars.button_text_string .. ', '
        else
            if p1 then
                vars.button_text_string = vars.button_text_string .. ', '
            else
                vars.button_text_string = vars.button_text_string .. ')'
            end
        end
        vars.button_text_string_length += 1
        if vars.button_text_string_length % 5 == 0 and vars.button_text_string_length ~= 0 then vars.button_text_string = vars.button_text_string .. '\n' end
    end

    for i = 1, vars.string_length do
        ::continue::
        vars.rand = math.random(1, 12)
        -- U, D, L, R, A, B, clockwise, widdershins, dock, undock, shake, mic
        if vars.rand >= 7 and vars.rand <= 10 then
            if not save.crank then
                goto continue
            else
                if vars.rand >= 9 and vars.rand <= 10 then
                    if vars.lastdock ~= nil then
                        if vars.lastdock == 9 and vars.rand == 9 then vars.rand = 10 end
                        if vars.lastdock == 10 and vars.rand == 10 then vars.rand = 9 end
                    else
                        vars.rand = 10
                    end
                    vars.lastdock = vars.rand
                end
                if vars.lastdock ~= nil then
                    if vars.lastdock == 9 and vars.rand == 7 or vars.lastdock == 9 and vars.rand == 8 then
                        goto continue
                    end
                else
                    goto continue
                end
            end
        end
        if vars.rand == 11 and not save.shaking then
            goto continue
        end
        if vars.rand == 12 and not save.mic then
            goto continue
        end
        table.insert(vars.button_string, vars.rand)
        vars.button_text_string = vars.button_text_string .. vars.button_texts[vars.rand]
        if i ~= vars.string_length then
            vars.button_text_string = vars.button_text_string .. ', '
        else
            vars.button_text_string = vars.button_text_string .. ')'
        end
        vars.button_text_string_length += 1
        if vars.button_text_string_length % 5 == 0 and vars.button_text_string_length ~= 0 then vars.button_text_string = vars.button_text_string .. '\n' end
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
        assets.buttony:drawTextAligned(vars.button_text_string, 175, 95 + (vars.anim_lines_frames.value * -20), kTextAlignment.center)
    end
    function rehearsal_lines:update()
        if vars.anim_lines ~= nil then
            self:moveTo(200, vars.anim_lines.value)
        end
    end

    class('rehearsal_showtime').extends(gfx.sprite)
    function rehearsal_showtime:init()
        rehearsal_showtime.super.init(self)
        self:setSize(400, 240)
        self:moveTo(200, 120)
        self:add()
    end
    function rehearsal_showtime:update()
        self:markDirty()
    end
    function rehearsal_showtime:draw()
        if not easy then
            assets.image_timer:draw(10, 10)
            assets.roobert:drawTextAligned(math.floor(vars.showtime_timer.timeLeft / 1000), 40, 36, kTextAlignment.center)
        end
        if mode == "multi" then
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(20, 10, 360, 34)
            gfx.setColor(gfx.kColorBlack)
            gfx.drawRect(23, 13, 354, 27)
            if p1 then
                assets.small:drawTextAligned(text('p1'), 200, 19, kTextAlignment.center)
            else
                assets.small:drawTextAligned(text('p2'), 200, 19, kTextAlignment.center)
            end
        end
        if vars.showtime then
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(245, 205, 150, 30)
            gfx.setColor(gfx.kColorBlack)
            gfx.drawRect(248, 208, 144, 24)
            assets.small:drawTextAligned(text('showtime'), 320, 212, kTextAlignment.center)
        end
    end

    -- Set the sprites
    self.lines = rehearsal_lines()
    self.showtime = rehearsal_showtime()
    self:add()
end

function rehearsal:startthething()
    if not vars.startedthething then
        vars.startedthething = true
        if not easy then
            vars.showtime_timer = pd.timer.new(math.min(10000 + math.ceil(vars.score / 10), 30000), function() self:time() end)
            vars.showtime_timer.delay = 2500
            if save.sfx then
                pd.timer.performAfterDelay(2000, function()
                    assets.timer:play()
                end)
            end
        end
        pd.timer.performAfterDelay(1000, function()
            if save.sfx then assets.paper2:play() end
            vars.anim_lines = pd.timer.new(500, 475, 240, pd.easingFunctions.outCubic)
            vars.anim_lines_frames = pd.timer.new(400, 1, 3)
        end)

        pd.timer.performAfterDelay(2500, function()
            vars.showtime = true
        end)
    end
end

function rehearsal:time()
    assets.timer:stop()
    assets.ding:play()
    self:leave()
end

function rehearsal:leave()
    if vars.showtime then
        if save.sfx then
            if assets.timer:isPlaying() then
                assets.timer:stop()
                assets.ding:play()
            end
            assets.paper1:play()
        end
        vars.showtime = false
        self.showtime:remove()
        vars.anim_lines = pd.timer.new(200, 240, 475, pd.easingFunctions.inSine)
        pd.timer.performAfterDelay(500, function()
            scenemanager:transitionscene(play, vars.score, vars.button_string)
        end)
    end
end

function rehearsal:update()
    if save.crank and not vars.startedthething then
        local dock = pd.isCrankDocked()
        if dock then
            self:startthething()
            vars.sprite:remove()
            vars.sprite = nil
        end
    end
end