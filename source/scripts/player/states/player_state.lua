class("PlayerState").extends(State)

function PlayerState:init(player)
    PlayerState.super.init(self)
    self.player = player
end

function PlayerState:update(delta_time)
    PlayerState.super.update(self, delta_time)
end