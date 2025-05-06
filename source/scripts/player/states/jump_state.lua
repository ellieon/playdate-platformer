class("JumpState").extends(AirState)

function JumpState:init(player)
    JumpState.super.init(self, player)
    self.jump_time = 0
    self.jump_start_time = 0
end

function JumpState:on_enter()
    JumpState.super.on_enter(self)
    self.player.times_jumped += 1

    self.player.y_velocity = self.player.initial_jump_velocity
    self.jump_time = 0
    self.player.touching_ground = false
end

function JumpState:update(delta_time)
    if JumpState.super.update(self, delta_time) then
        return
    end

    self.jump_time += delta_time
    local min_jump_achieved = (self.jump_time > self.player.jump_min_time) and not self.player.input_handler.jump_held
    local max_jump_achieved = self.jump_time > self.player.jump_max_time

    print(min_jump_achieved or max_jump_achieved)
    if max_jump_achieved or min_jump_achieved then
        self.sm:fall()
        return
    end
end

function JumpState:after_move()
    JumpState.super.after_move(self)
    if self.player.y_velocity > 0 or self.player.touching_ceiling then
        self.sm:fall()
        return
    end
end


function JumpState:on_exit()
end