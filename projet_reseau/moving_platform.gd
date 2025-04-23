extends Node2D

@export var upLimit := Vector2(0.0, 0.0)  # Direction du mouvement de la plateforme
@export var maxWait := 1  # Temps d'attente avant le mouvement
@export var maxTime := 1  # Temps de déplacement

var currentVelocity := Vector2.ZERO
var waiting := 0.0
var time := 0.0
var lastNormalPosition: Vector2
var player: CharacterBody2D  # Référence au joueur
var is_player_on_platform := false  # Vérifie si le joueur est sur la plateforme

# Appelé quand le nœud entre dans la scène
func _ready():
	lastNormalPosition = position
	waiting = 0.0
	time = 0.0

# Appelé chaque frame
func _process(delta):
	# Attente avant de commencer le mouvement
	if waiting <= maxWait :
		currentVelocity = Vector2.ZERO
		waiting += delta
		return

	# Si la plateforme est en mouvement
	if time <= maxTime:
		var nextPosition = position + delta * upLimit
		
		# Si le joueur est sur la plateforme, colle-le à la plateforme
		if is_player_on_platform:
			player.position += nextPosition - position
		
		
		position = nextPosition
		time += delta
		return
	
	# Si la plateforme a terminé le mouvement, inverse sa direction
	position = lastNormalPosition + upLimit
	lastNormalPosition = position
	waiting = 0.0
	time = 0.0
	upLimit *= -1

# Fonction pour détecter si le joueur est sur la plateforme
func _on_area_2d_body_entered(body):
	if body is Player:
		player = body
		is_player_on_platform = true


func _on_area_2d_body_exited(body):
	if body is Player:
		player = null
		is_player_on_platform = false
