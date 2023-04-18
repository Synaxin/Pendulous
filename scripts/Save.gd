extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var saves_path = "user://"
var save_data_template = "speed=2\nbasecompass=1\narmcompass=1\nsound=1\nmusic=1\n{}"

var speed = 2
var base_compass_on = true
var arm_compass_on = true
var sound_on = true
var music_on = true
var profile = 1

var current_profile_path = "user://profile1.txt"
var last_profile_path = "user://lastprofile.txt"
var current_profile_levels

# Called when the node enters the scene tree for the first time.
#Load last selected profile
func _ready():
	pass
	"""
	var last_profile = File.new()
	last_profile.open(last_profile_path, File.READ)
	if !last_profile.is_open():
		print("not open")
		last_profile.open(last_profile_path, File.WRITE)
		last_profile.store_string("1")
		last_profile.close()
		last_profile.open(last_profile_path, File.READ)
	var content = last_profile.get_as_text()
	var profile = 1
	if content == "2":
		profile = 2
	elif content == "3":
		profile = 3
	else:
		profile = 1
	_load(profile)
	#last_profile.
	_get_progress(20)
	_update_progress(1, 100)
	_update_progress(2, 100)
	_update_progress(3, 80)
	_update_progress(4, 20)
	_update_setting("speed", 3)
	_update_setting("basecompass", 0)
	"""


func _init_load():
	var last_profile = File.new()
	last_profile.open(last_profile_path, File.READ)
	if !last_profile.is_open():
		print("not open")
		last_profile.open(last_profile_path, File.WRITE)
		last_profile.store_string("1")
		last_profile.close()
		last_profile.open(last_profile_path, File.READ)
	var content = last_profile.get_as_text()
	profile = 1
	if content == "2":
		profile = 2
	elif content == "3":
		profile = 3
	else:
		profile = 1
	_load(profile)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#Load a profile
#Should iterate through the file, detect { as the start, using : as the separator for pairs, and , for the delimiter
func _load(profile_num):
	var profile = File.new()
	current_profile_path = saves_path + "profile" + str(profile_num) + ".txt"
	profile.open(current_profile_path, File.READ)
	if !profile.is_open():
		profile.open(current_profile_path, File.WRITE)
		profile.store_string(save_data_template)
		profile.close()
		profile.open(current_profile_path, File.READ)
	var content
	var current_string = ""
	var reached_levels = false
	while !profile.eof_reached():
		content = profile.get_line()
		current_string = ""
		for i in range(0, content.length()):
			if content[0] != "{":
				current_string = current_string + str(content[i])
				if current_string == "speed":
					for j in range(i, content.length()):
						if j + 1 < content.length():
							if content[j + 1] == "=":
								if j + 2 < content.length():
									speed = int(content[j + 2])
									print("Speed ", speed)
									break
					break
				elif current_string == "basecompass":
					for j in range(i, content.length()):
						if j + 1 < content.length():
							if content[j + 1] == "=":
								if j + 2 < content.length():
									base_compass_on = bool(int(content[j + 2]))
									print("BaseCompass ", base_compass_on)
									break
					break
				elif current_string == "armcompass":
					for j in range(i, content.length()):
						if j + 1 < content.length():
							if content[j + 1] == "=":
								if j + 2 < content.length():
									arm_compass_on = bool(int(content[j + 2]))
									print("Armcompass ", arm_compass_on)
									break
					break
				elif current_string == "sound":
					for j in range(i, content.length()):
						if j + 1 < content.length():
							if content[j + 1] == "=":
								if j + 2 < content.length():
									sound_on = bool(int(content[j + 2]))
									print("Sound ", sound_on)
									break
					break
				elif current_string == "music":
					for j in range(i, content.length()):
						if j + 1 < content.length():
							if content[j + 1] == "=":
								if j + 2 < content.length():
									
									music_on = bool(int(content[j + 2]))
									print("Music ", music_on)
									break
					break
			else:
				current_profile_levels = content
				break
	#print(current_profile_levels)
	profile.close()
	profile.open(last_profile_path, File.WRITE)
	profile.store_string(str(profile_num))
	profile.close()
	
func _update_setting(setting, value):
	var profile = File.new()
	profile.open(current_profile_path, File.READ)
	var content
	var file_content = ""
	var current_string = ""
	var line = 0
	while !profile.eof_reached():
		content = profile.get_line()
		current_string = ""
		for i in range(0, content.length()):
			current_string = current_string + str(content[i])
			if current_string == setting:
				for j in range(i, content.length()):
						if j + 1 < content.length():
							if content[j + 1] == "=":
								if j + 2 < content.length():
									content[j + 2] = str(value)
									print("currstr ", current_string, " ", value)
									break
		file_content = file_content + content + "\n"
	profile.close()
	profile.open(current_profile_path, File.WRITE)
	profile.store_string(file_content)
	profile.close()
	
	
