extends Node2D

@onready var timer = $Timer
@onready var label = $CanvasLayer/TimerLabel


var elapsed_time : int = 0
var elapsed_time_precise : float = 0.0
var timer_running : bool = true

func _ready():
	timer.start()

func _on_Timer_timeout():
	if timer_running:
		elapsed_time += 1
		var minutes = elapsed_time / 60
		var seconds = elapsed_time % 60
		label.text = "Temps : %02d:%02d" % [minutes, seconds]

func _process(delta):
	if timer_running:
		elapsed_time_precise += delta

func _on_area_2d_body_entered(body):
	if body is CharacterBody2D:
		call_deferred("_end_level")

func _end_level():
	timer_running = false
	timer.stop()
	if ("Level 2" not in AutoLoadTimer.level_times || elapsed_time_precise < AutoLoadTimer.get_level_time("Level 2")) :
		AutoLoadTimer.set_level_time("Level 2", elapsed_time_precise)
	call_deferred("_go_to_menu")

func _go_to_menu():
	get_tree().change_scene_to_file("res://menu.tscn")
