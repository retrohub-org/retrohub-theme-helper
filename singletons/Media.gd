extends Node

#warning-ignore:unused_signal
signal media_loaded(media_data, game_data, types)

enum Type {
	LOGO = 1 << 0,
	SCREENSHOT = 1 << 1,
	TITLE_SCREEN = 1 << 2,
	VIDEO = 1 << 3,
	BOX_RENDER = 1 << 4,
	BOX_TEXTURE = 1 << 5,
	SUPPORT_RENDER = 1 << 6,
	SUPPORT_TEXTURE = 1 << 7,
	MANUAL = 1 << 8,
	ALL = (1 << 9) - 1
}

var game_images := [
	"4_3.png", "16_9.png"
]

var box_images := [
	"rectangle.png", "square.png"
]

var support_images := [
	"rectangle_vertical.png", "rectangle_horizontal.png", "disc.png"
]

var blurhash_existing_images := {
	"logo.png": "L6S~L[of~Wt7WBayt7j[_3fQ9FfQ",
	"4_3.png": "L6S~I,of~WofNGfQxufQ~WfQ9Fj[",
	"16_9.png": "L5T8%fof~WofR*fQxufQ_3fQ4.j[",
	"rectangle.png": "LcDvZixu00M{ofj[WBayM{oft7WB",
	"square.png": "LSFiJh?H00M{ofj[ayayE1t7xuM{",
	"rectangle_vertical.png": "LOCGPwM{00%M?bRjD%xaRjj[ofWB",
	"rectangle_horizontal.png": "LKCP@eof9ZfQ?bj[M{fQ00ay%2fQ",
	"disc.png": "LFHenGt74nay%2j[R*ay00WB00ay",
}

var _media_cache := {}

var _thread : Thread
var _semaphore : Semaphore
var _processing_mutex := Mutex.new()
var _queue_mutex := Mutex.new()
var _queue := []

var _blurhash_cache := {}

func _enter_tree():
	_start_thread()

func _exit_tree():
	_stop_thread()

func _start_thread():
	if not _thread:
		_thread = Thread.new()
		_semaphore = Semaphore.new()

		_thread.start(Callable(self, "t_process_media_requests"))

func _stop_thread():
	_queue_mutex.lock()
	_queue.clear()
	_semaphore.post()
	_queue_mutex.unlock()

	_thread.wait_to_finish()
	_thread = null


func t_process_media_requests():
	while true:
		_processing_mutex.lock()
		# Wait for incoming requests
		_semaphore.wait()

		# Get a request type
		_queue_mutex.lock()
		# If queue is empty, app is signaling thread to finish
		if _queue.is_empty():
			_processing_mutex.unlock()
			_queue_mutex.unlock()
			return

		var req : Array = _queue.pop_front()
		var game_data : RetroHubGameData = req[0]
		var types : int = req[1]
		_queue_mutex.unlock()
		_processing_mutex.unlock()

		var media_data := retrieve_media_data(game_data, types)
		call_thread_safe("emit_signal", "media_loaded", media_data, game_data, types)

func clear_media_cache(data: RetroHubGameData):
	_media_cache.erase(data)

func clear_all_media_cache():
	_media_cache.clear()

func remove_media_cache(game_data: RetroHubGameData):
	_media_cache.erase(game_data)

func convert_type_bitmask_to_list(bitmask: int) -> Array:
	var arr := []
	if bitmask & Type.LOGO:
		arr.push_back(Type.LOGO)
	if bitmask & Type.SCREENSHOT:
		arr.push_back(Type.SCREENSHOT)
	if bitmask & Type.TITLE_SCREEN:
		arr.push_back(Type.TITLE_SCREEN)
	if bitmask & Type.VIDEO:
		arr.push_back(Type.VIDEO)
	if bitmask & Type.BOX_RENDER:
		arr.push_back(Type.BOX_RENDER)
	if bitmask & Type.BOX_TEXTURE:
		arr.push_back(Type.BOX_TEXTURE)
	if bitmask & Type.SUPPORT_RENDER:
		arr.push_back(Type.SUPPORT_RENDER)
	if bitmask & Type.SUPPORT_TEXTURE:
		arr.push_back(Type.SUPPORT_TEXTURE)
	if bitmask & Type.MANUAL:
		arr.push_back(Type.MANUAL)
	return arr

