class_name TimerGlobal
extends Node

var level_times := {}  # Exemple : { "1": 42.53, "2": 36.12 }

func set_level_time(level_id: int, time: float) -> bool:
	if (level_id == -1):
		level_id = 1
	if (level_times[str(level_id)] > time):
		level_times[str(level_id)] = time
		return true
	return false

func get_level_time(level_id := -1 ) -> float:
	if (level_id == -1):
		level_id = AutoloadClient.daily_level
	return level_times.get(level_id, 0.0)

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(1, AutoloadClient.LEVEL_COUNT + 1):
		level_times[str(i)] = 999.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
