local gfx <const> = playdate.graphics
class('SceneManager').extends()

function SceneManager:init()
    self.transition_time = 1000
    self.scenes = {}
    self.sprite_cache = {}
end

function SceneManager:update()
    local scene = self:get_current_scene()
    local input_handler = scene:get_input_handler()
    if input_handler then
        input_handler:update()
    end
    self.scenes[#self.scenes]:update() 
end

function SceneManager:push_scene(scene)
    self.new_scene = scene
    self:start_transition_to(true)
end

function SceneManager:switch_scene(scene) 
    self.new_scene = scene
    self:start_transition_to(false)
end

function SceneManager:pop_scene()
    self:start_pop_transition()
end

function SceneManager:start_transition_to(push)
    local timer = self:wipe_transition(0, 400)

    timer.timerEndedCallback = function()
        self:load_new_scene(push)
        timer = self:wipe_transition(400, 0)
        timer.timerEndedCallback = function () 
            self.sprite:remove()
        end
    end
end

function SceneManager:start_pop_transition()
    local timer = self:wipe_transition(0, 400)

    timer.timerEndedCallback = function()
        self:pop_current_scene()

        timer = self:wipe_transition(400, 0)
        timer.timerEndedCallback = function () 
            self.sprite:remove()
        end
    end
end

function SceneManager:load_new_scene(push)
    local scene = self:get_current_scene()
    if push and scene then
        self.sprite:remove()
        self.sprite_cache[scene:get_scene_name()] = gfx.sprite.getAllSprites()
    end
    
    if scene then
        scene:on_lose_focus()
    end

    gfx.sprite.removeAll()
    gfx.setDrawOffset(0,0)
    local scene = self.new_scene()
    scene:on_focus()
    if push then
        self.scenes[#self.scenes+1] = scene
    else 
        self.scenes = {scene}
    end
end

function SceneManager:pop_current_scene()
     self.scenes[#self.scenes]:on_lose_focus()
     table.remove(self.scenes, #self.scenes)
     gfx.sprite.removeAll()

     local current_scene = self:get_current_scene()
     local scene_name = current_scene:get_scene_name()

     for _, sprite in pairs(self.sprite_cache[scene_name]) do
         sprite:add()
     end

     self.sprite_cache[scene_name] = nil
     self:get_current_scene()
     current_scene:on_focus()
end

function SceneManager:wipe_transition(start_value, end_value)
    self.sprite = self:create_transition_sprite()
    self.sprite:setClipRect(0, 0, start_value, 240)

    local timer = playdate.timer.new(self.transition_time, start_value,
        end_value, playdate.easingFunctions.inOutCubic)
    
    timer.updateCallback = function(timer)
        self.sprite:setClipRect(0,0, timer.value, 240)
    end
    return timer
end

function SceneManager:create_transition_sprite()
    local rect_image = gfx.image.new('images/swipe-image')
    local sprite = gfx.sprite.new(rect_image)
    sprite:moveTo(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
    sprite:setZIndex(Z_INDEXES.Transition_Effect)
    sprite:setIgnoresDrawOffset(true)
    sprite:add()
    return sprite
end

function SceneManager:get_current_scene()
    return self.scenes[#self.scenes]
end