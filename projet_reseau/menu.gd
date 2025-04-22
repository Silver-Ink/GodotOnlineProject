extends Control

@onready var level_time_label = $VBoxContainer/LevelTimeLabel

@export var num_level := 1
func _ready():
	var text = ""
	for level_name in AutoLoadTimer.level_times.keys():
		var time = AutoLoadTimer.get_level_time(level_name)
		var minutes = int(time) / 60
		var seconds = int(time) % 60
		var milliseconds = int((time - int(time)) * 1000)
		text += "%s - Temps : %02d:%02d.%03d\n" % [level_name, minutes, seconds, milliseconds]

	level_time_label.text = text if text != "" else "Aucun niveau complété."

	$VBoxContainer/PlayButton.pressed.connect(on_play_pressed)
	$VBoxContainer/QuitButton.pressed.connect(on_quit_pressed)
	$VBoxContainer/TestButton.pressed.connect(on_test_pressed)

func on_play_pressed():
	# Remplace par ta scène de jeu
	var level = "level" + str(num_level)
	var path = "res://" + level + ".tscn"
	if FileAccess.file_exists(path):
		get_tree().change_scene_to_file(path)

func on_quit_pressed():
	get_tree().quit()
	
func on_test_pressed():
	AutoloadClient.client_connect_inst.send_test_score()
	
