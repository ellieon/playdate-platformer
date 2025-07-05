class('FallState').extends(AirState)

function FallState:init(player)
    FallState.super.init(self, player)
    self.coyote_time = 0
end

function FallState:on_enter(previous_state)
    FallState.super.on_enter(self, previous_state)

    if previous_state:isa(GroundState) then
        self.coyote_time = self.player.coyote_time
        self.player.times_jumped = 0
    elseif self.player.times_jumped < 1 then
        self.player.times_jumped = 1
    end
end

function FallState:update(delta_time)
    FallState.super.update(self, delta_time)
    if self.coyote_time > 0 then
        self.coyote_time -= delta_time
    end
    
    if self.player.y_velocity < 0 then
        self.player.y_velocity += 50
    end
end

function FallState:after_move()
    if FallState.super.after_move(self) then
        return
    end
    
    if self.coyote_time <= 0 and self.player.times_jumped < 1 then
        self.player.times_jumped = 1
    end
end
