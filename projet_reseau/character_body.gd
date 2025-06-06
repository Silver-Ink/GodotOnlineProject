class_name Player extends CharacterBody2D

const SPEED = 200.0
const MAX_SPEED = 800.0
const ACCELERATION = 1000.0
const DECELERATION = 1000.0
const JUMP_VELOCITY = -900.0
const BOUNCE_FACTOR = 0.65

var facing = 1

@onready var input_record: InputRecord = $InputRecord
@onready var anim: AnimatedSprite2D = $anim

#var velocity := Vector2.ZERO
func start_recording_inputs():
	input_record.start_recording()
	
func stop_recording_inputs():
	input_record.stop_recording()

func get_input_string():
	return input_record.inputs_to_string()
	

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("game_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# ----------------------------
	# 1. Bouger avec la vélocité précédente
	var previous_velocity = velocity
	move_and_slide()
	
	# 2. Détection de collision et rebond éventuel
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if abs(collision.get_normal().x) > 0.9:
			# Rebond horizontal
			velocity.x = -previous_velocity.x * BOUNCE_FACTOR
			break

	# 3. Maintenant appliquer les inputs (seulement après le rebond)
	var direction = Input.get_axis("game_left", "game_right")
	if direction != 0:
		if sign(direction) == sign(velocity.x) or velocity.x == 0:
			# Même direction ou immobile → on accélère
			var target_speed = move_toward(abs(velocity.x), MAX_SPEED, ACCELERATION * delta)
			velocity.x = direction * target_speed
		else:
			# Direction opposée → on freine seulement
			velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
	else:
		# Pas d'input → on freine normalement
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)
		
	
	if (!is_on_floor() && 0 > velocity.x):
		anim.flip_h = true
	else:
		anim.flip_h = false
	
	facing = sign(velocity.x) 
	if (0 > velocity.y):	
		anim.play("jump_right" if facing > 0 else "jump_left")
	elif (velocity.y > 0):
		anim.play("fall_right" if facing > 0 else "fall_left")
	elif (abs(velocity.x) > SPEED * .7):
		anim.play("run_right" if facing > 0 else "run_left")
	else:
		anim.play("idle_right" if facing > 0 else "idle_left")
