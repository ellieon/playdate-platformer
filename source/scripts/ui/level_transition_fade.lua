local gfx <const> = playdate.graphics
local pd <const> = playdate

local SCREEN_HEIGHT <const> = pd.display.getHeight()
local SCREEN_WIDTH <const> = pd.display.getWidth()

class('LevelTransitionFade').extends(gfx.sprite)

function LevelTransitionFade:init()
    LevelTransitionFade.super.init(self)
    self.fade_direction = 0
    self.alpha = 1;
    self.speed = 10;
    self:moveTo(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
    self:setIgnoresDrawOffset(true)
    self:setZIndex(Z_INDEXES.UI)
    self:add()
end

function LevelTransitionFade:fade_out(callback, context)
    self.fade_direction = -1
    self.alpha = 1
    self.callback = callback
    self.callback_context = context
end

function LevelTransitionFade:fade_in(callback, context)
    self.fade_direction = 1
    self.alpha = 0
    self.callback = callback
    self.callback_context = context
end

function LevelTransitionFade:update()
    LevelTransitionFade.super.update(self)
    if self.fade_direction == 0 then
        return
    end

    self.alpha = math.clamp(DELTA_TIME * self.fade_direction * self.speed + self.alpha, 0, 1)
    local image = gfx.image.new(playdate.display.getWidth(), playdate.display.getHeight())

    gfx.pushContext(image)
        gfx.setDrawOffset(0,0)
        gfx.setColor(gfx.kColorBlack)
        gfx.setDitherPattern(self.alpha, gfx.image.kDitherTypeBayer8x8)
        gfx.fillRect(0, 0, playdate.display.getWidth(), playdate.display.getHeight())
    gfx.popContext()
    self:setImage(image)

    if self.alpha == 1 or self.alpha == 0 then
        self.fade_direction = 0
        if self.callback then
            self.callback(table.unpack(self.callback_context))
        end
    end
end