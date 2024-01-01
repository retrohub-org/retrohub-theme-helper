@tool
extends Node

signal config_ready(config_data)
signal config_updated(key, old_value, new_value)

signal theme_config_ready
signal theme_config_updated(key, old_value, new_value)

signal game_data_updated(game_data)

var config : ConfigData = ConfigData.new()
var games : Array
var systems : Dictionary

var _systems_raw : Dictionary

var _theme_config : Dictionary

func _ready():
	if Engine.is_editor_hint(): return

	_load_systems()
	if RetroHub._helper_config.has("integration_rcheevos_enabled"):
		config.integration_rcheevos_enabled = RetroHub._helper_config["integration_rcheevos_enabled"]
	config_ready.emit(config)

func _load_systems():
	# Default systems
	_systems_raw = JSONUtils.map_array_by_key(JSONUtils.load_json_file(_get_systems_file()), "name")
	for key in _systems_raw:
		if _systems_raw[key].has("extends"):
			_systems_raw[key].merge(_systems_raw[_systems_raw[key]["extends"]])

func _load_game_data_files():
	games.clear()
	systems.clear()
	var dir := DirAccess.open(_get_gamelists_dir())
	if not dir or dir.list_dir_begin(): # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		push_error("Error when opening game directory " + _get_gamelists_dir())
		return
	var file_name := dir.get_next()
	while file_name != "":
		if dir.current_is_dir() and _systems_raw.has(file_name):
			_load_system_gamelists_files(_get_gamelists_dir().path_join(file_name), file_name)
		# We are not interested in files, only folders
		file_name = dir.get_next()
	dir.list_dir_end()
	# Finally order the games array
	games.sort_custom(Callable(RetroHubGameData, "sort"))

func _load_system_gamelists_files(folder_path: String, system_name: String):
	print("Loading games from directory " + folder_path)
	var dir := DirAccess.open(folder_path)
	if not dir or dir.list_dir_begin() :# TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		push_error("Error when opening game directory " + folder_path)
		return
	var file_name = dir.get_next()
	while file_name != "":
		var full_path = folder_path.path_join(file_name)
		if dir.current_is_dir():
			# Recurse
			# TODO: prevent infinite recursion with shortcuts/symlinks
			_load_system_gamelists_files(full_path, system_name)
		else:
			if not systems.has(system_name):
				var system := RetroHubSystemData.new()
				system.name = system_name
				system.fullname = _systems_raw[system_name]["fullname"]
				system.platform = _systems_raw[system_name]["platform"]
				system.category = RetroHubSystemData.category_to_idx(_systems_raw[system_name]["category"])
				system.num_games = 1
				systems[system_name] = system
			else:
				systems[system_name].num_games += 1

			var game := RetroHubGameData.new()
			game.path = file_name
			game.system = systems[system_name]
			game.system_path = system_name
			game.has_metadata = true
			if not _fetch_game_data(full_path, game):
				push_error("Metadata file corrupt!")
				game.name = file_name
				game.age_rating = "0/0/0"
				game.has_metadata = false
			games.push_back(game)
		file_name = dir.get_next()
	dir.list_dir_end()

func _fetch_game_data(path: String, game: RetroHubGameData) -> bool:
	var data : Dictionary = JSONUtils.load_json_file(path)
	if data.is_empty():
		return false

	game.name = data["name"]
	game.description = data["description"]
	game.rating = data["rating"]
	game.release_date = data["release_date"]
	game.developer = data["developer"]
	game.publisher = data["publisher"]
	game.genres = data["genres"]
	game.num_players = data["num_players"]
	game.age_rating = data["age_rating"]
	game.favorite = data["favorite"]
	game.play_count = data["play_count"]
	game.last_played = data["last_played"]
	game.has_media = data["has_media"]
	if data.has("emulator"):
		game.emulator = data["emulator"]
	if data.has("box_texture_regions"):
		for key in data["box_texture_regions"]:
			var region_data : PackedFloat64Array = data["box_texture_regions"][key].split_floats(";")
			if region_data.size() < 4: continue
			var key_idx : int = RetroHubGameData.BoxTextureRegions.keys().find(key.to_upper())
			if key_idx == -1: key_idx = int(key)
			game.box_texture_regions[key_idx] = Rect2(region_data[0], region_data[1], region_data[2], region_data[3])

	return true

func _get_game_data_path_from_file(system_name: String, file_name: String) -> String:
	return _get_gamelists_dir().path_join(system_name).path_join(file_name.get_file().trim_suffix(file_name.get_extension()) + "json")

func _is_file_from_system(file_name: String, system_name: String) -> bool:
	var extensions : Array = _systems_raw[system_name]["extension"]
	var file_extension := ("." + file_name.get_extension()).to_lower()
	for extension in extensions:
		# Defined as an extension
		if extension.begins_with("."):
			if extension.to_lower() == file_extension:
				return true
		# Defined as exact file name
		else:
			if extension.to_lower() == file_name.to_lower():
				return true

	return false

func get_theme_config(key, default_value):
	if not _theme_config.has(key):
		return default_value
	return _theme_config[key]

func set_theme_config(key, value):
	_theme_config[key] = value

func _get_config_dir() -> String:
	match FileUtils.get_os_id():
		FileUtils.OS_ID.WINDOWS:
			return FileUtils.get_home_dir() + "/RetroHub"
		_:
			return FileUtils.get_home_dir() + "/.retrohub"

func _get_systems_file() -> String:
	return "res://addons/retrohub_theme_helper/data/systems.json"

func _get_gamelists_dir() -> String:
	return _get_config_dir() + "/gamelists"

func _get_gamemedia_dir() -> String:
	return _get_config_dir() + "/gamemedia"
