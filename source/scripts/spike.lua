local gfx <const> = playdate.graphics

local spikeImage <const> = gfx.image.new("images/spike")

class("Spike").extends(Actor)

function Spike:init(x, y)
    Spike.super.init(self)
    self:setZIndex(Z_INDEXES.Hazard)
    self:setImage(spikeImage)
    self:setCenter(0, 0)
    self:moveTo(x,y)
    self:add()

    self:setTag(TAGS.Hazard)
    self:setCollideRect(3, 22, 28, 10)
end
