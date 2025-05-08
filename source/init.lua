-- Playdate core libraries
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- External libraries
import "scripts/libraries/AnimatedSprite"
import "scripts/libraries/LDtk"
import "scripts/libraries/timeline"

-- Game files
import "scripts/actor"
import "scripts/spike"
import "scripts/spikeball"
import "scripts/ability"

    --scenes
    import "scripts/scenes/scene"
    import "scripts/scenes/game_scene"
    import "scripts/scenes/map_scene"
    import "scripts/scenes/scene_manager"
    import "scripts/scenes/menu_scene"
    
    --util
    import "scripts/util/math"
    import "scripts/util/event_handler"
    import "scripts/util/table"
    --Ui
    import "scripts/ui/item_pickup_dialog.lua"
    import "scripts/ui/level_transition_fade.lua"
    -- State machine
    import "scripts/state_machine/state"
    import "scripts/state_machine/state_machine"        
    -- Player
    import "scripts/player/player"
    import "scripts/player/player_input_handler"
    import "scripts/player/player_camera"
        -- States
        import "scripts/player/states/player_state"
        import "scripts/player/states/ground_state"
        import "scripts/player/states/air_state"
        import "scripts/player/states/dash_state"
        import "scripts/player/states/fall_state"
        import "scripts/player/states/run_state"
        import "scripts/player/states/idle_state"
        import "scripts/player/states/jump_state"
        import "scripts/player/states/dash_state"
        import "scripts/player/states/freeze_state"


TAGS = {
    Player = 1,
    Hazard = 2,
    Pickup = 3,
}

Z_INDEXES = {
    Player = 100,
    Hazard = 200,
    Pickup = 50,
    UI = 10000,
    Transition_Effect = 20000
}

DELTA_TIME = 1.0 / playdate.display.getRefreshRate()
SCREEN_WIDTH = playdate.display.getWidth()
SCREEN_HEIGHT = playdate.display.getHeight()
SCENE_MANAGER = SceneManager()