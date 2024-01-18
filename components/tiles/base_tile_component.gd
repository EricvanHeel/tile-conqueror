class_name BaseTileComponent
extends Node2D

const OUTLINE_OFFSET = 7.5
const OUTLINE_CONNECTED_OFFSET = 8.0

# Tile map related
var tile_coords: Vector2i
var tile_set_id: int
var atlas_coords: Vector2i
var alternate_tile: int = 0  # used for rotated tiles in the tile map
# Game related
var animated_sprite: Area2D
var territory_line_1: Line2D = Line2D.new()
var territory_line_2: Line2D = Line2D.new()
var player_name: String = ""
var tile_production = TileProduction
var friendly_neighbors = [0, 0, 0, 0]

func _init(
	_tile_coords: Vector2i, _tile_set_id: int, _atlas_coords: Vector2i,
	_tile_production: TileProduction, _alternate_tile: int = 0
):
	tile_coords = _tile_coords
	tile_set_id = _tile_set_id
	atlas_coords = _atlas_coords
	alternate_tile = _alternate_tile
	tile_production = _tile_production
	territory_line_1.width = 1
	territory_line_2.width = 1

func _get_world_coords() -> Vector2:
	return get_parent().map_to_local(tile_coords)

func _set_animated_sprite(scene: PackedScene) -> void:
	animated_sprite = scene.instantiate()
	animated_sprite.position = _get_world_coords()
	add_child(animated_sprite)
	
func _get_outline_points(base_outline: Array) -> PackedVector2Array:
	var world_coords = _get_world_coords()
	var packed_vector_array = []
	for point in base_outline:
		packed_vector_array.append(point + world_coords)
	return packed_vector_array

func generate_resources() -> ResourcesObject:
	return tile_production.generate_resources()

func clear_animation() -> void:
	if animated_sprite:
		animated_sprite.queue_free()

func evaluate_neighbor(claimed_neighbor_tile: BaseTileComponent) -> void:
	if player_name == "":
		return
	if claimed_neighbor_tile.tile_coords - tile_coords == Vector2i.UP:
		if claimed_neighbor_tile.player_name == player_name:
			friendly_neighbors[0] = 1
		else:
			friendly_neighbors[0] = 0
	if claimed_neighbor_tile.tile_coords - tile_coords == Vector2i.RIGHT:
		if claimed_neighbor_tile.player_name == player_name:
			friendly_neighbors[1] = 1
		else:
			friendly_neighbors[1] = 0
	if claimed_neighbor_tile.tile_coords - tile_coords == Vector2i.DOWN:
		if claimed_neighbor_tile.player_name == player_name:
			friendly_neighbors[2] = 1
		else:
			friendly_neighbors[2] = 0
	if claimed_neighbor_tile.tile_coords - tile_coords == Vector2i.LEFT:
		if claimed_neighbor_tile.player_name == player_name:
			friendly_neighbors[3] = 1
		else:
			friendly_neighbors[3] = 0

func set_outline() -> void:
	if player_name == "":
		return
	territory_line_1.clear_points()
	territory_line_2.clear_points()
	match friendly_neighbors.reduce(func(accum, number): return accum + number):
		0:
			territory_line_1.points = _get_outline_points(Config.NO_FIRENDLY)
		1:
			var friendly_edge = friendly_neighbors.find(1)
			territory_line_1.points = _outline_three_sides(friendly_edge)
		2:
			if friendly_neighbors[0] == 1:
				if friendly_neighbors[1] == 1:
					territory_line_1.points = _outline_corner(1)
				if friendly_neighbors[2] == 1:
					territory_line_1.points = _outline_one_side(1)
					territory_line_2.points = _outline_one_side(3)
				if friendly_neighbors[3] == 1:
					territory_line_1.points = _outline_corner(0)
			if friendly_neighbors[1] == 1:
				if friendly_neighbors[2] == 1:
					territory_line_1.points = _outline_corner(2)
				if friendly_neighbors[3] == 1:
					territory_line_1.points = _outline_one_side(0)
					territory_line_2.points = _outline_one_side(2)
			if friendly_neighbors[3] == 1 and friendly_neighbors[2] == 1:
					territory_line_1.points = _outline_corner(3)
		3:
			var empty_edge = friendly_neighbors.find(0)
			territory_line_1.points = _outline_one_side(empty_edge)
	if territory_line_1.points.size() > 0:
		territory_line_1.default_color = Config.COLOR_MAP[player_name]["primary"]
		add_child(territory_line_1)
	if territory_line_2.points.size() > 0:
		territory_line_2.default_color = Config.COLOR_MAP[player_name]["primary"]
		add_child(territory_line_2)

# TODO: is this func used? Maybe for upgrading tiles?
func set_cell(tile_map: TileMap, layer: int) -> void:
	tile_map.set_cell(layer, tile_coords, tile_set_id, atlas_coords, alternate_tile)
	
func set_capitol(_player_name) -> void:
	player_name = _player_name
	set_outline()
	tile_production.militia.append_array([6, 6])

func set_attack_animation() -> void:
	_set_animated_sprite(load("res://scenes/AttackTarget.tscn"))

func set_deploy_animation() -> void:
	_set_animated_sprite(load("res://scenes/DeployArmy.tscn"))

func set_fortify_animation() -> void:
	_set_animated_sprite(load("res://scenes/FortifyTarget.tscn"))
	
func set_move_animation() -> void:
	_set_animated_sprite(load("res://scenes/MoveToTarget.tscn"))

# 0 is top missing, 1 is right, 2 is bottom, 3 is left
func _outline_three_sides(friendly_edge: int) -> PackedVector2Array:
	assert(friendly_edge > -1 and friendly_edge < 4, "Invalid rotation value in outline")
	match friendly_edge:
		0:
			return _get_outline_points(Config.TOP_FRIENDLY_ONLY)
		1:
			return _get_outline_points(Config.RIGHT_FRIENDLY_ONLY)
		2:
			return _get_outline_points(Config.BOT_FRIENDLY_ONLY)
		3:
			return _get_outline_points(Config.LEFT_FRIENDLY_ONLY)
	return []

# 0 is bottom-right, 1 is bottom-left, 2 is top-left, 3 is top-right
func _outline_corner(_rotation: int) -> PackedVector2Array:
	assert(_rotation > -1 and _rotation < 4, "Invalid rotation value in outline")
	match _rotation:
		0:
			return _get_outline_points(Config.TOP_LEFT_FRIENDLY)
		1:
			return _get_outline_points(Config.TOP_RIGHT_FRIENDLY)
		2:
			return _get_outline_points(Config.BOT_RIGHT_FRIENDLY)
		3:
			return _get_outline_points(Config.BOT_LEFT_FRIENDLY)
	return []

# 0 is top, 1 is right, 2 is bottom, 3 is left
func _outline_one_side(side: int) -> PackedVector2Array:
	assert(side > -1 and side < 4, "Invalid side value in outline")
	var world_coords = _get_world_coords()
	match side:
		0:
			return _get_outline_points(Config.TOP_NOT_FRIENDLY)
		1:
			return _get_outline_points(Config.RIGHT_NOT_FRIENDLY)
		2:
			return _get_outline_points(Config.BOT_NOT_FRIENDLY)
		3:
			return _get_outline_points(Config.LEFT_NOT_FRIENDLY)
	return []
