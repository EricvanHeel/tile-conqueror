class_name CoastalTileComponent
extends BaseTileComponent

func _init(tile_coords: Vector2i, atlas_coords: Vector2i, alternate_tile: int):
	super._init(tile_coords, 0, atlas_coords, TileProduction.new([4], [6], [], []), alternate_tile)
