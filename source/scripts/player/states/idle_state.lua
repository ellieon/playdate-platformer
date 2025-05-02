class("IdleState").extends(PlayerState)

function IdleState:update()
    IdleState.super.update(self)

    if self.player.input_handler:jump_pressed() then
        self.sm:jump()
    elseif self.player.input_handler.x_v ~= 0 then
        self.sm:run()
    else
        self.player.x_velocity = 0 
    end
end