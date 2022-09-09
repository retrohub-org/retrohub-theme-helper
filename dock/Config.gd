tool
extends Control

onready var n_config_scene := $"%ConfigScene"
onready var n_config_scene_load := $"%ConfigSceneLoad"

var settings : Dictionary

var file_popup : FileDialog setget set_file_popup
var file_selected_path : String

func set_file_popup(_file_popup: FileDialog):
	file_popup = _file_popup
	file_popup.connect("file_selected", self, "_on_file_selected")

func _on_file_selected(file: String):
	file_selected_path = file

# Called when the node enters the scene tree for the first time.
func _ready():
	var load_texture = get_icon("Load", "EditorIcons")
	n_config_scene_load.icon = load_texture

func load_settings(_settings: Dictionary):
	settings = _settings
	if settings.has("config_scene"):
		n_config_scene.text = settings["config_scene"]

func get_settings():
	return settings

func ask_file():
	file_selected_path = ""
	file_popup.popup_centered()

func _on_ConfigSceneLoad_pressed():
	file_popup.filters = PoolStringArray([
		"*.tscn ; TSCN Files",
		"*.scn ; SCN Files"])
	file_popup.access = FileDialog.ACCESS_RESOURCES
	ask_file()
	yield(file_popup, "popup_hide")
	if not file_selected_path.empty():
		settings["config_scene"] = file_selected_path
		n_config_scene.text = file_selected_path
