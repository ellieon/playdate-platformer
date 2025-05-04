class("GroundState").extends(PlayerState)

function GroundState:on_enter()
    self.player.times_jumped = 0
    self.player.dash_available = true
    GroundState.super.on_enter(self)

end

function GroundState:update(delta_time)
    GroundState.super.update(self, delta_time)
    if self.player.input_handler:jump_pressed() and self.player.times_jumped < self.player.max_jumps then
        self.sm:jump()
        return true
    end

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