class_name MainMenu extends Control

@onready var level_time_label = $ColorPanel/Panel/MarginContainer/VBoxContainer/LevelTimeLabel
@export var level_to_play = 1

func _ready():
	var text = ""
	for level_id in AutoLoadTimer.level_times.keys():
		var time = AutoLoadTimer.get_level_time( level_id.to_int())
		var minutes = int(time) / 60
		var seconds = int(time) % 60
		var milliseconds = int((time - int(time)) * 1000)
		text += "Level %s - Temps : %02d:%02d.%03d\n" % [level_id, minutes, seconds, milliseconds]

	level_time_label.text = text if text != "" else "Aucun niveau complété."

	$ColorPanel/Panel/MarginContainer/VBoxContainer/PlayButton.pressed.connect(on_play_pressed)
	$ColorPanel/Panel/MarginContainer/VBoxContainer/ConnectButton.pressed.connect(on_quit_pressed)
	$ColorPanel/Panel/MarginContainer/VBoxContainer/TestButton.pressed.connect(on_test_pressed)
	$ColorPanel/Panel/MarginContainer/VBoxContainer/QuitButton.pressed.connect(on_connect)

static func load_level(level : int, tree : SceneTree):
	level += 1
	var path = "res://Levels/level1.tscn" #% level
	#if FileAccess.file_exists(path):
	tree.change_scene_to_file(path)
	#else:
		#printerr("Level does not exist ... : ", level)
		
func on_play_pressed():
	AutoloadClient.client_connect_inst.connect_to_server()
	await AutoloadClient.client_connect_inst.server_connected
	
	AutoloadClient.client_connect_inst.get_daily_level()
	await AutoloadClient.client_connect_inst.daily_level_got
	
	load_level(AutoloadClient.daily_level, get_tree())
	
func on_quit_pressed():
	get_tree().quit()
	
func on_test_pressed():
	load_level(level_to_play, get_tree())
	
func on_connect():
	AutoloadClient.client_connect_inst.connect_to_server()
	
