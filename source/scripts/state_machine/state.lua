class("State").extends(Object)

function State:init() end

function State:on_enter() end

function State:on_exit() end

function State:update(delta_time) end

function State:after_move() end

function State:set_state_machine(sm)
    self.sm = sm
end