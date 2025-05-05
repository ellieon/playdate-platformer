local gfx <const> = playdate.graphics
local ldtk <const> = LDtk

TAGS = {
    Player = 1,
    Hazard = 2,
    Pickup = 3,
}

Z_INDEXES = {
    Player = 100,
    Hazard = 200,
    Pickup = 50,
    UI = 9999
}

local usePrecompiledLevels = not playdate.simulator

ldtk.load("levels/world.ldtk", usePrecompiledLevels)

class("GameScene").extends()
local font = gfx.font.new('fonts/font-pixieval')

function GameScene:init()
    self.event_handler = EventHandler()
    self.event_handler:subscribe('ability_picked_up', self, self.player_ability_pickup)

    self:goToLevel("Level_0")
    self.spawn_x = 12 * 16
    self.spawn_y = 160
    self.player = Player(self.spawn_x, self.spawn_y, self)


    
end

function GameScene:update()
    gfx.setFont(font)
    
    -- gfx.setColor(gfx.kColorBlack)
    -- gfx.fillRect(0, 0,150, 74)
    -- gfx.setColor(gfx.kColorWhite)
    -- gfx.drawText(self.player.currentState, 0, 0, 100, 11)
    -- gfx.drawText('X Vel: '..self.player.x_velocity, 0, 13, 100, 11)
    -- gfx.drawText('Y Vel: '..self.player.y_velocity, 0, 26, 100, 11)
    -- gfx.drawText('Touching Ground '..tostring(self.player.touching_ground), 0, 39, 150, 11)
    -- gfx.drawText('Touching Ceiling '..tostring(self.player.touching_ceiling), 0, 52, 150, 11)
    -- gfx.drawText('Dash Available: '..tostring(self.player.dash_available and self.player.dash_unlocked), 0, 63, 150, 11)

end

function GameScene:resetPlayer()
    self.player:moveTo(self.spawn_x, self.spawn_y)
    self.player:unfreeze()
end

function GameScene:enterRoom(direction)
    local level = ldtk.get_neighbours(self.level_name, direction)[1]
    self:goToLevel(level)
    self.player:add()

    local spawn_x, spawn_y
    if direction == "north" then
        spawn_x, spawn_y = self.player.x, 240
    elseif direction == "south" then
        spawn_x, spawn_y = self.player.x, 0
    elseif direction == "east" then
        spawn_x, spawn_y = 0, self.player.y
    elseif direction == "west" then
        spawn_x, spawn_y = 400, self.player.y
    end
    self.player:moveTo(spawn_x, spawn_y)
    self.spawn_x = spawn_x
    self.spawn_y = spawn_y
end

function GameScene:getPlayer() 
    return self.player
end

function GameScene:goToLevel(level_name)
    gfx.sprite.removeAll()
    self.level_name = level_name


    self:loadTilemap(level_name)
    self:loadEntities(level_name)

end

function GameScene:loadTilemap(level_name)
    local layers = ldtk.get_layers(level_name)
    assert(layers)
    for layer_name, layer in pairs(layers) do
        if layer.tiles then
            local tilemap = ldtk.create_tilemap(level_name, layer_name)

            local layerSprite = gfx.sprite.new()
            assert(tilemap)
            layerSprite:setTilemap(tilemap)
            layerSprite:moveTo(0, 0)
            layerSprite:setCenter(0, 0)
            layerSprite:setZIndex(layer.zIndex)
            layerSprite:add()

            local emptyTiles = ldtk.get_empty_tileIDs(level_name, "Solid", layer_name)

            if emptyTiles then
                gfx.sprite.addWallSprites(tilemap, emptyTiles)
            end
        end
    end
end

function GameScene:loadEntities(level_name)
    local entities = ldtk.get_entities(level_name)
    assert(entities)
    for _, entity in ipairs(entities) do
        local entityX, entityY = entity.position.x, entity.position.y
        local entityName = entity.name

        if entityName == "Spike" then 
            Spike(entityX, entityY)
        elseif entityName == "Spikeball" then
            Spikeball(entityX, entityY, entity)
        elseif entityName == "Ability" then
            Ability(entityX, entityY, entity, self)
        end
    end
end 

function GameScene:player_ability_pickup(event, name)
    print(name)
    self.player:freeze()
    self.pickupBox = ItemPickupDialog('Acquired ' .. name .. ' Ability!', self.unfreeze_player, {self})
end

function GameScene:unfreeze_player()
    self.player:unfreeze()
end
