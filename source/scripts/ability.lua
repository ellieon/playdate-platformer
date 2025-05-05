local gfx <const> = playdate.graphics

class("Ability").extends(gfx.sprite)

function Ability:init(x, y, entity, game_scene)
    self.fields = entity.fields
    if self.fields.pickedUp == true then
        return
    end

    self.abilityName = self.fields.ability

    local ability_image = gfx.image.new("images/" ..self.abilityName)
    assert(ability_image)
    
    self:setImage(ability_image)
    self:setZIndex(Z_INDEXES.Pickup)
    self:setCenter(0 ,0)
    self:moveTo(x,y)
    self:add()

    self:setTag(TAGS.Pickup)
    self:setCollideRect(0, 0, self:getSize())

    self.notifications = game_scene.event_handler
end

function Ability:pickUp(player)
    if self.abilityName == "Jump" then
        player.max_jumps = 1
    end
    if self.abilityName == "DoubleJump" then 
        player.max_jumps = 2
    elseif self.abilityName == "Dash" then
        player.dash_unlocked    = true
    end
    self.fields.pickedUp = true

    self.notifications:notify('ability_picked_up', self.abilityName)
    self:remove()
end