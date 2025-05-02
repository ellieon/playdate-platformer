class("AirState").extends(PlayerState)

function AirState:on_enter()
end

function AirState:update()
    AirState.super.update()
    if self.player.input_handler.x_v > 0 then
        self.player.x_velocity = self.player.maxSpeed
    elseif self.player.input_handler.x_v < 0 then
        self.player.x_velocity = -self.player.maxSpeed
    end

    if self.player.touching_ground then
        self.sm:idle()
    end

    if self.player.x_velocity > 0 then
        self.player.x_velocity -= self.player.air_x_friction
    elseif self.player.x_velocity < 0 then
        self.player.x_velocity += self.player.air_x_friction
    end

    if math.abs(self.player.x_velocity) < self.player.minimum_air_speed or self.touching_wall then
        self.player.x_velocity += self.player.air_x_friction
    end
end
