import "init"

local pd <const> = playdate
local gfx <const> = playdate.graphics

local game_scene = GameScene()
--local map_scene = MapScene()
SCENE_MANAGER.scenes = {game_scene}

function pd.update()
    SCENE_MANAGER:update()

    gfx.sprite.update()
    gfx.setBackgroundColor(gfx.kColorBlack)
    pd.timer.updateTimers()
end