local pd <const> = playdate
local gfx <const> = pd.graphics
local smp <const> = pd.sound.sampleplayer

local curtains = gfx.imagetable.new('images/curtains')
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
    self.transitioning = false
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
    local transitiontimer = self:transition(1, 13)
    transitiontimer.timerEndedCallback = function()
        self:loadnewscene()
        transitiontimer = self:transition(14, 24)
        transitiontimer.timerEndedCallback = function()
            self.transitioning = false
            self.sprite_curtains:remove()
        end
    end
end

function scenemanager:transition(curtains_start, curtains_end)
    self.sprite_curtains = self:curtains()
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
    local curtains_timer = pd.timer.new(self.transitiontime, curtains_start, curtains_end)
    curtains_timer.updateCallback = function(timer) self.sprite_curtains:setImage(curtains[math.floor(timer.value)]) end
    return curtains_timer
end

function scenemanager:curtains()
    local loading = gfx.sprite.new()
    if self.sprite_curtains then
        loading:setImage(self.sprite_curtains:getImage())
    else
        loading:setImage(curtains[1])
    end
    loading:setZIndex(26000)
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