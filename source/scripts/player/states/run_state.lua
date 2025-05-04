class("RunState").extends(GroundState)

function RunState:init(player)
    RunState.super.init(self, player)

    self.last_flip = 1
end

function RunState:on_enter()
    RunState.super.on_enter(self)
    self.last_flip = self.player.globalFlip
end

function RunState:update()
    
    RunState.super.update(self)

    local x_acceleration = self.player.x_acceleration

    if (self.player.globalFlip == 1 and self.player.input_handler.x_v > 0) or (self.player.globalFlip == 0 and self.player.input_handler.x_v < 0) then
        x_acceleration = self.player.x_turn_acceleration
    end

    if self.player.input_handler.x_v > 0 then
        self.player.x_velocity += x_acceleration
        if self.player.x_velocity > self.player.max_speed then
            self.player.x_velocity = self.player.max_speed
        end
    elseif self.player.input_handler.x_v < 0 then
        self.player.x_velocity -= x_acceleration
        if math.abs(self.player.x_velocity) > self.player.max_speed then
            self.player.x_velocity = -(self.player.max_speed)
        end
    elseif math.abs(self.player.x_velocity) > self.player.x_run_deceleration then
        if self.player.x_velocity > 0 then
            self.player.x_velocity -= self.player.x_run_deceleration
        elseif self.player.x_velocity < 0 then
            self.player.x_velocity += self.player.x_run_deceleration
        end
    else
        self.sm:idle()
    end

    self.last_flip = self.player.globalFlip
end

function RunState:after_move()

end