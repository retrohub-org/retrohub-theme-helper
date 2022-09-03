tool
extends Control

onready var n_games_option := $"%GamesOption"
onready var n_games_tab := $"%GamesTab"
onready var n_random_num := $"%RandomNum"
onready var n_local_label := $"%LocalLabel"

onready var base_text : String = n_local_label.text

var settings : Dictionary

var file_popup : FileDialog setget set_file_popup
var file_selected_path : String

func _ready():
	n_local_label.text = base_text % RetroHubConfig.get_gamelists_dir()

func set_file_popup(_file_popup: FileDialog):
	file_popup = _file_popup
	file_popup.connect("file_selected", self, "_on_file_selected")

func _on_file_selected(file: String):
	file_selected_path = file

func load_settings(_settings: Dictionary):
	settings = _settings
	if settings.has("games_mode"):
		match settings["games_mode"]:
			"none":
				n_games_option.select(0)
			"random":
				n_games_option.select(1)
			"local":
				n_games_option.select(2)
		n_games_tab.current_tab = n_games_option.selected
	if settings.has("random_num"):
		n_random_num.value = settings["random_num"]

func get_settings():
	return settings

func ask_file():
	file_selected_path = ""
	file_popup.popup_centered()

func _on_GamesOption_item_selected(index):
	n_games_tab.current_tab = index
	match index:
		0:
			settings["games_mode"] = "none"
		1:
			settings["games_mode"] = "random"
		2:
			settings["games_mode"] = "local"


func _on_RandomNum_value_changed(value):
	settings["random_num"] = int(value)

