tool
extends Node

enum OS_ID {
	WINDOWS,
	MACOS,
	LINUX,
	UNSUPPORTED
}

# Finds the first file/folder that exists from the array of paths.
func test_for_valid_path(paths: Array):
	var dir = Directory.new()
	for path in paths:
		if dir.dir_exists(path) or dir.file_exists(path):
			return path
	return ""

func get_home_dir():
	match get_os_id():
		OS_ID.WINDOWS:
			# C:/Users/xxx/RetroHub
			var homedrive := OS.get_environment("HOMEDRIVE")
			var homepath := OS.get_environment("HOMEPATH")
			var path = homedrive + homepath
			# Replace \ with /
			path = path.replace('\\', '/')
			return path
		OS_ID.MACOS, OS_ID.LINUX:
			# ~/.retrohub
			return OS.get_environment("HOME")

func get_os_id() -> int:
	match OS.get_name():
		"Windows", "UWP":
			return OS_ID.WINDOWS
		"macOS":
			return OS_ID.MACOS
		"X11":
			return OS_ID.LINUX
		_:
			return OS_ID.UNSUPPORTED

func get_os_string() -> String:
	match OS.get_name():
		"Windows", "UWP":
			return "windows"
		"macOS":
			return "macos"
		"X11":
			return "linux"
		_:
			return "null"