class_name ForestTileComponent
extends BaseTileComponent

func _init(tile_coords: Vector2i):
	super._init(tile_coords, 0, Config.FOREST_COORDS, TileProduction.new([4], [6], [], []))
