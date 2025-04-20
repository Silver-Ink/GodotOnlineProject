class_name ClientConnection extends Node

var input_log = {"a" : 5, "b" : 3}
@onready var http: HTTPRequest = $HTTPRequest

func send_test_score():
	var payload = {
		"steam_id": "1234567890",
		"auth_ticket": "FAKE_TICKET",
		"time": 9.21,
		"inputs": input_log,
		"version": 0
	}

	var json : String = JSON.stringify(payload, "\t")
	var result = http.request("http://127.0.0.1:8000/submit_score", ["Content-Type: application/json"], HTTPClient.METHOD_POST, json)


func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	print("===================")
	print("result = ", result)
	print("response = ", response_code)
	print("headers = ", headers)
	print("body = ", body)
