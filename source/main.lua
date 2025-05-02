import "init"

local pd <const> = playdate
local gfx <const> = playdate.graphics

local gameScene = GameScene()

function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
end