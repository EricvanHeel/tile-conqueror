class_name HeavyMountainTileComponent
extends BaseTileComponent

func _init(tile_coords: Vector2i):
	super._init(tile_coords, 0, Config.HEAVY_MTN_COORDS, TileProduction.new([], [], [], []))
