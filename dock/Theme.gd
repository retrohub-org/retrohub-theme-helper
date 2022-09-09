tool
extends Control

onready var n_id := $"%ID"
onready var n_name := $"%Name"
onready var n_description := $"%Description"
onready var n_icon_preview := $"%IconPreview"
onready var n_icon := $"%Icon"
onready var n_icon_load := $"%IconLoad"
onready var n_authors := $"%Authors"
onready var n_version := $"%Version"
onready var n_url := $"%URL"
onready var n_entry_scene := $"%EntryScene"
onready var n_entry_scene_load := $"%EntrySceneLoad"

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
	n_icon_load.icon = load_texture
	n_entry_scene_load.icon = load_texture

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
	file_selected_path = ""
	file_popup.popup_centered()

func _on_Name_text_changed(new_text):
	settings["name"] = new_text


func _on_Description_text_changed():
	settings["description"] = n_description.text


func _on_IconLoad_pressed():
	file_popup.filters = PoolStringArray([
		"*.png ; PNG Images",
		"*.jpg ; JPEG Images",
		"*.svg ; SVG Images"])
	file_popup.access = FileDialog.ACCESS_RESOURCES
	ask_file()
	yield(file_popup, "popup_hide")
	if not file_selected_path.empty():
		settings["icon"] = file_selected_path
		set_icon_path(file_selected_path)


func _on_EntrySceneLoad_pressed():
	file_popup.filters = PoolStringArray([
		"*.tscn ; TSCN Files",
		"*.scn ; SCN Files"])
	file_popup.access = FileDialog.ACCESS_RESOURCES
	ask_file()
	yield(file_popup, "popup_hide")
	if not file_selected_path.empty():
		settings["entry_scene"] = file_selected_path
		n_entry_scene.text = file_selected_path


func _on_Authors_text_changed(new_text):
	settings["authors"] = new_text


func _on_Version_text_changed(new_text):
	settings["version"] = new_text


func _on_URL_text_changed(new_text):
	settings["url"] = new_text


func _on_ID_text_changed(new_text):
	settings["id"] = new_text
