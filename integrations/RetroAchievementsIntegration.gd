extends RetroHubIntegration

class_name RetroAchievementsIntegration

const ConsoleMapping := {
	"genesis": 1,
	"n64": 2,
	"64dd": 2,
	"snes": 3,
	"satellaview": 3,
	"sufami": 3,
	"gb": 4,
	"gba": 5,
	"gbc": 6,
	"nes": 7,
	"fds": 7,
	"tg16": 8,
	"supergrafx": 8,
	"segacd": 9,
	"sega32x": 10,
	"mastersystem": 11,
	"psx": 12,
	"atarilynx": 13,
	"ngp": 14,
	"ngpc": 14,
	"gamegear": 15,
	"gc": 16,
	"atarijaguar": 17,
	"nds": 18,
	"wii": 19,
	"wiiu": 20,
	"ps2": 21,
	"xbox": 22,
	"odyssey2": 23,
	"pokemini": 24,
	"atari2600": 25,
	"dos": 26,
	"pc": 26,
	"arcade": 27,
	"atomiswave": 27,
	"naomi": 27,
	"naomigd": 27,
	"virtualboy": 28,
	"msx": 29,
	"c64": 30,
	"zx81": 31,
	"oric": 32,
	"sg-1000": 33,
	"multivision": 33,
	"vic20": 34,
	"amiga": 35,
	"amiga600": 35,
	"amiga1200": 35,
	"atarist": 36,
	"amstradcpc": 37,
	"gx4000": 37,
	"apple2": 38,
	"saturn": 39,
	"dreamcast": 40,
	"psp": 41,
	"cdimono1": 42,
	"3do": 43,
	"colecovision": 44,
	"intellivision": 45,
	"vectrex": 46,
	"pc88": 47,
	"pc98": 48,
	"pcfx": 49,
	"atari5200": 50,
	"atari7800": 51,
	"x68000": 52,
	"wonderswan": 53,
	"wonderswancolor": 53,
	"neogeocd": 56,
	"channelf": 57,
	"zxspectrum": 59,
	"gameandwatch": 60,
	"n3ds": 62,
	"x1": 64,
	"tic80": 65,
	"to8": 66,
	"tg-cd": 76,
	"atarijaguarcd": 77,
	"uzebox": 80,
}

class GameInfo:
	enum Error {
		OK, # All good
		ERR_INVALID_CRED, # Username/API key is invalid
		ERR_CONSOLE_NOT_SUPPORTED, # Console is not supported by RA
		ERR_GAME_NOT_FOUND, # Game not found
		ERR_NETWORK, # Generic network error
		ERR_INTERNAL # Generic internal error (RetroHub/Godot), should not happen: report it!
	}

	# Error code, if any.
	var err : GameInfo.Error = Error.OK

	# Game ID in RetroAchievements.
	var id : int

	# Available achievements in the game.
	var achievements : Array[Achievement]

	# How many players are registered to have played the game (in soft/hard mode).
	var player_count : int

class Achievement:
	# Achievement ID in RetroAchievements.
	var id : int

	# Title of the achievement.
	var title : String

	# Description of the achievement.
	var description : String

	# Achievement type
	enum Type {
		NORMAL, # Regular achievement
		PROGRESSION, # Represents in-game progression
		WIN, # Is a win condition
		MISSABLE # Can be missed during gameplay
	}
	var type : Type

	# Whether the achievement is unlocked (in soft/hard mode).
	var unlocked : bool
	var unlocked_hard_mode : bool

	# How many players have unlocked the achievement in soft mode.
	var unlocked_count : int
	var unlocked_hard_mode_count : int

	var _icon_url : String

	func load_icon() -> Texture:
		var icon := preload("res://addons/retrohub_theme_helper/assets/achievement.png")
		return icon

