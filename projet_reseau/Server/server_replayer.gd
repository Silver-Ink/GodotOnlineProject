extends Node

func _ready():
	
	var args = OS.get_cmdline_args()
	var replay_path = "../server/replay.json"
	if args.size() > 0:
		replay_path = args[0]
		
	var file = FileAccess.open(replay_path, FileAccess.READ)
	if (file):
		print("Found ", replay_path)
	var replay_data = JSON.parse_string(file.get_as_text())
	file.close()
	
	print("Json Retrieved")
	var inputs = replay_data["inputs"]
	var expected_time = replay_data["time"]

	#var simulated_time = simulate_game(inputs)

	if expected_time < 10:
		get_tree().quit(0)
	else:
		get_tree().quit(1)
