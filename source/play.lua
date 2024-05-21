import 'title'
import 'rehearsal'
import 'fail'
import 'results'
import 'shaker'

-- Setting up consts
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer
local text <const> = gfx.getLocalizedText

class('play').extends(gfx.sprite) -- Create the scene's class
function play:init(...)
    play.super.init(self)
    local args = {...} -- Arguments passed in through the scene management will arrive here
    gfx.sprite.setAlwaysRedraw(true)

    function pd.gameWillPause() -- When the game's paused...
        local menu = pd.getSystemMenu()
        menu:removeAllMenuItems()
        menu:addMenuItem(text('slidetitle'), function()
            fademusic(0)
            backtotitle(function()
                if mode ~= "oneshot" then
                    vars.pause:start()
                end
            end,
            function()
                assets.crowd:stop()
                assets.crowd_angry:stop()
                assets.applause_1:stop()
                assets.applause_2:stop()
                assets.applause_3:stop()
                assets.light_applause:stop()
                assets.footsteps:stop()
            end)
            if mode ~= "oneshot" then
                vars.pause:pause()
            end
        end)
    end

    assets = { -- All assets go here. Images, sounds, fonts, etc.
        stage = gfx.imagetable.new('images/stage'),
        image_spotlight = gfx.image.new('images/spotlight'),
        image_audience = gfx.image.new('images/audience'),
        miss = gfx.imagetable.new('images/miss'),
        buttony = gfx.font.new('fonts/buttony'),
        image_rose = gfx.image.new('images/rose'),
        speech = gfx.imagetable.new('images/speech'),
        image_speech_hint = gfx.image.new('images/speech_hint'),
        cough = smp.new('audio/sfx/cough'),
        crowd = smp.new('audio/sfx/crowd'),
        crowd_angry = smp.new('audio/sfx/crowd_angry'),
        applause_1 = smp.new('audio/sfx/applause_1'),
        applause_2 = smp.new('audio/sfx/applause_2'),
        applause_3 = smp.new('audio/sfx/applause_3'),
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
        whisper_a = smp.new('audio/sfx/whisper_a'),
        whisper_b = smp.new('audio/sfx/whisper_b'),
        whisper_l = smp.new('audio/sfx/whisper_l'),
        whisper_r = smp.new('audio/sfx/whisper_r'),
        whisper_u = smp.new('audio/sfx/whisper_u'),
        whisper_d = smp.new('audio/sfx/whisper_d'),
        whisper_c = smp.new('audio/sfx/whisper_s'),
        whisper_w = smp.new('audio/sfx/whisper_w'),
        whisper_9 = smp.new('audio/sfx/whisper_['),
        whisper_0 = smp.new('audio/sfx/whisper_]'),
        whisper_s = smp.new('audio/sfx/whisper_s'),
        whisper_m = smp.new('audio/sfx/whisper_m'),
        heckle_1 = smp.new('audio/sfx/heckle_1'),
        heckle_2 = smp.new('audio/sfx/heckle_2'),
        heckle_3 = smp.new('audio/sfx/heckle_3'),
        heckle_4 = smp.new('audio/sfx/heckle_4'),
        laugh_1 = smp.new('audio/sfx/laugh_1'),
        laugh_2 = smp.new('audio/sfx/laugh_2'),
        laugh_3 = smp.new('audio/sfx/laugh_3'),
    }

    vars = { -- All variables go here. Args passed in from earlier, scene variables, etc.
        score = args[1],
        button_string = args[2],
        button_index = 1,
        in_progress = false,
        misses = 0,
        anim_audience = pd.timer.new(1000, 0, 1, pd.easingFunctions.inOutSine),
        button_text_string = '',
        spotlight = false,
        status = "idle",
        anim_person = pd.timer.new(1200, 1, 4.9),
        anim_person_x = pd.timer.new(2700, -25, 85),
        anim_cane = pd.timer.new(1, -253, -253),
        hint_string = '',
        show_hint = false,
        roses = 0,
        crank = 0,
        totalcrank = 0,
        lastcrank = 0,
        mic = 0,
        mic_cooldown = false,
    }
    vars.playHandlers = {
        AButtonDown = function()
            self:button(5)
        end,

        BButtonDown = function()
            self:button(6)
        end,

        upButtonDown = function()
            self:button(1)
        end,

        downButtonDown = function()
            self:button(2)
        end,

        leftButtonDown = function()
            self:button(3)
        end,

        rightButtonDown = function()
            self:button(4)
        end,
    }
    pd.inputHandlers.push(vars.playHandlers)

    if mode ~= "oneshot" then
        vars.pause = pd.timer.new(6000 + (1000 * math.random()), function() self:pause_callback() end)
    end

    vars.anim_person.repeats = true
    vars.anim_audience.reverses = true
    vars.anim_audience.repeats = true

    vars.shaker = Shaker.new(function()
        if save.shaking and vars.in_progress then
            self:button(11)
        end
    end, {sensitivity = Shaker.kSensitivityMedium, threshold = 0.5, samples = 20})

    gfx.sprite.setBackgroundDrawingCallback(function(x, y, width, height) -- Background drawing
        assets.stage[vars.stage_rand]:draw(0, 0)
    end)

    vars.person_rand = math.random(1, 5)
    vars.stage_rand = math.random(1, #assets.stage)
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
            assets.speech[2]:draw(0, 5)
        end
        assets.cast[vars.cast_rand]:draw(210, 40)
        assets.image_cane:draw(vars.anim_cane.value, 115)
        assets.buttony:drawTextAligned(vars.button_text_string, 190, 25, kTextAlignment.right)
        if vars.show_hint then
            assets.image_speech_hint:draw(310, 35)
            assets.buttony:drawText(vars.hint_string, 340, 45)
        end
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

    class('play_rose').extends(gfx.sprite)
    function play_rose:init()
        play_rose.super.init(self)
        self.start_x = math.random(50, 350)
        self.end_x = self.start_x + math.random(-30, 30)
        self.timer_x = pd.timer.new(1000, self.start_x, self.end_x, pd.easingFunctions.outSine)
        self.timer_y = pd.timer.new(800, 280, 190, pd.easingFunctions.outBack)
        self:setImage(assets.image_rose)
        self:setZIndex(5)
        self:add()
    end
    function play_rose:update()
        self:moveTo(self.timer_x.value, self.timer_y.value)
    end

    if save.crank then
        function pd.crankDocked()
            play:button(9)
        end

        function pd.crankUndocked()
            play:button(10)
        end
    end

    -- Set the sprites
    self.person = play_person()
    self.hud = play_hud()
    self:add()

    assets.footsteps:setRate(1.25)
    if save.sfx then assets.footsteps:play() end

    pd.timer.performAfterDelay(2700, function()
        vars.anim_person = pd.timer.new(1, 5, 5.9)
    end)

    pd.timer.performAfterDelay(3000, function()
        if save.sfx then assets.spotlight:play() end
        vars.spotlight = true
        vars.anim_person = pd.timer.new(1, 6, 6.9)
        newmusic('audio/music/music2', true)
        vars.in_progress = true
        if save.shaking then
            pd.startAccelerometer()
            vars.shaker:setEnabled(true)
        end
        if save.mic then
            pd.sound.micinput.startListening()
        end
        pd.timer.performAfterDelay(750, function()
            if save.sfx then assets.shhh:play() end
            assets.crowd:stop()
        end)
    end)

    if save.sfx then assets.crowd:play(0) end
end

function play:pause_callback()
    if vars.in_progress then
        if easy then
            save.hints += 1
            local button = vars.button_string[vars.button_index]
            if button == 3 then
                vars.hint_string = 'l'
                if save.sfx then assets.whisper_l:play() end
            elseif button == 4 then
                vars.hint_string = 'r'
                if save.sfx then assets.whisper_r:play() end
            elseif button == 1 then
                vars.hint_string = 'u'
                if save.sfx then assets.whisper_u:play() end
            elseif button == 2 then
                vars.hint_string = 'd'
                if save.sfx then assets.whisper_d:play() end
            elseif button == 6 then
                vars.hint_string = 'b'
                if save.sfx then assets.whisper_b:play() end
            elseif button == 5 then
                vars.hint_string = 'a'
                if save.sfx then assets.whisper_a:play() end
            elseif button == 7 then
                vars.hint_string = 'c'
                if save.sfx then assets.whisper_c:play() end
            elseif button == 8 then
                vars.hint_string = 'w'
                if save.sfx then assets.whisper_w:play() end
            elseif button == 9 then
                vars.hint_string = '{'
                if save.sfx then assets.whisper_9:play() end
            elseif button == 10 then
                vars.hint_string = '}'
                if save.sfx then assets.whisper_0:play() end
            elseif button == 11 then
                vars.hint_string = 's'
                if save.sfx then assets.whisper_s:play() end
            elseif button == 12 then
                vars.hint_string = 'm'
                if save.sfx then assets.whisper_m:play() end
            end
            vars.show_hint = true
        else
            if vars.misses < 3 then
                save.heckles += 1
                if save.sfx then assets['heckle_' .. math.random(1, 4)]:play() end
                pd.timer.performAfterDelay(1750, function()
                if save.sfx then assets['laugh_' .. math.random(1, 3)]:play() end
                    vars.misses += 1
                    save.misses += 1
                end)
            end
        end
    end
end

function play:hit(button, index)
    if vars.in_progress then
        vars.anim_person = pd.timer.new(300, 7, 8.9)
        if mode ~= "oneshot" then
            vars.pause:pause()
            vars.pause:remove()
            vars.pause = pd.timer.new(4000 + (1000 * math.random()), function() self:pause_callback() end)
        end
        assets.honk:setRate(1 + ((math.random() / 2) - 0.5))
        if save.sfx then assets.honk:play() end
        vars.show_hint = false
        if vars.button_text_string ~= '' then
            vars.button_text_string = vars.button_text_string .. ', '
        end
        if button == 3 then
            vars.button_text_string = vars.button_text_string .. 'L'
        elseif button == 4 then
            vars.button_text_string = vars.button_text_string .. 'R'
        elseif button == 1 then
            vars.button_text_string = vars.button_text_string .. 'U'
        elseif button == 2 then
            vars.button_text_string = vars.button_text_string .. 'D'
        elseif button == 6 then
            vars.button_text_string = vars.button_text_string .. 'B'
        elseif button == 5 then
            vars.button_text_string = vars.button_text_string .. 'A'
        elseif button == 7 then
            vars.button_text_string = vars.button_text_string .. 'C'
        elseif button == 8 then
            vars.button_text_string = vars.button_text_string .. 'W'
        elseif button == 9 then
            vars.button_text_string = vars.button_text_string .. '['
        elseif button == 10 then
            vars.button_text_string = vars.button_text_string .. ']'
        elseif button == 11 then
            vars.button_text_string = vars.button_text_string .. 'S'
        elseif button == 12 then
            vars.button_text_string = vars.button_text_string .. 'M'
        end
    end
end

function play:miss(button, index)
    if vars.in_progress then
        vars.misses += 1
        save.misses += 1
        if mode ~= "oneshot" then
            vars.pause:pause()
            vars.pause:remove()
        end
        if mode == "oneshot" or vars.misses >= 3 then
            self:lose()
        else
            vars.anim_person = pd.timer.new(1, 13, 14.9)
            if save.sfx then assets.cough:play() end
        end
        if vars.button_text_string ~= '' then
            vars.button_text_string = vars.button_text_string .. ', '
        end
        if button == 3 then
            vars.button_text_string = vars.button_text_string .. 'l'
        elseif button == 4 then
            vars.button_text_string = vars.button_text_string .. 'r'
        elseif button == 1 then
            vars.button_text_string = vars.button_text_string .. 'u'
        elseif button == 2 then
            vars.button_text_string = vars.button_text_string .. 'd'
        elseif button == 6 then
            vars.button_text_string = vars.button_text_string .. 'b'
        elseif button == 5 then
            vars.button_text_string = vars.button_text_string .. 'a'
        elseif button == 7 then
            vars.button_text_string = vars.button_text_string .. 'c'
        elseif button == 8 then
            vars.button_text_string = vars.button_text_string .. 'w'
        elseif button == 9 then
            vars.button_text_string = vars.button_text_string .. '{'
        elseif button == 10 then
            vars.button_text_string = vars.button_text_string .. '}'
        elseif button == 11 then
            vars.button_text_string = vars.button_text_string .. 's'
        elseif button == 12 then
            vars.button_text_string = vars.button_text_string .. 'm'
        end
    end
end

function play:addrose()
    vars.roses += 1
    self['rose_' .. vars.roses] = play_rose()
end

function play:win()
    vars.shaker:setEnabled(false)
    pd.stopAccelerometer()
    pd.sound.micinput.stopListening()
    if vars.in_progress then
        vars.in_progress = false
        if mode == "multi" then
            p1 = not p1
        else
            vars.score += 1
        end
        vars.anim_person = pd.timer.new(750, 15, 18.9)
        vars.anim_person.repeats = true
        if save.sfx then
            if vars.misses <= 1 then
                assets['applause_' .. math.random(1, 3)]:play()
            else
                assets.light_applause:play()
            end
        end
        pd.timer.performAfterDelay(500 + (500 * math.random()), function() self:addrose() end)
        pd.timer.performAfterDelay(1000 + (500 * math.random()), function() self:addrose() end)
        pd.timer.performAfterDelay(2000 + (500 * math.random()), function() self:addrose() end)
        pd.timer.performAfterDelay(3000, function()
            fademusic()
            scenemanager:transitionscene(rehearsal, vars.score, vars.button_string)
        end)
    end
end

function play:lose()
    vars.shaker:setEnabled(false)
    pd.stopAccelerometer()
    pd.sound.micinput.stopListening()
    if vars.in_progress then
        vars.in_progress = false
        if save.sfx then assets.scratch:play() end
        vars.anim_person = pd.timer.new(500, 19, 20.9)
        vars.anim_person.repeats = true
        if save.sfx then assets.crowd_angry:play() end
        fademusic(500)
        pd.timer.performAfterDelay(500, function()
            vars.spotlight = false
            if save.sfx then assets.spotlight:play() end
            if save.sfx then assets.cane:play() end
            vars.anim_person = pd.timer.new(500, 21, 22.9)
            vars.anim_person.repeats = true
            vars.anim_cane = pd.timer.new(900, -253, -106, pd.easingFunctions.outBack)
        end)
        pd.timer.performAfterDelay(1300, function()
            vars.anim_cane = pd.timer.new(250, -106, -253)
        end)
        pd.timer.performAfterDelay(1300, function()
            if save.sfx then assets.whoosh:play() end
            vars.button_text_string = ''
            vars.anim_person = pd.timer.new(500, 23, 27)
        end)
        pd.timer.performAfterDelay(2000, function()
            if mode == "multi" then
                scenemanager:transitionscene(results)
            else
                scenemanager:transitionscene(fail, vars.score)
            end
        end)
    end
end

function play:button(released)
    if vars.in_progress then
        if vars.button_string[vars.button_index] == released then
            self:hit(released, vars.button_index)
            vars.button_index += 1
            if vars.button_index > #vars.button_string then
                self:win()
            end
        else
            self:miss(released, vars.button_index)
        end
    end
end

function play:update()
    vars.shaker:update()
    if save.crank then
        vars.crank = pd.getCrankChange()
        vars.totalcrank += math.floor(vars.crank)
        if math.floor(vars.crank) == 0 then
            vars.totalcrank = 0
        end
        if vars.totalcrank >= 230 then
            play:button(7)
            vars.totalcrank = 0
        elseif vars.totalcrank <= -230 then
            play:button(8)
            vars.totalcrank = 0
        end
    end
    if save.mic then
        if vars.mic_cooldown then
            vars.mic = 0
        else
            vars.mic = pd.sound.micinput.getLevel()
        end
        if vars.mic > 0.2 then
            play:button(12)
            vars.mic_cooldown = true
            pd.timer.performAfterDelay(750, function()
                vars.mic_cooldown = false
            end)
        end
    end
end