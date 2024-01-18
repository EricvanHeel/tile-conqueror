class_name PlayerComponent
extends Node2D

@export var tile_map: TileMap
@export var player_name: String
@export var game_state: GameStateComponent

var armies: Array[ArmyComponent] = []
var selected_army: ArmyComponent

var capitol: CapitolResource = CapitolResource.new()
var owned_tiles: Array[TileResource] = []

var player_resources: ResourcesObject = ResourcesObject.new()

signal capitol_request

func _ready() -> void:
	if player_name == "red":
		var army_scene = preload("res://scenes/Army.tscn")
		var new_army = army_scene.instantiate()
		new_army.init_scene(player_name, 3, Vector2(192, 160))
		add_child(new_army)
		armies.append(new_army)
	if player_name == "purple":
		var army_scene = preload("res://scenes/Army.tscn")
		var new_army = army_scene.instantiate()
		new_army.init_scene(player_name, 5, Vector2(208, 160))
		add_child(new_army)
		armies.append(new_army)
	for army in armies:
		# make sure to add this when new armies created in game
		army.army_clicked.connect(_army_selected)

#func _input(event):
	#if !game_state.is_my_turn(player_name):
		#return
	#if game_state.current_phase == Config.CAPITOL_SELECT:
		#if event.is_action_pressed("left_click"):
			## get_global_mouse_position() accounts for zoom/pan
			#capitol_request.emit(tile_map.local_to_map(get_global_mouse_position()))
	#elif game_state.current_phase == Config.UPKEEP:
		#pass
	#elif game_state.current_phase == Config.MAIN_PHASE:
		#if game_state.current_action == Config.ARMY_ACTION:
			#if event.is_action_pressed("ui_left"):
				#selected_army.move_army(tile_map, Vector2(-80, 0), "left")
			#if event.is_action_pressed("ui_right"):
				#selected_army.move_army(tile_map, Vector2(80, 0), "right")
			#if event.is_action_pressed("ui_up"):
				#selected_army.move_army(tile_map, Vector2(0, -80), "up")
			#if event.is_action_pressed("ui_down"):
				#selected_army.move_army(tile_map, Vector2(0, 80), "down")

func _process(delta):
	if game_state.is_my_turn(player_name) and game_state.current_phase == Config.UPKEEP:
		if game_state.current_action == Config.GATHER_RESOURCES:
			print("Gathering resources")
			var resources_gained = ResourcesObject.new()
			for tile in owned_tiles:
				resources_gained.add_resources_objects(tile.get_resources())
			player_resources.add_resources_objects(resources_gained)
			game_state.current_action = Config.IDLE_ACTION
			game_state.current_phase = Config.MAIN_PHASE

func _army_selected(army: ArmyComponent):
	if game_state.current_phase == Config.MAIN_PHASE or game_state.current_phase == Config.UPKEEP:
		if army == selected_army:
			selected_army = null
			game_state.current_action = Config.IDLE_ACTION
			# Remove all targets
			army.action_targets
		else:
			selected_army = army
			game_state.current_action = Config.ARMY_ACTION
			# Add add targets

func set_capitol(tile_object: TileResource) -> void:
	tile_object._militia += [6, 6]
	owned_tiles.append(tile_object)
	if capitol.sprite:
		capitol.sprite.queue_free()
	capitol.tile = tile_object
	capitol.sprite = Sprite2D.new()
	capitol.sprite.texture = load("res://assets/icons/" + player_name + "_capitol.png")
	capitol.sprite.position = tile_map.map_to_local(tile_object._tile_coords)
	add_child(capitol.sprite)
	

func get_capitol_coords() -> Vector2i:
	if capitol.tile:
		return capitol.tile._tile_coords
	return Vector2i(-1, -1)
