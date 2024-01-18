class_name PlainsTileComponent
extends BaseTileComponent

func _init(tile_coords: Vector2i):
	super._init(tile_coords, 0, Config.PLAINS_COORDS, TileProduction.new([4], [], [], []))