#Should iterate through the file, detect { as the start, using : as the separator for pairs, and , for the delimiter
#Detect if level has already been written to, if so update progress, otherwise append before the }
func _update_progress(level, progress):
	var profile = File.new()
	profile.open(current_profile_path, File.READ)
	var profile_contents = ""
	var content
	while !profile.eof_reached():
		content = profile.get_line()
		if content[0] != "{":
			profile_contents = profile_contents + content + "\n"
		else:
			break
	profile.close()
	var current_string = ""
	var current_progress = ""
	var progress_start_index = 0
	var progress_end_index = 0
	var after_colon = false
	var found = false
	for i in range(0, current_profile_levels.length()):
		if current_profile_levels[i] != "{" and current_profile_levels[i] != "}":
			if current_profile_levels[i] == ":":
				after_colon = true
				if current_string.is_valid_integer():
					if int(current_string) == int(level):
						found = true
						progress_start_index = i + 1
				continue
			elif current_profile_levels[i] == ",":
				if found:
					progress_end_index = i
					break
				current_string = ""
				current_progress = ""
				after_colon = false
				continue
			if !after_colon:
				current_string = current_string + str(current_profile_levels[i])
			else:
				if found:
					current_progress = current_progress + str(current_profile_levels[i])
	if found:
		#print(level)
		var prog_length = progress_end_index - progress_start_index
		if progress_start_index != 0 and progress_end_index != 0:
			if prog_length == str(progress).length():
				for i in range(0, prog_length):
					current_profile_levels[progress_start_index + i] = str(progress)[i]
				#print("Equal to", level)
			elif prog_length < str(progress).length():
				for i in range(0, prog_length):
					current_profile_levels[progress_start_index + i] = str(progress)[i]
				current_profile_levels = current_profile_levels.insert(progress_end_index - 1, str(progress)[prog_length])
				#print("Greater than", level)
			elif prog_length > str(progress).length():
				#print("Less than", level)
				for i in range(0, prog_length):
					if i == prog_length - 1:
						current_profile_levels[progress_start_index + i] = ""
					else:
						current_profile_levels[progress_start_index + i] = str(progress)[i]
		
	else:
		current_profile_levels = current_profile_levels.insert(current_profile_levels.length() - 1, str(level) + ":" + str(progress) + ",")
	profile_contents = profile_contents + current_profile_levels
	profile.open(current_profile_path, File.WRITE)
	profile.store_string(profile_contents)
	profile.close()
	
	
#Return progress of all levels
func _get_progress(num_levels):
	var data_array = []
	for i in range(0, num_levels):
		data_array.append(0)
	var current_string = ""
	var current_progress = ""
	var after_colon = false
	for i in range(0, current_profile_levels.length()):
		if current_profile_levels[i] != "{" and current_profile_levels[i] != "}":
			if current_profile_levels[i] == ":":
				after_colon = true
				continue
			elif current_profile_levels[i] == ",":
				if current_string.is_valid_integer():
					if int(current_string) - 1 < num_levels:
						if current_progress.is_valid_integer():
							data_array[int(current_string) - 1] = int(current_progress)
				current_string = ""
				current_progress = ""
				after_colon = false
				continue
			if !after_colon:
				current_string = current_string + str(current_profile_levels[i])
			else:
				current_progress = current_progress + str(current_profile_levels[i])
	print(data_array)
	return data_array

#Return progress of specific level
func _get_level_progress(level):
	var current_string = ""
	var current_progress = ""
	var after_colon = false
	var found = true
	for i in range(0, current_profile_levels.length()):
		if current_profile_levels[i] != "{" and current_profile_levels[i] != "}":
			if current_profile_levels[i] == ":":
				after_colon = true
				continue
			elif current_profile_levels[i] == ",":
				if current_string.is_valid_integer():
					if int(current_string) == int(level):
						found = true
						break
				current_string = ""
				current_progress = ""
				after_colon = false
				continue
			if !after_colon:
				current_string = current_string + str(current_profile_levels[i])
			else:
				current_progress = current_progress + str(current_profile_levels[i])
	if found:
		return int(current_progress)
	else:
		return 0
		
func _reset_profile(profile_num):
	var profile = File.new()
	current_profile_path = saves_path + "profile" + str(profile_num) + ".txt"
	profile.open(current_profile_path, File.READ)
	profile.open(current_profile_path, File.WRITE)
	profile.store_string(save_data_template)
	profile.close()
	print("Reset " + str(profile_num))
	_load(profile_num)
	#profile.open(current_profile_path, File.READ)
		
func _get_settings():
	return [speed, base_compass_on, arm_compass_on, music_on, sound_on]
	
func _get_profile():
	return profile
	
