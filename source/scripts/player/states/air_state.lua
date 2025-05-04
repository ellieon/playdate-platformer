class("AirState").extends(PlayerState)

function AirState:init(player)
    AirState.super.init(self, player)
    self.last_flip = self.player.globalFlip
end


function AirState:on_enter()
    AirState.super.on_enter(self)
    self.last_flip = self.player.globalFlip
end

function AirState:update(delta_time)
    AirState.super.update(self, delta_time)

    if self.player.input_handler.dash and self.player.dash_unlocked and self.player.dash_available then
        self.sm:dash()
        return
    end

    local x_acceleration = self.player.x_acceleration

    if self.player.globalFlip ~= self.last_flip then
        x_acceleration *= 4
    end

    if math.abs(self.player.x_velocity) <= self.player.max_speed then
        if self.player.input_handler.x_v > 0 then
            self.player.x_velocity += x_acceleration
        elseif self.player.input_handler.x_v < 0 then
            self.player.x_velocity -= x_acceleration
        end
    end

    if self.player.times_jumped < self.player.max_jumps and self.player.input_handler:jump_pressed() then
        self.sm:double_jump()
        return
    end


    -- Add drag to slow down player
    if self.player.x_velocity > 0 then
        self.player.x_velocity -= self.player.air_x_friction
    elseif self.player.x_velocity < 0 then
        self.player.x_velocity += self.player.air_x_friction
    end

    -- if drag has taken player below minimum speed, clamp them to minimum
    if self.player.x_velocity ~= 0 and (math.abs(self.player.x_velocity) < self.player.minimum_air_speed) then
        if self.player.x_velocity < 0 then
            self.player.x_velocity += self.player.air_x_friction
        else
            self.player.x_velocity -= self.player.air_x_friction
        end
    end
end


function AirState:after_move()
    if self.player.touching_ground then
        self.sm:land()
        return true
    end

    if self.player.touching_wall then
        self.player.x_velocity = 0
    end
end