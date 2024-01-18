class_name TileProduction
extends Resource

var food: Array[int]
var wood: Array[int]
var stone: Array[int]
var militia: Array[int]

var random = RandomNumberGenerator.new()

func _init(_food: Array[int], _wood: Array[int], _stone: Array[int], _militia: Array[int]):
	food = _food
	wood = _wood
	stone = _stone
	militia = _militia

func generate_resources() -> ResourcesObject:
	var resources_object = ResourcesObject.new()
	for die in food:
		resources_object.food += random.randi_range(1, die)
	for die in wood:
		resources_object.wood += random.randi_range(1, die)
	for die in stone:
		resources_object.stone += random.randi_range(1, die)
	for die in militia:
		resources_object.militia += random.randi_range(1, die)
	return resources_object
