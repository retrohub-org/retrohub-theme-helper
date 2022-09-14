extends Node

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
	match randi() % 3:
		0:
			format_arr = [day, month, year, hour, minute, second]
		1:
			format_arr = [year, month, day, hour, minute, second]
		2, _:
			format_arr = [month, day, year, hour, minute, second]
	return "%s/%s/%s %s:%s:%s" % format_arr

func localize_age_rating(age_rating_raw: String) -> Control:
	var rating_idx := randi() % 3
	var rating_node = preload("res://addons/retrohub_theme_helper/ui/AgeRatingTextureRect.tscn").instance()
	rating_node.from_rating_str(age_rating_raw, rating_idx)
	return rating_node

func localize_console_name(console_name_raw: String) -> String:
	return console_name_raw

func localize_console_fullname(console_fullname_raw: String) -> String:
	return console_fullname_raw
