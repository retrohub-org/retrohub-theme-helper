extends Node

signal app_initializing
signal app_closing
signal app_received_focus
signal app_lost_focus
signal app_returning(system_data, game_data)

signal system_receive_start
signal system_received(system_data)
signal system_receive_end

signal game_receive_start
signal game_received(game_data)
signal game_receive_end

var curr_game_data : RetroHubGameData = null

var _helper_config : Dictionary

const version_major := 1
const version_minor := 0
const version_patch := 1
const version_extra := ""
var version_str := "%d.%d.%d%s" % [version_major, version_minor, version_patch, version_extra]

@onready var GameRandomData = preload("res://addons/retrohub_theme_helper/utils/GameRandomData.gd").new()

func _enter_tree():
	_load_helper_config()

func _ready():
	emit_signal("app_initializing", true)
	_load_titles()

func _notification(what):
	match what:
		NOTIFICATION_APPLICATION_FOCUS_IN:
			emit_signal("app_received_focus")
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			emit_signal("app_lost_focus")

func _load_helper_config():
	var path := "res://addons/retrohub_theme_helper/config.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		var test_json_conv = JSON.new()
		test_json_conv.parse(file.get_as_text())
		var result := test_json_conv.get_data()
		file.close()
		if result:
			_helper_config = result

func is_main_app() -> bool:
	return false

func is_input_echo() -> bool:
	return false

func _load_titles():
	await get_tree().process_frame
	if _helper_config.has("games_mode"):
		match _helper_config["games_mode"]:
			"random":
				load_random_titles()
			"local":
				load_local_titles()

func load_random_titles():
	randomize()
	var num_games : int = _helper_config["random_num"] if _helper_config.has("random_num") else 1

	emit_signal("system_receive_start")
	var system_datas := {}
	for system in RetroHubConfig._systems_raw.values():
		var system_data := RetroHubSystemData.new()
		system_data.name = system["name"]
		system_data.fullname = system["fullname"]
		system_data.platform = system["platform"]
		system_data.category = RetroHubSystemData.category_to_idx(system["category"])
		system_data.num_games = num_games
		system_datas[system_data.name] = system_data
		emit_signal("system_received", system_data)
	emit_signal("system_receive_end")
	
	emit_signal("game_receive_start")
	for system in RetroHubConfig._systems_raw.values():
		for i in range(num_games):
			emit_signal("game_received", gen_random_game(system_datas[system["name"]]))
	emit_signal("game_receive_end")

func gen_random_game(system):
	var game_data := RetroHubGameData.new()
	game_data.has_metadata = true
	game_data.has_media = true
	game_data.system = system
	game_data.name = GameRandomData.random_title()
	game_data.path = game_data.name.to_lower() + GameRandomData.random_extension()
	game_data.description = GameRandomData.random_description()
	game_data.rating = randf()
	game_data.release_date = GameRandomData.random_date(false)
	game_data.developer = GameRandomData.random_company()
	game_data.publisher = GameRandomData.random_company()
	game_data.genres = GameRandomData.random_genres()
	
	# 50/50 chance of being single or multiplayer
	if randf() > 0.5:
		game_data.num_players = "1-1"
	else:
		game_data.num_players = "%d-%d" % [1 + randi() % 4, 2 + randi() % 7]
	game_data.age_rating = GameRandomData.random_age_rating()
	game_data.favorite = randf() > 0.7
	game_data.play_count = randi() % 1000
	game_data.last_played = GameRandomData.random_date(true)
	
	return game_data

func load_local_titles():
	RetroHubConfig._load_game_data_files()
	var systems : Dictionary = RetroHubConfig.systems
	if not systems.is_empty():
		emit_signal("system_receive_start")
		for system in systems.values():
			emit_signal("system_received", system)
		emit_signal("system_receive_end")
		
		emit_signal("game_receive_start")
		for game in RetroHubConfig.games:
			emit_signal("game_received", game)
		emit_signal("game_receive_end")

func set_curr_game_data(game_data: RetroHubGameData) -> void:
	curr_game_data = game_data

func launch_game() -> void:
	if not curr_game_data:
		printerr("No current game data selected!")
		return

	print("Launching game ", curr_game_data.name)

func quit():
	RetroHubMedia._stop_thread()
	get_tree().quit()

func request_theme_reload():
	pass
