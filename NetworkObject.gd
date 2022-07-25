extends Node

class_name NetworkObject

func update_server_with_new_state(state): # To be overridden
	rpc_unreliable("get_updated_by_server", state)


puppet func get_updated_by_server(new_state): # To be overridden
	pass
