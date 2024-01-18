class_name CapitolComponent
extends Sprite2D

var tile_coords: Vector2i

func _init(world_position: Vector2, _tile_coords: Vector2i, player_name: String) -> void:
	tile_coords = _tile_coords
	position = world_position
	texture = load("res://assets/icons/" + player_name + "_capitol.png")
