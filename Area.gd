extends Area

func _ready():
	add_to_group(Strings.HAZARD_GROUP_ID)


func _on_player_added_to_tree(player):
	connect("body_entered", player, "_on_Hazard_body_entered")
