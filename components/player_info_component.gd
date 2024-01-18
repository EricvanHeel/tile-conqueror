class_name PlayerInfoComponent
extends Node2D

const BTN_MODE_END_TURN = "End Turn"
const BTN_MODE_END_UPKEEP = "End Upkeep"
const BTN_MODE_END_FEED_ARMY = "Done"
const BTN_MODE_CANCEL_DEPLOY = "Cancel"

@export var player_label: RichTextLabel
@export var action_label: Label

@export var food_label: Label
@export var wood_label: Label
@export var stone_label: Label
@export var militia_label: Label

@export var gained_food_label: Label
@export var gained_wood_label: Label
@export var gained_stone_label: Label
@export var gained_militia_label: Label

@export var game_button: Button
@export var deploy_button: TextureButton

func start_turn(player_name: String, resources_object: ResourcesObject) -> void:
	game_button.visible = false
	deploy_button.disabled = true
	player_label.bbcode_text = \
		"Player: [color=" + Config.COLOR_MAP[player_name]['primary'] + "]" + player_name.capitalize()
	food_label.text = str(resources_object.food)
	wood_label.text = str(resources_object.wood)
	stone_label.text = str(resources_object.stone)
	militia_label.text = str(resources_object.militia)

func add_resources(resources_object: ResourcesObject) -> void:
	set_action_label("Gathering Resources...")
	food_label.text = str(int(food_label.text) + resources_object.food)
	wood_label.text = str(int(wood_label.text) + resources_object.wood)
	stone_label.text = str(int(stone_label.text) + resources_object.stone)
	militia_label.text = str(int(militia_label.text) + resources_object.militia)
	gained_food_label.text = "+" + str(resources_object.food)
	gained_wood_label.text = "+" + str(resources_object.wood)
	gained_stone_label.text = "+" + str(resources_object.stone)
	gained_militia_label.text = "+" + str(resources_object.militia)
	for gained_resource_label in [gained_food_label, gained_wood_label, gained_stone_label, gained_militia_label]:
		var tween = create_tween()
		tween.tween_property(gained_resource_label, "modulate:a", 1, 1)
		tween.tween_interval(1)
		tween.tween_property(gained_resource_label, "modulate:a", 0, 1)

func set_button_mode(mode: String) -> void:
	game_button.text = mode
	game_button.visible = true

func set_action_label(action: String) -> void:
	action_label.text = action
