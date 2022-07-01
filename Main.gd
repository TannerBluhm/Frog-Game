extends Spatial

func reset():
	$Player.translation = $Spawn.translation
	$Player.rotation = $Spawn.rotation
	
	print(get_tree().get_nodes_in_group("Flys"))
	
	for node in get_tree().get_nodes_in_group("Flys"):
		if not node.is_inside_tree():
			add_child(node)
