local gfx <const> = playdate.graphics

class("GameScene").extends()

function GameScene:init()
    self.event_handler = EventHandler()
    self.event_handler:subscribe('ability_picked_up', self, self.player_ability_pickup)
    self.camera = PlayerCamera()
    self:goToLevel("Level_0", true)
    self.player = Player(self.spawn_x, self.spawn_y + 16, self)
    self.camera.x = self.spawn_x
    self.camera.y = self.spawn_y
    self.moving = false
end

function GameScene:on_focus()
    self.mapMenuItem = playdate.getSystemMenu():addMenuItem('Map',  function ()
        SCENE_MANAGER:push_scene(MapScene)
    end)

    if not self.mainMenuItem then
        self.mainMenuItem = playdate.getSystemMenu():addMenuItem('Menu', function ()
            playdate.getSystemMenu():removeAllMenuItems()
            SCENE_MANAGER:switch_scene(MenuScene)
        end)
    end
end

function GameScene:on_lose_focus()
    playdate.getSystemMenu():removeMenuItem(self.mapMenuItem)
end

function GameScene:update()
    self.camera:update()

    self.camera.target_x = self.player.x
    self.camera.target_y = self.player.y + 40
    
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

    local neighbours = LDTK.get_neighbours(self.level_name, direction)
    if not neighbours then
        return
    end

    for i=1, #neighbours, 1 do
        local name = neighbours[i]
        local rect = LDTK.get_rect(name)
        
        if math.pointInRect(self.player_world_point, rect) then
            self.moving = true
            self.player:freeze()

            local fade = LevelTransitionFade()
            fade:fade_out(function (self, rect, name, fade) 

                self.spawn_x, self.spawn_y = self:convert_world_point_to_local(self.player_world_point, rect)
                self.camera:set_position(self.spawn_x, self.spawn_y)
                self:goToLevel(name, true)
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

function GameScene:goToLevel(level_name, spawn_entities)
    gfx.sprite.removeAll()
    self.level_name = level_name
    self.level_rect = LDTK.get_rect(level_name)

    self.camera:set_level_bounds(self.level_rect.width, self.level_rect.height)

    self:loadTilemap(level_name)
    if spawn_entities then
        self:loadEntities(level_name)
    end
end

function GameScene:loadTilemap(level_name)
    local layers = LDTK.get_layers(level_name)
    assert(layers)
    for layer_name, layer in pairs(layers) do
        if layer.tiles then
            local tilemap = LDTK.create_tilemap(level_name, layer_name)

            local layerSprite = gfx.sprite.new()
            assert(tilemap)
            layerSprite:setTilemap(tilemap)
            layerSprite:moveTo(0, 0)
            layerSprite:setCenter(0, 0)
            layerSprite:setZIndex(layer.zIndex)
            layerSprite:setUpdatesEnabled(false)
            layerSprite:add()

            local emptyTiles = LDTK.get_empty_tileIDs(level_name, "Solid", layer_name)

            if emptyTiles then
                gfx.sprite.addWallSprites(tilemap, emptyTiles)
            end
        end
    end
end

function GameScene:loadEntities(level_name)
    local entities = LDTK.get_entities(level_name)

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

function GameScene:get_scene_name()
    return "Game"
end

function GameScene:get_input_handler()
    return self.player.input_handler
end