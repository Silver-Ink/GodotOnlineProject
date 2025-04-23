class_name TimerGlobal
extends Node

var level_times := {}  # Exemple : { "Level1": 42.53, "Level2": 36.12 }

func set_level_time(level_name: String, time: float):
	level_times[level_name] = time

func get_level_time(level_name: String) -> float:
	return level_times.get(level_name, 0.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
