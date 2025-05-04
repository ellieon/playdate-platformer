import "init"

local pd <const> = playdate
local gfx <const> = playdate.graphics

local game_scene = GameScene()

function pd.update()
    gfx.sprite.update()
    game_scene:update()


    pd.timer.updateTimers()
end