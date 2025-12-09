extends Node2D

var tween: Tween
var versionFile = "user://version.json"
var currentVersion
var serverVersion
var game_content_path = "user://AllLevel.pck"
#var inter = preload("res://CommonScripts/ads/Interstatial.gd")
#var ad = inter.new()
var rewar = preload("res://CommonScripts/ads/Rewarded.gd")
var rewarAD = rewar.new()
var FileControl = preload("res://CommonScripts/FileControl/FileControl.gd")
var fControl = FileControl.new()

func _ready():
	# Connect TouchScreenButton signals
	$"Start-BT".pressed.connect(_on_start_bt_down)
	$"Start-BT".released.connect(_on_start_bt_up)
	$"LevelSelectBt".pressed.connect(_on_level_select_bt_down)
	$"LevelSelectBt".released.connect(_on_level_select_bt_up)
	$"Quit-BT".pressed.connect(_on_quit_bt_down)
	$"Quit-BT".released.connect(_on_quit_bt_up)
	print("running patch downloader...")
	#ad._on_load_pressed()
	rewarAD._on_load_pressed()
	print("ad loaded")
	
	#debug update
	#fControl._debug_update_by_version()
	
	currentVersion = fControl._local_version_check()
	fControl._check_and_load_resource_pack()
	
	
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
	#get_tree().change_scene_to_file("res://UI/level_select_menu.tscn")
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
func _server_version_request(result, _response_code, _headers, body):
	print("downloading...")
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("patch could not be downloaded")
	print(HTTPRequest.RESULT_SUCCESS)
	
	#var content = body.get_string_from_utf8()
	#var json = JSON.new()
	var content = JSON.parse_string(body.get_string_from_utf8())
	var response = content["version"]
	print("Content from remote file:")
	print(response)
	serverVersion = response
	
	#Check version
	
	if(serverVersion > currentVersion):
		$Loading.visible = true
		print("new update is available...")
		
		#Download new server game content file
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.request_completed.connect(self.file_version_request)
		
		var error = http_request.request("https://raw.githubusercontent.com/GameUnity-2025/Troll-Godot-Adventure/main/UpdateFiles/AllLevel.pck")
		if error != OK:
			push_error("An error occurred in the HTTP request.")	
	else:
		print("version up to date...")
	

##Getting JSON version file local
#func _load_version_file(path: String):
	#if FileAccess.file_exists(path):
		#var dataFromFile = FileAccess.open(path, FileAccess.READ)
		#var versionFromfile = JSON.parse_string(dataFromFile.get_as_text())
		#var version = versionFromfile["version"]
		#dataFromFile.close()
		#print(version)
		#currentVersion = version
	#else:
		#print("Missing version file ???")

func _load_level_resources():
	if ProjectSettings.load_resource_pack(game_content_path):
		print("loaded game content file...")
	else: 
		print("no game content file found")

func file_version_request(result, _response_code, _headers, body):
	
	print("downloading files...")
	
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("patch could not be downloaded")
	print(HTTPRequest.RESULT_SUCCESS)
	
	var file = FileAccess.open(game_content_path, FileAccess.WRITE)
	#var file = FileAccess.file_exists(game_content_path)
	if file:
		file.store_buffer(body)
		file.close()
		print("saving new file to game_content...")
		if ProjectSettings.load_resource_pack(game_content_path):
			print("load new resource pack...")
			
			#load local version and modify
			#optimize later so doesnt have to open twice 
			var dataFromFile = FileAccess.open(versionFile, FileAccess.READ)
			var versionFromfile = JSON.parse_string(dataFromFile.get_as_text())
			versionFromfile["version"] = serverVersion
			dataFromFile.close()
			#debug 
			var version = versionFromfile["version"]
			print("updated version")
			print(version)
			#debug
			
			var writeFile = FileAccess.open(versionFile, FileAccess.WRITE)
			print(writeFile)
			var stringified = JSON.stringify(versionFromfile,"\t")
			print(stringified)
			writeFile.store_string(stringified)
			writeFile.close()
			
			
			currentVersion = version
			
			$Loading.visible = false
		else:
			print("something went wrong, cannot load resource pack")
	else:
		print("Error saving file.")

func _on_death_limit_reached():
	print("💀 Death limit reached - UI will handle display")

func _on_daily_death_updated(current: int, max_deaths: int):
	print("Daily deaths updated: %d/%d" % [current, max_deaths])

func _on_show_ins_ad_pressed() -> void:
	#ad._on_show_pressed()
	rewarAD._on_show_pressed()
	DeathLimitManager.try_reduce_death()
	print("showing ad")
	
