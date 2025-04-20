class_name ClientConnection extends Node

var input_log = []
@onready var http: HTTPRequest = $HTTPRequest

func send_test_score():
	var payload = {
		"steam_id": "1234567890",
		"auth_ticket": "FAKE_TICKET",
		"time": 53.21,
		"inputs": input_log,
		"version": 0
	}

	var json : String = JSON.stringify(payload)

	http.request("http://localhost:8000/submit_score", ["Content-Type: application/json"], HTTPClient.METHOD_POST, json)
