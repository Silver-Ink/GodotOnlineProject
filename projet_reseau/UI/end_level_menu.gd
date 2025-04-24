class_name EndLevelMenu extends CanvasLayer


func _on_retry_button_down() -> void:
	MainMenu.load_level(AutoloadClient.daily_level, get_tree())

func _on_menu_button_down() -> void:
	get_tree().change_scene_to_file("res://UI/menu.tscn")

var lst_label : Array
func _ready() -> void:
	lst_label.append($Control/Panel/Container/VBoxContainer/Score/Label)
	lst_label.append($Control/Panel/Container/VBoxContainer/Score2/Label)
	lst_label.append($Control/Panel/Container/VBoxContainer/Score3/Label)
	lst_label.append($Control/Panel/Container/VBoxContainer/Score4/Label)
	lst_label.append($Control/Panel/Container/VBoxContainer/Score5/Label)

func set_ranking_time(lst_ghost : Array, player_time :float):
	var lst_time : Array
	for g in lst_ghost:
		lst_time.append(g["time"])
	lst_time.append(player_time)
	lst_time.sort()
	
	var nb_label = len(lst_label)
	var nb_concurrents = min(nb_label, len(lst_time))
	for i in range(nb_concurrents):
		var time = lst_time[i]
		var label_formatted = false
		for g in lst_ghost:
			if (g["time"] == time):
				format_label(lst_label[i], time, "ghost")
				label_formatted = true
				break
		if (!label_formatted):
			format_label(lst_label[i], player_time, "You")
			
	for i in range(nb_concurrents, nb_label):
		var label = lst_label[i]
		print("invisible ", i)
		label.get_parent().visible = false
				
func format_label(label : Label, time : float, text : String):
	label.text = "%s         %f" % [text, time]
