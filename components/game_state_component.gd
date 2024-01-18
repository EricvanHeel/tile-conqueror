class_name GameStateComponent
extends Node2D

@export var player_names: Array[String]
@export var player_info: PlayerInfoComponent
var current_turn: int
var current_phase: String
var current_action: String
var player_resources: Dictionary = {}  # {String, ResourcesObject} key is player name, type hints currently not supported

func _ready() -> void:
	for player in player_names:
		player_resources[player] = ResourcesObject.new()
	current_turn = 0
	current_phase = Config.CAPITOL_SELECT
	current_action = Config.IDLE_ACTION
	player_info.game_button.pressed.connect(_game_button_pressed)
	player_info.set_action_label("Select Capitol")
	print("Beginning turn: " + player_names[current_turn])
	player_info.start_turn(player_names[current_turn], player_resources[player_names[current_turn]])

func _game_button_pressed() -> void:
	if current_phase == Config.UPKEEP:
		if current_action == Config.ARMY_ACTION:
			print("Setting to cleanup state")
			current_action = Config.CLEANUP
	elif current_phase == Config.MAIN_PHASE:
		if current_action == Config.IDLE_ACTION:
			end_turn()

func enter_idle_main_phase() -> void:
	print("Entering Idle Main Phase")
	current_phase = Config.MAIN_PHASE
	current_action = Config.IDLE_ACTION
	player_info.set_button_mode("End Turn")
	player_info.set_action_label("Main Phase")
	if player_resources[player_names[current_turn]].militia > 4:
		player_info.deploy_button.disabled = false

func gather_resources(gained_resources: ResourcesObject) -> void:
	player_info.add_resources(gained_resources)
	player_resources[current_player()].add_resources_objects(gained_resources)
	current_action = Config.IDLE_ACTION

func enter_feed_armies() -> void:
	current_action = Config.ARMY_ACTION
	player_info.set_action_label("Feed Your Armies")
	player_info.set_button_mode("Done")
	
func current_player() -> String:
	return player_names[current_turn]

func end_turn():
	print("Ending turn: " + player_names[current_turn])
	current_turn += 1
	if current_turn == player_names.size():
		current_turn = 0
		if current_phase == Config.CAPITOL_SELECT:
			current_phase = Config.UPKEEP
			current_action = Config.GATHER_RESOURCES
	print("Beginning turn: " + player_names[current_turn])
	player_info.start_turn(player_names[current_turn], player_resources[player_names[current_turn]])
	if current_phase == Config.MAIN_PHASE:
		if current_action == Config.IDLE_ACTION:
			current_phase = Config.UPKEEP
			current_action = Config.GATHER_RESOURCES

func is_my_turn(player_name: String) -> bool:
	return player_names[current_turn] == player_name
