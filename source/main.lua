import "init"

local pd <const> = playdate
local gfx <const> = playdate.graphics

local game_scene = GameScene()
--local menu_scene = MenuScene()

SCENE_MANAGER.scenes = {game_scene}

game_scene:on_focus();

gfx.setBackgroundColor(gfx.kColorBlack)

function pd.update()
    SCENE_MANAGER:update()

    gfx.sprite.update()
    pd.timer.updateTimers()
end