local pd <const> = playdate
local gfx <const> = pd.graphics

local SCREEN_WIDTH <const> = pd.display.getWidth()
local SCREEN_HEIGHT <const> = pd.display.getHeight()

local X_OFFSET <const> = SCREEN_WIDTH / 2
local Y_OFFSET <const> = SCREEN_HEIGHT / 2

class('PlayerCamera').extends()

function PlayerCamera:init()
    PlayerCamera.super.init(self)

    self.x = 0
    self.y = 0

    self.target_x = 1
    self.target_y = 1

    self.level_width = playdate.display.getWidth()
    self.level_height = playdate.display.getHeight()

    self.speed = 30
    
    self.timeline = Timeline()
    self.timeline:setPaused(true)

    self.events = {}
end

function PlayerCamera:update()
    self.timeline:update(DELTA_TIME)

    if not self.timeline:isPaused() and not self.timeline:isAtEnd() then
        local ranges = self.timeline:getCurrentRanges()
        local event_name = table.first(ranges).name
        if event_name then
            local event = self.events[event_name]
            local current_time = self.timeline:getRangeProgress(event_name)
            self.x = math.linearScaleBetween(current_time, event.start_x, event.target_x, 0.0, 1.0)
            self.y = math.linearScaleBetween(current_time, event.start_y, event.target_y, 0.0, 1.0)
        end
    else
        self.x = self.target_x
        self.y = self.target_y
    end

    if self.x < X_OFFSET then self.x = X_OFFSET end 
    if self.y < Y_OFFSET then self.y = Y_OFFSET end
    if self.x > self.level_width - X_OFFSET then self.x = self.level_width - X_OFFSET end
    if self.y > self.level_height - Y_OFFSET then self.y = self.level_height - Y_OFFSET end

    gfx.setDrawOffset(-self.x + X_OFFSET, -self.y + Y_OFFSET)

end

function PlayerCamera:set_position(x, y)
    self.x = x
    self.y = y
    self.target_x = x
    self.target_y = y
    gfx.setDrawOffset(-self.x + X_OFFSET, -self.y + Y_OFFSET)
end

-- Set the bounds of the camera so the view will stay within
function PlayerCamera:set_level_bounds(width, height)
    self.level_width = math.max(width, playdate.display.getWidth())
    self.level_height = math.max(height, playdate.display.getHeight())
end

function PlayerCamera:add_scroll_event(name, start_x, start_y, target_x, target_y, time, callback, callback_context)
    self.events[name] = {start_x = start_x, start_y = start_y, target_x = target_x, target_y = target_y, time = time}
    self.timeline:appendRange(name, time, callback, callback_context)
end

function PlayerCamera:play_scroll_events()
    self.timeline:gotoBeginning(0)
    self.timeline:setPaused(false)
end

function PlayerCamera:stop_scroll_events()
    self.timeline:setPaused(true)
end

function PlayerCamera:clear_scroll_events()
    self.timeline:reset()
    self.events = {}
end