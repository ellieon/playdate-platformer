local gfx <const> = playdate.graphics

local TEXT <const> = 'Press A to Start'
class('MenuScene').extends(Scene)

function MenuScene:init()

    MenuScene.super.init(self)
    self.timeline = Timeline()

    self.timeline:addRange('image', 1.0, 2.0)   
    self.timeline:appendRange('toptext', 0.7)
    self.timeline:appendRange('wait', 1)
    self.timeline:appendRange('offsetleft', 1)

    self.time = 0
    local kiwi_image = gfx.image.new('images/menu/kiwi-128-128-bw')
    self.kiwi_sprite = gfx.sprite.new(kiwi_image)
    self.kiwi_sprite:moveTo(200, -128) --off screen centered
    self.kiwi_sprite:add()

    local top_text_image = gfx.image.new('images/menu/kiwi')
    self.top_sprite = gfx.sprite.new(top_text_image)
    self.top_sprite:moveTo(-80, 65) -- End at 160, 65
    self.top_sprite:add()
    

    local bottom_text_image = gfx.image.new('images/menu/quest')
    self.bottom_sprite = gfx.sprite.new(bottom_text_image)
    self.bottom_sprite:moveTo(500, 180) --End at 220, 180
    self.bottom_sprite:add()

    local text_image = gfx.image.new(gfx.getTextSize(TEXT))
    gfx.pushContext(text_image)
        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawTextAligned(TEXT, 0, 0, gfx.kAlignCenter)
    gfx.popContext()
    self.text_sprite = gfx.sprite.new(text_image)
    self.text_sprite:moveTo(400, 130)
    self.text_sprite:setVisible(false)
    self.text_sprite:add()
end

function MenuScene:update()
    gfx.clear(gfx.kColorBlack)
    MenuScene.super.update(self)
    self.timeline:update(DELTA_TIME)

    self:update_kiwi_image()
    self:update_top_image()
    self:update_bottom_image()

    gfx.setDrawOffset(-75 * self.timeline:getRangeProgress('offsetleft'), 0)

    if self.timeline:isAtEnd() then
        self.text_sprite:setVisible(true)
        if playdate.buttonJustPressed(playdate.kButtonA) then
            SCENE_MANAGER:switch_scene(GameScene)
        end
    end 
end

function MenuScene:update_kiwi_image()
    local progress = self.timeline:getRangeProgress('image')
    local y_pos = playdate.easingFunctions.outBounce(progress, -64, 184, 1)
    self.kiwi_sprite:moveTo(self.kiwi_sprite.x, y_pos)    
end

function MenuScene:update_top_image()
    local progress = self.timeline:getRangeProgress('toptext')
    local x_pos = playdate.easingFunctions.outInCirc(progress, -80, 240, 1)
   -- print(progress)
    self.top_sprite:moveTo(x_pos, self.top_sprite.y)    
end

function MenuScene:update_bottom_image()
    local progress = self.timeline:getRangeProgress('toptext')
    local x_pos = playdate.easingFunctions.outInCirc(progress, 500, -280, 1)
   -- print(progress)
    self.bottom_sprite:moveTo(x_pos, self.bottom_sprite.y)    
end
