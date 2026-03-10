extends Node2D

var tween: Tween
var versionFile = "user://version.json"
var currentVersion
var serverVersion
var game_content_path = "user://test2s1.pck"
#var inter = preload("res://CommonScripts/ads/Interstatial.gd")
#var ad = inter.new()
var rewar = preload("res://CommonScripts/ads/Rewarded.gd")
var rewarAD = rewar.new()
var FileControl = preload("res://CommonScripts/FileControl/FileControl.gd")
var fControl = FileControl.new()
# Đường dẫn scene
const MAIN_SCENE := "res://Scene Main Start/main.tscn"
const SPECIAL_SCENE := "res://Special Main Scene/special_main.tscn"


const MAIN_LEVEL_SELECT := "res://UI/level_select_menu.tscn"
const SPECIAL_LEVEL_SELECT := "res://Special Main Scene/SpecialLevelSelect.tscn"
func _ready():

	# START
	$"StartRoot/Start-BT".pressed.connect(
		func(): animate_button_down($StartRoot)
	)
	$"StartRoot/Start-BT".released.connect(
		func():
			animate_button_up($StartRoot)
			_on_start_bt_up()
	)

	# LEVEL SELECT
	$LevelRoot/LevelSelectBt.pressed.connect(
		func(): animate_button_down($LevelRoot)
	)
	$LevelRoot/LevelSelectBt.released.connect(
		func():
			animate_button_up($LevelRoot)
			_on_level_select_bt_up()
	)

	# QUIT
	$"QuitRoot/Quit-BT".pressed.connect(
		func(): animate_button_down($QuitRoot)
	)
	$"QuitRoot/Quit-BT".released.connect(
		func():
			animate_button_up($QuitRoot)
			_on_quit_bt_up()
	)

	# TROLL 😈
	$"TrollRoot/Troll-Bt".pressed.connect(
		func(): animate_button_down($TrollRoot)
	)
	$"TrollRoot/Troll-Bt".released.connect(
		func():
			animate_button_up($TrollRoot)
			_on_troll_bt_up()
	)
	print("running patch downloader...")
	# Defer AdMob init to next frame so Godot renders first frame before blocking
	# This fixes gray screen on remote deploy
	add_child(rewarAD)
	await get_tree().process_frame
	#ad._on_load_pressed()
	rewarAD._on_load_pressed.call_deferred()
	print("ad loaded")
	
	#debug update
	#fControl._debug_update_by_version()
	
	currentVersion = fControl._local_version_check()
	fControl._check_and_load_resource_pack()
	
	
	#creating new HTTPRequest 
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._server_version_request)
	
	var error = http_request.request("https://raw.githubusercontent.com/GameUnity-2025/Troll-Godot-Adventure/refs/heads/main/UpdateFiles/serverVersion.json")
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	
	# Nhạc
	var current_path := get_tree().current_scene.scene_file_path
	if current_path == SPECIAL_SCENE:
		AudioController.play_special_music()
	else:
		AudioController.play_main_music()


# --- XỬ LÝ NÚT START ---
func _on_start_bt_down():
	animate_button_down($"StartRoot/Start-BT")

func _on_start_bt_up():
	animate_button_up($"StartRoot/Start-BT")
	$"/root/AudioController".play_click()
	

	
	# 2. Kiểm tra đang ở Menu nào để hành động tương ứng
	var current_path := get_tree().current_scene.scene_file_path
	
	if current_path == SPECIAL_SCENE:
		# --- CHẾ ĐỘ SPECIAL ---
		# Start game = Luôn bắt đầu từ Level 1 + Có Intro kể chuyện
		print("MAIN: Bắt đầu Special Mode!")
		GameManager.start_special_level(1) 
		
	else:
		# --- CHẾ ĐỘ MAIN THƯỜNG ---
		# Start game = Tiếp tục level cao nhất đã mở (Load Progress)
		var last_unlocked = GameManager.max_level_unlocked
		print("MAIN: Tiếp tục Main Mode tại level: ", last_unlocked)
		GameManager.go_to_level(last_unlocked)

# --- XỬ LÝ NÚT LEVEL SELECT ---
func _on_level_select_bt_down():
	animate_button_down($LevelRoot/LevelSelectBt)

func _on_level_select_bt_up():
	animate_button_up($LevelRoot/LevelSelectBt)
	$"/root/AudioController".play_click()
	
	# Điều hướng sang bảng chọn level tương ứng
	var current_path := get_tree().current_scene.scene_file_path
	
	if current_path == SPECIAL_SCENE:
		# Mở bảng chọn level của Special (1-10)
		if ResourceLoader.exists(SPECIAL_LEVEL_SELECT):
			get_tree().change_scene_to_file.call_deferred(SPECIAL_LEVEL_SELECT)
		else:
			print("❌ Chưa tạo file SpecialLevelSelect.tscn!")
	else:
		# Mở bảng chọn level thường (1-50)
		get_tree().change_scene_to_file.call_deferred(MAIN_LEVEL_SELECT)

