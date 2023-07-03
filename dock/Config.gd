@tool
extends Control

@onready var n_config_scene := $"%ConfigScene"
@onready var n_config_scene_load := $"%ConfigSceneLoad"

var settings : Dictionary

var file_popup : EditorFileDialog: set = set_file_popup
var active := false

func set_file_popup(_file_popup: EditorFileDialog):
	file_popup = _file_popup
	file_popup.file_selected.connect(_on_file_selected)
	file_popup.canceled.connect(_on_file_selected.bind(""))

func _on_file_selected(file: String):
	if active:
		settings["config_scene"] = file
		n_config_scene.text = file

# Called when the node enters the scene tree for the first time.
func _ready():
	var load_texture = get_theme_icon("Load", "EditorIcons")
	n_config_scene_load.icon = load_texture
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if not is_visible_in_tree():
		active = false

func load_settings(_settings: Dictionary):
	settings = _settings
	if settings.has("config_scene"):
		n_config_scene.text = settings["config_scene"]

func get_settings():
	return settings

func ask_file():
	active = true
	file_popup.popup_centered_ratio(0.6)

func _on_ConfigSceneLoad_pressed():
	file_popup.filters = PackedStringArray([
		"*.tscn ; TSCN Files",
		"*.scn ; SCN Files"])
	file_popup.access = EditorFileDialog.ACCESS_RESOURCES
	file_popup.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	ask_file()
