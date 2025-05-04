class("IdleState").extends(GroundState)

function IdleState:on_enter()
    IdleState.super.on_enter(self)
    self.player.x_velocity = 0
    self.player.y_velocity = 0
end

function IdleState:update()
    --TODO: There may be a bug here if the GroundState update changed to the jump state, it should be fine but just in case
    if self.player.input_handler.x_v ~= 0 then
        self.sm:run()
        return
    else
        self.player.x_velocity = 0
    end

    IdleState.super.update(self)
end