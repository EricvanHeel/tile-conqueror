class_name ArmyComponent
extends Area2D

var game_state: GameStateComponent
var player_name: String
var strength: int = 0
var has_movement = false
var is_fed = true
var banner_sprite = Sprite2D.new()
var strength_sprite = Sprite2D.new()
var action_targets: Array[Area2D] = []

signal army_clicked

func init_scene(_player_name: String, _strength: int, _position: Vector2, _game_state: GameStateComponent):
	player_name = _player_name
	game_state = _game_state
	position = _position
	strength = _strength
	banner_sprite.texture = load("res://assets/icons/armies/" + player_name + "_army.png")
	# can use sprite.modulate property to set a color mask
	if player_name == "white":
		strength_sprite.self_modulate = Color("000000")
	else:
		strength_sprite.self_modulate = Color("ffffff")
	strength_sprite.texture = load("res://assets/icons/armies/numbers/" + str(strength) + ".png")
	add_child(banner_sprite)
	add_child(strength_sprite)

func _input_event(viewport, event, shape_idx) -> void:
	if not game_state.is_my_turn(player_name):
		return
	if not has_movement and is_fed:
		return
	if event.is_action_pressed("left_click"):
		army_clicked.emit(self)

func clear_action_targets() -> void:
	for action_target in action_targets:
		action_target.queue_free()
	action_targets = [] # Is this needed?

func move_army(position_delta: Vector2) -> void:
	position = position.lerp(position_delta + position, 0.2)
