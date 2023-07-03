@tool
extends Control

@onready var n_id := %ID
@onready var n_name := %Name
@onready var n_description := %Description
@onready var n_icon_preview := %IconPreview
@onready var n_icon := %Icon
@onready var n_icon_load := %IconLoad
@onready var n_authors := %Authors
@onready var n_version := %Version
@onready var n_url := %URL
@onready var n_entry_scene := %EntryScene
@onready var n_entry_scene_load := %EntrySceneLoad

var settings : Dictionary

var file_popup : EditorFileDialog: set = set_file_popup
var active := false

enum Mode {
	ICON,
	ENTRY_SCENE
}
var curr_mode : Mode

func set_file_popup(_file_popup: EditorFileDialog):
	file_popup = _file_popup
	file_popup.file_selected.connect(_on_file_selected)
	file_popup.canceled.connect(_on_file_selected.bind(""))

func _on_file_selected(file: String):
	if active:
		match curr_mode:
			Mode.ICON:
				settings["icon"] = file
				set_icon_path(file)
			Mode.ENTRY_SCENE:
				settings["entry_scene"] = file
				n_entry_scene.text = file

# Called when the node enters the scene tree for the first time.
func _ready():
	var load_texture = get_theme_icon("Load", "EditorIcons")
	n_icon_load.icon = load_texture
	n_entry_scene_load.icon = load_texture
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed():
	if not is_visible_in_tree():
		active = false

func load_settings(_settings: Dictionary):
	settings = _settings
	if settings.has("id"):
		n_id.text = settings["id"]
	if settings.has("name"):
		n_name.text = settings["name"]
	if settings.has("description"):
		n_description.text = settings["description"]
	if settings.has("icon"):
		set_icon_path(settings["icon"])
	if settings.has("authors"):
		n_authors.text = settings["authors"]
	if settings.has("version"):
		n_version.text = settings["version"]
	if settings.has("url"):
		n_url.text = settings["url"]
	if settings.has("entry_scene"):
		n_entry_scene.text = settings["entry_scene"]

func set_icon_path(path: String):
	var tex = load(path)
	n_icon.texture = tex
	n_icon_preview.current_tab = 1 if tex else 0

func get_settings():
	return settings

func ask_file():
	active = true
	file_popup.popup_centered()

func _on_Name_text_changed(new_text):
	settings["name"] = new_text


func _on_Description_text_changed():
	settings["description"] = n_description.text


func _on_IconLoad_pressed():
	file_popup.filters = PackedStringArray([
		"*.png ; PNG Images",
		"*.jpg ; JPEG Images",
		"*.svg ; SVG Images"])
	file_popup.access = EditorFileDialog.ACCESS_RESOURCES
	file_popup.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	ask_file()
	curr_mode = Mode.ICON


func _on_EntrySceneLoad_pressed():
	file_popup.filters = PackedStringArray([
		"*.tscn ; TSCN Files",
		"*.scn ; SCN Files"])
	file_popup.access = EditorFileDialog.ACCESS_RESOURCES
	file_popup.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	ask_file()
	curr_mode = Mode.ENTRY_SCENE


func _on_Authors_text_changed(new_text):
	settings["authors"] = new_text


func _on_Version_text_changed(new_text):
	settings["version"] = new_text


func _on_URL_text_changed(new_text):
	settings["url"] = new_text


func _on_ID_text_changed(new_text):
	settings["id"] = new_text
