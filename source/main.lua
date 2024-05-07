-- Importing things
import 'CoreLibs/math'
import 'CoreLibs/timer'
import 'CoreLibs/object'
import 'CoreLibs/sprites'
import 'CoreLibs/graphics'
import 'CoreLibs/animation'
import 'scenemanager'
import 'title'
scenemanager = scenemanager()

-- Setting up basic SDK params
local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer
local fle <const> = pd.sound.fileplayer

pd.display.setRefreshRate(30)
gfx.setLineWidth(2)
gfx.setBackgroundColor(gfx.kColorBlack)
pd.setMenuImage(gfx.image.new('images/pause'))

catalog = true
easy = true
-- Save check
function savecheck()
    save = pd.datastore.read()
    if save == nil then save = {} end
    save.score_easy = save.score_easy or 0
    save.score_hard = save.score_hard or save.score or 0
    save.score = nil
    save.hints = save.hints or 0
    save.heckles = save.heckles or 0
    if save.hard == nil then save.hard = false end
    save.plays = save.plays or 0
    save.misses = save.misses or 0
end

-- ... now we run that!
savecheck()

-- Legacy check
if save.score_easy >= 25 then
    save.hard = true
end

function pd.keyPressed(q)
    print('C-C-C-COMBO BREAKER!! Hard mode unlocked!!')
    save.hard = true
end

-- When the game closes...
function pd.gameWillTerminate()
    pd.datastore.write(save)
    if pd.isSimulator ~= 1 then
        local img = gfx.getDisplayImage()
        local sound = smp.new('audio/sfx/launch')
        sound:play()
        local byebye = gfx.imagetable.new('images/byebye')
        local byebyeanim = gfx.animator.new(2200, 1, #byebye)
        gfx.setDrawOffset(0, 0)
        while not byebyeanim:ended() do
            img:draw(0, 0)
            byebye:drawImage(math.floor(byebyeanim:currentValue()), 0, 0)
            pd.display.flush()
        end
    end
end

function pd.deviceWillSleep()
    pd.datastore.write(save)
end

-- Setting up music
music = nil

-- Fades the music out, and trashes it when finished. Should be called alongside a scene change, only if the music is expected to change. Delay can set the delay (in seconds) of the fade
function fademusic(delay)
    delay = delay or 749
    if music ~= nil then
        music:setVolume(0, 0, delay/1000, function()
            music:stop()
            music = nil
        end)
    end
end

-- New music track. This should be called in a scene's init, only if there's no track leading into it. File is a path to an audio file in the PDX. Loop, if true, will loop the audio file. Range will set the loop's starting range.
function newmusic(file, loop, range)
    if music == nil then -- If a music file isn't actively playing...then go ahead and set a new one.
        music = fle.new(file)
        if loop then -- If set to loop, then ... loop it!
            music:setLoopRange(range or 0)
            music:play(0)
        else
            music:play()
            music:setFinishCallback(function()
                music = nil
            end)
        end
    end
end

function pd.timer:resetnew(duration, startValue, endValue, easingFunction)
	self.duration = duration
	self._startValue = startValue
	self._endValue = endValue or 0
	self._easingFunction = easingFunction or pd.easingFunctions.linear
	self._currentTime = 0
	self._lastTime = nil
	self.active = true
	self.hasReversed = false
    self.reverses = false
    self.repeats = false
	self.remainingDelay = self.delay
	self.value = self._startValue
	self._calledOnRepeat = nil
    self.discardOnCompletion = false
    self.paused = false
end

-- This function returns the inputted number, with the ordinal suffix tacked on at the end (as a string)
function ordinal(num)
    local m10 = num % 10 -- This is the number, modulo'd by 10.
    local m100 = num % 100 -- This is the number, modulo'd by 100.
    if m10 == 1 and m100 ~= 11 then -- If the number ends in 1 but NOT 11...
        return tostring(num) .. gfx.getLocalizedText("st") -- add "st" on.
    elseif m10 == 2 and m100 ~= 12 then -- If the number ends in 2 but NOT 12...
        return tostring(num) .. gfx.getLocalizedText("nd") -- add "nd" on,
    elseif m10 == 3 and m100 ~= 13 then -- and if the number ends in 3 but NOT 13...
        return tostring(num) .. gfx.getLocalizedText("rd") -- add "rd" on.
    else -- If all those checks passed us by,
        return tostring(num) .. gfx.getLocalizedText("th") -- then it ends in "th".
    end
end

function backtotitle(acallback, bcallback)
    local image = gfx.image.new(400, 240)
    local sasser = gfx.font.new('fonts/sasser')
    local small = gfx.font.new('fonts/small')
    local click = smp.new('audio/sfx/click')
    gfx.pushContext(image)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(10, 10, 380, 220)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(13, 13, 374, 214)
        sasser:drawTextAligned('Are you sure you wanna quit?', 200, 25, kTextAlignment.center)
        small:drawTextAligned('if you quit now, all the progress in\nthis game will be lost. your\nscore won\'t be saved, and you can\'t\ncome back later. are you sure?', 200, 80, kTextAlignment.center)
        small:drawTextAligned('B - quit to title   A - keep playing', 200, 200, kTextAlignment.center)
    gfx.popContext(image)
    local sprite = gfx.sprite.new(image)
    sprite:setCenter(0, 0)
    sprite:moveTo(0, 0)
    sprite:setZIndex(999)
    sprite:setIgnoresDrawOffset(true)
    sprite:add()
    local backHandlers = {
        AButtonDown = function()
            pd.inputHandlers.pop()
            sprite:remove()
            click:play()
            click = nil
            sprite = nil
            backHandlers = nil
            if acallback ~= nil then
                acallback()
            end
        end,

        BButtonDown = function()
            pd.inputHandlers.pop()
            sprite:remove()
            click:play()
            click = nil
            sprite = nil
            backHandlers = nil
            scenemanager:transitionscene(title)
            if bcallback ~= nil then
                bcallback()
            end
        end,
    }
    pd.inputHandlers.push(backHandlers, true)
    image = nil
    sasser = nil
    small = nil
end

-- This function shakes the screen. int is a number representing intensity. time is a number representing duration
function shakies(time, int)
    if pd.getReduceFlashing() then -- If reduce flashing is enabled, then don't shake.
        return
    end
    anim_shakies = pd.timer.new(time or 500, int or 10, 0, pd.easingFunctions.outElastic)
end

scenemanager:switchscene(title)

function pd.update()
    -- Screen shake update logic
    if anim_shakies ~= nil then
        pd.display.setOffset(anim_shakies.value, 0)
    end
    -- Catch-all stuff ...
    gfx.sprite.update()
    pd.timer.updateTimers()
end