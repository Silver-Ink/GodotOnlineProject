extends Node

var _client_connection_scene : PackedScene = preload("res://Client/client_connection.tscn")
var client_connect_inst : ClientConnection


func _ready():
	if (ProjectSettings.get_setting_with_override("global/IsServerValidator") == false):
		if (_client_connection_scene):
			client_connect_inst = _client_connection_scene.instantiate()
			add_child(client_connect_inst)
			print("Correctly loaded client connection")
	else:
		print("Did not loaded client connection")
