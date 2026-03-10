extends Node

var versionFileRes = "res://game_content/version.json"
var versionFileUser = "user://version.json"
var finalPath = "res://game_content/AllLevel.pck"
var currentVersion
var serverVersion
var game_content_path = "res://game_content/test2s1.pck"  
var game_content_user = "user://test2s1.pck"

func _debug_update_by_version():
	#Assign version 
	print("debug chaning to version 1.0")
	var saveVersion = FileAccess.open(versionFileUser,FileAccess.WRITE)
	if saveVersion:
		var save_version = {
			"version": 1.0
		}
		saveVersion.store_string(JSON.stringify(save_version))
		saveVersion.close()

#Getting JSON version file local res://
func _local_version_check():
	if !FileAccess.file_exists(versionFileUser):
		#No version file in user://
		print("no version in user:// found")
		#
		if FileAccess.file_exists(versionFileRes):
			#No version in user:// BUT res:// exists
			var resData = FileAccess.open(versionFileRes, FileAccess.READ)
			var resVer = JSON.parse_string(resData.get_as_text())
			var verRes = resVer["version"]
			resData.close()
			#
			print("res file found and version: " + str(verRes))
			#
			currentVersion = verRes
		else:
			#No version in user:// AND res://
			currentVersion = 1.0
		
		#Assign version 
		var saveVersion = FileAccess.open(versionFileUser,FileAccess.WRITE)
		if saveVersion:
			var save_version = {
				"version": currentVersion
			}
			saveVersion.store_string(JSON.stringify(save_version))
			saveVersion.close()
		return currentVersion
	else:
		#version file found in user://
		var resData = FileAccess.open(versionFileUser, FileAccess.READ)
		var userVer = JSON.parse_string(resData.get_as_text())
		var version = userVer["version"]
		resData.close()
		print("user:// file version " + str(version))
		currentVersion = version
		return currentVersion

func _check_and_load_resource_pack():
	if !FileAccess.file_exists(game_content_user):
		print("user resource file doesn't exist")
	
		var file_source = FileAccess.open(game_content_path, FileAccess.READ)
		if file_source == null:
			print("Error opening source PCK file: ", error_string(FileAccess.get_open_error()))
			return

		var file_dest = FileAccess.open(game_content_user, FileAccess.WRITE)
		if file_dest == null:
			print("Error opening destination PCK file: ", error_string(FileAccess.get_open_error()))
			file_source.close()
			return

		# Copy the data in chunks
		var buffer = file_source.get_buffer(file_source.get_length())
		file_dest.store_buffer(buffer)
		
		file_source.close()
		file_dest.close()
		
		#check after copy
		if FileAccess.file_exists(game_content_user):
			print("Successfully copied PCK file to user://")
			finalPath = game_content_user
		else:
			print("Failed to copy PCK file.")
	else:
		print("user resource file found")
		finalPath= game_content_user
	
	#load resource
	ProjectSettings.load_resource_pack(finalPath)
	print("loaded game content file...")
