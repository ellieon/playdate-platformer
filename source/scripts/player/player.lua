local pd <const> = playdate
local gfx <const> = playdate.graphics

class("Player").extends(AnimatedSprite)

function Player:init(x, y, game_manager)
    self.game_manager = game_manager

    local playerImageTable = gfx.imagetable.new("images/kiwi-test-table-32-32")
    Player.super.init(self, playerImageTable)

    -- Player attributes

    self.x_acceleration = 15
    self.max_speed = 120
    self.x_turn_acceleration = 45
    self.x_run_deceleration = 15

    self.jump_velocity = -420
    self.initial_jump_velocity = -330
    self.jump_acceleration = -90

    self.gravity = 45
    self.air_x_friction = 3
    self.minimum_air_speed = 15
    self.terminal_velocity = 500
    self.coyote_time =  7 * DELTA_TIME -- 7 frames of coyote time

    self.dash_frames = 5 * DELTA_TIME
    self.dash_speed = 300

    self.max_jumps = 1
    self.dash_unlocked = false
    -- Player state

    self.x_velocity = 0
    self.y_velocity = 0
    self.times_jumped = 0
    self.dash_available = true;

    self.touching_ground = false
    self.touching_ceiling = false
    self.touching_wall = false
    self.dead = false
    self.disable_gravity = false

    self:addState("idle", 1, 1)
    self:addState("run", 1, 4, {tickStep = 5})
    self:addState("jump", 4, 4)
    self:addState("fall", 4, 4)
    self:addState("dash", 4, 4)
    self:addState("freeze", 4, 4)
    self.currentState = 'idle'

    self:playAnimation()
    self:moveTo(x,y)
    self:setZIndex(Z_INDEXES.Player)
    self:setTag(TAGS.Player)
    self:setCollideRect(8, 11, 16, 21)

    self.sm = StateMachine()

    self.sm:add_state(IdleState(self), 'idle')
    self.sm:add_state(RunState(self), 'run')
    self.sm:add_state(JumpState(self), 'jump')
    self.sm:add_state(DashState(self), 'dash')
    self.sm:add_state(FallState(self), 'fall')
    self.sm:add_state(FreezeState(self), 'freeze')

    self.sm:set_initial_state('jump')

    self.sm:add_transition('idle', '*', 'idle')
    self.sm:add_transition('run', {'idle'}, 'run')
    self.sm:add_transition('jump', {'dash', 'idle', 'run'}, 'jump')
    self.sm:add_transition('double_jump', {'fall', 'jump'}, 'jump')
    self.sm:add_transition('dash', {'idle', 'run', 'jump', 'fall'}, 'dash')
    self.sm:add_transition('air_dash_end', {'dash'}, 'jump')
    self.sm:add_transition('land', {'fall'}, 'run')
    self.sm:add_transition('fall', {'idle', 'run', 'jump', 'dash'}, 'fall')
    self.sm:add_transition('freeze', '*', 'freeze')
    self.sm:add_transition('unfreeze', {'freeze'}, 'fall')

    self.input_handler = PlayerInputHandler(self)
end

function Player:update()
    Player.super.update(self)
    
    self.input_handler:update()
    self.sm:update(DELTA_TIME)
    self:handleMovementAndCollisions()
    self.sm:after_move()
    --self.currentState = self.sm.active_state
    self:changeState(self.sm.active_state)
    --self:updateAnimation()

end


function Player:handleMovementAndCollisions()
    self:apply_gravity()

    local target_x = self.x + (self.x_velocity * DELTA_TIME)
    local target_y = self.y + (self.y_velocity * DELTA_TIME)

    local actualX, actualY, collisions, length = self:moveWithCollisions(target_x, target_y) 

    self.x = actualX
    self.y = actualY
 
    self.touching_ground = false
    self.touching_ceiling = false
    self.touching_wall = false
 
    local died = false
 
    for i=1, length do
         local collision = collisions[i]
         local collisionType = collision.type
         local collisionObject = collision.other
         local collisionTag = collisionObject:getTag()
 
         if collisionType == gfx.sprite.kCollisionTypeSlide then
 
             if collision.normal.y == -1 then
                 self.touching_ground = true
             elseif collision.normal.y == 1 then
                 self.touching_ceiling = true
             end
 
             if collision.normal.x ~= 0 then
                 self.touching_wall = true
             end
         end
         
         if collisionTag == TAGS.Hazard then
             died = true
         elseif collisionTag == TAGS.Pickup then
             collisionObject:pickUp(self)
         end
     end
 
     if self.x_velocity < 0 then
         self.globalFlip = 1
     elseif  self.x_velocity > 0 then
         self.globalFlip = 0
     end
 
    --  if self.x < 0 then
    --      self.game_manager:enterRoom("west")
    --  elseif self.x > 400 then
    --      self.game_manager:enterRoom("east")
    --  elseif self.y < 0 then
    --      self.game_manager:enterRoom("north")
    --  elseif self.y > 240 then
    --      self.game_manager:enterRoom("south")
    --  end
 
     if died then
         self:freeze()
         pd.timer.performAfterDelay(200, function()
            self:setCollisionsEnabled(true)
            self.game_manager:resetPlayer()
        end)
     end
 end

 function Player:apply_gravity()
    if self.disable_gravity then
        return
    end

    if self.touching_ceiling then
        self.y_velocity = 0
        return
    end

    if self.touching_ground then
        self.y_velocity = 1
        return
    end

    self.y_velocity += self.gravity

    if(self.y_velocity > self.terminal_velocity) then
        self.y_velocity = self.terminal_velocity
    end
end

function Player:collisionResponse(other)
    local tag = other.getTag
    if tag == TAGS.Hazard or tag == TAGS.Pickup then
        return gfx.sprite.kCollisionTypeOverlap
    end
    return gfx.sprite.kCollisionTypeSlide
end

function Player:freeze()
    self.sm:freeze()
end

function Player:unfreeze()
    self.sm:unfreeze()
end