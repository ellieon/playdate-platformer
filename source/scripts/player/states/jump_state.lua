class("JumpState").extends(AirState)

function JumpState:on_enter()
    self.player.y_velocity = self.player.jump_velocity
    self.player.touching_ground = false
end

function JumpState:on_exit()
end