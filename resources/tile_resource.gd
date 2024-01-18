class_name TileResource
extends Resource

var _tile_coords: Vector2i
var _food: Array[int]
var _wood: Array[int]
var _stone: Array[int]
var _militia: Array[int]

var random = RandomNumberGenerator.new()
	
func _init(tile_coords: Vector2i, food: Array[int], wood: Array[int], stone: Array[int], militia: Array[int]):
	_tile_coords = tile_coords
	_food = food
	_wood = wood
	_stone = stone
	_militia = militia

func get_resources() -> ResourcesObject:
	var resources_object = ResourcesObject.new()
	for die in _food:
		resources_object.food += random.randi_range(1, die)
	for die in _wood:
		resources_object.wood += random.randi_range(1, die)
	for die in _stone:
		resources_object.stone += random.randi_range(1, die)
	for die in _militia:
		resources_object.militia += random.randi_range(1, die)
	return resources_object
	
