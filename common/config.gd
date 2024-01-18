extends Node

# Game phases
const CAPITOL_SELECT = "capitol_select"
const UPKEEP = "upkeep"
const MAIN_PHASE = "main_phase"

# Game actions
const IDLE_ACTION = "idle"
const GATHER_RESOURCES = "gather_resources"
const CLEANUP = "cleanup"
const DEPLOY_ARMY = "deploy"
const ARMY_ACTION = "army"

# Tile Map data
const PLAINS_COORDS = Vector2i(6, 0)
const LIGHT_MTN_COORDS = Vector2i(6, 1)
const FOREST_COORDS = Vector2i(6, 2)
const COASTAL_COORDS = [Vector2i(6, 3), Vector2i(6, 4), Vector2i(6, 5), Vector2i(6, 6), Vector2i(6, 7), Vector2i(6, 8)]
const RIVER_COORDS = [Vector2i(7, 1), Vector2i(7, 2), Vector2i(7, 3)]
const HEAVY_MTN_COORDS = Vector2i(7, 0)
const SEA_COORDS = Vector2i(7, 5)

const BASE_TILE_LAYER = 0
const BASE_TILE_SET_ID = 0
const UPGRADED_TILE_SET_ID = 1
const RIVER_TILE_LAYER = 5
var VALID_CAPITOL_COORDS = [PLAINS_COORDS, FOREST_COORDS] + COASTAL_COORDS + RIVER_COORDS
var VALID_ARMY_MOVE_COORDS = [PLAINS_COORDS, FOREST_COORDS, LIGHT_MTN_COORDS] + COASTAL_COORDS + RIVER_COORDS

const ADJACENT_TILE_VECTORS = [Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT]

# Colors
const SELECTED_COLOR = Color("fac150")
const COLOR_MAP = {
	"red": {
		"primary": "d50000",
		"shadow": "912d26"
	},
	"white": {
		"primary": "ededed",
		"shadow": "bcbcbc"
	},
	"blue": {
		"primary": "38c8cf",
		"shadow": "299095"
	},
	"purple": {
		"primary": "7d66dd",
		"shadow": "6351af"
	}
}

# Outlines
const O = 7.5
const X = 8.0

const TOP_FRIENDLY_ONLY = [Vector2(O, -X), Vector2(O, O), Vector2(-O, O), Vector2(-O, -X)]
const RIGHT_FRIENDLY_ONLY = [Vector2(X, O), Vector2(-O, O), Vector2(-O, -O), Vector2(X, -O)]
const BOT_FRIENDLY_ONLY = [Vector2(-O, X), Vector2(-O, -O), Vector2(O, -O), Vector2(O, X)]
const LEFT_FRIENDLY_ONLY = [Vector2(-X, -O), Vector2(O, -O), Vector2(O, O), Vector2(-X, O)]

const BOT_LEFT_FRIENDLY = [Vector2(-X, -O), Vector2(O, -O), Vector2(O, X)]
const TOP_LEFT_FRIENDLY = [Vector2(O, -X), Vector2(O, O), Vector2(-X, O)]
const TOP_RIGHT_FRIENDLY = [Vector2(X, O), Vector2(-O, O), Vector2(-O, -X)]
const BOT_RIGHT_FRIENDLY = [Vector2(-O, X), Vector2(-O, -O), Vector2(X, -O)]

const TOP_NOT_FRIENDLY = [Vector2(-X, -O), Vector2(X, -O)]
const RIGHT_NOT_FRIENDLY = [Vector2(O, -X), Vector2(O, X)]
const BOT_NOT_FRIENDLY = [Vector2(X, O), Vector2(-X, O)]
const LEFT_NOT_FRIENDLY = [Vector2(-O, X), Vector2(-O, -X)]

const NO_FIRENDLY = [Vector2(O, -O), Vector2(O, O), Vector2(-O, O), Vector2(-O, -O), Vector2(O, -O), Vector2(O, O)]
