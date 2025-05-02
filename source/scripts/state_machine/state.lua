class("State").extends(Object)

function State:init() end

function State:on_enter() end

function State:on_exit() end

function State:update() end

function State:set_state_machine(sm)
    self.sm = sm
end