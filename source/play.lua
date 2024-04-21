import 'title'
import 'rehearsal'
import 'fail'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer

-- Tanuk_CodeSequence library, from Toad and Schyzo
class('Tanuk_CodeSequence').extends(gfx.sprite)

function Tanuk_CodeSequence:init(sequence)
    assert(sequence, "An input sequence must be provided")
    self.sequence = sequence
    self.sequenceIndex = 1
    self:add()
end

function Tanuk_CodeSequence:update()
    local current, pressed, released = pd.getButtonState()
    if released == 0 then return end -- No button released
    if self.sequence[self.sequenceIndex] == released then
        play:hit(released, self.sequenceIndex)
        self.sequenceIndex = self.sequenceIndex + 1

        if self.sequenceIndex > #self.sequence then
            play:win()
            self:remove()
            self = nil
        end
    else
        play:miss()
    end
end

---To be called to remove the timers
function Tanuk_CodeSequence:cleanup()
    if self.timerInput ~= nil then
        self.timerInput:remove()
        self.timerInput = nil
    end
end

class('play').extends(gfx.sprite) -- Create the scene's class
function play:init(...)
    play.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    gfx.sprite.setAlwaysRedraw(true)
    
    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem('return to title', function()
            fademusic(0)
            assets.crowd:stop()
            assets.crowd_angry:stop()
            assets.applause:stop()
            assets.light_applause:stop()
            assets.footsteps:stop()
            scenemanager:switchscene(title)
        end)
    end
    
    assets = { -- All assets go here. Images, sounds, fonts, etc.
        image_stage = gfx.image.new('images/stage'),
        image_spotlight = gfx.image.new('images/spotlight'),
        image_audience = gfx.image.new('images/audience'),
        miss = gfx.imagetable.new('images/miss'),
        buttony = gfx.font.new('fonts/buttony'),
        speech = gfx.imagetable.new('images/speech'),
        cough = smp.new('audio/sfx/cough'),
        crowd = smp.new('audio/sfx/crowd'),
        crowd_angry = smp.new('audio/sfx/crowd_angry'),
        applause = smp.new('audio/sfx/applause'),
        light_applause = smp.new('audio/sfx/light_applause'),
        spotlight = smp.new('audio/sfx/spotlight'),
        shhh = smp.new('audio/sfx/shhh'),
        footsteps = smp.new('audio/sfx/footsteps'),
        image_cane = gfx.image.new('images/cane'),
        cane = smp.new('audio/sfx/cane'),
        whoosh = smp.new('audio/sfx/whoosh'),
        scratch = smp.new('audio/sfx/scratch'),
        patch = gfx.image.new('images/patch'),
        cast = gfx.imagetable.new('images/cast'),
        honk = smp.new('audio/sfx/honk'),
    }
    
    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        score = args[1],
        button_string = args[2],
        in_progress = false,
        misses = 0,
        anim_audience = pd.timer.new(1000, 0, 1, pd.easingFunctions.inOutSine),
        button_text_string = '',
        spotlight = false,
        status = "idle",
        anim_person = pd.timer.new(1500, 1, 4.9),
        anim_person_x = pd.timer.new(3500, -25, 85),
        anim_cane = pd.timer.new(1, -158, -158),
        person_rand = math.random(1, 4),
    }
    vars.playHandlers = {
    }
    pd.inputHandlers.push(vars.playHandlers)

    vars.anim_person.repeats = true
    vars.anim_audience.reverses = true
    vars.anim_audience.repeats = true

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.image_stage:draw(0, 0)
    end)

    vars.cast_rand = math.random(1, #assets.cast)
    assets.person = gfx.imagetable.new('images/person_' .. vars.person_rand)

    class('play_hud').extends(gfx.sprite)
    function play_hud:init()
        play_hud.super.init(self)
        self:setSize(400, 240)
        self:setZIndex(3)
        self:setCenter(0, 0)
        self:add()
    end
    function play_hud:draw()
        if vars.spotlight then
            assets.image_spotlight:draw(30, 0)
        end
        assets.patch:draw(53, 0)
        assets.image_audience:draw(0, 200 + (10 * vars.anim_audience.value))
        assets.miss[vars.misses + 1]:draw(20, 190)
        if vars.button_text_string ~= '' then
            if vars.status == "just_hit" then
                assets.speech[1]:draw(0, 5)
            else
                assets.speech[2]:draw(0, 5)
            end
        end
        assets.cast[vars.cast_rand]:draw(210, 40)
        assets.image_cane:draw(vars.anim_cane.value, 115)
        assets.buttony:drawTextAligned(vars.button_text_string, 190, 25, kTextAlignment.right)
    end

    class('play_person').extends(gfx.sprite)
    function play_person:init()
        play_person.super.init(self)
        self:setSize(120, 143)
        self:setZIndex(4)
        self:moveTo(0, 125)
        self:add()
    end
    function play_person:draw()
        assets.person[math.floor(vars.anim_person.value)]:draw(0, 0)
    end
    function play_person:update()
        if vars.anim_person_x ~= nil then
            self:moveTo(math.floor(vars.anim_person_x.value / 2) * 2, 125)
        end
    end

    -- Set the sprites
    self.person = play_person()
    self.hud = play_hud()
    self:add()

    assets.footsteps:play()

    pd.timer.performAfterDelay(3500, function()
        vars.anim_person:resetnew(1, 5, 5.9)
    end)

    pd.timer.performAfterDelay(4000, function()
        assets.spotlight:play()
        vars.spotlight = true
        vars.anim_person:resetnew(1, 6, 6.9)
        newmusic('audio/music/music2', true)
        pd.timer.performAfterDelay(750, function()
            assets.shhh:play()
            assets.crowd:stop()
            pd.timer.performAfterDelay(250, function()
                vars.in_progress = true
                sequence = Tanuk_CodeSequence(vars.button_string)
            end)
        end)
    end)

    assets.crowd:play(0)
end

function play:hit(button, index)
    if vars.in_progress then
        vars.status = "just_hit"
        vars.anim_person:resetnew(1, 7, 7.9)
        assets.honk:setRate(1 + ((math.random() / 2) - 0.5))
        assets.honk:play()
        pd.timer.performAfterDelay(50, function()
            vars.status = "hit"
            if vars.in_progress then
                vars.anim_person:resetnew(1, 8, 8.9)
            end
        end)
        if index ~= 1 then
            vars.button_text_string = vars.button_text_string .. ', '
        end
        if button == 1 then
            -- Left is 1
            vars.button_text_string = vars.button_text_string .. 'L'
        elseif button == 2 then
            -- Right is 2
            vars.button_text_string = vars.button_text_string .. 'R'
        elseif button == 4 then
            -- Up is 4
            vars.button_text_string = vars.button_text_string .. 'U'
        elseif button == 8 then
            -- Down is 8
            vars.button_text_string = vars.button_text_string .. 'D'
        elseif button == 16 then
            -- B is 16
            vars.button_text_string = vars.button_text_string .. 'B'
        elseif button == 32 then
            -- A is 32
            vars.button_text_string = vars.button_text_string .. 'A'
        end
    end
end

function play:miss()
    if vars.in_progress then
        vars.misses += 1
        save.misses += 1
        vars.status = "just_missed"
        vars.anim_person = pd.timer.new(1, 9, 9.9)
        pd.timer.performAfterDelay(40, function()
            vars.status = "missed"
            if vars.in_progress then
                vars.anim_person = pd.timer.new(1, 10, 10.9)
            end
        end)
        assets.cough:play()
        if vars.misses >= 3 then
            self:lose()
        end
    end
end

function play:win()
    if vars.in_progress then
        vars.in_progress = false
        vars.anim_person = pd.timer.new(1000, 11, 12.9)
        vars.anim_person.repeats = true
        if vars.misses <= 1 then
            assets.applause:play()
        else
            assets.light_applause:play()
        end
        vars.score += 1
        pd.timer.performAfterDelay(5000, function()
            fademusic()
            scenemanager:transitionscene(rehearsal, vars.score, vars.button_string)
        end)
    end
end

function play:lose()
    if vars.in_progress then
        vars.in_progress = false
        assets.scratch:play()
        vars.anim_person = pd.timer.new(1, 13, 13.9)
        vars.button_text_string = ''
        assets.crowd_angry:play()
        fademusic(500)
        pd.timer.performAfterDelay(1000, function()
            assets.cane:play()
            vars.anim_cane = pd.timer.new(850, -158, -1, pd.easingFunctions.outSine)
        end)
        pd.timer.performAfterDelay(1900, function()
            vars.anim_cane = pd.timer.new(250, -1, -158)
        end)
        pd.timer.performAfterDelay(2000, function()
            assets.whoosh:play()
            vars.anim_person = pd.timer.new(500, 14, 18)
        end)
        pd.timer.performAfterDelay(5000, function()
            scenemanager:transitionscene(fail, vars.score)
        end)
    end
end