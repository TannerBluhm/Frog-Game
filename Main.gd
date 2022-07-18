extends Spatial

export var time_to_complete_level := 3000

var level_data: LevelData

var frog_player_scene = preload("res://Player.tscn")

signal ready_with_data(data)

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	
	level_data = LevelData.new(time_to_complete_level)
	
	for fly_spawner in get_tree().get_nodes_in_group(Strings.FLY_SPAWNERS_GROUP_ID):
		fly_spawner.spawn()
		
	emit_signal("ready_with_data", level_data)
	spawn_players()


func spawn_players():
	# Spawn this clients player
	var client_network_id = get_tree().get_network_unique_id()
	spawn_player(client_network_id)
	
	# Spawn all of the other players
	for player_id in PlayerList.other_players:
		spawn_player(player_id)


func spawn_player(id):
	var player_instance = frog_player_scene.instance()
	add_child(player_instance)
	player_instance.set_name(str(id))
	player_instance.set_network_master(id)
	player_instance.translation = $Spawn.translation
#	player_instance.rotation = $Spawn.translation


func reset():
	$Player.translation = $Spawn.translation
	$Player.rotation = $Spawn.rotation
	
	for fly_spawner in get_tree().get_nodes_in_group(Strings.FLY_SPAWNERS_GROUP_ID):
		fly_spawner.spawn()


func _player_connected(id):
	spawn_player(id)
