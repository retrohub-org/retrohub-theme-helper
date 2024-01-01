@tool
extends Control

@onready var n_config_scene := %ConfigScene
@onready var n_config_scene_load := %ConfigSceneLoad
@onready var n_rcheevos_enabled := %RCheevosEnabled

var theme_settings : Dictionary
var addon_settings : Dictionary

var file_popup : EditorFileDialog: set = set_file_popup
var active := false

func set_file_popup(_file_popup: EditorFileDialog):
	file_popup = _file_popup
	file_popup.file_selected.connect(_on_file_selected)
	file_popup.canceled.connect(_on_file_selected.bind(""))

func _on_file_selected(file: String):
	if active:
		theme_settings["config_scene"] = file
		n_config_scene.text = file

# Called when the node enters the scene tree for the first time.
func _ready():
	var load_texture = get_theme_icon("Load", "EditorIcons")
	n_config_scene_load.icon = load_texture
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if not is_visible_in_tree():
		active = false

func load_settings(_theme_settings: Dictionary, _addon_settings: Dictionary):
	theme_settings = theme_settings
	if theme_settings.has("config_scene"):
		n_config_scene.text = theme_settings["config_scene"]
	if addon_settings.has("integration_rcheevos_enabled"):
		n_rcheevos_enabled.set_pressed_no_signal(addon_settings["integration_rcheevos_enabled"])

func get_settings():
	return theme_settings

func get_addon_settings():
	return addon_settings

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


func _on_r_cheevos_enabled_toggled(toggled_on: bool):
	addon_settings["integration_rcheevos_enabled"] = toggled_on