func convert_type_to_media_path(type: int) -> String:
	match type:
		Type.LOGO:
			return "logo"
		Type.SCREENSHOT:
			return "screenshot"
		Type.TITLE_SCREEN:
			return "title-screen"
		Type.VIDEO:
			return "video"
		Type.BOX_RENDER:
			return "box-render"
		Type.BOX_TEXTURE:
			return "box-texture"
		Type.SUPPORT_RENDER:
			return "support-render"
		Type.SUPPORT_TEXTURE:
			return "support-texture"
		Type.MANUAL:
			return "manual"
		_:
			return "unknown"

func retrieve_media_data(game_data: RetroHubGameData, types: int = Type.ALL) -> RetroHubGameMediaData:
	if not game_data.has_media:
		push_error("Error: game %s has no media" % game_data.name)
		return null

	if RetroHub._helper_config.has("games_mode"):
		match RetroHub._helper_config["games_mode"]:
			"local":
				return load_media_data(game_data, types)
			"random", _:
				return gen_random_media_data(game_data, types)
	else:
		return gen_random_media_data(game_data, types)

func retrieve_media_data_async(game_data: RetroHubGameData, types: int = Type.ALL, priority: bool = false):
	if not game_data.has_media:
		push_error("Error: game %s has no media" % game_data.name)
		return

	_queue_mutex.lock()
	var req := [game_data, types]
	if priority:
		_queue.push_front(req)
	else:
		_queue.push_back(req)
	#warning-ignore:return_value_discarded
	_semaphore.post()
	_queue_mutex.unlock()

func retrieve_media_data_and_blurhash_async(game_data: RetroHubGameData, types: Type = Type.ALL, priority: bool = false) -> RetroHubGameMediaData:
	retrieve_media_data_async(game_data, types, priority)
	return retrieve_media_blurhash(game_data, types)

func retrieve_media_blurhash(game_data: RetroHubGameData, types: Type = Type.ALL) -> RetroHubGameMediaData:
	if not game_data.has_media:
		push_error("Error: game %s has no media" % game_data.name)
		return null

	if RetroHub._helper_config.has("games_mode"):
		match RetroHub._helper_config["games_mode"]:
			"local":
				return _load_blurhash(game_data, types)
			"random", _:
				return _fetch_random_blurhash(game_data, types)
	else:
		return _fetch_random_blurhash(game_data, types)

func _load_blurhash(game_data: RetroHubGameData, types: Type = Type.ALL) -> RetroHubGameMediaData:
	var game_media_data := RetroHubGameMediaData.new()

	var media_path := RetroHubConfig.get_gamemedia_dir().path_join(game_data.system_path)
	var game_path := game_data.path.get_file().get_basename()

	var blurhashes := _get_blurhash(game_data)

	# Logo
	if types & Type.LOGO and blurhashes.has("logo"):
		game_media_data.logo = BlurHash.decode(blurhashes["logo"], 16, 9)

	# Screenshot
	if types & Type.SCREENSHOT and blurhashes.has("screenshot"):
		game_media_data.screenshot = BlurHash.decode(blurhashes["screenshot"], 16, 9)

	# Title screen
	if types & Type.TITLE_SCREEN and blurhashes.has("title-screen"):
		game_media_data.title_screen = BlurHash.decode(blurhashes["title-screen"], 16, 9)

	# Box render
	if types & Type.BOX_RENDER and blurhashes.has("box-render"):
		game_media_data.box_render = BlurHash.decode(blurhashes["box-render"], 16, 9)

	# Box texture
	if types & Type.BOX_TEXTURE and blurhashes.has("box-texture"):
		game_media_data.box_texture = BlurHash.decode(blurhashes["box-texture"], 16, 9)

	# Support render
	if types & Type.SUPPORT_RENDER and blurhashes.has("support-render"):
		game_media_data.support_render = BlurHash.decode(blurhashes["support-render"], 16, 9)

	# Support texture
	if types & Type.SUPPORT_TEXTURE and blurhashes.has("support-texture"):
		game_media_data.support_texture = BlurHash.decode(blurhashes["support-texture"], 16, 9)

	return game_media_data

