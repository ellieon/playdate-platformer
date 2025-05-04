class("IdleState").extends(GroundState)

function IdleState:on_enter()
    IdleState.super.on_enter(self)
    self.player.x_velocity = 0
    self.player.y_velocity = 0
end

function IdleState:update(delta_time)
     if IdleState.super.update(self, delta_time) then
        return true
     end

    if self.player.input_handler.x_v ~= 0 then
        self.sm:run()
        return
    else
        self.player.x_velocity = 0
    end


end