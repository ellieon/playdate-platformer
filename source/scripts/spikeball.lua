local gfx <const> = playdate.graphics

local spikeBallImage <const> = gfx.image.new("images/spikeball")

class("Spikeball").extends(gfx.sprite)

function Spikeball:init(x, y, entity)
    self:setZIndex(Z_INDEXES.Hazard)
    self:setImage(spikeBallImage)
    self:setCenter(0, 0)
    self:moveTo(x,y)
    self:add()

    self:setTag(TAGS.Hazard)
    self:setCollideRect(6, 6, 20, 20)

    local fields = entity.fields
    self.xVelocity = fields.xVelocity
    self.yVelocity = fields.yVelocity
end

function Spikeball:collisionResponse(other)
    if other:getTag() == TAGS.Player then
        return gfx.sprite.kCollisionTypeOverlap
    end
    return gfx.sprite.kCollisionTypeBounce
end

function Spikeball:update()
    local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)
    local hitWall = false

    for i=1, length do
        local collision = collisions[i]
        if collision.other:getTag() ~= TAGS.Player then
            if collision.normal.y ~= 0 then
                self.yVelocity *= -1
            elseif  collision.normal.x ~= 0 then
                self.xVelocity *= -1
            end
        end
    end
end
