class_name WorldComponent
extends Node2D

@export var tile_map: TileMap
@export var players: Array[PlayerComponent]
@export var game_state: GameStateComponent

func _ready():
	for player in players:
		player.capitol_request.connect(_set_capitol)
	game_state.initialize_game_state(players)

func _set_capitol(tile_coords: Vector2i) -> void:
	for player in players:
		var player_capitol_pos = player.get_capitol_coords()
		if player_capitol_pos == Vector2i(-1, -1):
			continue
		var diff = tile_coords - player.get_capitol_coords()
		if (diff.x < 5 and diff.x > -5) and (diff.y < 5 and diff.y > -5):
			print("Capitol and surrounding area already taken")
			return
	if tile_map.get_cell_atlas_coords(0, tile_coords) not in Config.VALID_CAPITOL_COORDS:
		print("Invalid tile for capitol; must be Plains, Forest, River or Coastal")
		return
	var tile_object = get_tile_from_coords(tile_coords)
	players[game_state.current_turn].set_capitol(tile_object)
	game_state.end_turn()

func get_tile_from_coords(tile_coords: Vector2i) -> TileResource:
	var river_atlas_coords = tile_map.get_cell_atlas_coords(Config.RIVER_TILE_LAYER, tile_coords)
	if river_atlas_coords != Vector2i(-1, -1):
		return RiverResource.new(tile_coords)
	var atlas_coords = tile_map.get_cell_atlas_coords(Config.BASE_TILE_LAYER, tile_coords)
	if atlas_coords == Config.PLAINS_COORDS:
		return PlainsResource.new(tile_coords)
	if atlas_coords == Config.FOREST_COORDS:
		return ForestResource.new(tile_coords)
	if atlas_coords == Config.LIGHT_MTN_COORDS:
		return LightMountainResource.new(tile_coords)
	if atlas_coords in Config.COASTAL_COORDS:
		return CoastalResource.new(tile_coords)
	assert(false, "Could not determine Tile object from coords: " + str(tile_coords))
	return null
