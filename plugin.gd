tool
extends EditorPlugin

const THEME_SETTINGS_PATH := "res://theme.json"
const ADDON_SETTINGS_PATH := "res://addons/retrohub_theme_helper/config.json"

var dock
var singleton
var theme_settings := {}
var addon_settings := {}

func _ready():
	add_singletons()
	add_dock()
	load_settings()

func _exit_tree():
	remove_dock()
	remove_singletons()

func disable_plugin():
	save_settings()

func build():
	save_settings()
	return true

func save_external_data():
	save_settings()

func add_singletons():
	add_autoload_singleton("JSONUtils", "res://addons/retrohub_theme_helper/utils/JSONUtils.gd")
	add_autoload_singleton("FileUtils", "res://addons/retrohub_theme_helper/utils/FileUtils.gd")
	add_autoload_singleton("RegionUtils", "res://addons/retrohub_theme_helper/utils/RegionUtils.gd")
	add_autoload_singleton("RetroHubConfig", "res://addons/retrohub_theme_helper/Config.gd")
	add_autoload_singleton("RetroHubUI", "res://addons/retrohub_theme_helper/UI.gd")
	add_autoload_singleton("RetroHub", "res://addons/retrohub_theme_helper/RetroHub.gd")
	add_autoload_singleton("RetroHubMedia", "res://addons/retrohub_theme_helper/Media.gd")

func add_dock():
	dock = preload("res://addons/retrohub_theme_helper/dock/Dock.tscn").instance()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, dock)

func load_settings():
	theme_settings = load_json(THEME_SETTINGS_PATH)
	addon_settings = load_json(ADDON_SETTINGS_PATH)
	var editor_control = get_editor_interface().get_base_control()
	dock.setup_popup(editor_control)
	dock.load_settings(theme_settings, addon_settings)

func load_json(path: String):
	var file := File.new()
	var dir := Directory.new()
	if dir.file_exists(path):
		if file.open(path, File.READ):
			push_warning("Error when opening %s, settings will be reset..." % path)
			return {}
		var result := JSON.parse(file.get_as_text())
		if result.error:
			push_warning("Error when parsing JSON for %s at line %d: %s. Settings will be reset..." % [path, result.error_line, result.error_string])
			return {}
		file.close()
		return result.result
	return {}

func remove_singletons():
	remove_autoload_singleton("RetroHubMedia")
	remove_autoload_singleton("RetroHub")
	remove_autoload_singleton("RetroHubUI")
	remove_autoload_singleton("RetroHubConfig")
	remove_autoload_singleton("RegionUtils")
	remove_autoload_singleton("FileUtils")
	remove_autoload_singleton("JSONUtils")

func remove_dock():
	remove_control_from_docks(dock)
	dock.queue_free()

func save_settings():
	theme_settings = dock.get_theme_settings()
	addon_settings = dock.get_addon_settings()
	save_json(theme_settings, THEME_SETTINGS_PATH)
	save_json(addon_settings, ADDON_SETTINGS_PATH)
	
func save_json(dict: Dictionary, path: String):
	var file := File.new()
	if file.open(path, File.WRITE):
		push_warning("Error when opening %s, settings will not be saved." % path)
		return
	file.store_string(JSON.print(dict, "\t"))
	file.close()