class Raw extends Object:
	class Response:
		# Godot error. If not OK, some internal error ocurred when trying to make the request.
		var godot_error : int
		# HTTP response code. If not 200 (OK), the request failed.
		var response_code : int
		# Response; can be Dictionary or Array
		var body

	static func get_achievement_of_the_week(auth: Dictionary) -> Response:
		return Response.new()

	static func get_claims(auth: Dictionary, kind: String) -> Response:
		return Response.new()

	static func get_active_claims(auth: Dictionary) -> Response:
		return Response.new()

	static func get_top_ten_users(auth: Dictionary) -> Response:
		return Response.new()

	static func get_user_recent_achievements(auth: Dictionary, username: String, recent_minutes: int = 60) -> Response:
		return Response.new()

	static func get_achievements_earned_between(auth: Dictionary, username: String, from_date: String, to_date: String) -> Response:
		return Response.new()

	static func get_achievements_earned_on_day(auth: Dictionary, username: String, on_date: String) -> Response:
		return Response.new()

	static func get_game_info_and_user_progress(auth: Dictionary, username: String, game_id: int) -> Response:
		return Response.new()

	static func get_user_awards(auth: Dictionary, username: String) -> Response:
		return Response.new()

	static func get_user_claims(auth: Dictionary, username: String) -> Response:
		return Response.new()

	static func get_user_completed_games(auth: Dictionary, username: String) -> Response:
		return Response.new()

	static func get_user_game_rank_and_score(auth: Dictionary, username: String, game_id: int) -> Response:
		return Response.new()

	static func get_user_points(auth: Dictionary, username: String) -> Response:
		return Response.new()

	static func get_user_progress(auth: Dictionary, username: String, game_ids) -> Response:
		return Response.new()

	static func get_user_recently_played_games(auth: Dictionary, username: String, count: int = 10, offset: int = 0) -> Response:
		return Response.new()

	static func get_user_summary(auth: Dictionary, username: String, recent_games_count: int = 0, recent_achievements_count: int = 5) -> Response:
		return Response.new()

	static func get_achievement_count(auth: Dictionary, game_id: int) -> Response:
		return Response.new()

	static func get_achievement_distribution(auth: Dictionary, game_id: int) -> Response:
		return Response.new()

	static func get_game(auth: Dictionary, game_id: int) -> Response:
		return Response.new()

	static func get_game_extended(auth: Dictionary, game_id: int) -> Response:
		return Response.new()

	static func get_game_rank_and_score(auth: Dictionary, game_id: int, type: String) -> Response:
		return Response.new()

	static func get_game_rating(auth: Dictionary, game_id: int) -> Response:
		return Response.new()

	static func get_console_ids(auth: Dictionary) -> Response:
		return Response.new()

	static func get_game_list(auth: Dictionary, console_id: int, should_only_retrieve_games_with_achievements: bool = false, should_retrieve_game_hashes: bool = false) -> Response:
		return Response.new()

	static func get_achievement_unlocks(auth: Dictionary, achievement_id: int, count: int = 50, offset: int = 0) -> Response:
		return Response.new()

static func is_available() -> bool:
	return RetroHub._helper_config.has("integration_rcheevos_enabled") and \
		RetroHub._helper_config["integration_rcheevos_enabled"]

static var _ready_called := false

func _ready():
	_ready_called = true

static func ensure_ready():
	if not _ready_called:
		push_error("RetroAchievementIntegration not added to the scene tree! You must add it prior to using it.")
	return _ready_called

func build_auth() -> Dictionary:
	return {
		"z": "_api_username",
		"y": "_api_key"
	}

func get_game_info(data: RetroHubGameData) -> GameInfo:
	if not ensure_ready():
		queue_free()
		return null

	var info := GameInfo.new()
	info.id = randi() % 10000
	var player_count := randi() % 10000
	info.player_count = player_count
	for __ in range(randi() % 75):
		var achievement := Achievement.new()
		achievement.id = randi() % 10000
		achievement.title = "Achievement %d" % achievement.id
		achievement.description = "Achievement %d description" % achievement.id
		if randf() > 0.8:
			achievement.type = randi() % (Achievement.Type.size()-1) + 1 as Achievement.Type
		achievement.unlocked = randf() > 0.2
		achievement.unlocked_hard_mode = achievement.unlocked and randf() > 0.8
		achievement.unlocked_count = randi() % player_count
		achievement.unlocked_hard_mode_count = randi() % player_count
		
		info.achievements.push_back(achievement)

	return info

func get_game_hash(data: RetroHubGameData) -> String:
	if not ensure_ready():
		queue_free()
		return ""

	if not ConsoleMapping.has(data.system.name):
		return ""
	return RCheevosHash.get_file_hash(data.path, ConsoleMapping[data.system.name])
