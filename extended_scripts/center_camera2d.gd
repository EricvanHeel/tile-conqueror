extends Camera2D

const OG_VIEWPORT_WIDTH = 384
const RELEASE_FALLOFF = 10
const ACCELERATION = 80
const MAX_SPEED = 20
const MAX_ZOOM = 1.5
const ZOOM_INCREMENT = 0.05
const ZOOM_RATE = 8.0

@export var tile_map: TileMap

var velocity: Vector2 = Vector2.ZERO
var tile_map_size: Vector2i
var min_zoom: float
var target_zoom: float
var camera_offset: Vector2

func _ready():
	tile_map_size = _get_tile_map_size()
	min_zoom = _get_camera_to_tile_map_zoom_ratio()
	target_zoom = min_zoom
	set_zoom(Vector2(min_zoom, min_zoom))
	_init_position_and_offset()
	
func _unhandled_input(event) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom_out()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_in()

func _process(delta):
	var input_vector = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	_calculate_velocity(input_vector)
	_update_position()
	
func _init_position_and_offset():
	var viewport_size = get_viewport().size
	camera_offset = Vector2(
		viewport_size.x / (2 * _get_magnification()), 
		viewport_size.y / (2 * _get_magnification())
	)
	global_position = Vector2(camera_offset / zoom)
	
func _update_position():
	var delta = get_process_delta_time()
	zoom = lerp(zoom, target_zoom * Vector2.ONE, ZOOM_RATE * delta)
	set_physics_process(not is_equal_approx(zoom.x, target_zoom))
	global_position += lerp(velocity, Vector2.ZERO, pow(2, -32 * delta))
	global_position.x = clamp(
		global_position.x,
		camera_offset.x / zoom.x,
		tile_map_size.x - (camera_offset.x / zoom.x)
	)
	global_position.y = clamp(
		global_position.y,
		camera_offset.y / zoom.y,
		tile_map_size.y - (camera_offset.y / zoom.y)
	)
	
func _zoom_in():
	target_zoom = max(target_zoom - ZOOM_INCREMENT, min_zoom)
	set_physics_process(true)
	
func _zoom_out():
	target_zoom = min(target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	set_physics_process(true)

func _get_tile_map_size():
	var tile_size = tile_map.tile_set.tile_size
	var tile_map_size_by_tiles = tile_map.get_used_rect()
	var tile_map_size = Vector2i(
		tile_map_size_by_tiles.end.x - tile_map_size_by_tiles.position.x,
		tile_map_size_by_tiles.end.y - tile_map_size_by_tiles.position.y
	)
	return Vector2i(tile_map_size * tile_size)

func _get_camera_to_tile_map_zoom_ratio():
	var viewport_size = get_viewport().size
	var viewport_ratio = float(viewport_size[0]) / viewport_size[1]
	var tile_map_ratio = float(tile_map_size.x) / tile_map_size.y
	
	var zoom_ratio = 1.0
	if tile_map_ratio > viewport_ratio:
		zoom_ratio = float(viewport_size[1]) / (tile_map_size.y * _get_magnification())
	else:
		zoom_ratio = float(viewport_size[0]) / (tile_map_size.x * _get_magnification())
	return zoom_ratio
	
func _get_magnification():
	return float(get_viewport().size[0]) / OG_VIEWPORT_WIDTH
	
func _calculate_velocity(direction):
	var delta = get_process_delta_time()
	velocity += direction * ACCELERATION * delta
	if direction.x == 0:
		velocity.x = lerp(0.0, velocity.x, pow(2, -RELEASE_FALLOFF * delta))
	if direction.y == 0:
		velocity.y = lerp(0.0, velocity.y, pow(2, -RELEASE_FALLOFF * delta))
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	velocity.y = clamp(velocity.y, -MAX_SPEED, MAX_SPEED)
