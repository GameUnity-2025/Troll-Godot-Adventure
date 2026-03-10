extends Node

var versionFileRes = "res://game_content/version.json"
var versionFileUser = "user://version.json"
var currentVersion: float = 0.0

# Base game luôn nằm trong res
var game_content_path = "res://game_content/base_game.pck"

# DLC nằm trong user
var dlc_folder = "user://pck/"
var dlc_path = "user://pck/Special_Levels.pck"


# --- 1. Kiểm tra version local ---
func _local_version_check() -> float:
	var path = versionFileUser if FileAccess.file_exists(versionFileUser) else versionFileRes
	
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		var json = JSON.parse_string(file.get_as_text())
		
		if json and json.has("version"):
			currentVersion = float(json["version"])
			
		file.close()
		
	return currentVersion


# --- 2. Lưu version mới ---
func _save_local_version(ver: float):
	var file = FileAccess.open(versionFileUser, FileAccess.WRITE)
	
	if file:
		file.store_string(JSON.stringify({"version": ver}))
		file.close()


# --- 3. Load Base Game ---
func _check_and_load_resource_pack():
	if ProjectSettings.load_resource_pack(game_content_path):
		print("✅ Base Game Loaded from res://")
	else:
		print("❌ Không tìm thấy Base Game PCK!")


# --- 4. Load DLC ---
func _load_special_dlc():

	if FileAccess.file_exists(dlc_path):
		if ProjectSettings.load_resource_pack(dlc_path):
			print("✅ DLC loaded từ user://pck/")
			return true
	
	print("ℹ️ Không tìm thấy DLC để nạp")
	return false