# --- XỬ LÝ NÚT TROLL (CHUYỂN ĐỔI MAIN <-> SPECIAL) ---


func _on_troll_bt_down():
	animate_button_down($"TrollRoot/Troll-Bt")

func _on_troll_bt_up():
	animate_button_up($"TrollRoot/Troll-Bt")
	$"/root/AudioController".play_click()	
	# ✨ HIỆU ỨNG ĐẶC BIỆT CHO NÚT TROLL ✨
	# 1. Screen shake rung lắc
	screen_shake(0.4, 15.0, 40.0)
	
	# 2. Flash đỏ nhẹ
	screen_flash(Color(1.0, 0.3, 0.3, 0.4), 0.3)
	
	# 3. Zoom effect cho button
	var zoom_tween = create_tween()
	zoom_tween.tween_property($TrollRoot, "scale", Vector2(1.2, 1.2), 0.1)
	zoom_tween.tween_property($TrollRoot, "scale", Vector2.ONE, 0.15)
	
	# 4. Chờ một chút rồi mới chuyển scene (cho hiệu ứng chạy xong)
	await get_tree().create_timer(0.4).timeout
	_toggle_main_special_scene()

func _toggle_main_special_scene():
	var current_scene := get_tree().current_scene
	if not current_scene: return

	var current_path := current_scene.scene_file_path
	var next_scene := ""

	if current_path == MAIN_SCENE:
		next_scene = SPECIAL_SCENE
	elif current_path == SPECIAL_SCENE:
		next_scene = MAIN_SCENE
	else:
		next_scene = MAIN_SCENE # Mặc định về Main nếu lạc trôi

	if ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file.call_deferred(next_scene)
	else:
		push_error("❌ Scene not found: " + next_scene)

# --- CÁC HÀM PHỤ TRỢ KHÁC (Quit, Animation, Popup) GIỮ NGUYÊN ---
func _on_quit_bt_down():
	animate_button_down($"QuitRoot/Quit-BT")

func _on_quit_bt_up():
	animate_button_up($"QuitRoot/Quit-BT")
	$"/root/AudioController".play_click()
	get_tree().quit()

func animate_button_down(root: Node2D):
	if not is_instance_valid(root): return
	
	if tween: tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(root, "scale", Vector2(0.9, 0.9), 0.1)


func animate_button_up(root: Node2D):
	if not is_instance_valid(root): return
	
	if tween: tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(root, "scale", Vector2.ONE, 0.15)

# --- SCREEN SHAKE EFFECT ---
func screen_shake(duration: float = 0.3, intensity: float = 10.0, frequency: float = 30.0):
	"""Tạo hiệu ứng rung màn hình - shake toàn bộ scene"""
	var original_position = position
	var elapsed = 0.0
	
	# Tạo shake bằng timer
	var shake_timer = Timer.new()
	shake_timer.wait_time = 1.0 / frequency
	shake_timer.one_shot = false
	add_child(shake_timer)
	
	var shake_callable = func():
		elapsed += shake_timer.wait_time
		if elapsed >= duration:
			position = original_position
			shake_timer.stop()
			shake_timer.queue_free()
		else:
			var progress = 1.0 - (elapsed / duration)
			var shake_amount = intensity * progress
			position = original_position + Vector2(
				randf_range(-shake_amount, shake_amount),
				randf_range(-shake_amount, shake_amount)
			)
	
	shake_timer.timeout.connect(shake_callable)
	shake_timer.start()

func screen_flash(color: Color = Color(1, 0, 0, 0.3), duration: float = 0.2):
	"""Tạo hiệu ứng flash màn hình"""
	var flash = ColorRect.new()
	flash.color = color
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var canvas = CanvasLayer.new()
	canvas.layer = 150
	canvas.add_child(flash)
	add_child(canvas)
	
	var flash_tween = create_tween()
	flash_tween.tween_property(flash, "modulate:a", 0.0, duration)
	flash_tween.tween_callback(func(): canvas.queue_free())



# Keep old functions for compatibility (but they won't be called)
func _on_quit_bt_pressed() -> void:
	pass

func _on_start_bt_pressed() -> void:
	pass

func _on_level_select_bt_pressed() -> void:
	pass

#HTTPRequest for server version completion
func _server_version_request(result, _response_code, _headers, body):
	print("downloading version file ...")
	if result != HTTPRequest.RESULT_SUCCESS:
		push_error("patch could not be downloaded")
	print(HTTPRequest.RESULT_SUCCESS)
	
	#var content = body.get_string_from_utf8()
	#var json = JSON.new()
	var content = JSON.parse_string(body.get_string_from_utf8())
	var response = content["version"]
	print("remote version" + str(response))
	serverVersion = response
	
	#Check version
	
	if(serverVersion > currentVersion):
		if has_node("Loading"):
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
			
			if has_node("Loading"):
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
	
