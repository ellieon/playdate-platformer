class("PlayerInputHandler").extends()

local pd <const> = playdate

function PlayerInputHandler:init(player)
    self.x_v = 0
    self.y_v = 0
    self.jump_held = false
    self.dash = false
    self.jump_buffer = 0
    self.player = player
    
    --Self needs to be passed through on the callback, mechanism to do this doesnt exist
    --self.player.sm:subscribe('jump', EVENT_TYPE.STATE_ENTER, self.reset_jump_buffer, {self})
end

function PlayerInputHandler:update()
    self.x_v = 0
    self.y_v = 0

    if pd.buttonIsPressed(pd.kButtonRight) then
        self.x_v = 1
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
        self.x_v = -1
    end

    if(pd.buttonIsPressed(pd.kButtonA)) then
        self.jump_held = true
    else
        self.jump_held = false
    end

    self.jump_buffer -= DELTA_TIME

    if self.jump_buffer <= 0 then
        self.jump_buffer = 0
    end
    
    if pd.buttonJustPressed(pd.kButtonA) then
        self.jump_buffer = 3 * DELTA_TIME --3 Frame jump buffer
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        self.dash = true
    else 
        self.dash = false
    end
    
end
function PlayerInputHandler:reset_jump_buffer()
    self.jump_buffer = 0
end

function PlayerInputHandler:jump_pressed()
    return self.jump_buffer > 0
end