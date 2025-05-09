import "init"

local pd <const> = playdate
local gfx <const> = playdate.graphics

if not playdate.simulator then
    local menu_scene = MenuScene()
    SCENE_MANAGER.scenes = {menu_scene}
else
    local game_scene = GameScene()
    SCENE_MANAGER.scenes = {game_scene}
    game_scene:on_focus()
end

gfx.setBackgroundColor(gfx.kColorBlack)

function pd.update()
    pd.timer.updateTimers()
    SCENE_MANAGER:update()
    gfx.sprite.update()
end