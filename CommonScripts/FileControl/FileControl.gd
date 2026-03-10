extends Node

var versionFileRes = "res://game_content/version.json"
var versionFileUser = "user://version.json"
<<<<<<< Updated upstream
var finalPath = "res://game_content/AllLevel.pck"
var currentVersion
var serverVersion
var game_content_path = "res://game_content/AllLevel.pck"
var game_content_user = "user://AllLevel.pck"
=======
var currentVersion: float = 0.0
>>>>>>> Stashed changes

# Base game luôn nằm trong res
var game_content_path = "res://game_content/base_game.pck"  # ← Đổi tên file test vào đây
# DLC nằm trong thư mục con của user://
var dlc_folder = "user://pck/"
var dlc_path = "user://pck/Special_Levels.pck"

# 1. Kiểm tra version local
func _local_version_check() -> float:
	var path = versionFileUser if FileAccess.file_exists(versionFileUser) else versionFileRes
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		currentVersion = float(JSON.parse_string(file.get_as_text())["version"])
		file.close()
	return currentVersion

# 2. Lưu version vào user://
func _save_local_version(ver: float):
	var file = FileAccess.open(versionFileUser, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"version": ver}))
		file.close()

# 3. Load Resource Pack
# Hàm nạp Base Game (Gọi ngay khi mở app)
func _check_and_load_resource_pack():
	if ProjectSettings.load_resource_pack(game_content_path):
		print("✅ Base Game Loaded from res://")
	else:
		print("❌ Lỗi: Không tìm thấy Base PCK trong res!")


# Hàm nạp DLC (Chỉ gọi khi vào Menu Special)
func _load_special_dlc():
	if FileAccess.file_exists(dlc_path):
		if ProjectSettings.load_resource_pack(dlc_path):
			print("✅ DLC loaded từ user://pck/")
			return true
	print("ℹ️ Không tìm thấy DLC để nạp")
	return false
