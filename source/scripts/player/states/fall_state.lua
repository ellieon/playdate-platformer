class('FallState').extends(AirState)

function FallState:on_enter()
    if self.player.times_jumped < 0 then
        self.player.times_jumped = 1
    end
end