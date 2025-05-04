-- Playdate core libraries
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- External libraries
import "scripts/libraries/AnimatedSprite"
import "scripts/libraries/LDtk"

-- Game files
import "scripts/game_scene"

import "util/math"

import "scripts/actor"
import "scripts/spike"
import "scripts/spikeball"
import "scripts/ability"


    -- State machine
    import "scripts/state_machine/state"
    import "scripts/state_machine/state_machine"        
    -- Player
    import "scripts/player/player"
    import "scripts/player/player_input_handler"
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