local gfx <const> = playdate.graphics
local ldtk <const> = LDtk

local usePrecompiledLevels = not playdate.simulator

ldtk.load("levels/world.ldtk", usePrecompiledLevels)

class("GameScene").extends()
local font = gfx.font.new('fonts/font-pixieval')

function GameScene:init()
    self.event_handler = EventHandler()
    self.event_handler:subscribe('ability_picked_up', self, self.player_ability_pickup)
    self.camera = PlayerCamera()
    self:goToLevel("Level_0")
    self.player = Player(self.spawn_x, self.spawn_y + 16, self)
    self.camera.x = self.spawn_x
    self.camera.y = self.spawn_y
    self.moving = false
    -- self.camera:add_scroll_event('0', self.camera.x, self.camera.y, self.camera.x, self.camera.y, 1)

    -- self.camera:add_scroll_event('1', self.camera.x, self.camera.y, 1250, self.camera.y, 1)
    -- self.camera:add_scroll_event('2', 1250, self.camera.y, 1250, 392, 1)
    -- self.camera:add_scroll_event('3', 1250, 392, 465, 392, 2)
    -- self.camera:add_scroll_event('4', 465, 392, 465, 570, .75)
    -- self.camera:add_scroll_event('5', 465, 570, 110, 570, 1)
    -- self.camera:add_scroll_event('6', 110, 570, 110, 570, 2)


    -- self.camera:add_scroll_event('7', 465, 570, self.player.x, self.player.y, 0.5, function () self.player:unfreeze() end, self)


    -- self.player:freeze()
    -- self.camera:play_scroll_events()

end

function GameScene:update()
    gfx.setFont(font)
    self.camera:update()

    self.camera.target_x = self.player.x
    self.camera.target_y = self.player.y
    
    self.player_world_point = {x= self.player.x + self.level_rect.x, y = self.player.y + self.level_rect.y}

    if not math.pointInRect(self.player_world_point, self.level_rect) then
        self:move_room()
    end
end

function GameScene:move_room()
    if self.moving then
        return
    end

    local direction = 'east'
    if(self.player.x > self.level_rect.width) then
        direction = 'east'
    elseif(self.player.y > self.level_rect.height) then
        direction = 'south'
    elseif(self.player.y < 0) then
        direction = 'north'
    elseif(self.player.x < 0) then
        direction = 'west'
    end

    local neighbours = ldtk.get_neighbours(self.level_name, direction)
    if not neighbours then
        return
    end

    for i=1, #neighbours, 1 do
        local name = neighbours[i]
        local rect = ldtk.get_rect(name)
        
        if math.pointInRect(self.player_world_point, rect) then
            self.moving = true
            self.player:freeze()

            local fade = LevelTransitionFade()
            fade:fade_out(function (self, rect, name, fade) 

                self.spawn_x, self.spawn_y = self:convert_world_point_to_local(self.player_world_point, rect)
                self.camera:set_position(self.spawn_x, self.spawn_y)
                self:goToLevel(name)
                self.player:add()
                self.player:moveTo(self.spawn_x, self.spawn_y)
                self.player:unfreeze()
                fade:add() -- We have to add the fade back in, as it gets removed when we call gotolevel
                fade:fade_in(function (self, fade) 
                    fade:remove() 
                    self.moving = false
                end, {self, fade})

                
            end, {self, rect, name, fade})
        end
    end
end

function GameScene:resetPlayer()
    self.player:moveTo(self.spawn_x, self.spawn_y)
    self.player:unfreeze()
end

function GameScene:convert_world_point_to_local(point, world_rect)
    return point.x - world_rect.x, point.y - world_rect.y
end

function GameScene:getPlayer() 
    return self.player
end

function GameScene:goToLevel(level_name)
    gfx.sprite.removeAll()
    self.level_name = level_name
    self.level_rect = ldtk.get_rect(level_name)

    self.camera:set_level_bounds(self.level_rect.width, self.level_rect.height)

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
            layerSprite:setUpdatesEnabled(false)
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
        local entity_x, entity_y = entity.position.x, entity.position.y
        local entity_name = entity.name

        if entity_name == "Spike" then 
            Spike(entity_x, entity_y)
        elseif entity_name == "Spikeball" then
            Spikeball(entity_x, entity_y, entity)
        elseif entity_name == "Ability" then
            Ability(entity_x, entity_y, entity, self)
        elseif entity_name == "SpawnPoint" then
            if not self.spawn_x then
                self.spawn_x = entity_x
                self.spawn_y = entity_y
            end
        end
    end
end 

function GameScene:player_ability_pickup(event, name)
    self.player:freeze()
    self.pickupBox = ItemPickupDialog('Acquired ' .. name .. ' Ability!', function (self)
        self.player:unfreeze()
        self.pickupBox:remove()
    end, {self})
end
