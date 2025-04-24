class_name BaseLevel extends Node2D

@onready var timer : Timer = $Timer
@onready var end_area: Area2D = $Area2D
@onready var label : Label

@onready var player: Player = $Player

const TIMER_UI = preload("res://timer_ui.tscn")
const END_LEVEL_MENU = preload("res://end_level_menu.tscn")

@export var level_id : int = -1
var elapsed_time : int = 0
var elapsed_time_precise : float = 0.0
var timer_running : bool = true

func _ready():
	#timer.timeout.connect(_on_Timer_timeout)
	#end_area.body_entered.connect(_on_area_2d_body_entered)
	
	if (SteamManager.is_steam_running):
		AutoloadClient.client_connect_inst.get_best_time(level_id)
		await AutoloadClient.client_connect_inst.best_time_got
		
		AutoloadClient.client_connect_inst.get_nearby_ghosts(AutoLoadTimer.get_level_time())
		await AutoloadClient.client_connect_inst.nearby_ghosts_got
	
	 #Attention au timer, les fantomes risques de commencer ern avance de 1 sec!
	_instanciate_ghosts_from_inputs(AutoloadClient.nearby_ghosts)
	
	var timer_ui = TIMER_UI.instantiate()
	add_child(timer_ui)
	label = timer_ui.get_child(0)
	timer.start()

func _process(delta):
	if timer_running:
		elapsed_time_precise += delta
		
func _on_Timer_timeout():
	if timer_running:
		elapsed_time += 1
		var minutes = elapsed_time / 60
		var seconds = elapsed_time % 60
		label.text = "Temps : %02d:%02d" % [minutes, seconds]

func _on_area_2d_body_entered(body):
	if body is Player:
		call_deferred("_end_level")

func _end_level():
	timer_running = false
	timer.stop()
	player.stop_recording_inputs()
	var inputs = player.get_input_string()
	print("inputs", inputs)
	
	if (AutoLoadTimer.set_level_time(level_id, elapsed_time_precise)):
		AutoloadClient.client_connect_inst.submit_test_score(inputs, elapsed_time_precise)
	
	var end_menu : EndLevelMenu = END_LEVEL_MENU.instantiate()
	add_child(end_menu)
	var test : Control
	
func _instanciate_ghosts_from_inputs(inputs : Dictionary):
	print(inputs)
