class_name ClientConnection extends Node

signal server_connected
signal score_submitted
signal daily_level_got(level : int)
signal daily_ranking_got(rank : int)
signal nearby_ghosts_got(ghosts : Dictionary)
signal best_time_got(time : float)

@onready var http_connect_to_server: HTTPRequest = $HTTP_connect_to_server
@onready var http_submit_score: HTTPRequest = $HTTP_submit_score
@onready var http_get_daily_level: HTTPRequest = $HTTP_get_daily_level
@onready var http_get_daily_ranking: HTTPRequest = $HTTP_get_daily_ranking
@onready var http_get_nearby_ghosts: HTTPRequest = $HTTP_get_nearby_ghosts
@onready var http_get_best_time: HTTPRequest = $HTTP_get_best_time

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
	var result = send_request(HTTPClient.METHOD_POST, "connect", http_connect_to_server, payload)
	
func _on_connected_to_server(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if (result == 0 && response_code == HTTPClient.RESPONSE_OK):
		connected = true
		server_connected.emit()
		print("connected successfully !")
	else:
		printerr("Error during connection")
		
		
		
		
	
func submit_test_score(inputs : String, time : float):
	var payload = {
		"steam_id": steam_id,
		"auth_ticket": ticket,
		"inputs": inputs,
		"time": time
	}
	send_request(HTTPClient.METHOD_POST, "submit_score", http_submit_score, payload)
	
func _on_score_submitted(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if (result == 0 && response_code == HTTPClient.RESPONSE_OK):
		score_submitted.emit()
		print("score submitted successfully")
	else:
		printerr("Error sending scores")
	
	
	
	
func get_daily_level():
	send_request(HTTPClient.METHOD_GET, "daily_level", http_get_daily_level)
	
func _on_daily_level_got(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if (result == 0 && response_code == HTTPClient.RESPONSE_OK):
		var json : Dictionary = JSON.parse_string(body.get_string_from_utf8())
		var level = json["daily_level"]
		daily_level_got.emit(int(level))
		print("daily level received : ", level)
	else:
		printerr("Error getting level")
	



func get_daily_ranking(time : float):
	var url = "daily_ranking?claimed_time=%f" % time
	send_request(HTTPClient.METHOD_GET, url.uri_encode(), http_get_daily_ranking)
	
func _on_daily_ranking_got(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if (result == 0 && response_code == HTTPClient.RESPONSE_OK):
		var json : Dictionary = JSON.parse_string(body.get_string_from_utf8())
		var rank = json["ranking"]
		daily_ranking_got.emit(int(rank))
		print("rank received : ", rank)
	else:
		printerr("Error getting rank")
		
		
		
		
func get_nearby_ghosts(time : float):
	var url = "nearby_ghosts?claimed_time=%f" % time
	send_request(HTTPClient.METHOD_GET, url, http_get_nearby_ghosts)
	
func _on_nearby_ghosts_got(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if (result == 0 && response_code == HTTPClient.RESPONSE_OK):
		var json : Dictionary = JSON.parse_string(body.get_string_from_utf8())
		var ghosts : Dictionary = json["ghosts"]
		print("ghosts received : ", ghosts)
		nearby_ghosts_got.emit(ghosts)
	else:
		printerr("Error getting ghosts")
		
		
		
		
func get_best_time(level : int):
	var url = "best_time?steam_id=%s&level=%s" % [steam_id, level] 
	send_request(HTTPClient.METHOD_GET, url, http_get_best_time)
	
func _on_best_time_got(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	if (result == 0 && response_code == HTTPClient.RESPONSE_OK):
		var json : Dictionary = JSON.parse_string(body.get_string_from_utf8())
		var time : float = json["best_time"]
		best_time_got.emit(time)
		print("Best time received", time)
	else:
		printerr("Error getting best time")





func send_request(method : HTTPClient.Method, page : String, http_node : HTTPRequest, payload_dict : Dictionary = {}):
	var json_payload := ""
	if (!payload_dict.is_empty()):
		json_payload = JSON.stringify(payload_dict)
	return http_node.request(server_adress + page, ["Content-Type: application/json"], method, json_payload)
