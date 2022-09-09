extends Node

var game_images := [
	"4_3.png", "16_9.png"
]

var box_images := [
	"rectangle.png", "square.png"
]

var support_images := [
	"rectangle_vertical.png", "rectangle_horizontal.png", "disc.png"
]

func retrieve_media_data(game_data: RetroHubGameData) -> RetroHubGameMediaData:
	if not game_data.has_media:
		return null

	if RetroHub._helper_config.has("games_mode"):
		match RetroHub._helper_config["games_mode"]:
			"local":
				return load_media_data(game_data)
			"random", _:
				return gen_random_media_data()
	else:
		return gen_random_media_data()

func gen_random_media_data() -> RetroHubGameMediaData:
	var game_media_data := RetroHubGameMediaData.new()

	var base_path = "res://addons/retrohub_theme_helper/assets/"
	var image := Image.new()
	var file := File.new()
	# Logo
	var path = base_path + "logo/logo.png"
	if image.load(path):
		print("Error when loading sample logo image!")
	else:
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(image, 6)
		game_media_data.logo = image_texture

	# Screenshot
	path = base_path + "screenshot/" + game_images[randi() % game_images.size()]
	if image.load(path):
		print("Error when loading sample screenshot image")
	else:
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(image, 6)
		game_media_data.screenshot = image_texture

	# Title screen
	path = base_path + "title-screen/" + game_images[randi() % game_images.size()]
	if image.load(path):
		print("Error when loading sample title screen image")
	else:
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(image, 6)
		game_media_data.title_screen = image_texture

	# Box render
	var box_tex = box_images[randi() % box_images.size()]
	path = base_path + "box-render/" + box_tex
	if image.load(path):
		print("Error when loading sample box render image")
	else:
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(image, 6)
		game_media_data.box_render = image_texture

	# Box texture
	path = base_path + "box-texture/" + box_tex
	if image.load(path):
		print("Error when loading sample box texture image")
	else:
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(image, 6)
		game_media_data.box_texture = image_texture

	# Support render
	var support_tex = support_images[randi() % support_images.size()]
	path = base_path + "support-render/" + support_tex
	if image.load(path):
		print("Error when loading sample support render image")
	else:
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(image, 6)
		game_media_data.support_render = image_texture

	# Support texture
	path = base_path + "support-texture/" + support_tex
	if image.load(path):
		print("Error when loading sample support texture image")
	else:
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(image, 6)
		game_media_data.support_texture = image_texture

	# Video
	path = base_path + "video/video.mp4"
	if not file.file_exists(path):
		print("Error when loading sample video")
	else:
		var video_stream := VideoStreamGDNative.new()
		#var video_stream := VideoStreamWebm.new()
		video_stream.set_file(path)
		game_media_data.video = video_stream
	
	# Manual
	## FIXME: Very likely we won't be able to support PDF reading.

	return game_media_data

func load_media_data(game_data: RetroHubGameData) -> RetroHubGameMediaData:
	var game_media_data := RetroHubGameMediaData.new()

	var media_path = RetroHubConfig.get_gamemedia_dir() + "/" + game_data.system_name
	var game_path = game_data.path.get_file().get_basename()

	var image := Image.new()
	var file := File.new()
	var path : String

	# Logo
	path = media_path + "/logo/" + game_path + ".png"
	if image.load(path):
		print("Error when loading logo image for game %s!" % game_data.name)
	else:
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(image, 6)
		game_media_data.logo = image_texture

	# Screenshot
	path = media_path + "/screenshot/" + game_path + ".png"
	if image.load(path):
		print("Error when loading screenshot image for game %s!" % game_data.name)
	else:
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(image, 6)
		game_media_data.screenshot = image_texture

	# Title screen
	path = media_path + "/title-screen/" + game_path + ".png"
	if image.load(path):
		print("Error when loading title screen image for game %s!" % game_data.name)
	else:
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(image, 6)
		game_media_data.title_screen = image_texture

	# Box render
	path = media_path + "/box-render/" + game_path + ".png"
	if image.load(path):
		print("Error when loading box render image for game %s!" % game_data.name)
	else:
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(image, 6)
		game_media_data.box_render = image_texture

	# Box texture
	path = media_path + "/box-texture/" + game_path + ".png"
	if image.load(path):
		print("Error when loading box texture image for game %s!" % game_data.name)
	else:
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(image, 6)
		game_media_data.box_texture = image_texture

	# Support render
	path = media_path + "/support-render/" + game_path + ".png"
	if image.load(path):
		print("Error when loading support render image for game %s!" % game_data.name)
	else:
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(image, 6)
		game_media_data.support_render = image_texture

	# Support texture
	path = media_path + "/support-texture/" + game_path + ".png"
	if image.load(path):
		print("Error when loading support texture image for game %s!" % game_data.name)
	else:
		var image_texture = ImageTexture.new()
		image_texture.create_from_image(image, 6)
		game_media_data.support_texture = image_texture

	# Video
	path = media_path + "/video/" + game_path + ".mp4"
	if not file.file_exists(path):
		print("Error when loading video for game %s!" % game_data.name)
	else:
		var video_stream := VideoStreamGDNative.new()
		#var video_stream := VideoStreamWebm.new()
		video_stream.set_file(path)
		game_media_data.video = video_stream
	
	# Manual
	## FIXME: Very likely we won't be able to support PDF reading.

	return game_media_data
