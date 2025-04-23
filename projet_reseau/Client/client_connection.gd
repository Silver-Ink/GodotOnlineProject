class_name ClientConnection extends Node

@onready var http: HTTPRequest = $HTTPRequest

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
	var result = send_request(HTTPClient.METHOD_POST, "connect", payload)
	if (result == 0):
		connected = true
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
	send_request(HTTPClient.METHOD_POST, "submit_score", payload)
	
func get_daily_level():
	var payload = {
		"steam_id": steam_id,
		"auth_ticket": ticket
	}
	send_request(HTTPClient.METHOD_GET, "daily_level", payload)
	
func get_daily_ranking():
	var payload = {
		"steam_id": steam_id,
		"auth_ticket": ticket
	}
	send_request(HTTPClient.METHOD_GET, "daily_ranking", payload)
	
func get_nearby_ghosts():
	var payload = {
		"steam_id": steam_id,
		"auth_ticket": ticket
	}
	send_request(HTTPClient.METHOD_GET, "nearby_ghosts", payload)
	http.download_file

func send_request(method : HTTPClient.Method, page : String, payload_dict : Dictionary):
	var json_payload = JSON.stringify(payload_dict)
	return http.request(server_adress + page, ["Content-Type: application/json"], method, json_payload)

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("===================")
	print("result = ", result)
	print("response = ", response_code)
	print("headers = ", headers)
	print("body = ", body)
