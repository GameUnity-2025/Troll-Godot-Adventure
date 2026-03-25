extends Node

var versionFileRes = "res://game_content/version.json"
var versionFileUser = "user://version.json"
var currentVersion: float = 0.0
var _base_pack_mounted := false

# Probe path used to verify that the base pack is really mounted.
const LEVEL_PROBE_PATH := "res://All_Level/Map Level 1/Level_1.tscn"
const COPY_CHUNK_SIZE := 1024 * 1024

# Keep this variable for backward compatibility with old calls.
var game_content_path = "res://game_content/game_full.pck"

# Multiple candidate packs are kept because different exports used different names.
var _base_pack_candidates_res: PackedStringArray = [
	"res://game_content/game_full.pck",
	"res://game_content/AllLevel.pck",
	"res://game_content/game_base.pck"
]

# User-space fallback (works reliably on iOS after first copy/download).
var base_pack_user_path = "user://game_full.pck"

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
func _check_and_load_resource_pack() -> bool:
	if _base_pack_mounted and _is_base_content_ready():
		return true

	# 1) Prefer user:// pack if it already exists.
	if FileAccess.file_exists(base_pack_user_path):
		if ProjectSettings.load_resource_pack(base_pack_user_path):
			if _is_base_content_ready():
				_base_pack_mounted = true
				print("✅ Base Game Loaded from user://")
				return true

	# 2) Try all known res:// candidate names.
	for res_pack in _base_pack_candidates_res:
		if not FileAccess.file_exists(res_pack):
			continue

		if ProjectSettings.load_resource_pack(res_pack):
			if _is_base_content_ready():
				_base_pack_mounted = true
				print("✅ Base Game Loaded from ", res_pack)
				game_content_path = res_pack
				return true

		# iOS fallback: copy pack to user:// then load from there.
		if _copy_pack_to_user(res_pack, base_pack_user_path):
			if ProjectSettings.load_resource_pack(base_pack_user_path) and _is_base_content_ready():
				_base_pack_mounted = true
				print("✅ Base Game Loaded from copied user:// pack")
				game_content_path = base_pack_user_path
				return true

	print("❌ Không tìm thấy hoặc không nạp được Base Game PCK!")
	return false

func _is_base_content_ready() -> bool:
	var probe = ResourceLoader.load(LEVEL_PROBE_PATH)
	return probe is PackedScene

func _copy_pack_to_user(from_res_path: String, to_user_path: String) -> bool:
	var source = FileAccess.open(from_res_path, FileAccess.READ)
	if source == null:
		return false

	var user_dir = to_user_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(user_dir):
		DirAccess.make_dir_recursive_absolute(user_dir)

	var target = FileAccess.open(to_user_path, FileAccess.WRITE)
	if target == null:
		source.close()
		return false

	while source.get_position() < source.get_length():
		var remaining = source.get_length() - source.get_position()
		var read_size = mini(COPY_CHUNK_SIZE, remaining)
		var chunk = source.get_buffer(read_size)
		if chunk.is_empty() and read_size > 0:
			source.close()
			target.close()
			return false
		target.store_buffer(chunk)

	source.close()
	target.close()
	return true


# --- 4. Load DLC ---
func _load_special_dlc():

	if FileAccess.file_exists(dlc_path):
		if ProjectSettings.load_resource_pack(dlc_path):
			print("✅ DLC loaded từ user://pck/")
			return true
	
	print("ℹ️ Không tìm thấy DLC để nạp")
	return false
