extends Node

var color_success := Color("41eb83")
var color_warning := Color("ffd24a")
var color_error := Color("ff5d5d")
var color_unavailable := Color("999999")

signal path_selected(file)

func filesystem_filters(filters: Array = []):
	pass

func request_file_load(base_path: String) -> void:
	pass

func request_folder_load(base_path: String) -> void:
	pass
