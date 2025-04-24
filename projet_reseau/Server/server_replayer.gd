extends Node

func _ready():
	print("start verifying replay")
	var args = OS.get_cmdline_args()
	var inputs := ""
	if args.size() > 0:
		inputs = args[0]
		
	var expected_time := 0.
	if (args.size() > 1):
		expected_time = float(args[1])
	
	print("corrected time:%f;" % expected_time)

	#var simulated_time = simulate_game(inputss)

	if expected_time < 10:
		get_tree().quit(0)
	else:
		get_tree().quit(1)
