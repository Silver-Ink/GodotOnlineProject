class_name ClientConnection extends Node

@onready var http: HTTPRequest = $HTTPRequest


func send_test_score():
	var steam_id = Steam.getSteamID()
	var ticket = Steam.getAuthSessionTicket()
	var size = ticket["size"]
		
	var payload = {
		"steam_id": steam_id,
		"auth_ticket": ticket,
		"ticket_size": size,
		"inputs": "placeholder_input_data",
		"time": 9.21,
		"version": 0
	}
	var json_payload = JSON.stringify(payload)
	http.request("http://127.0.0.1:8000/submit_score", ["Content-Type: application/json"], HTTPClient.METHOD_POST, json_payload)


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("===================")
	print("result = ", result)
	print("response = ", response_code)
	print("headers = ", headers)
	print("body = ", body)
