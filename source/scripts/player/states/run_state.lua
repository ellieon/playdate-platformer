class("RunState").extends(PlayerState)

function RunState:update()
    
    RunState.super.update(self)

    if self.player.input_handler:jump_pressed() then
        self.sm:jump()
    elseif self.player.input_handler.x_v > 0 then
        self.player.x_velocity = self.player.maxSpeed
    elseif self.player.input_handler.x_v < 0 then
        self.player.x_velocity = -self.player.maxSpeed
    else
        self.sm:idle()
    end
end