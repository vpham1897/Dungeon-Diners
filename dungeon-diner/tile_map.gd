extends TileMap

func _ready():
	set_process_input(true)

func _input(event):
	if event is InputEventMouseMotion:
		var mouse_pos = get_local_mouse_position()
		var tile_pos = local_to_map(mouse_pos)
		var source_id = get_cell_source_id(0, tile_pos)  # 0 is the layer index

		if source_id != -1:  # -1 means no tile is present at this position
			var tile_data = tile_set.get_tileset_source(source_id)
			var tile_name = tile_data.get_name()
			print("Tile Source ID:", source_id, "Tile Name:", tile_name)
		else:
			print("No tile at this position")