func cancel_media_data_async(game_data: RetroHubGameData) -> void:
	if _queue.is_empty():
		return
	_processing_mutex.lock()
	_queue_mutex.lock()
	for req in _queue:
		if req[0] == game_data:
			_queue.erase(req)
			#warning-ignore:return_value_discarded
			_semaphore.wait()
			break
	_queue_mutex.unlock()
	_processing_mutex.unlock()

func gen_random_media_data(game_data: RetroHubGameData, types: int) -> RetroHubGameMediaData:
	if not _media_cache.has(game_data):
		_media_cache[game_data] = RetroHubGameMediaData.new()
	var game_media_data : RetroHubGameMediaData = _media_cache[game_data]

	var base_path = "res://addons/retrohub_theme_helper/assets/"

	# Logo
	var path = base_path + "logo/logo.png"
	if types & Type.LOGO and FileAccess.file_exists(path):
		var image = Image.load_from_file(path)
		image.generate_mipmaps()
		var image_texture = ImageTexture.create_from_image(image)
		if not image_texture:
			print("Error when loading sample logo image!")
		else:
			game_media_data.logo = image_texture

	# Screenshot
	path = base_path + "screenshot/" + game_images[randi() % game_images.size()]
	if types & Type.SCREENSHOT and FileAccess.file_exists(path):
		var image = Image.load_from_file(path)
		image.generate_mipmaps()
		var image_texture = ImageTexture.create_from_image(image)
		if not image_texture:
			print("Error when loading sample screenshot image")
		else:
			game_media_data.screenshot = image_texture

	# Title screen
	path = base_path + "title-screen/" + game_images[randi() % game_images.size()]
	if types & Type.TITLE_SCREEN and FileAccess.file_exists(path):
		var image = Image.load_from_file(path)
		image.generate_mipmaps()
		var image_texture = ImageTexture.create_from_image(image)
		if not image_texture:
			print("Error when loading sample title screen image")
		else:
			game_media_data.title_screen = image_texture

	# Box render
	var box_tex = box_images[randi() % box_images.size()]
	path = base_path + "box-render/" + box_tex
	if types & Type.BOX_RENDER and FileAccess.file_exists(path):
		var image = Image.load_from_file(path)
		image.generate_mipmaps()
		var image_texture = ImageTexture.create_from_image(image)
		if not image_texture:
			print("Error when loading sample box render image")
		else:
			game_media_data.box_render = image_texture

	# Box texture
	path = base_path + "box-texture/" + box_tex
	if types & Type.BOX_TEXTURE and FileAccess.file_exists(path):
		var image = Image.load_from_file(path)
		image.generate_mipmaps()
		var image_texture = ImageTexture.create_from_image(image)
		if not image_texture:
			print("Error when loading sample box texture image")
		else:
			game_media_data.box_texture = image_texture

	# Support render
	var support_tex = support_images[randi() % support_images.size()]
	path = base_path + "support-render/" + support_tex
	if types & Type.SUPPORT_RENDER and FileAccess.file_exists(path):
		var image = Image.load_from_file(path)
		image.generate_mipmaps()
		var image_texture = ImageTexture.create_from_image(image)
		if not image_texture:
			print("Error when loading sample support render image")
		else:
			game_media_data.support_render = image_texture

	# Support texture
	path = base_path + "support-texture/" + support_tex
	if types & Type.SUPPORT_TEXTURE and FileAccess.file_exists(path):
		var image = Image.load_from_file(path)
		image.generate_mipmaps()
		var image_texture = ImageTexture.create_from_image(image)
		if not image_texture:
			print("Error when loading sample support texture image")
		else:
			game_media_data.support_texture = image_texture

	# Video

	path = base_path + "video/video.mp4"
	if types & Type.VIDEO and FileAccess.file_exists(path):
		var video_stream := VideoStream.new()
		video_stream.set_file(path)
		game_media_data.video = video_stream

	# Manual
	## FIXME: Very likely we won't be able to support PDF reading.

	return game_media_data

