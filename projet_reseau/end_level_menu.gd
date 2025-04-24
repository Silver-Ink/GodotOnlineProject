class_name EndLevelMenu extends CanvasLayer


func _on_retry_button_down() -> void:
	MainMenu.load_level(AutoloadClient.daily_level, get_tree())

func _on_menu_button_down() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
