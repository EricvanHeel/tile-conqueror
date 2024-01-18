class_name ResourcesObject
extends Resource

var food: int = 0
var wood: int = 0
var stone: int = 0
var militia: int = 0

func add_resources_objects(other_resources_object: ResourcesObject) -> void:
	food += other_resources_object.food
	wood += other_resources_object.wood
	stone += other_resources_object.stone
	militia += other_resources_object.militia

func print() -> void:
	prints("Food: " + str(food), "Wood: " + str(wood), "Stone: " + str(stone), "Militia: " + str(militia))
