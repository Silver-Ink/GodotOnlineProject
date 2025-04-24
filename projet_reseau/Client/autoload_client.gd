extends Node

var _client_connection_scene : PackedScene = preload("res://Client/client_connection.tscn")
var client_connect_inst : ClientConnection

const LEVEL_COUNT = 2

var daily_level : int = -1
var daily_rank : int = -1
var nearby_ghosts : Dictionary


func _ready():
	if (ProjectSettings.get_setting_with_override("global/IsServerValidator") == false):
		if (_client_connection_scene):
			client_connect_inst = _client_connection_scene.instantiate()
			add_child(client_connect_inst)
			print("Correctly loaded client connection")
			connect_signals()
	else:
		print("Did not loaded client connection")


func connect_signals():
	client_connect_inst.daily_level_got.connect(on_daily_level_got)
	client_connect_inst.daily_ranking_got.connect(on_daily_ranking_got)
	client_connect_inst.nearby_ghosts_got.connect(on_nearby_ghosts_got)

func on_daily_level_got(level: int):
	daily_level = level
	
func on_daily_ranking_got(rank: int):
	daily_rank = rank
	
func on_nearby_ghosts_got(ghosts: Dictionary):
	nearby_ghosts = ghosts
	
func on_best_time_got(time: float):
	if (time != -1):
		AutoLoadTimer.level_times[daily_level] = time
