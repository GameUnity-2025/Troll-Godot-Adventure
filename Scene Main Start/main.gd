extends Node2D

var tween: Tween
var currentVersion: float
var serverVersion: float
var pending_pck_url: String

var fake_progress: float = 0.0
var downloading_dlc: bool = false
var fake_speed: float = 4.0

var versionFile = "user://version.json"
var game_content_path = "user://AllLevel.pck"

var rewar = preload("res://CommonScripts/ads/Rewarded.gd")
var rewarAD = rewar.new()

const MAIN_SCENE := "res://Scene Main Start/main.tscn"
const SPECIAL_SCENE := "res://Special Main Scene/special_main.tscn"
const MAIN_LEVEL_SELECT := "res://UI/level_select_menu.tscn"
const SPECIAL_LEVEL_SELECT := "res://Special Main Scene/SpecialLevelSelect.tscn"

func _ready():
	$"StartRoot/Start-BT".pressed.connect(
		func(): animate_button_down($StartRoot)
	)
	$"StartRoot/Start-BT".released.connect(
		func():
			animate_button_up($StartRoot)
			_on_start_bt_up()
	)

	$LevelRoot/LevelSelectBt.pressed.connect(
		func(): animate_button_down($LevelRoot)
	)
	$LevelRoot/LevelSelectBt.released.connect(
		func():
			animate_button_up($LevelRoot)
			_on_level_select_bt_up()
	)

	$"QuitRoot/Quit-BT".pressed.connect(
		func(): animate_button_down($QuitRoot)
	)
	$"QuitRoot/Quit-BT".released.connect(
		func():
			animate_button_up($QuitRoot)
			_on_quit_bt_up()
	)

	$"TrollRoot/Troll-Bt".pressed.connect(
		func(): animate_button_down($TrollRoot)
	)
	$"TrollRoot/Troll-Bt".released.connect(
		func():
			animate_button_up($TrollRoot)
			_on_troll_bt_up()
	)

	print("running patch downloader...")
	rewarAD._on_load_pressed()
	print("ad loaded")

	currentVersion = FileControl._local_version_check()
	FileControl._check_and_load_resource_pack()
	print("Local Version: ", currentVersion)

	print("Checking update from Render Server...")
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._on_render_update_response)

	var server_url = "https://game-update-server-q7tg.onrender.com/api/levels/latest"
	var error = http_request.request(server_url)

	if error != OK:
		push_error("Không thể kết nối tới Server Render.")

	var current_path := get_tree().current_scene.scene_file_path
	if current_path == SPECIAL_SCENE:
		AudioController.play_special_music()
	else:
		AudioController.play_main_music()

func _on_start_bt_down():
	animate_button_down($"StartRoot/Start-BT")

func _on_start_bt_up():
	animate_button_up($"StartRoot/Start-BT")
	$"/root/AudioController".play_click()

	var current_path := get_tree().current_scene.scene_file_path

	if current_path == SPECIAL_SCENE:
		print("MAIN: Bắt đầu Special Mode!")
		GameManager.start_special_level(1)
	else:
		var last_unlocked = GameManager.max_level_unlocked
		print("MAIN: Tiếp tục Main Mode tại level: ", last_unlocked)
		GameManager.go_to_level(last_unlocked)

func _on_level_select_bt_down():
	animate_button_down($LevelRoot/LevelSelectBt)

func _on_level_select_bt_up():
	animate_button_up($LevelRoot/LevelSelectBt)
	$"/root/AudioController".play_click()

	var current_path := get_tree().current_scene.scene_file_path

	if current_path == SPECIAL_SCENE:
		if ResourceLoader.exists(SPECIAL_LEVEL_SELECT):
			get_tree().change_scene_to_file.call_deferred(SPECIAL_LEVEL_SELECT)
		else:
			print("❌ Chưa tạo file SpecialLevelSelect.tscn!")
	else:
		get_tree().change_scene_to_file.call_deferred(MAIN_LEVEL_SELECT)

func _on_troll_bt_down():
	animate_button_down($"TrollRoot/Troll-Bt")

