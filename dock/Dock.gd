tool
extends Control

onready var n_theme := $"%Theme"
onready var n_games := $"%Games"
onready var n_config := $"%Config"

onready var n_file_dialog := $"%FileDialog"

func setup_popup(editor_control: Control):
	n_file_dialog.get_parent().remove_child(n_file_dialog)
	editor_control.add_child(n_file_dialog)

func get_theme_settings() -> Dictionary:
	var theme_settings = n_theme.get_settings()
	return theme_settings

func get_addon_settings() -> Dictionary:
	var addon_settings = n_games.get_settings()
	return addon_settings

func load_settings(theme_settings: Dictionary, addon_settings: Dictionary):
	n_theme.load_settings(theme_settings)
	n_theme.file_popup = n_file_dialog
	n_games.load_settings(addon_settings)
	n_games.file_popup = n_file_dialog
	#n_config.load_settings(theme_settings["config"])
