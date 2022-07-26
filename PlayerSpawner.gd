extends Spatial

export var length_of_spawn_area: float = 1.0
export var width_of_spawn_area: float = 1.0
export var random_rotations: bool = false

var length_to_width_ration: float = length_of_spawn_area / width_of_spawn_area
var num_spawns = 0

# Math seems to check out here, just gotta figure out how to make sure server is setting the spawns for all clients
func spawn():
	num_spawns = PlayerList.other_players.size() + 1
	var spawns = []
	
	var x_offset = length_of_spawn_area / sqrt(num_spawns)
	var z_offset = width_of_spawn_area / sqrt(num_spawns)
	
	var current_spawn_pos = translation
	for spawn in num_spawns:
		var new_spawn = Position3D.new()
		new_spawn.translation = current_spawn_pos
		spawns.append(new_spawn)
		
		current_spawn_pos.x = current_spawn_pos.x + x_offset
		current_spawn_pos.z = current_spawn_pos.z + z_offset
