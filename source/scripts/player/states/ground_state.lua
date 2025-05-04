class("GroundState").extends(PlayerState)

function GroundState:on_enter()
    self.player.times_jumped = 0
    GroundState.super.on_enter(self)

end

function GroundState:update()
    GroundState.super.update(self)
    if self.player.input_handler:jump_pressed() and self.player.max_jumps > 0 then
        self.sm:jump()
    end
end