func _fetch_random_blurhash(game_data: RetroHubGameData, types: int) -> RetroHubGameMediaData:
	var game_media_data := RetroHubGameMediaData.new()

	# Logo
	if types & Type.LOGO:
		game_media_data.logo = BlurHash.decode(blurhash_existing_images["logo.png"] , 16, 9)

	# Screenshot
	if types & Type.SCREENSHOT:
		game_media_data.screenshot = BlurHash.decode(blurhash_existing_images[game_images[randi() % game_images.size()]], 16, 9)

	# Title screen
	if types & Type.TITLE_SCREEN:
		game_media_data.title_screen = BlurHash.decode(blurhash_existing_images[game_images[randi() % game_images.size()]], 16, 9)

	# Box render
	if types & Type.BOX_RENDER:
		game_media_data.box_render = BlurHash.decode(blurhash_existing_images[box_images[randi() % box_images.size()]], 16, 9)

	# Box texture
	if types & Type.BOX_TEXTURE:
		game_media_data.box_texture = BlurHash.decode(blurhash_existing_images[box_images[randi() % box_images.size()]], 16, 9)

	# Support render
	if types & Type.SUPPORT_RENDER:
		game_media_data.support_render = BlurHash.decode(blurhash_existing_images[support_images[randi() % support_images.size()]], 16, 9)

	# Support texture
	if types & Type.SUPPORT_TEXTURE:
		game_media_data.support_texture = BlurHash.decode(blurhash_existing_images[support_images[randi() % support_images.size()]], 16, 9)

	return game_media_data

