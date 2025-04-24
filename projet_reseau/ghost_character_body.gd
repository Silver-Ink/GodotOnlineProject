class_name Ghost
extends CharacterBody2D

const SPEED = 200.0
const MAX_SPEED = 800.0
const ACCELERATION = 1000.0
const DECELERATION = 1000.0
const JUMP_VELOCITY = -900.0
const BOUNCE_FACTOR = 1.0

var playback_data = []
var playback_index = 0
var playback_time = 0.0

var current_actions: Array[int] = []

var jump := false
var old_jump := false

var left := false
var right := false

func load_actions(path: String):
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		print("Erreur lors de la lecture du fichier ghost")
		return
	
	playback_data.clear()
	
	while not file.eof_reached():
		var t = file.get_float()
		var count = file.get_8()
		print("Temps : ", t, " Nombre d'actions : ", count)
		var actions: Array[int] = []
		for i in range(count):  # Correction ici, on parcourt le nombre d'actions, pas `count` directement
			var action = file.get_8()
			print("Action lue : ", action)
			actions.append(action)
		playback_data.append({ "time": t, "actions": actions })
	
	print("Données lues : ", playback_data)  # Afficher les données du fichier pour vérifier le format


func start_playback():
	playback_index = 0
	playback_time = 0.0
	#is_playing = true
	print("Début de la lecture des actions")

func _physics_process(delta):
	playback_time += delta
	
	while playback_index < playback_data.size() and playback_data[playback_index]["time"] <= playback_time:
		current_actions = playback_data[playback_index]["actions"]
		print("Actions à jouer : ", current_actions)
		playback_index += 1

	# --- Mouvements simulés comme le joueur ---
	if not is_on_floor():
		velocity += get_gravity() * delta

	if (jump && !old_jump) and is_on_floor():  # game_jump
		velocity.y = JUMP_VELOCITY
		#print("Saut effectué")

	var previous_velocity = velocity
	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if abs(collision.get_normal().x) > 0.9:
			velocity.x = -previous_velocity.x * BOUNCE_FACTOR
			#print("Rebond horizontal appliqué")
			break

	# Setting direction according to booleans
	var direction = 0
	if (left and not right):
		direction = -1
	if (right and not left):
		direction = 1

	if direction != 0:
		if sign(direction) == sign(velocity.x) or velocity.x == 0:
			var target_speed = move_toward(abs(velocity.x), MAX_SPEED, ACCELERATION * delta)
			velocity.x = direction * target_speed
			#print("Vitesse horizontale appliquée : ", velocity.x)
		else:
			velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

	# Afficher la position et la vitesse pour le débogage
	#print("Position actuelle : ", position, " | Vitesse : ", velocity)
	
	# Update "old input" values
	old_jump = jump
