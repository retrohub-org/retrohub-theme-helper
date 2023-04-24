extends Resource
class_name ConfigData

var is_first_time : bool = true
var games_dir : String = FileUtils.get_home_dir() + "/ROMS"
var current_theme : String = "default"
var lang : String = "en"
var fullscreen : bool = true
var vsync : bool = true
var render_resolution : int = 100
var region : String = "usa"
var rating_system : String = "esrb"
var date_format : String = "mm/dd/yyyy"
var system_names : Dictionary = default_system_names()
var scraper_hash_file_size : int = 64
var scraper_ss_use_custom_account : bool = false
var scraper_ss_max_threads : int = 6
var custom_input_remap : String = ""
var input_key_map : Dictionary = default_input_key_map()
var input_controller_map : Dictionary = default_input_controller_map()
var input_controller_main_axis : String = "left"
var input_controller_secondary_axis : String = "right"
var input_controller_icon_type : String = "auto"
var input_controller_echo_pre_delay: float = 0.75
var input_controller_echo_delay: float = 0.15
var virtual_keyboard_layout : String = "qwerty"
var virtual_keyboard_type : String = default_virtual_keyboard_type()
var virtual_keyboard_show_on_controller : bool = true
var virtual_keyboard_show_on_mouse : bool = false
var accessibility_screen_reader_enabled : bool = true

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
const KEY_SCRAPER_HASH_FILE_SIZE = "scraper_hash_file_size"
const KEY_SCRAPER_SS_USE_CUSTOM_ACCOUNT = "scraper_ss_use_custom_account"
const KEY_SCRAPER_SS_MAX_THREADS = "scraper_ss_max_threads"
const KEY_CUSTOM_INPUT_REMAP = "custom_input_remap"
const KEY_INPUT_KEY_MAP = "input_key_map"
const KEY_INPUT_CONTROLLER_MAP = "input_controller_map"
const KEY_INPUT_CONTROLLER_MAIN_AXIS = "input_controller_main_axis"
const KEY_INPUT_CONTROLLER_SECONDARY_AXIS = "input_controller_secondary_axis"
const KEY_INPUT_CONTROLLER_ICON_TYPE = "input_controller_icon_type"
const KEY_INPUT_CONTROLLER_ECHO_PRE_DELAY = "input_controller_echo_pre_delay"
const KEY_INPUT_CONTROLLER_ECHO_DELAY = "input_controller_echo_delay"
const KEY_VIRTUAL_KEYBOARD_LAYOUT = "virtual_keyboard_layout"
const KEY_VIRTUAL_KEYBOARD_TYPE = "virtual_keyboard_type"
const KEY_VIRTUAL_KEYBOARD_SHOW_ON_CONTROLLER = "virtual_keyboard_show_on_controller"
const KEY_VIRTUAL_KEYBOARD_SHOW_ON_MOUSE = "virtual_keyboard_show_on_mouse"
const KEY_ACCESSIBILITY_SCREEN_READER_ENABLED = "accessibility_screen_reader_enabled"

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

static func default_virtual_keyboard_type() -> String:
	if FileUtils.is_steam_deck():
		return "steam"
	else:
		return "builtin"
