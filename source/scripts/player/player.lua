local pd <const> = playdate
local gfx <const> = playdate.graphics

class("Player").extends(Actor)

function Player:init(x, y, game_manager)
    self.game_manager = game_manager

    local playerImageTable = gfx.imagetable.new("images/player-table-96-96.png")
    Player.super.init(self, playerImageTable)

    -- Player attributes
    self.x_acceleration = 450
    self.max_speed = 150
    self.x_turn_acceleration = 2000
    self.x_run_deceleration = 450

    self.initial_jump_velocity = -550
    self.jump_min_time = 0
    self.jump_max_time = 0.4

    self.gravity = 900
    self.air_x_friction = 100
    self.minimum_air_speed = 15
    self.terminal_velocity = 500
    self.coyote_time =  7 * DELTA_TIME -- 7 frames of coyote time

    self.dash_frames = 20 * DELTA_TIME
    self.dash_speed = 300

    self.max_jumps = 1
    self.dash_unlocked = true

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

    self:addState("idle", 1, 10,{tickStep = 8})
    self:addState("run", 11, 18, {tickStep = 8})
    self:addState("jump", 21, 26, {tickStep = 8})
    self:addState("fall", 26, 26, {tickStep = 8})
    self:addState("dash", 31, 35)
    self:addState("freeze", 4, 4)
    self.currentState = 'idle'

    self:playAnimation()
    self:moveTo(x,y)
    self:setZIndex(Z_INDEXES.Player)
    self:setTag(TAGS.Player)
    self:setCollideRect(38, 42, 17, 49)

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
    self.sm:update(DELTA_TIME)
    self:handleMovementAndCollisions()
    self.sm:after_move()
    self:changeState(self.sm.active_state)
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

    self.y_velocity += self.gravity * DELTA_TIME

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