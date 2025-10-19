extends Node2D

var tween: Tween
var versionFile = "res://version.json"
var currentVersion
var serverVersion
var game_content_path = "res://game_content/AllLevel.zip"

func _ready():
	# Connect TouchScreenButton signals
	$"Start-BT".pressed.connect(_on_start_bt_down)
	$"Start-BT".released.connect(_on_start_bt_up)
	$"LevelSelectBt".pressed.connect(_on_level_select_bt_down)
	$"LevelSelectBt".released.connect(_on_level_select_bt_up)
	$"Quit-BT".pressed.connect(_on_quit_bt_down)
	$"Quit-BT".released.connect(_on_quit_bt_up)
	print("running patch downloader...")
	
	_load_version_file(versionFile)
	
	_load_level_resources()
	
	$Version.text = "Version: "+ str(currentVersion)
	#creating new HTTPRequest 
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._server_version_request)
	
	var error = http_request.request("https://raw.githubusercontent.com/GameUnity-2025/Troll-Godot-Adventure/main/UpdateFiles/serverVersion.json")
	if error != OK:
		push_error("An error occurred in the HTTP request.")	

	
func animate_button_down(button: Node):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(button, "scale", button.scale * 0.9, 0.1)

func animate_button_up(button: Node):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(button, "scale", button.scale / 0.9, 0.1)

# Start Button
func _on_start_bt_down():
	animate_button_down($"Start-BT")

func _on_start_bt_up():
	animate_button_up($"Start-BT")
	$"/root/AudioController".play_click()
	
	# Vào level cuối cùng đã unlock thay vì current_level
	var last_unlocked = GameManager.max_level_unlocked
	print("Going to last unlocked level: ", last_unlocked)
	GameManager.go_to_level(last_unlocked)

# Level Select Button  
func _on_level_select_bt_down():
	animate_button_down($"LevelSelectBt")

func _on_level_select_bt_up():
	animate_button_up($"LevelSelectBt")
	AudioController.play_click()
	get_tree().change_scene_to_file.call_deferred("res://UI/level_select_menu.tscn")

# Quit Button
func _on_quit_bt_down():
	animate_button_down($"Quit-BT")

func _on_quit_bt_up():
	animate_button_up($"Quit-BT")
	$"/root/AudioController".play_click()
	get_tree().quit()

# Keep old functions for compatibility (but they won't be called)
func _on_quit_bt_pressed() -> void:
	pass

func _on_start_bt_pressed() -> void:
	pass

func _on_level_select_bt_pressed() -> void:
	pass

#HTTPRequest for server version completion
func _server_version_request(result, response_code, headers, body):
	print("downloading...")
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("patch could not be downloaded")
	print(HTTPRequest.RESULT_SUCCESS)
	
	#var content = body.get_string_from_utf8()
	var json = JSON.new()
	var content = json.parse_string(body.get_string_from_utf8())
	var response = content["version"]
	print("Content from remote file:")
	print(response)
	serverVersion = response
	
	#Check version
	if(serverVersion > currentVersion):
		print("new update is available...")
		$UpdateCheck.text = "updating to... "+ str(serverVersion)
		
		#Download new server game content file
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.request_completed.connect(self._file_version_request)
		
		var error = http_request.request("https://raw.githubusercontent.com/GameUnity-2025/Troll-Godot-Adventure/main/UpdateFiles/AllLevel.zip")
		if error != OK:
			push_error("An error occurred in the HTTP request.")	
	else:
		print("version up to date...")
		$UpdateCheck.text = "your version is up to date"
	

#Getting JSON version file local
func _load_version_file(versionFile: String):
	if FileAccess.file_exists(versionFile):
		var dataFromFile = FileAccess.open(versionFile, FileAccess.READ)
		var versionFromfile = JSON.parse_string(dataFromFile.get_as_text())
		var version = versionFromfile["version"]
		print(version)
		currentVersion = version
	else:
		print("Missing version file ???")

func _load_level_resources():
	if ProjectSettings.load_resource_pack(game_content_path):
		print("loaded game content file...")
	else: 
		print("no game content file found")

func _file_version_request(result, response_code, headers, body):
	print("downloading files...")
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("patch could not be downloaded")
	print(HTTPRequest.RESULT_SUCCESS)
	
	var file = FileAccess.open("res://game_content/AllLevel.zip", FileAccess.WRITE)
	if file:
		file.store_buffer(body)
		file.close()
		print("saving new file to game_content...")
	else:
		print("Error saving file.")
	if ProjectSettings.load_resource_pack("res://game_content/AllLevel.zip"):
		print("load new resource pack...")
		
		#load local version and modify
		#optimize later so doesnt have to open twice 
		var dataFromFile = FileAccess.open(versionFile, FileAccess.READ)
		var versionFromfile = JSON.parse_string(dataFromFile.get_as_text())
		versionFromfile["version"] = serverVersion
		
		#debug 
		var version = versionFromfile["version"]
		print("updated version")
		print(version)
		#debug
		
		var writeFile = FileAccess.open(versionFile, FileAccess.WRITE)
		var stringified = JSON.stringify(versionFromfile,"\t")
		writeFile.store_string(stringified)
		writeFile.close()
		
		
		currentVersion = version
		$Version.text = "Version: "+ str(currentVersion)
		$UpdateCheck.text = "Up to Date !"
	else:
		print("something went wrong, cannot load resource pack")
