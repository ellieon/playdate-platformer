class("PlayerInputHandler").extends()

local pd <const> = playdate

function PlayerInputHandler:init(player)
    self.x_v = 0
    self.y_v = 0
    self.jump_buffer = 0
    self.player = player

    self.player.sm:subscribe('jump', EVENT_TYPE.STATE_ENTER, self.reset_jump_buffer)
end

function PlayerInputHandler:update()
    self.x_v = 0
    self.y_v = 0

    if pd.buttonIsPressed(pd.kButtonRight) then
        self.x_v = 1
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
        self.x_v = -1
    end

    self.jump_buffer -= 1

    if self.jump_buffer <= 0 then
        self.jump_buffer = 0
    end
    
    if pd.buttonJustPressed(pd.kButtonA) then
        self.jump_buffer = 5
    end
    
end
function PlayerInputHandler:reset_jump_buffer()
    print('reset_jump_buffer')
    self.jump_buffer = 0
end


function PlayerInputHandler:jump_pressed()
    return self.jump_buffer > 0
end
