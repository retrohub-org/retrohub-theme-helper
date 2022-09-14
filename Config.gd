tool
extends Node

signal config_ready(config_data)
signal config_updated(key, old_value, new_value)

signal theme_config_ready()
signal theme_config_updated(key, old_value, new_value)

signal system_data_updated(system_data)
signal game_data_updated(game_data)
signal game_media_data_updated(game_media_data)

var games : Array
var systems : Dictionary
var _systems_raw : Dictionary

var _theme_config : Dictionary

var _dir := Directory.new()

func _ready():
	if not Engine.editor_hint:
		_systems_raw = JSONUtils.map_array_by_key(JSONUtils.load_json_file(get_systems_file())["systems_list"], "name")
		expand_systems()

func expand_systems():
	for key in _systems_raw:
		if _systems_raw[key].has("extends"):
			_systems_raw[key].merge(_systems_raw[_systems_raw[key]["extends"]])

func load_game_data_files():
	games.clear()
	systems.clear()
	if _dir.open(get_gamelists_dir()) or _dir.list_dir_begin(true):
		print("Error when opening game lists directory " + get_gamelists_dir())
		return
	var file_name = _dir.get_next()
	while file_name != "":
		if _dir.current_is_dir() and _systems_raw.has(file_name):
			load_system_gamelists_files(get_gamelists_dir() + "/" + file_name, file_name)
		# We are not interested in files, only folders
		file_name = _dir.get_next()
	_dir.list_dir_end()

func load_system_gamelists_files(folder_path: String, system_name: String):
	var dir = Directory.new()
	if dir.open(folder_path) or dir.list_dir_begin(true):
		print("Error when opening game directory " + folder_path)
		return
	var file_name = dir.get_next()
	while file_name != "":
		var full_path = folder_path + "/" + file_name
		if dir.current_is_dir():
			# Recurse
			# TODO: prevent infinite recursion with shortcuts/symlinks
			load_system_gamelists_files(full_path, system_name)
		else:
			if not systems.has(system_name):
				var system := RetroHubSystemData.new()
				system.name = system_name
				system.fullname = _systems_raw[system_name]["fullname"]
				system.platform = _systems_raw[system_name]["platform"]
				system.category = convert_system_category(_systems_raw[system_name]["category"])
				system.num_games = 1
				systems[system_name] = system
			else:
				systems[system_name].num_games += 1

			var game := RetroHubGameData.new()
			game.system_name = system_name
			game.has_metadata = true
			game.path = file_name
			if not fetch_game_data(full_path, game):
				game.name = game.path
				game.has_metadata = false
				print("Metadata file corrupt!")
			games.push_back(game)
		file_name = dir.get_next()
	dir.list_dir_end()

func convert_system_category(category_raw: String):
	match category_raw:
		"computer":
			return RetroHubSystemData.Category.Computer
		"engine":
			return RetroHubSystemData.Category.GameEngine
		"modern_console":
			return RetroHubSystemData.Category.ModernConsole
		"arcade":
			return RetroHubSystemData.Category.Arcade
		"console", _:
			return RetroHubSystemData.Category.Console

func fetch_game_data(path: String, game: RetroHubGameData) -> bool:
	var data : Dictionary = JSONUtils.load_json_file(path)
	if data.empty():
		return false
	
	game.name = data["name"]
	game.description = data["description"]
	game.rating = data["rating"]
	game.release_date = localize_date(data["release_date"] as String)
	game.developer = data["developer"]
	game.publisher = data["publisher"]
	game.genres = data["genres"]
	game.num_players = data["num_players"]
	game.age_rating = data["age_rating"]
	game.favorite = data["favorite"]
	game.play_count = data["play_count"]
	game.last_played = localize_date(data["last_played"] as String)
	game.has_media = data["has_media"]

	return true

func get_theme_config(key, default_value):
	return default_value

func set_theme_config(key, value):
	pass

func localize_date(date_raw: String) -> String:
	if date_raw == "null" or date_raw.empty():
		return date_raw
	var year = date_raw.substr(0, 4)
	var month = date_raw.substr(4, 2)
	var day = date_raw.substr(6, 2)
	var hour = date_raw.substr(9, 2)
	var minute = date_raw.substr(11, 2)
	var second = date_raw.substr(13, 2)
	var format_arr : Array
	return "%s/%s/%s %s:%s:%s" % [month, day, year, hour, minute, second]

func get_config_dir() -> String:
	match FileUtils.get_os_id():
		FileUtils.OS_ID.WINDOWS:
			return FileUtils.get_home_dir() + "/RetroHub"
		_:
			return FileUtils.get_home_dir() + "/.retrohub"

func get_config_file() -> String:
	return get_config_dir() + "/rh_config.json"

func get_systems_file() -> String:
	return  "res://addons/retrohub_theme_helper/data/systems.json"

func get_emulators_file() -> String:
	return get_config_dir() + "/rh_emulators.json"

func get_themes_dir():
	return get_config_dir() + "/themes"

func get_gamelists_dir():
	return get_config_dir() + "/gamelists"

func get_gamemedia_dir():
	return get_config_dir() + "/gamemedia"


