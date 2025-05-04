class("JumpState").extends(AirState)

function JumpState:on_enter()
    self.player.times_jumped += 1

    self.player.y_velocity = self.player.initial_jump_velocity
    if self.player.y_velocity < self.player.jump_velocity then
        self.player.y_velocity = self.player.jump_velocity
    end

    self.player.touching_ground = false
    self.player.input_handler:reset_jump_buffer()
end

function JumpState:update(delta_time)
    if JumpState.super.update(self, delta_time) then
        return
    end

    if not self.player.input_handler.jump_held then
        self.sm:fall()
        return
    end

    if self.player.input_handler.jump_held and not self.apex_hit then
        self.player.y_velocity += self.player.jump_acceleration
        if self.player.y_velocity < self.player.jump_velocity then
            self.player.y_velocity = self.player.jump_velocity
            self.sm:fall()
            return
        end
    end
end

function JumpState:after_move()
    JumpState.super.after_move(self)
    if self.player.y_velocity > 0 or self.player.touching_ceiling then
        self.sm:fall()
        return
    end
end


function JumpState:on_exit()
end