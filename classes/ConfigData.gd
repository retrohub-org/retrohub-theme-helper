extends Resource
class_name ConfigData

const KEY_IS_FIRST_TIME = "is_first_time"
const KEY_GAMES_DIR = "games_dir"
const KEY_CURRENT_THEME = "current_theme"
const KEY_LANG = "lang"
const KEY_FULLSCREEN = "fullscreen"
const KEY_VSYNC = "vsync"
const KEY_RENDER_RESOLUTION = "render_resolution"
const KEY_REGION = "region"
const KEY_RATING_SYSTEM = "rating_system"
const KEY_DATE_FORMAT = "date_format"
const KEY_SYSTEM_NAMES = "system_names"
const KEY_SCRAPER_SS_USE_CUSTOM_ACCOUNT = "scraper_ss_use_custom_account"
const KEY_SCRAPER_SS_USERNAME = "scraper_ss_username"
const KEY_SCRAPER_SS_PASSWORD = "scraper_ss_password"
const KEY_CUSTOM_INPUT_REMAP = "custom_input_remap"
const KEY_INPUT_KEY_MAP = "input_key_map"
const KEY_INPUT_CONTROLLER_MAP = "input_controller_map"
const KEY_INPUT_CONTROLLER_MAIN_AXIS = "input_controller_main_axis"
const KEY_INPUT_CONTROLLER_SECONDARY_AXIS = "input_controller_secondary_axis"
const KEY_INPUT_CONTROLLER_ICON_TYPE = "input_controller_icon_type"

static func default_system_names() -> Dictionary:
	return {
		"genesis": "genesis",
		"nes": "nes",
		"snes": "snes",
		"tg16": "tg16",
		"tg-cd": "tg-cd",
		"odyssey2": "odyssey2"
	}

static func get_system_rename_options(system: String) -> Array:
	match system:
		"genesis":
			return ["genesis", "megadrive"]
		"nes":
			return ["nes", "famicom"]
		"snes":
			return ["snes", "sfc"]
		"tg16":
			return ["tg16", "pcengine"]
		"tg-cd":
			return ["tg-cd", "pcenginecd"]
		"odyssey2":
			return ["odyssey2", "videopac"]
		_:
			return [system]


static func default_input_key_map() -> Dictionary:
	return {
		"rh_accept": [KEY_ENTER],
		"rh_back": [KEY_BACKSPACE],
		"rh_major_option": [KEY_CONTROL],
		"rh_minor_option": [KEY_ALT],
		"rh_menu": [KEY_ESCAPE],
		"rh_theme_menu": [KEY_SHIFT],
		"rh_up": [KEY_UP, KEY_W],
		"rh_down": [KEY_DOWN, KEY_S],
		"rh_left": [KEY_LEFT, KEY_A],
		"rh_right": [KEY_RIGHT, KEY_D],
		"rh_left_shoulder": [KEY_Q],
		"rh_right_shoulder": [KEY_E]
	}

static func default_input_controller_map() -> Dictionary:
	return {
		"rh_accept": [JOY_XBOX_A],
		"rh_back": [JOY_XBOX_B],
		"rh_major_option": [JOY_XBOX_X],
		"rh_minor_option": [JOY_XBOX_Y],
		"rh_menu": [JOY_START],
		"rh_theme_menu": [JOY_SELECT],
		"rh_up": [JOY_DPAD_UP],
		"rh_down": [JOY_DPAD_DOWN],
		"rh_left": [JOY_DPAD_LEFT],
		"rh_right": [JOY_DPAD_RIGHT],
		"rh_left_shoulder": [JOY_L],
		"rh_right_shoulder": [JOY_R],
		"rh_left_trigger": [JOY_L2],
		"rh_right_trigger": [JOY_R2]
	}