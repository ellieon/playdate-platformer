local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry
local pd <const> = playdate

local delta_time <const> = 1.0 / pd.display.getRefreshRate()
local SCREEN_HEIGHT <const> = pd.display.getHeight()
local SCREEN_WIDTH <const> = pd.display.getWidth()

local font_height <const> = gfx.getSystemFont():getHeight()

class('ItemPickupDialog').extends(gfx.sprite)

function ItemPickupDialog:init(text, close_callback, callback_params)
    ItemPickupDialog.super.init(self)
    self.timeline = Timeline()
    self.timeline:addRange("box",0, 0.15)
    self.timeline:appendRange("text", 0.7)
    self.text = text
    self.max_width = 300
    self.max_height = 100
    self.button_timer = -0.5;
    self.button_radius = font_height / 2;
    self.close_callback = close_callback
    self.callback_params = callback_params
    self:moveTo(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
    self:setZIndex(1000)
    self:add()
end

function ItemPickupDialog:update()
    ItemPickupDialog.super.update(self)

    self.timeline:update(delta_time)

    local box_progress = self.timeline:getRangeProgress('box')
    local text_progress = self.timeline:getRangeProgress('text')
    local fill_width = self.max_width * math.max(box_progress, 0.01)
    local fill_height = self.max_height * math.max(box_progress, 0.01)
    local image = gfx.image.new(fill_width, fill_height)

    gfx.pushContext(image)
        self:draw_box(fill_width, fill_height)
        self:draw_text(self.timeline:getRangeProgress('text'), fill_width, fill_height)

        if(text_progress == 1) then
            self:draw_button(fill_width, fill_height, delta_time)

            if pd.buttonJustPressed(pd.kButtonA) then
                self:remove()
                self.close_callback(table.unpack(self.callback_params))
            end
        end
    gfx.popContext()
    self:setImage(image)
end


function ItemPickupDialog:draw_box(fill_width, fill_height)
    gfx.setColor(gfx.kColorBlack)
    gfx.setDitherPattern(0.1, gfx.image.kDitherTypeBayer8x8)
    gfx.fillRoundRect(0, 0, fill_width, fill_height, 5)
    gfx.setColor(gfx.kColorWhite)
    gfx.drawRoundRect(0, 0, fill_width, fill_height, 5)
    
end

function ItemPickupDialog:draw_text(progress, fill_width, fill_height)
    local sub_string = string.sub(self.text, 1, math.floor(#self.text * (progress)))

    if #sub_string > 0 then
        gfx.setImageDrawMode(gfx.kDrawModeNXOR)
		gfx.setFont(gfx.getFont("bold"))
		gfx.drawTextAligned(sub_string, fill_width / 2, (fill_height / 2) - font_height / 2, kTextAlignment.center)
    end
end

function ItemPickupDialog:draw_button(fill_width, fill_height, delta_time)
    if self.button_timer >= 0 then
        gfx.fillCircleAtPoint(fill_width / 2, fill_height - self.button_radius * 2, self.button_radius)
        gfx.drawTextAligned('A', fill_width / 2, fill_height - self.button_radius - font_height, kTextAlignment.center)
    end

    if self.button_timer > 1 then
        self.button_timer = -0.5
    end

    self.button_timer += delta_time
end