func load_media_data(game_data: RetroHubGameData, types: int) -> RetroHubGameMediaData:
	if not _media_cache.has(game_data):
		_media_cache[game_data] = RetroHubGameMediaData.new()
	var game_media_data : RetroHubGameMediaData = _media_cache[game_data]

	var media_path := RetroHubConfig.get_gamemedia_dir().path_join(game_data.system_path)
	var game_path := game_data.path.get_file().get_basename()

	var path : String

	# Logo
	if not game_media_data.logo:
		path = media_path + "/logo/" + game_path + ".png"
		if types & Type.LOGO and FileAccess.file_exists(path):
			var image := Image.load_from_file(path)
			image.generate_mipmaps()
			var image_texture := ImageTexture.create_from_image(image)
			if not image_texture:
				push_error("Error when loading logo image for game %s!" % game_data.name)
			else:
				game_media_data.logo = image_texture

	# Screenshot
	if not game_media_data.screenshot:
		path = media_path + "/screenshot/" + game_path + ".png"
		if types & Type.SCREENSHOT and FileAccess.file_exists(path):
			var image := Image.load_from_file(path)
			image.generate_mipmaps()
			var image_texture := ImageTexture.create_from_image(image)
			if not image_texture:
				push_error("Error when loading screenshot image for game %s!" % game_data.name)
			else:
				game_media_data.screenshot = image_texture

	# Title screen
	if not game_media_data.title_screen:
		path = media_path + "/title-screen/" + game_path + ".png"
		if types & Type.TITLE_SCREEN and FileAccess.file_exists(path):
			var image := Image.load_from_file(path)
			image.generate_mipmaps()
			var image_texture := ImageTexture.create_from_image(image)
			if not image_texture:
				push_error("Error when loading title screen image for game %s!" % game_data.name)
			else:
				game_media_data.title_screen = image_texture

	# Box render
	if not game_media_data.box_render:
		path = media_path + "/box-render/" + game_path + ".png"
		if types & Type.BOX_RENDER and FileAccess.file_exists(path):
			var image := Image.load_from_file(path)
			image.generate_mipmaps()
			var image_texture := ImageTexture.create_from_image(image)
			if not image_texture:
				push_error("Error when loading box render image for game %s!" % game_data.name)
			else:
				game_media_data.box_render = image_texture

	# Box texture
	if not game_media_data.box_texture:
		path = media_path + "/box-texture/" + game_path + ".png"
		if types & Type.BOX_TEXTURE and FileAccess.file_exists(path):
			var image := Image.load_from_file(path)
			image.generate_mipmaps()
			var image_texture := ImageTexture.create_from_image(image)
			if not image_texture:
				push_error("Error when loading box texture image for game %s!" % game_data.name)
			else:
				game_media_data.box_texture = image_texture

	# Support render
	if not game_media_data.support_render:
		path = media_path + "/support-render/" + game_path + ".png"
		if types & Type.SUPPORT_RENDER and FileAccess.file_exists(path):
			var image := Image.load_from_file(path)
			image.generate_mipmaps()
			var image_texture := ImageTexture.create_from_image(image)
			if not image_texture:
				push_error("Error when loading support render image for game %s!" % game_data.name)
			else:
				game_media_data.support_render = image_texture

	# Support texture
	if not game_media_data.support_texture:
		path = media_path + "/support-texture/" + game_path + ".png"
		if types & Type.SUPPORT_TEXTURE and FileAccess.file_exists(path):
			var image := Image.load_from_file(path)
			image.generate_mipmaps()
			var image_texture := ImageTexture.create_from_image(image)
			if not image_texture:
				push_error("Error when loading support texture image for game %s!" % game_data.name)
			else:
				game_media_data.support_texture = image_texture

	# Video
	if not game_media_data.video:
		path = media_path + "/video/" + game_path + ".mp4"
		if types & Type.VIDEO and FileAccess.file_exists(path):
			var video_stream := VideoStream.new()
			video_stream.set_file(path)
			game_media_data.video = video_stream

	# Manual
	## FIXME: Very likely we won't be able to support PDF reading.

	return game_media_data

func _get_blurhash(game_data: RetroHubGameData) -> Dictionary:
	var media_path := RetroHubConfig.get_gamemedia_dir().path_join(game_data.system_path)
	var game_path := game_data.path.get_file().get_basename()

	var blurhash_path := media_path.path_join("blurhash").path_join(game_path + ".json")
	if FileAccess.file_exists(blurhash_path):
		return JSONUtils.load_json_file(blurhash_path)

	return _compute_blurhash(game_data)

func _compute_blurhash(game_data: RetroHubGameData) -> Dictionary:
	if _blurhash_cache.has(game_data):
		return _blurhash_cache[game_data]

	print("BlurHash non existant for ", game_data.name, ", computing it. Expect slowdown!")
	var media_data := load_media_data(game_data,
		Type.LOGO | Type.SCREENSHOT | Type.TITLE_SCREEN | \
		Type.BOX_RENDER | Type.BOX_TEXTURE | \
		Type.SUPPORT_RENDER | Type.SUPPORT_TEXTURE
	)

	var hash_data := {}
	for data in [
		["logo", media_data.logo],
		["screenshot", media_data.screenshot],
		["title-screen", media_data.title_screen],
		["box-render", media_data.box_render],
		["box-texture", media_data.box_texture],
		["support-render", media_data.support_render],
		["support-texture", media_data.support_texture]
	]:
		var key : String = data[0]
		var texture : Texture2D = data[1]
		if not texture: continue

		var blurhash := BlurHash.encode(texture, 4, 3)
		if blurhash.is_empty(): continue
		hash_data[key] = blurhash

	_blurhash_cache[game_data] = hash_data
	return hash_data
