extends Control

@onready var level_time_label = $VBoxContainer/LevelTimeLabel

@export var num_level := 1
func _ready():
	var text = ""
	for level_id in AutoLoadTimer.level_times.keys():
		var time = AutoLoadTimer.get_level_time(level_id)
		var minutes = int(time) / 60
		var seconds = int(time) % 60
		var milliseconds = int((time - int(time)) * 1000)
		text += "Level %s - Temps : %02d:%02d.%03d\n" % [level_id, minutes, seconds, milliseconds]

	level_time_label.text = text if text != "" else "Aucun niveau complété."

	$VBoxContainer/PlayButton.pressed.connect(on_play_pressed)
	$VBoxContainer/QuitButton.pressed.connect(on_quit_pressed)
	$VBoxContainer/TestButton.pressed.connect(on_test_pressed)

func on_play_pressed():
	var level = "level" + str(num_level)
	var path = "res://Levels/" + level + ".tscn"
	if FileAccess.file_exists(path):
		get_tree().change_scene_to_file(path)

func on_quit_pressed():
	get_tree().quit()
	
func on_test_pressed():
	AutoloadClient.client_connect_inst.connect_to_server()
	AutoloadClient.client_connect_inst.submit_test_score()
	
