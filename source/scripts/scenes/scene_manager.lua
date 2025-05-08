local gfx <const> = playdate.graphics
class('SceneManager').extends()

function SceneManager:init()
    self.time = 1000
    self.scenes = {}
end

function SceneManager:update()
    self.scenes[#self.scenes]:update() 
end

function SceneManager:push_scene(scene)
    self.new_scene = scene
    self.push = true
    self:start_transition()
end

function SceneManager:pop_scene(scene)
    self:start_pop_transition()
end

function SceneManager:switch_scene(scene) 
    self.new_scene = scene
    self.push = false
    self:start_transition() 
end

function SceneManager:load_new_scene()
    if not self.push then
        gfx.sprite.removeAll()
    end
    
    gfx.setDrawOffset(0,0)
    local scene = self.new_scene()
    if self.push then
        self.scenes[#self.scenes+1] = scene
    else 
        self.scenes = {scene}
    end
end

function SceneManager:start_transition()
    local timer = self:wipe_transition(0, 400)

    timer.timerEndedCallback = function()
        self:load_new_scene()
        timer = self:wipe_transition(400, 0)
    end
end

function SceneManager:start_pop_transition()
    local timer = self:transition(0, 400)

    timer.timerEndedCallback = function()
        self.scenes[#self.scenes]:on_remove()
        table.remove(self.scenes, #self.scenes)
        timer = self:wipe_transition(400, 0)
    end
end

function SceneManager:wipe_transition(start_value, end_value)
    local sprite = self:create_transition_sprite()
    sprite:setClipRect(0, 0, start_value, 240)

    local timer = playdate.timer.new(self.time, start_value,
        end_value, playdate.easingFunctions.inOutCubic)
    
    timer.updateCallback = function(timer)
        sprite:setClipRect(0,0, timer.value, 240)
    end
    return timer
end

function SceneManager:create_transition_sprite()
    local rect_image = gfx.image.new('images/swipe-image')
    -- local rect_image = gfx.image.new(SCREEN_WIDTH, SCREEN_HEIGHT, gfx.kColorBlack)
    local sprite = gfx.sprite.new(rect_image)
    sprite:moveTo(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
    sprite:setZIndex(Z_INDEXES.Transition_Effect)
    sprite:setIgnoresDrawOffset(true)
    sprite:add()
    return sprite
end