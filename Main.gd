extends Spatial

export var time_to_complete_level := 3000

var level_data: LevelData

signal ready_with_data(data)

func _ready():
	
	level_data = LevelData.new(time_to_complete_level)
	
	for fly_spawner in get_tree().get_nodes_in_group(Strings.FLY_SPAWNERS_GROUP_ID):
		fly_spawner.spawn()
		
	emit_signal("ready_with_data", level_data)


func reset():
	$Player.translation = $Spawn.translation
	$Player.rotation = $Spawn.rotation
	
	for fly_spawner in get_tree().get_nodes_in_group(Strings.FLY_SPAWNERS_GROUP_ID):
		fly_spawner.spawn()
