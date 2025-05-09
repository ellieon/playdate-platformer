local gfx <const> = playdate.graphics
local pd <const> = playdate

local MINIMUM_MAP_SCALE <const> = 0.05
local _ = {}

class('MapSceneInputHandler').extends()
function MapSceneInputHandler:init()
    self.x_v = 0
    self.y_v = 0
    self.b_pressed = false
end

function MapSceneInputHandler:update()
    self.x_v = 0
    self.y_v = 0
    if pd.buttonIsPressed(pd.kButtonLeft) then
        self.x_v = 1
    end
    if pd.buttonIsPressed(pd.kButtonRight)  then
        self.x_v = -1
    end
    if pd.buttonIsPressed(pd.kButtonUp) then
        self.y_v = 1
    end
    if pd.buttonIsPressed(pd.kButtonDown)  then
        self.y_v = -1
    end

    if pd.buttonJustPressed(pd.kButtonB) then
        self.b_pressed = true
        return
    else
        self.b_pressed = false
    end
end


class('MapScene').extends(Scene)
function MapScene:init() 
    MapScene.super.init(self)
    self.input_handler = MapSceneInputHandler()
    self.world_rect = _.determine_map_size()
    self.map_sprite = self:construct_map_image()
    self.ui_sprite = self:generate_ui_frame()
    self.x = 0
    self.y = 0
    self.scale = 1
end

function MapScene:update()
    MapScene.super.update(self)
    
    self.x += self.input_handler.x_v * 5
    self.y += self.input_handler.y_v * 5

    if self.input_handler.b_pressed then
        SCENE_MANAGER:pop_scene()
        return
    end

    self.map_sprite:moveTo(self.x, self.y)
    self.map_sprite:setScale(self.scale, self.scale)
end

function _.determine_map_size() 
    --Move this as part of LDtk importer to save performance
    local rects = LDTK.get_level_rects()
    local min_x, min_y, max_x, max_y = 0, 0, 0, 0
    for _, r in pairs(rects) do
        min_x = math.min(min_x, r.x)
        min_y = math.min(min_y, r.y)
        max_x = math.max(max_x, r.x + r.width)
        max_y = math.max(max_y, r.y + r.height)
    end

    return {x = min_x, y = min_y, width = max_x - min_x, height = max_y - min_y}
end

function MapScene:construct_map_image()
    self.scale = playdate.display.getWidth() / self.world_rect.width
    self.scale = math.max(playdate.display.getHeight() / self.world_rect.height, self.scale)
    
    local scale = math.max(self.scale, self.scale)

    local map_image = gfx.image.new(self.world_rect.width * self.scale, self.world_rect.height * self.scale)
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.pushContext(map_image)
        gfx.setDrawOffset(-self.world_rect.x * self.scale,-self.world_rect.y * self.scale)
        gfx.fillRect(self.world_rect.x, self.world_rect.y, self.world_rect.width, self.world_rect.height)
        gfx.setColor(gfx.kColorWhite)
        local rects = LDTK.get_level_rects()
        for _, r in pairs(rects) do
            gfx.setColor(gfx.kColorWhite)
            local x, y, width, height = r.x * scale, r.y * self.scale, r.width * scale, r.height * scale
            gfx.fillRect(x, y, width, height)
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(x + 2, y + 2, width - 4, height - 4)
        end
    gfx.popContext()

    local map_sprite = gfx.sprite.new(map_image)
    map_sprite:add()
    map_sprite:setIgnoresDrawOffset(true)
    map_sprite:setCenter(0,0)
    map_sprite:moveTo(0,0)
    map_sprite:setZIndex(9998)

    return map_sprite
end

function MapScene:generate_ui_frame()
    local width, height = pd.display.getWidth(), pd.display.getHeight()
    local map_frame = gfx.image.new(width, height)

    gfx.pushContext(map_frame)
        gfx.setLineWidth(10)
     
        --Draw thick black border
        gfx.drawRect(0,0, width, height)
        gfx.setLineWidth(2)
        gfx.setColor(gfx.kColorWhite)
        --Draw thin white border around the edge
        gfx.drawRoundRect(1, 1, width-2,height-2,3)
        --Draw another thinner white border just inside the last
        gfx.drawRect(6,6,width - 12, height -12)

        --Draw a box in the top center screen for the title
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(200-30, 6, 60, 30)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawRoundRect(200-30, 6, 60, 30, 3)
        gfx.setImageDrawMode(gfx.kDrawModeNXOR)
        gfx.setFont(gfx.getFont("bold"))
		gfx.drawTextAligned('MAP', 200, 14, kTextAlignment.center)

        --Draw a box in the bottom right for controls
        gfx.setColor(gfx.kColorBlack)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        gfx.fillRect(311, 201, 80, 30)
        gfx.setColor(gfx.kColorWhite)
        gfx.drawRoundRect(311, 201, 80, 30, 3)
    gfx.popContext()

    local ui_sprite = gfx.sprite.new(map_frame)
    ui_sprite:setIgnoresDrawOffset(true)
    ui_sprite:add()
    ui_sprite:setCenter(0,0)
    ui_sprite:moveTo(0,0)
    ui_sprite:setZIndex(9999)

    return ui_sprite
end

function MapScene:get_scene_name()
    return "Map"
end

function MapScene:get_input_handler()
    MapScene.super.get_input_handler(self)

    return self.input_handler
end