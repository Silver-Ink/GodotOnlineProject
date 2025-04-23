class_name BaseLevel extends Node2D

@onready var timer : Timer = $Timer
@onready var end_area: Area2D = $Area2D
@onready var label : Label

const TIMER_UI = preload("res://timer_ui.tscn")

@export var level_id : int = -1
var elapsed_time : int = 0
var elapsed_time_precise : float = 0.0
var timer_running : bool = true

func _ready():
	#timer.timeout.connect(_on_Timer_timeout)
	#end_area.body_entered.connect(_on_area_2d_body_entered)
	
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
	if body is CharacterBody2D:
		call_deferred("_end_level")

func _end_level():
	timer_running = false
	timer.stop()
	AutoLoadTimer.set_level_time(level_id, elapsed_time_precise)
	call_deferred("_go_to_menu")

func _go_to_menu():
	get_tree().change_scene_to_file("res://menu.tscn")
