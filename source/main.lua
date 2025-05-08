import "init"

local pd <const> = playdate
local gfx <const> = playdate.graphics

local menu_scene = MenuScene()
SCENE_MANAGER.scenes = {menu_scene}

gfx.setBackgroundColor(gfx.kColorBlack)

function pd.update()
    SCENE_MANAGER:update()

    gfx.sprite.update()
    pd.timer.updateTimers()
end