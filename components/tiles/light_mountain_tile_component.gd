class_name LightMountainTileComponent
extends BaseTileComponent

func _init(tile_coords: Vector2i):
	super._init(tile_coords, 0, Config.LIGHT_MTN_COORDS, TileProduction.new([], [], [6], []))
