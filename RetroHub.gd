extends Node

signal app_initializing
signal app_closing
signal app_received_focus
signal app_lost_focus
signal app_returning(system_data, game_data)

signal system_receive_start()
signal system_received(system_data)
signal system_receive_end()

signal game_receive_start()
signal game_received(game_data)
signal game_receive_end()

var _joypad_echo_event : InputEvent
var _joypad_echo_timer := Timer.new()
var _joypad_echo_interval_timer := Timer.new()

var _helper_config : Dictionary

var is_echo : bool

var curr_game_data : RetroHubGameData

onready var GameRandomData = preload("res://addons/retrohub_theme_helper/utils/GameRandomData.gd").new()

func _enter_tree():
	_joypad_echo_timer.wait_time = 1.0
	_joypad_echo_interval_timer.wait_time = 0.1
	_joypad_echo_timer.one_shot = true
	_joypad_echo_timer.connect("timeout", self, "_on_joypad_echo_timer_timeout")
	_joypad_echo_interval_timer.connect("timeout", self, "_on_joypad_echo_interval_timer_timeout")
	add_child(_joypad_echo_timer)
	add_child(_joypad_echo_interval_timer)

func _ready():
	emit_signal("app_initializing", true)
	_load_helper_config()
	load_titles()

func _on_joypad_echo_timer_timeout():
	_joypad_echo_interval_timer.start()
	_joypad_echo_interval_timer.wait_time = 0

func _on_joypad_echo_interval_timer_timeout():
	Input.parse_input_event(_joypad_echo_event)

func _input(event):
	is_echo = event.is_echo()
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_up") \
			or Input.is_action_just_released("ui_right") or Input.is_action_just_released("ui_down"):
			_joypad_echo_timer.stop()
			_joypad_echo_interval_timer.stop()

		if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_up") \
			or Input.is_action_just_pressed("ui_right") or Input.is_action_just_pressed("ui_down"):
			if _joypad_echo_timer.is_stopped():
				_joypad_echo_event = event
				_joypad_echo_timer.start()
				print("Waiting...")

func _on_app_closing():
	emit_signal("app_closing")

func _on_app_received_focus():
		emit_signal("app_received_focus")

func _on_app_lost_focus():
	emit_signal("app_lost_focus")

func _load_helper_config():
	var path := "res://addons/retrohub_theme_helper/config.json"
	var file := File.new()
	if not file.open(path, File.READ):
		var result := JSON.parse(file.get_as_text())
		file.close()
		if not result.error:
			_helper_config = result.result

func is_main_app() -> bool:
	return false

func load_titles():
	yield(get_tree(), "idle_frame")
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
	for system in RetroHubConfig._systems_raw.values():
		var system_data := RetroHubSystemData.new()
		system_data.name = system["name"]
		system_data.fullname = system["fullname"]
		system_data.platform = system["platform"]
		system_data.category = RetroHubConfig.convert_system_category(system["category"])
		system_data.num_games = num_games
		emit_signal("system_received", system_data)
	emit_signal("system_receive_end")
	
	emit_signal("game_receive_start")
	for system in RetroHubConfig._systems_raw.values():
		for i in range(num_games):
			emit_signal("game_received", gen_random_game(system["name"]))
	emit_signal("game_receive_end")

func gen_random_game(system_name):
	var game_data := RetroHubGameData.new()
	game_data.has_metadata = true
	game_data.has_media = true
	game_data.system_name = system_name
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
	RetroHubConfig.load_game_data_files()
	emit_signal("system_receive_start")
	for system in RetroHubConfig.systems.values():
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

func is_input_echo():
	return is_echo

func stop_game():
	print("Stopping game")
	load_titles()

func request_theme_reload():
	pass
