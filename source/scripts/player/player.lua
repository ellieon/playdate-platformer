local pd <const> = playdate
local gfx <const> = playdate.graphics

class("Player").extends(AnimatedSprite)


function Player:init(x, y, gameScene)
    self.gameScene = gameScene

    local playerImageTable = gfx.imagetable.new("images/player-table-32-32")
    Player.super.init(self, playerImageTable)

    self.x_velocity = 0
    self.y_velocity = 0
    self.gravity = 1.5
    self.max_speed = 4.0
    self.jump_velocity = -14
    self.initial_jump_velocity = -11
    self.jump_acceleration = -3
    self.coyote_time = 3
    self.air_x_friction = 0.2
    self.minimum_air_speed = 0.5
    self.terminal_velocity = 100
    self.currentState = 'idle'
    self.x_acceleration = 0.5
    self.x_turn_acceleration = 1.5
    self.x_run_deceleration = 0.5

    self.times_jumped = 0
    self.max_jumps = 1
    self.dash_unlocked = false
    self.dashSpeed = 12
    self.dashMinimumSpeed = 3
    self.dashDrag = 0.8

    self.touching_ground = false
    self.touching_ceiling = false
    self.touching_wall = false
    self.dead = false

    self:addState("idle", 1, 1)
    self:addState("run", 1, 3, {tickStep = 4})
    self:addState("jump", 4, 4)
    self:addState("fall", 4, 4)
    self:addState("dash", 4, 4)
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

    self.sm:set_initial_state('jump')

    self.sm:add_transition('idle', '*', 'idle')
    self.sm:add_transition('run', {'idle'}, 'run')
    self.sm:add_transition('jump', {'idle', 'run'}, 'jump')
    self.sm:add_transition('double_jump', {'fall', 'jump', 'dash'}, 'jump')
    self.sm:add_transition('dash', {'idle', 'run', 'jump'}, 'dash')
    self.sm:add_transition('air_dash_end', {'dash'}, 'jump')
    self.sm:add_transition('land', {'fall'}, 'run')
    self.sm:add_transition('fall', {'run', 'jump', 'dash'}, 'fall')

    self.input_handler = PlayerInputHandler(self)
end

function Player:update()
    Player.super.update(self)
    -- if self.dead then
    --     return
    -- end
    
    self.input_handler:update()
    self.sm:update()

    self:handleMovementAndCollisions()

    self.sm:after_move()

    self.currentState = self.sm.active_state
    self:updateAnimation()

    
end


function Player:handleMovementAndCollisions()
    
    self:apply_gravity()

    local _, _, collisions, length = self:moveWithCollisions(self.x + self.x_velocity, self.y + self.y_velocity) 
 
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
                 self.doubleJumpAvailable = true
                 self.dashAvailable = true
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
 
     if self.x < 0 then
         self.gameScene:enterRoom("west")
     elseif self.x > 400 then
         self.gameScene:enterRoom("east")
     elseif self.y < 0 then
         self.gameScene:enterRoom("north")
     elseif self.y > 240 then
         self.gameScene:enterRoom("south")
     end
 
     if died then
         --self:die()
     end
 end

 function Player:apply_gravity()
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




-- function Player:handleGroundInput()
-- if pd.buttonJustPressed(pd.kButtonB) and self.dashAvailable and self.dash_unlocked then
--         self:changeToDashState()
--         self.sm:dash()
--     end
-- end

-- function Player:handleAirInput()
--     if self:playerJumped() and self.double_jump and self.doubleJumpAvailable then
--         self.doubleJumpAvailable = false
--         self:changeToJumpState()
--     elseif pd.buttonJustPressed(pd.kButtonB) and self.dashAvailable and self.dash_unlocked then
--         self:changeToDashState()
-- end



-- function Player:die()
--     self.x_velocity = 0
--     self.y_velocity = 0
--     self.dead = true
--     self:setCollisionsEnabled(false)
--     pd.timer.performAfterDelay(200, function()
--         self:setCollisionsEnabled(true)
--         self.dead = false
--         self.gameScene:resetPlayer()
--     end)
-- end

-- function Player:changeToDashState()
--     self.dashAvailable = false
--     self.y_velocity = .2

--     if pd.buttonIsPressed(pd.kButtonLeft) then
--         self.x_velocity = -self.dashSpeed
--     elseif pd.buttonIsPressed(pd.kButtonRight) then
--         self.x_velocity = self.dashSpeed
--     else
--         if self.globalFlip == 1 then
--             self.x_velocity = -self.dashSpeed
--         else
--             self.x_velocity = self.dashSpeed
--         end
--     end
--     self:changeState("dash")
-- end


-- function Player:handleState()
--     if self.currentState == "jump" then
--         if self.touching_ground then
--             self:changeToIdleState()
--         end
--         self:applyGravity()
--         self:applyDrag(self.drag)
--         self:handleAirInput()
--     elseif self.currentState == "dash" then
--         self:applyGravity(0.3)
--         self:applyDrag(self.dashDrag)
--         if math.abs(self.x_velocity) <= self.dashMinimumSpeed or self.touching_wall then
--             self:changeToFallState()
--         end
--     end
-- end

