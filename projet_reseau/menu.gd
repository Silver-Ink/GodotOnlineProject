extends Control


func _ready():
	$VBoxContainer/PlayButton.pressed.connect(on_play_pressed)
	$VBoxContainer/QuitButton.pressed.connect(on_quit_pressed)
	$VBoxContainer/TestButton.pressed.connect(on_test_pressed)

func on_play_pressed():
	# Remplace par ta scène de jeu
	get_tree().change_scene_to_file("res://level1.tscn")

func on_quit_pressed():
	get_tree().quit()
	
func on_test_pressed():
	AutoloadClient.client_connect_inst.send_test_score()
	
