class_name InputRecord extends Node2D

const _available_actions : Array[String] = ["ui_left", "ui_right", "ui_accept"]

var _actions_starting_time : Array[float] = []
var _actions_holding_time : Array[float] = []

var _currently_recording := false
var _current_time := 0.0

var _record_file : FileAccess
var _record_file_path := "user://test_file.dat"

var temp = false

const GHOST_CHARACTER_2D = preload("res://ghost_character2D.tscn")
var ghost_char

func _ready() -> void:
	# Setting up starting/holding times
	for i in len(_available_actions):
		_actions_starting_time.append(-1.)
		_actions_holding_time.append(-1.)

	ghost_char = GHOST_CHARACTER_2D.instantiate()
	get_tree().current_scene.add_child.call_deferred(ghost_char)
	ghost_char.position = get_parent().position

	start_recording()

func _process(delta: float) -> void:
	if (not _currently_recording):
		return

	_current_time += delta

	for i in len(_available_actions):
		if (Input.is_action_just_pressed(_available_actions[i])):
			_actions_starting_time[i] = _current_time
			_actions_holding_time[i] = 0.
		else:
			if (_actions_holding_time[i] >= 0):
				_actions_holding_time[i] += delta

		if (Input.is_action_just_released(_available_actions[i])):
			# When input is released, store input info
			_record_file.store_float(_actions_starting_time[i]) # when input started,
			_record_file.store_float(_actions_holding_time[i]) # how long input was held,
			_record_file.store_8(i) # and input type id

		# testing
		if (Input.is_action_just_pressed("ui_down")):
			stop_recording()
			print("---")
			recreate_inputs(inputs_to_string())
			print("---")

func start_recording():
	_record_file = FileAccess.open(_record_file_path, FileAccess.WRITE)
	_currently_recording = true

func stop_recording():
	_record_file.close()
	_currently_recording = false


func inputs_to_string():
	var file = FileAccess.open(_record_file_path, FileAccess.READ)

	var str := ""
	var dict := {}

	while (file.get_position() < file.get_length()):
		var start_time := file.get_float()
		var hold_time := file.get_float()
		var action_type_id := file.get_8()

		str += ("%f - %f :%s\n" % [start_time, hold_time, _available_actions[action_type_id]])
		if dict.get(start_time) == null:
			dict[start_time] = [[_available_actions[action_type_id], hold_time],]
		else:
			dict[start_time].append([_available_actions[action_type_id], hold_time])

	# Sorting because dict is not guaranteed to be in order
	dict.sort()

	return dict

func recreate_inputs(input_info : Dictionary):
	if temp:
		return

	temp = true

	var time_already_waited := 0
	for action_start_time in input_info.keys():
		await get_tree().create_timer(action_start_time - time_already_waited).timeout

		for started_action in input_info[action_start_time]:
			ghost_action_on(started_action[0])
			set_timer_ghost_action_off(started_action[0], started_action[1])

		time_already_waited = action_start_time

func ghost_action_on(action_name : String):
	if (action_name == "ui_left"):
		ghost_char.left = true
	elif (action_name == "ui_right"):
		ghost_char.right = true
	elif (action_name == "ui_accept"):
		ghost_char.jump = true

func set_timer_ghost_action_off(action_name : String, hold_time : float):
	if (action_name == "ui_left"):
		get_tree().create_timer(hold_time).timeout.connect(ghost_left_off)
	elif (action_name == "ui_right"):
		get_tree().create_timer(hold_time).timeout.connect(ghost_right_off)
	elif (action_name == "ui_accept"):
		get_tree().create_timer(hold_time).timeout.connect(ghost_jump_off)

func ghost_jump_off():
	ghost_char.jump = false

func ghost_left_off():
	ghost_char.left = false

func ghost_right_off():
	ghost_char.right = false
