class_name ClientConnection extends Node

signal server_connected
signal score_submitted
signal daily_level_got(level : int)
signal daily_ranking_got(rank : int)
signal nearby_ghosts_got(ghosts : Dictionary)

@onready var http_connect_to_server: HTTPRequest = $HTTP_connect_to_server
@onready var http_submit_score: HTTPRequest = $HTTP_submit_score
@onready var http_get_daily_level: HTTPRequest = $HTTP_get_daily_level
@onready var http_get_daily_ranking: HTTPRequest = $HTTP_get_daily_ranking
@onready var http_get_nearby_ghosts: HTTPRequest = $HTTP_get_nearby_ghosts

var server_adress = 'http://127.0.0.1:8000/'

var steam_id : int
var ticket : Dictionary
var connected = false
	
func connect_to_server():
	steam_id = Steam.getSteamID()
	ticket = Steam.getAuthSessionTicket()
	
	var payload = {
	"steam_id": steam_id,
	"auth_ticket": ticket,
	}	
	var result = send_request(HTTPClient.METHOD_POST, "connect", payload, http_connect_to_server)
	
func _on_connected_to_server(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if (result == 0 && response_code == HTTPClient.RESPONSE_OK):
		connected = true
		server_connected.emit()
	else:
		printerr("Error during connection")
		
	
func submit_test_score():
	var payload = {
		"steam_id": steam_id,
		"auth_ticket": ticket,
		"inputs": "placeholder_input_data",
		"time": 9.21,
		"version": 0
	}
	send_request(HTTPClient.METHOD_POST, "submit_score", payload, http_submit_score)
	
func _on_score_submitted(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if (result == 0 && response_code == HTTPClient.RESPONSE_OK):
		score_submitted.emit()
	else:
		printerr("Error sending scores")
	
func get_daily_level():
	var payload = {
		"steam_id": steam_id,
		"auth_ticket": ticket
	}
	send_request(HTTPClient.METHOD_GET, "daily_level", payload, http_get_daily_level)
	
func _on_daily_level_got(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if (result == 0 && response_code == HTTPClient.RESPONSE_OK):
		var json : Dictionary = JSON.parse_string(body.get_string_from_utf8())
		var level = json["daily_level"]
		daily_level_got.emit(int(level))
	else:
		printerr("Error getting level")
			
	
	
func get_daily_ranking():
	var payload = {
		"steam_id": steam_id,
		"auth_ticket": ticket
	}
	send_request(HTTPClient.METHOD_GET, "daily_ranking", payload, http_get_daily_ranking)
	
func _on_daily_ranking_got(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if (result == 0 && response_code == HTTPClient.RESPONSE_OK):
		var json : Dictionary = JSON.parse_string(body.get_string_from_utf8())
		var rank = json["ranking"]
		daily_ranking_got.emit(int(rank))
	else:
		printerr("Error getting level")
		
func get_nearby_ghosts():
	var payload = {
		"steam_id": steam_id,
		"auth_ticket": ticket
	}
	send_request(HTTPClient.METHOD_GET, "nearby_ghosts", payload, http_get_nearby_ghosts)
	
func _on_nearby_ghosts_got(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if (result == 0 && response_code == HTTPClient.RESPONSE_OK):
		var json : Dictionary = JSON.parse_string(body.get_string_from_utf8())
		var ghosts : Dictionary = json["ghosts"]
		print(ghosts)
		nearby_ghosts_got.emit(ghosts)
	else:
		printerr("Error getting level")

func send_request(method : HTTPClient.Method, page : String, payload_dict : Dictionary, http_node : HTTPRequest):
	var json_payload = JSON.stringify(payload_dict)
	return http_node.request(server_adress + page, ["Content-Type: application/json"], method, json_payload)
