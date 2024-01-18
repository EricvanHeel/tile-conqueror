class_name CustomTileMapComponent
extends TileMap

@export var game_state: GameStateComponent

var army_scene = preload("res://scenes/Army.tscn")

var tile_map_cells: Dictionary = {}  # {Vector2i: BaseTileComponent} Type hints tbd: https://github.com/godotengine/godot/pull/78656
var armies: Dictionary = {}  # {Vector2i: ArmyComponent}
var capitols: Dictionary = {}  # {String: CapitolComponent} key is player_name

func _ready() -> void:
	_initialize_tiles(Config.BASE_TILE_LAYER, Config.PLAINS_COORDS, PlainsTileComponent)
	_initialize_tiles(Config.BASE_TILE_LAYER, Config.FOREST_COORDS, ForestTileComponent)
	_initialize_tiles(Config.BASE_TILE_LAYER, Config.LIGHT_MTN_COORDS, LightMountainTileComponent)
	for atlas_coords in Config.COASTAL_COORDS:
		_initialize_tiles(Config.BASE_TILE_LAYER, atlas_coords, CoastalTileComponent, true)
	_initialize_tiles(Config.BASE_TILE_LAYER, Config.HEAVY_MTN_COORDS, HeavyMountainTileComponent)
	_initialize_tiles(Config.BASE_TILE_LAYER, Config.SEA_COORDS, SeaTileComponent)
	# rivers are last, as they're on a diff layer and should overwrite the map we're defining
	for atlas_coords in Config.RIVER_COORDS:
		_initialize_tiles(Config.RIVER_TILE_LAYER, atlas_coords, RiverTileComponent, true)
	assert(tile_map_cells.size() == 800)
	game_state.player_info.deploy_button.pressed.connect(_deploy_button_pressed)
	game_state.player_info.game_button.pressed.connect(_game_button_pressed)

func _initialize_tiles(tile_layer: int, atlas_coords: Vector2i, cls, is_dynamic: bool = false) -> void:
	for cell_coords in get_used_cells_by_id(tile_layer, Config.BASE_TILE_SET_ID, atlas_coords):
		var tile_component
		if is_dynamic:
			var alternate_tile = get_cell_alternative_tile(tile_layer, cell_coords)
			tile_component = cls.new(cell_coords, atlas_coords, alternate_tile)
		else:
			tile_component = cls.new(cell_coords)
		tile_map_cells[cell_coords] = tile_component
		add_child(tile_component)

func _unhandled_input(event) -> void:
	if event.is_action_pressed("left_click"):
		if game_state.current_phase == Config.CAPITOL_SELECT:
			set_capitol(game_state.current_player(), get_global_mouse_position())
		if game_state.current_phase == Config.MAIN_PHASE:
			if game_state.current_action == Config.DEPLOY_ARMY:
				var event_tile_coords = local_to_map(get_global_mouse_position())
				var capitol_coords = capitols[game_state.current_player()].tile_coords
				if event_tile_coords not in adjacent_tile_cooords(capitol_coords):
					return
				var deploy_tile = tile_map_cells[event_tile_coords]
				if deploy_tile.atlas_coords not in Config.VALID_ARMY_MOVE_COORDS:
					return
				var army = army_scene.instantiate()
				army.init_scene(game_state.current_player(), 1, map_to_local(event_tile_coords), game_state)
				armies[event_tile_coords] = army
				add_child(army)
				_clear_adjacent_animations(capitol_coords)
				deploy_tile.player_name = game_state.current_player()
				_claim_tile(deploy_tile)
				army.connect("army_clicked", _army_clicked)
				game_state.enter_idle_main_phase()
	# RIGHT CLICK FOR DEBUG
	if event.is_action_pressed("right_click"):
		var tile_clicked = tile_map_cells[local_to_map(get_global_mouse_position())]
		# Do testing/debug stuff here

func _process(delta) -> void:
	if game_state.current_phase == Config.UPKEEP:
		if game_state.current_action == Config.GATHER_RESOURCES:
			var resources_gained = ResourcesObject.new()
			for tile in _get_player_owned_tiles(game_state.current_player()):
				resources_gained.add_resources_objects(tile.generate_resources())
			game_state.gather_resources(resources_gained)
			await get_tree().create_timer(3).timeout
			for key in armies.keys():
				if armies[key].player_name == game_state.current_player():
					armies[key].is_fed = false
					tile_map_cells[key].set_move_animation()
			game_state.enter_feed_armies()
		if game_state.current_action == Config.CLEANUP:
			print("Cleanup")
			for key in armies.keys():
				if armies[key].player_name == game_state.current_player() and not armies[key].is_fed:
					tile_map_cells[key].clear_animation()
					armies[key].queue_free()
					armies.erase(key)
			print(armies)
			game_state.enter_idle_main_phase()

