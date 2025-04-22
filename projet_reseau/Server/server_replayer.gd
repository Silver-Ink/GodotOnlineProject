extends Node

func _ready():
	
	var args = OS.get_cmdline_args()
	var inputs := ""
	if args.size() > 0:
		inputs = args[0]
		
	var expected_time := 0.
	if (args.size() > 1):
		expected_time = args[0]
	
	print("receive input")
	print(inputs)
	print("receive time")
	print(expected_time)

	#var simulated_time = simulate_game(inputss)

	if expected_time < 10:
		get_tree().quit(0)
	else:
		get_tree().quit(1)