func _on_troll_bt_up():
	animate_button_up($"TrollRoot/Troll-Bt")
	$"/root/AudioController".play_click()
	screen_shake(0.4, 15.0, 40.0)
	screen_flash(Color(1.0, 0.3, 0.3, 0.4), 0.3)

	var zoom_tween = create_tween()
	zoom_tween.tween_property($TrollRoot, "scale", Vector2(1.2, 1.2), 0.1)
	zoom_tween.tween_property($TrollRoot, "scale", Vector2.ONE, 0.15)

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
		next_scene = MAIN_SCENE

	if ResourceLoader.exists(next_scene):
		get_tree().change_scene_to_file.call_deferred(next_scene)
	else:
		push_error("❌ Scene not found: " + next_scene)

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

func screen_shake(duration: float = 0.3, intensity: float = 10.0, frequency: float = 30.0):
	var original_position = position
	var elapsed = 0.0
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

func _on_quit_bt_pressed() -> void:
	pass

func _on_start_bt_pressed() -> void:
	pass

func _on_level_select_bt_pressed() -> void:
	pass

func _on_render_update_response(result, response_code, _headers, body):
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		print("❌ Server không phản hồi (Code: ", response_code, ")")
		return

	var json_data = JSON.parse_string(body.get_string_from_utf8())
	if json_data and json_data.has("success") and json_data.success:
		serverVersion = float(json_data.version)
		pending_pck_url = json_data.url

		print("Server Version: ", serverVersion, " | Local Version: ", currentVersion)

		if serverVersion > currentVersion:
			print("🚀 Bắt đầu tải DLC từ: ", pending_pck_url)
			if !DirAccess.dir_exists_absolute(FileControl.dlc_folder):
				DirAccess.make_dir_recursive_absolute(FileControl.dlc_folder)

			if has_node("Loading"):
				$Loading.visible = true

			if has_node("showInsAd"):
				$showInsAd.visible = false

			fake_progress = 0
			downloading_dlc = true
			_update_progress_ui(0)
			_start_download_dlc(pending_pck_url)

func _start_download_dlc(url):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.set_download_file(FileControl.dlc_path)
	http_request.request_completed.connect(self._on_dlc_download_finished)
	http_request.request(url)

func _on_dlc_download_finished(result, response_code, _headers, _body):
	downloading_dlc = false
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		_update_progress_ui(100)
		await get_tree().create_timer(0.3).timeout
		FileControl._save_local_version(serverVersion)
		currentVersion = serverVersion
		if has_node("Loading"):
			$Loading.visible = false

		if has_node("showInsAd"):
			$showInsAd.visible = true
		print("✅ Đã tải và cập nhật DLC mới thành công!")
	else:
		if has_node("Loading"):
			$Loading.visible = false

		if has_node("showInsAd"):
			$showInsAd.visible = true
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

	var file = FileAccess.open(game_content_path, FileAccess.WRITE)
	if file:
		file.store_buffer(body)
		file.close()
		print("saving new file to game_content...")
		if ProjectSettings.load_resource_pack(game_content_path):
			print("load new resource pack...")
			var dataFromFile = FileAccess.open(versionFile, FileAccess.READ)
			var versionFromfile = JSON.parse_string(dataFromFile.get_as_text())
			versionFromfile["version"] = serverVersion
			dataFromFile.close()
			
			var writeFile = FileAccess.open(versionFile, FileAccess.WRITE)
			var stringified = JSON.stringify(versionFromfile, "\t")
			writeFile.store_string(stringified)
			writeFile.close()

			currentVersion = serverVersion
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

		if has_node("Loading/Runner"):
			var runner = $Loading/Runner

			var bar_width = bar.size.x
			var offset_x = (bar_width * value) / 100.0
			var target_x = bar.position.x + offset_x

			# Nếu đã hoàn tất thì đặt thẳng vị trí
			if value >= 100:
				runner.position.x = target_x
			else:
				# Nếu đang chạy thì lerp cho mượt
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
