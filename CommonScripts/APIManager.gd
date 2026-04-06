extends Node

signal player_data_loaded(data)

var BASE_URL = "http://localhost:3000"

# 🔥 DÁN TOKEN TEST VÀO ĐÂY
var token: String = ""
var token_file = "user://token.save"
var is_ready = false


signal death_response(data)

func _ready():
	load_token()
	is_ready = true
	if token != "":
		print("🔑 Auto login detected. Fetching data...")
		get_player_data()
	else:
		print("ℹ️ No token found. Waiting for login.")

# --- QUẢN LÝ TOKEN ---

func save_token():
	var file = FileAccess.open(token_file, FileAccess.WRITE)
	if file:
		file.store_string(token)
		file.close()
		print("💾 Token saved to local storage.")

func load_token():
	if FileAccess.file_exists(token_file):
		var file = FileAccess.open(token_file, FileAccess.READ)
		var saved = file.get_as_text()
		file.close()
		if saved.strip_edges() != "":
			token = saved
			print("🔑 Loaded token from file.")
			return
	token = ""

func send_death():
	request_api("/player/death", HTTPClient.METHOD_POST, func(result, code, body):
		print("📡 Response code:", code)
		print("📦 Raw:", body.get_string_from_utf8())

		if code != 200:
			print("❌ API ERROR")
			return

		var json = JSON.parse_string(body.get_string_from_utf8())
		if json == null:
			print("❌ JSON parse error")
			return

		death_response.emit(json)
	)

func get_player_data():
	request_api("/player/me", HTTPClient.METHOD_GET, func(result, code, body):

		if code == 401:
			print("🔒 Token expired (player_data)")
			logout()
			return

		if result != HTTPRequest.RESULT_SUCCESS or code != 200:
			print("❌ Get player data failed")
			return

		var json = JSON.parse_string(body.get_string_from_utf8())
		if json == null:
			print("❌ JSON parse error")
			return

		print("📥 Player data:", json)
		player_data_loaded.emit(json)
	)

func update_progress(current_level, max_level):
	var http = HTTPRequest.new()
	add_child(http)

	var body = JSON.stringify({
		"current_level": current_level,
		"max_level_unlocked": max_level
	})

	http.request_completed.connect(func(result, code, headers, body):
		http.queue_free()

		if code == 401:
			print("🔒 Token expired")
			logout()
			return

		if result == HTTPRequest.RESULT_SUCCESS and code == 200:
			print("✅ Progress synced to server")
		else:
			print("❌ Failed to sync progress")
	)

	var headers = [
		"Content-Type: application/json",
		"Authorization: " + token
	]

	http.request(BASE_URL + "/player/progress", headers, HTTPClient.METHOD_POST, body)

func register(username: String, password: String, callback: Callable):
	var http = HTTPRequest.new()
	add_child(http)

	var body = JSON.stringify({
		"username": username,
		"password": password
	})

	http.request_completed.connect(func(result, code, headers, response_body):
		http.queue_free()

		print("📡 Register code:", code)
		print("📦 Register response:", response_body.get_string_from_utf8())

		if result != HTTPRequest.RESULT_SUCCESS or code != 200:
			callback.call(false, "Register failed")
			return

		callback.call(true, "Registered successfully")
	)

	var headers = [
		"Content-Type: application/json"
	]

	http.request(BASE_URL + "/auth/register", headers, HTTPClient.METHOD_POST, body)
	
func login(username: String, password: String, callback: Callable):
	var http = HTTPRequest.new()
	add_child(http)

	var body = JSON.stringify({
		"username": username,
		"password": password
	})

	http.request_completed.connect(func(result, code, headers, response_body):
		http.queue_free()

		print("📡 Login code:", code)
		print("📦 Login response:", response_body.get_string_from_utf8())

		if result != HTTPRequest.RESULT_SUCCESS or code != 200:
			callback.call(false, "Login failed")
			return

		var data = JSON.parse_string(response_body.get_string_from_utf8())

		if data == null:
			callback.call(false, "Invalid server response")
			return

		if data.has("token"):
			token = data.token
			save_token()
			callback.call(true, "Success")
		else:
			callback.call(false, "No token")
	)

	var headers = [
		"Content-Type: application/json"
	]

	http.request(BASE_URL + "/auth/login", headers, HTTPClient.METHOD_POST, body)

func logout():
	token = ""

	if FileAccess.file_exists(token_file):
		DirAccess.remove_absolute(token_file)

	print("🚪 User logged out.")

	get_tree().reload_current_scene()

func request_api(endpoint: String, method: int, callback: Callable, body := ""):
	var http = HTTPRequest.new()
	add_child(http)

	http.request_completed.connect(func(result, code, headers, res_body):
		http.queue_free()

		if result != HTTPRequest.RESULT_SUCCESS:
			print("❌ Network error")
			callback.call(result, code, res_body)
			return

		if code == 401:
			print("🔒 Token expired")
			logout()
			return

		callback.call(result, code, res_body)
	)

	var headers = [
		"Content-Type: application/json"
	]

	if token != "":
		headers.append("Authorization: " + token)

	http.request(BASE_URL + endpoint, headers, method, body)
