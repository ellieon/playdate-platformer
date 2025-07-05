class("GroundState").extends(PlayerState)

function GroundState:on_enter()
    GroundState.super.on_enter(self)
    self.player.times_jumped = 0
    self.player.dash_available = true
end

function GroundState:update(delta_time)
    GroundState.super.update(self, delta_time)
    if self.player.input_handler:jump_pressed() and self.player.times_jumped < self.player.max_jumps then
        self.sm:jump()
        return true
    end

    --Not decided on if dash will be allowed from ground, or if it will be a slide instead
    if self.player.input_handler.dash and self.player.dash_unlocked and self.player.dash_available then
         self.sm:dash()
         return true
    end
end

function GroundState:after_move()
    GroundState.super.after_move(self)
    if not self.player.touching_ground then
        self.sm:fall()
    end
    
end