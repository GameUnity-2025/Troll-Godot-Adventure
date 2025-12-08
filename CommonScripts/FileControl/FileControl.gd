extends Node

var versionFile = "res://game_content/version.json"
var currentVersion
var serverVersion
var game_content_path = "res://game_content/AllLevel.pck"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.get_name() == "Android":
		print("isAndroid")
		if FileAccess.file_exists(versionFile):
			pass
		else:
			pass
			
#Getting JSON version file local
func _load_version_file(path: String):
	if FileAccess.file_exists(path):
		var dataFromFile = FileAccess.open(path, FileAccess.READ)
		var versionFromfile = JSON.parse_string(dataFromFile.get_as_text())
		var version = versionFromfile["version"]
		dataFromFile.close()
		print(version)
		currentVersion = version
	else:
		print("Missing version file ???")
