class_name SeaTileComponent
extends BaseTileComponent

func _init(tile_coords: Vector2i):
	super._init(tile_coords, 0, Config.SEA_COORDS, TileProduction.new([], [], [], []))
