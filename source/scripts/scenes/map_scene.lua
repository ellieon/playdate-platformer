local gfx <const> = playdate.graphics
local pd <const> = playdate
local ldtk <const> = LDtk

local usePrecompiledLevels = not playdate.simulator

ldtk.load("levels/world.ldtk", usePrecompiledLevels)

local MINIMUM_MAP_SCALE <const> = 0.05
local _ = {}

class('MapScene').extends(Scene)
function MapScene:init() 
    MapScene.super.init(self)
    self.world_rect = _.determine_map_size()
    self:construct_map_image()
    self:generate_ui_frame()
    self.x = 0
    self.y = 0
    self.scale = 1

end

function MapScene:update()
    MapScene.super.update(self)
    if pd.buttonIsPressed(pd.kButtonLeft) then
        self.x += 5
    end
    if pd.buttonIsPressed(pd.kButtonRight)  then
        self.x -= 5
    end
    if pd.buttonIsPressed(pd.kButtonUp) then
        self.y += 5
    end
    if pd.buttonIsPressed(pd.kButtonDown)  then
        self.y -= 5
    end

    if pd.buttonIsPressed(pd.kButtonA) then
        self.scale += 0.1
    end

    if pd.buttonIsPressed(pd.kButtonB) then
        self.scale -= 0.1
        if self.scale < 0.5 then
            self.scale = 0.5
        end
    end
    self.map_sprite:moveTo(self.x, self.y)
    self.map_sprite:setScale(self.scale, self.scale)
end

function _.determine_map_size() 
    --Move this as part of LDtk importer to save performance
    local rects = ldtk.get_level_rects()
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

    self.map_image = gfx.image.new(self.world_rect.width * self.scale, self.world_rect.height * self.scale)
    gfx.setBackgroundColor(gfx.kColorBlack)
    gfx.pushContext(self.map_image)
        gfx.setDrawOffset(-self.world_rect.x * self.scale,-self.world_rect.y * self.scale)
        gfx.fillRect(self.world_rect.x, self.world_rect.y, self.world_rect.width, self.world_rect.height)
        gfx.setColor(gfx.kColorWhite)
        local rects = ldtk.get_level_rects()
        for _, r in pairs(rects) do
            gfx.setColor(gfx.kColorWhite)
            local x, y, width, height = r.x * scale, r.y * self.scale, r.width * scale, r.height * scale
            gfx.fillRect(x, y, width, height)
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(x + 2, y + 2, width - 4, height - 4)
        end
    gfx.popContext()
    playdate.datastore.writeImage(self.map_image, 'map.gif')

    self.map_sprite = gfx.sprite.new(self.map_image)
    self.map_sprite:add()
    self.map_sprite:setCenter(0,0)
    self.map_sprite:moveTo(0,0)
    self.map_sprite:setZIndex(9998)
  
end

function MapScene:generate_ui_frame()
    local width, height = pd.display.getWidth(), pd.display.getHeight()
    self.map_frame = gfx.image.new(width, height)
    playdate.datastore.writeImage(self.map_image, 'map.gif')

    gfx.pushContext(self.map_frame)
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

    self.ui_sprite = gfx.sprite.new(self.map_frame)
    self.ui_sprite:setIgnoresDrawOffset(true)
    self.ui_sprite:add()
    self.ui_sprite:setCenter(0,0)
    self.ui_sprite:moveTo(0,0)
    self.ui_sprite:setZIndex(9999)
end