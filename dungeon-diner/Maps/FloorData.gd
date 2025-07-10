extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func get_tile_info_at(world_position: Vector2) -> TileData:
	var tile_coords = local_to_map(to_local(world_position)) 
	return get_cell_tile_data(tile_coords)
