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

function FallState:update()
    FallState.super.update(self)
    if self.coyote_time > 0 then
        self.coyote_time -= 1
    end
end

function FallState:after_move()
    FallState.super.after_move(self)
    if self.coyote_time <= 0 and self.player.times_jumped < 1 then
        self.player.times_jumped = 1
    end
end
