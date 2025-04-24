class_name InputRecord extends Node2D

const _available_actions : Array[String] = ["ui_left", "ui_right", "ui_accept"]

var _currently_recording := false
var _current_time := 0.0

var _record_file : FileAccess
var _record_file_path := "user://test_file.dat"

func _ready() -> void:
	start_recording()
	
func _process(delta: float) -> void:
	if (not _currently_recording):
		return
	
	_current_time += delta

	if (Input.is_anything_pressed()):
		var action_list := []
		var any_action := false
		
		for i in len(_available_actions):
			if (Input.is_action_pressed(_available_actions[i])):
				any_action = true
				action_list.append(i)
		
		if (any_action):
			#_record_file.store_string(str(_current_time))
			_record_file.store_float(_current_time)
			for action_index in action_list:
				#_record_file.store_string(str(action_index))
				_record_file.store_8(action_index)

func start_recording():
	_record_file = FileAccess.open(_record_file_path, FileAccess.WRITE)
	_currently_recording = true
	
func stop_recording():
	_record_file.close()
	_currently_recording = false


func inputs_to_string():
	var file = FileAccess.open(_record_file_path, FileAccess.READ)
	
	var str := ""
	while (not file.eof_reached()): 
		str += ("%f:%s;" % [file.get_float(), _available_actions[file.get_8()]])
	return str