func _get_player_owned_tiles(player_name) -> Array:
	return tile_map_cells.values().filter(func(tile): return tile.player_name == game_state.current_player())

func _deploy_button_pressed() -> void:
	if game_state.current_phase == Config.MAIN_PHASE and game_state.current_action == Config.IDLE_ACTION:
		game_state.player_info.deploy_button.disabled = true
		for adjacent_tile in _get_deployable_tiles(capitols[game_state.current_player()].tile_coords):
			adjacent_tile.set_deploy_animation()
		game_state.current_action = Config.DEPLOY_ARMY
		game_state.player_info.set_button_mode("Cancel")
		game_state.player_info.set_action_label("Deploy Army")

func _game_button_pressed() -> void:
	if game_state.current_phase == Config.MAIN_PHASE:
		if game_state.current_action == Config.DEPLOY_ARMY:
			_clear_adjacent_animations(capitols[game_state.current_player()].tile_coords)
			game_state.enter_idle_main_phase()

func _clear_adjacent_animations(center_tile_coords: Vector2i) -> void:
	for adjacent_tile_coord in adjacent_tile_cooords(center_tile_coords):
		var adjacent_tile = tile_map_cells[adjacent_tile_coord]
		adjacent_tile.clear_animation()

func _claim_tile(tile: BaseTileComponent) -> void:
	for adjacent_tile_coords in adjacent_tile_cooords(tile.tile_coords):
		var adjacent_tile = tile_map_cells[adjacent_tile_coords]
		adjacent_tile.evaluate_neighbor(tile)
		adjacent_tile.set_outline()
		tile.evaluate_neighbor(adjacent_tile)
	tile.set_outline()
		
func _get_deployable_tiles(source_coords: Vector2i) -> Array[BaseTileComponent]:
	var deployable_tiles: Array[BaseTileComponent] = []
	for adjacent_tile_coord in adjacent_tile_cooords(source_coords):
		var adjacent_tile = tile_map_cells[adjacent_tile_coord]
		if adjacent_tile.atlas_coords in Config.VALID_ARMY_MOVE_COORDS:
			deployable_tiles.append(adjacent_tile)
	return deployable_tiles
	
func _army_clicked(army: ArmyComponent) -> void:
	print("Army Clicked")
	if game_state.current_phase == Config.UPKEEP and game_state.current_action == Config.ARMY_ACTION:
		army.is_fed = true
		var tile_map_coords = local_to_map(army.position)
		tile_map_cells[tile_map_coords].clear_animation()
	if game_state.current_phase == Config.MAIN_PHASE:
		if game_state.current_action == Config.IDLE_ACTION:
			print("Army action")
			game_state.current_action == Config.ARMY_ACTION
			var army_tile_coords = local_to_map(army.position)
		elif game_state.current_action == Config.ARMY_ACTION:
			print("Setting to idle state")
			game_state.current_action == Config.IDLE_ACTION
		
func adjacent_tile_cooords(tile_coords: Vector2i) -> Array[Vector2i]:
	var adjacent_tile_cooords: Array[Vector2i] = []
	for adjacent_vector in Config.ADJACENT_TILE_VECTORS:
		adjacent_tile_cooords.append(tile_coords + adjacent_vector)
	return adjacent_tile_cooords

func upgrade_tile(world_position: Vector2) -> void:
	var tile_coords = local_to_map(world_position)
	# TODO: tile_map_cells[tile_coords]. upgrade_tile()

func set_capitol(player_name: String, world_position: Vector2) -> void:
	# Note: Only works if capitol select is first thing done in game (as we're just checking player_name)
	var tile_coords = local_to_map(world_position)
	if tile_map_cells[tile_coords].atlas_coords not in Config.VALID_CAPITOL_COORDS:
		print("Invalid tile for Capitol")
		return
	var world_coords = map_to_local(tile_coords)
	
	for player in capitols.keys():
		var tile_diff = capitols[player].tile_coords - tile_coords
		if (tile_diff.x < 5 and tile_diff.x > -5) and (tile_diff.y < 5 and tile_diff.y > -5):
			print("Capitol or surrounding area already taken")
			return
	var capitol_tile = tile_map_cells[tile_coords]
	capitol_tile.set_capitol(player_name)
	capitols[player_name] = CapitolComponent.new(world_coords, tile_coords, player_name)
	add_child(capitols[player_name])
	game_state.end_turn()
