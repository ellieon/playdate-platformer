EVENT_TYPE = {
  STATE_ENTER = 'Enter',
  STATE_EXIT = 'Exit'
}

class("StateMachine").extends()

function StateMachine:init()
  self.states = {}
  self.active_state = ''
  self.transition_table = {}
  
end

function StateMachine:set_initial_state(initial_state)
  if self.active_state ~= '' then
    return
  end

  self.active_state = initial_state
end

-- @param state State The state to add to the state machine
function StateMachine:add_state(state, name)
  assert(not self.states[state])
  self.states[name] = state
  state:set_state_machine(self)
end

function StateMachine:add_transition(name, from_states, to_state)
  -- Events to be callable functions, for example adding event "jump, ground, jump" will create a function on state
  -- machine called jump, which will transition from state ground to state jump
  -- The from state will check  

  local function transition_callback(self) 
    local valid_state = false

    if from_states == '*' then 
      valid_state = true
    elseif from_states == self.active_state then
    elseif #from_states > 0 then
      for i=1, #from_states do
          if from_states[i] == self.active_state then
            valid_state = true
          end
      end
    end

    if valid_state then
      local current_state = self:get_current_state()
      current_state:on_exit()
      self:alert_subscriber(self.active_state, EVENT_TYPE.STATE_EXIT,
        {from_state = current_state, to_state = self:get_state(to_state), self})
        
      self.active_state = to_state
      self:get_current_state():on_enter()
      self:alert_subscriber(self.active_state, EVENT_TYPE.STATE_ENTER,
        {from_state = current_state, to_state = self:get_state(to_state), self})
      --self:get_current_state():update()
    else
      print('Current state '..self.active_state.. ' not a valid state for event ' ..name)
    end  
  end
  self[name] = transition_callback
end

function StateMachine:alert_subscriber(name, event_type, params)
  local callback = self[name..event_type]
  if callback then
    callback(table.unpack(params))
  end
end

function StateMachine:subscribe(name, event_type, callback)
  assert(self.states[name])
  local eventName = name..event_type
  self[eventName] = callback
end

function StateMachine:update() 
  if self:get_current_state() then
    self:get_current_state():update()
  end
end

function StateMachine:after_move()
  if self:get_current_state() then
    self:get_current_state():after_move()
  end
end

function StateMachine:get_current_state()
  return self.states[self.active_state]
end

function StateMachine:get_state(name)
  return self.states[name]
end