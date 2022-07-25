extends Spatial

export var time_to_complete_level := 3000

var level_data: LevelData

var frog_player_scene = preload("res://Player.tscn")
var players: Array = []

signal ready_with_data(data)
signal player_added_to_tree(player)

func _ready():
	_init_connections()
	
	level_data = LevelData.new(time_to_complete_level)
	
	for fly_spawner in get_tree().get_nodes_in_group(Strings.FLY_SPAWNERS_GROUP_ID):
		fly_spawner.spawn()
		
	emit_signal("ready_with_data", level_data)
	spawn_players()


func _init_connections():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	_connect_hazards()


func spawn_players():
	# Spawn this clients player
	var client_network_id = get_tree().get_network_unique_id()
	var this_player = spawn_player(client_network_id)
	players.append(this_player)
	
	# Spawn all of the other players
	for player_id in PlayerList.other_players:
		var other_player = spawn_player(player_id)
		players.append(other_player)


func spawn_player(id):
	var player_instance = frog_player_scene.instance()
	add_child(player_instance)
	player_instance.set_name(str(id))
	player_instance.set_network_master(id)
	player_instance.translation = $Spawn.translation
	player_instance.rotation = $Spawn.rotation
	
	emit_signal("player_added_to_tree", player_instance)
	return player_instance


func _connect_hazards():
	var hazards = get_tree().get_nodes_in_group(Strings.HAZARD_GROUP_ID)
	for hazard in hazards:
		connect("player_added_to_tree", hazard, "_on_player_added_to_tree")


func reset():
	for player in players:
		player.translation = $Spawn.translation
		player.rotation = $Spawn.rotation
	
	for fly_spawner in get_tree().get_nodes_in_group(Strings.FLY_SPAWNERS_GROUP_ID):
		fly_spawner.spawn()


func _player_connected(id):
	spawn_player(id)
