extends Node2D

onready var title_screen := $TitleScreen
onready var level_scene = preload("res://Main.tscn")

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")


func _player_connected(id):
	print("Player connected to the server!")
	PlayerList.other_players.append(id)


func _on_HostButton_pressed():
	print("Hosting server")
	var host = NetworkedMultiplayerENet.new()
	var response = host.create_server(Ints.PORT, Ints.MAX_PLAYER_COUNT)
	if response != OK:
		print("Error creating server: " + str(response))
		return
	
	$TitleScreen/HostButton.disabled = true
	$TitleScreen/JoinButton.hide()
	get_tree().set_network_peer(host)
	
	
	var level = preload("res://Main.tscn").instance()
	get_tree().get_root().add_child(level)
	title_screen.hide()


func _on_JoinButton_pressed():
	print("Joining server")
	var host = NetworkedMultiplayerENet.new()
	var response = host.create_client(Strings.SERVER_IP_AS_STRING, Ints.PORT)
	if response != OK:
		print("Error connecting to server: " + str(response))
		return
	
	get_tree().set_network_peer(host)
	
	$TitleScreen/HostButton.hide()
	$TitleScreen/JoinButton.disabled = true
	
	var level = preload("res://Main.tscn").instance()
	get_tree().get_root().add_child(level)
	title_screen.hide()


func _start_level(player) -> void:
	var level = level_scene.instance()
	get_tree().get_root().add_child(level)
	title_screen.hide()
