extends Node

var color_theme_accent := Color("ffbb89")

var color_success := Color("41eb83")
var color_warning := Color("ffd24a")
var color_error := Color("ff5d5d")
var color_pending := Color("dddddd")
var color_unavailable := Color("999999")

const max_popupmenu_height := 300

enum Icons {
	DOWNLOADING,
	ERROR,
	FAILURE,
	IMAGE_DOWNLOADING,
	LOAD,
	LOADING,
	SETTINGS,
	SUCCESS,
	VISIBILITY_HIDDEN,
	VISIBILITY_VISIBLE,
	WARNING
}

signal path_selected(file)

func filesystem_filters(filters: Array = []):
	pass

func request_file_load(base_path: String) -> void:
	pass

func request_folder_load(base_path: String) -> void:
	pass

func load_app_icon(icon: int) -> Texture:
	return Texture.new()

func show_virtual_keyboard() -> void:
	pass

func is_virtual_keyboard_visible() -> bool:
	return false

func hide_virtual_keyboard() -> void:
	pass
