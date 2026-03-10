extends Node2D

var tween: Tween
var currentVersion: float
var serverVersion: float
var pending_pck_url: String

var fake_progress: float = 0.0
var downloading_dlc: bool = false
var fake_speed: float = 4.0   # % mỗi giây (điều chỉnh tùy file)


var versionFile = "user://version.json"
<<<<<<< Updated upstream
var currentVersion
var serverVersion
=======
>>>>>>> Stashed changes
var game_content_path = "user://AllLevel.pck"
#var inter = preload("res://CommonScripts/ads/Interstatial.gd")
#var ad = inter.new()
var rewar = preload("res://CommonScripts/ads/Rewarded.gd")
var rewarAD = rewar.new()
<<<<<<< Updated upstream
var FileControl = preload("res://CommonScripts/FileControl/FileControl.gd")
var fControl = FileControl.new()
=======

# Đường dẫn scene
const MAIN_SCENE := "res://Scene Main Start/main.tscn"
const SPECIAL_SCENE := "res://Special Main Scene/special_main.tscn"
>>>>>>> Stashed changes

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
	
	# Kiểm tra version hiện có và load Resource Pack (AllLevel.pck)
	# 1. Kiểm tra version nội bộ thông qua Autoload Singleton
	currentVersion = FileControl._local_version_check()
	FileControl._check_and_load_resource_pack()
	print("Local Version: ", currentVersion)
	
	# 2. Gọi Server Render check update
	print("Checking update from Render Server...")
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._on_render_update_response)

	var server_url = "https://game-update-server-q7tg.onrender.com/api/levels/latest"
	var error = http_request.request(server_url)
	
	if error != OK:
<<<<<<< Updated upstream
		push_error("An error occurred in the HTTP request.")	

=======
		push_error("Không thể kết nối tới Server Render.")
	
>>>>>>> Stashed changes
	
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
<<<<<<< Updated upstream
	animate_button_up($"LevelSelectBt")
	AudioController.play_click()
	#get_tree().change_scene_to_file("res://UI/level_select_menu.tscn")
	get_tree().change_scene_to_file.call_deferred("res://UI/level_select_menu.tscn")
# Quit Button
=======
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
		FileControl._load_special_dlc()
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
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
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
		$Loading.visible = true
		print("new update is available...")
=======
# --- 1. Xử lý phản hồi từ Render Server ---
func _on_render_update_response(result, response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("❌ Server không phản hồi (Code: ", response_code, ")")
		return
>>>>>>> Stashed changes
		
	var json_data = JSON.parse_string(body.get_string_from_utf8())
	if json_data and json_data.has("success") and json_data.success:
		serverVersion = float(json_data.version)
		
		# SỬA TẠI ĐÂY: Đổi pck_url thành url
		pending_pck_url = json_data.url 
		
		print("Server Version: ", serverVersion, " | Local Version: ", currentVersion)
		
		if serverVersion > currentVersion:
			print("🚀 Bắt đầu tải DLC từ: ", pending_pck_url)
			
			# Kiểm tra và tạo folder nếu chưa có
			if !DirAccess.dir_exists_absolute(FileControl.dlc_folder):
				DirAccess.make_dir_recursive_absolute(FileControl.dlc_folder)
			
			if has_node("Loading"):
				$Loading.visible = true

			fake_progress = 0
			downloading_dlc = true
			_update_progress_ui(0)

			_start_download_dlc(pending_pck_url)


# --- 2. Hàm bắt đầu tải file .pck ---
func _start_download_dlc(url):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	# Dùng đường dẫn từ Singleton
	http_request.set_download_file(FileControl.dlc_path) 
	http_request.request_completed.connect(self._on_dlc_download_finished)
	http_request.request(url)


# --- 3. Xử lý sau khi tải xong PCK ---
func _on_dlc_download_finished(result, response_code, _headers, _body):
	downloading_dlc = false

	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		_update_progress_ui(100)
		await get_tree().create_timer(0.3).timeout

		FileControl._save_local_version(serverVersion)
		currentVersion = serverVersion

		if has_node("Loading"):
			$Loading.visible = false

		print("✅ Đã tải và cập nhật DLC mới thành công!")

	else:
		if has_node("Loading"):
			$Loading.visible = false

		print("❌ Tải DLC thất bại!")


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


func _process(delta):
	if downloading_dlc:
		if fake_progress < 90.0:
			fake_progress = lerp(fake_progress, 90.0, delta * 0.5)
			_update_progress_ui(fake_progress)


func _update_progress_ui(value: float):
	value = clamp(value, 0, 100)

	if has_node("Loading/ProgressBar"):
		var bar = $Loading/ProgressBar
		bar.value = value

	# 👉 THÊM PHẦN NÀY CHO RUNNER
		if has_node("Loading/Runner"):
			var runner = $Loading/Runner
			
			var bar_width = bar.size.x
			var offset_x = (bar_width * value) / 100.0
			var target_x = bar.position.x + offset_x

			if value >= 100:
				# Khi hoàn tất thì set thẳng
				runner.position.x = target_x
			else:
				# Khi đang chạy thì lerp cho mượt
				runner.position.x = lerp(runner.position.x, target_x, 0.2)

	if has_node("Loading/Label"):
		var percent_text = str(int(value)) + "%"

		if value < 30:
			$Loading/Label.text = "Đang kiểm tra dữ liệu... (" + percent_text + ")"
		elif value < 85:
			$Loading/Label.text = "Đang tải nội dung mới... (" + percent_text + ")"
		elif value < 100:
			$Loading/Label.text = "Đang hoàn tất... (" + percent_text + ")"
		else:
			$Loading/Label.text = "Hoàn tất!"
