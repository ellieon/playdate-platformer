class('FreezeState').extends(PlayerState)

function FreezeState:init(player)
    FreezeState.super.init(self, player)
    self.entry_x = 0
    self.entry_y = 0
end


function FreezeState:on_enter()
    FreezeState.super.on_enter(self)
    self.entry_x = self.player.x_velocity
    self.entry_y = self.player.y_velocity
    self.player.disable_gravity = true
    self.player.x_velocity = 0
    self.player.y_velocity = 0
end

function FreezeState:on_exit()
    FreezeState.super.on_exit(self)
    self.player.x_velocity = self.entry_x
    self.player.y_velocity = self.entry_y
    self.player.disable_gravity = false
    
end