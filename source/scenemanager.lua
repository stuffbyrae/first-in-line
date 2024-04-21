local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer

local image_curtain_left = gfx.image.new('images/curtain_left')
local image_curtain_right = gfx.image.new('images/curtain_right')
local curtain1 = smp.new('audio/sfx/curtain1')
local curtain2 = smp.new('audio/sfx/curtain2')
local curtain3 = smp.new('audio/sfx/curtain3')
local curtain4 = smp.new('audio/sfx/curtain4')

class('scenemanager').extends()

function scenemanager:init()
    self.transitiontime = 750
    self.transitioning = false
end

function scenemanager:switchscene(scene, ...)
    self.newscene = scene
    self.sceneargs = {...}
    -- Pop any rogue input handlers, leaving the default one.
    local inputsize = #playdate.inputHandlers - 1
    for i = 1, inputsize do
        pd.inputHandlers.pop()
    end
    self:loadnewscene()
end

function scenemanager:transitionscene(scene, ...)
    if self.transitioning then return end
    -- Pop any rogue input handlers, leaving the default one.
    local inputsize = #playdate.inputHandlers - 1
    for i = 1, inputsize do
        pd.inputHandlers.pop()
    end
    self.transitioning = true
    self.newscene = scene
    self.sceneargs = {...}
    local transitiontimer = self:transition(-230, 0, 400, 170, pd.easingFunctions.outSine)
    transitiontimer.timerEndedCallback = function()
        self:loadnewscene()
        transitiontimer = self:transition(0, -230, 170, 400, pd.easingFunctions.inSine)
        transitiontimer.timerEndedCallback = function()
            self.transitioning = false
            self.sprite_curtain_left:remove()
            self.sprite_curtain_right:remove()
        end
    end
end

function scenemanager:transition(curtain_left_start, curtain_left_end, curtain_right_start, curtain_right_end, ease)
    self.sprite_curtain_left = self:curtain_left()
    self.sprite_curtain_right = self:curtain_right()
    self.sprite_curtain_left:moveTo(curtain_left_start, 0)
    self.sprite_curtain_right:moveTo(curtain_right_start, 0)
    local sfx_rand = math.random(1, 4)
    if sfx_rand == 1 then
        curtain1:play()
    elseif sfx_rand == 2 then
        curtain2:play()
    elseif sfx_rand == 3 then
        curtain3:play()
    elseif sfx_rand == 4 then
        curtain4:play()
    end
    local curtain_left_timer = pd.timer.new(self.transitiontime, curtain_left_start, curtain_left_end, ease)
    local curtain_right_timer = pd.timer.new(self.transitiontime, curtain_right_start, curtain_right_end, ease)
    curtain_left_timer.updateCallback = function(timer) self.sprite_curtain_left:moveTo(math.floor(timer.value / 2) * 2, 0) end
    curtain_right_timer.updateCallback = function(timer) self.sprite_curtain_right:moveTo(math.floor(timer.value / 2) * 2, 0) end
    return curtain_left_timer
end

function scenemanager:curtain_left()
    local loading = gfx.sprite.new(image_curtain_left)
    loading:setZIndex(26000)
    loading:moveTo(0, 0)
    loading:setCenter(0, 0)
    loading:setIgnoresDrawOffset(true)
    loading:add()
    return loading
end

function scenemanager:curtain_right()
    local loading = gfx.sprite.new(image_curtain_right)
    loading:setZIndex(25999)
    loading:moveTo(0, 0)
    loading:setCenter(0, 0)
    loading:setIgnoresDrawOffset(true)
    loading:add()
    return loading
end

function scenemanager:loadnewscene()
    self:cleanupscene()
    self.newscene(table.unpack(self.sceneargs))
end

function scenemanager:cleanupscene()
    assets = nil -- Nil all the assets,
    vars = nil -- and nil all the variables.
    gfx.sprite.performOnAllSprites(function(sprite)
        sprite:remove()
        sprite = nil
    end)
    self:removealltimers() -- Remove every timer,
    collectgarbage('collect') -- and collect the garbage.
    gfx.setDrawOffset(0, 0) -- Lastly, reset the drawing offset. just in case.
end

function scenemanager:removealltimers()
    local alltimers = pd.timer.allTimers()
    for _, timer in ipairs(alltimers) do
        timer:remove()
        timer = nil
    end
end