extends Node

@onready var is_steam_running = false

func _ready():
	if Engine.is_editor_hint(): return

	if Steam.steamInit():
		is_steam_running = true
		print("Steam initialized with username : ", Steam.getPersonaName())
	else:
		print("Steam not initialized")
