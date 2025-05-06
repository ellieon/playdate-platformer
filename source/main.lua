import "init"

local pd <const> = playdate
local gfx <const> = playdate.graphics

--local game_scene = GameScene()
local map_scene = MapScene()

function pd.update()
    gfx.sprite.update()
    gfx.setBackgroundColor(gfx.kColorBlack)
    map_scene:update()
    --game_scene:update()       
    pd.timer.updateTimers()
end