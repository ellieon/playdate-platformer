class("DashState").extends(PlayerState)

function DashState:on_enter(previous_state)
    DashState.super.on_enter(previous_state)
   
    self.dash_timer = self.player.dash_frames

    if self.player.input_handler.x_v < 0 then
        self.player.x_velocity -=self.player.dash_speed
    elseif self.player.input_handler.x_v > 0 then
        self.player.x_velocity += self.player.dash_speed
    else
        if self.player.globalFlip == 1 then
            self.player.x_velocity = -self.player.dash_speed
        else
            self.player.x_velocity = self.player.dash_speed
        end
    end
end

function DashState:update(delta_time)
    DashState.super.update(self, delta_time)

    if self.player.input_handler:jump_pressed() and self.player.max_jumps > self.player.times_jumped then
        self.sm:jump()
        return
    end

    if self.dash_timer > 0 then
        self.dash_timer -=1
        return
    end
    if self.player.x_velocity > 0 then
        self.player.x_velocity -= self.player.dash_deceleration
    elseif self.player.x_velocity < 0 then
        self.player.x_velocity += self.player.dash_deceleration
    end

    if math.abs(self.player.x_velocity) <= self.player.dash_minumum_speed then
        self.sm:fall()
        return
    end
end

function DashState:after_move()
    if self.player.touching_wall then
        self.sm:fall()
    end
end
