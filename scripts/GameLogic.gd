extends Node2D
signal menu_button
signal level_to_page




# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var folder_overlay = "res:///art/Levels/Overlays/"
var folder_reference = "res:///art/Levels/References/"
var folder_levels = "res:///scenes/assets/Levels/Level"
var overlay
var reference
var ref_assigned = false

var active_scene

export var accuracy_c = 0.7
export var accuracy_b = 0.8
export var accuracy_a = 0.9
export var accuracy_s = 1

export var slow_speed = 0.012
export var norm_speed = 0.008
export var fast_speed = 0.006

var current_level = 0
var current_profile = 1

export var num_levels = 4
var highest_level = 1

var level_progresses = []
var pend_speed = 2
var base_comp_on = true
var pen_comp_on = true
var music_on = true
var sound_on = true

var time_counter = 0
var level_completion_time = 0
var level_completion_wait = 2
var level_complete = false


onready var pendulum = $Pendulum
onready var level_select = $LevelSelect
onready var level_overlay = $Pendulum/PendControl/ZNode/ViewportContainer/Viewport/LevelOverlay

# Called when the node enters the scene tree for the first time.
func _ready():
	print(level_select)
	for i in range(0, num_levels):
		level_select._add_button()
		
	#Add in save logic
	#$Save._init_load()
	_open_save(true)
	#emit_signal("level_to_page")
	#$LevelSelect._level_to_page(2)
	pass
	#_check_drawing()
	
func _process(delta):
	time_counter += delta
	if time_counter >= level_completion_time + level_completion_wait and level_complete:
		level_complete = false
		$CompleteMenu/CanvasLayer.show()
	
func _get_highest_level():
	pass

func _initiate(over, ref):
	overlay = over
	level_overlay.texture = overlay
	
	if ref_assigned:
		reference.unlock()
	else:
		ref_assigned = true
	reference = ref
	print(reference)
	reference.lock()
	#print(reference.get_pixel(344, 263))

func _load_level(level_num):
	active_scene = load(folder_levels + str(level_num) + ".tscn").instance()
	current_level = int(level_num)
	print(active_scene)
	add_child(active_scene)
	#var level_info = active_scene.get_node("Level")
	#print(level_info)
	pendulum._initialize_pendulum(active_scene._get_arm_info(), active_scene._get_rotation_info(), active_scene._get_start_info())
	pendulum._reset()
	_initiate(active_scene._get_overlay(), active_scene._get_reference())
	
	
func _unload_level():
	active_scene.queue_free()
	level_overlay.texture = Image.new()
	pendulum._reset_pendulum()

func _check_drawing(image):
	level_complete = true
	level_completion_time = time_counter
	#var temp = load("res:///ReferenceOverlay.png")
	#temp = temp.get_data()
	#temp.lock()
	image.lock()
	reference.lock()
	var matches_red = 0
	var matches_white = 0
	var matches_none = 0
	var blanks = 0
	var num_white = 0
	var num_red = 0
	for i in range(image.get_size().y):
		for j in range(image.get_size().x):
			var blue_found
			var comp_pixel = image.get_pixel(j, i)
			var ref_pixel = reference.get_pixel(j, i)
			if comp_pixel.b > 0.8 and comp_pixel.r < 0.8 and comp_pixel.g < 0.8 and comp_pixel.a == 1:
				blue_found = true
			if ref_pixel.r > ref_pixel.g and ref_pixel.r > ref_pixel.b:
				num_red += 1
				if blue_found:
					matches_red += 1
			elif ref_pixel.r > 0.5 and ref_pixel.g > 0.5 and ref_pixel.b > 0.5:
				num_white += 1
				if blue_found:
					matches_white += 1
			else:
				if blue_found:
					matches_none += 1
				else:
					blanks += 1
	#print(highest_white)
	#print(highest_red)
	#print(highest_blue)
	#print(matches_red)
	#print(matches_white)
	#print(matches_none)
	#print(blanks)
	print(matches_red, " ", num_red)
	var accuracy = float(matches_red) / float(num_red)
	#accuracy += (matches_white / num_red) / 2
	#var sum = matches_red + matches_white + matches_none
	#print(sum)
	var num_fields = 0
	
	if matches_red != 0:
		num_fields += 1
	if matches_white != 0:
		num_fields += 1
	if matches_none != 0:
		num_fields += 1
		
	#if accuracy > 1:
		#accuracy = 1
	#accuracy *= 100
	#if sum > 0:
		
		#var average = sum / num_fields
		#var accuracy_red = float(matches_red) / sum
		#var accuracy_white = float(matches_white) / sum
		#var accuracy_none = float(matches_none) / sum
		#print(accuracy_red, " red")
		#print(accuracy_white, " white")
		#accuracy = accuracy_red + (accuracy_white / 2) - (accuracy_none / 2)
		#print(accuracy * 100, "Total accuracy")
	image.unlock()
	var accuracy_val = int(accuracy * 100)
	$CompleteMenu._set_accuracy(accuracy_val)
	
	var old_progress = $Save._get_level_progress(current_level)
	var highest_progress = old_progress
	if old_progress < accuracy_val:
		highest_progress = accuracy_val
		_update_level_progress(current_level, accuracy_val)
		if accuracy_val == 100:
			$CompleteMenu._set_praise(2)
		else:
			$CompleteMenu._set_praise(1)
	else:
		if accuracy_val == 100:
			$CompleteMenu._set_praise(2)
		else:
			$CompleteMenu._set_praise(0)
			
	if highest_progress < accuracy_c:
		$CompleteMenu._set_next_lock(true)
	else:
		$CompleteMenu._set_next_lock(false)
		
	if current_level + 1 > num_levels:
		$CompleteMenu._set_no_next()
	
	
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _update_level_progress(level, progress):
	$Save._update_progress(level, progress)
	level_progresses[int(level) - 1] = progress
	if int(level) == highest_level:
		print(highest_level)
		highest_level += 1
		$LevelSelect._update_locked(highest_level)
	$LevelSelect._update_progress(level, progress)
	pass

func _update_options(loaded):
	if !loaded:
		var val_array = $Options._get_vals() #Speed, base comp, pen comp, music, sound
		if val_array[0] != pend_speed:
			pend_speed = val_array[0]
			print("Pend_speed ", val_array[0])
			$Save._update_setting("speed", pend_speed)
			if val_array[0] == 3:
				$Pendulum._set_rotation_interval(fast_speed)
			elif val_array[0] == 2:
				$Pendulum._set_rotation_interval(norm_speed)
			else:
				$Pendulum._set_rotation_interval(slow_speed)
			
		if base_comp_on != val_array[1] or pen_comp_on != val_array[2]:
			base_comp_on = val_array[1]
			$Save._update_setting("basecompass", int(base_comp_on))
		
		if pen_comp_on != val_array[2]:
			pen_comp_on = val_array[2]
			$Save._update_setting("armcompass", int(pen_comp_on))
			
		$Pendulum._set_comp_vis(base_comp_on, pen_comp_on)
			
		if music_on != val_array[3]:
			music_on = val_array[3]
			$Save._update_setting("music", int(music_on))
			
		if sound_on != val_array[4]:
			sound_on = val_array[4]
			$Save._update_setting("sound", int(sound_on))
			
			
	else:
		if pend_speed == 3:
			$Pendulum._set_rotation_interval(fast_speed)
		elif pend_speed == 2:
			$Pendulum._set_rotation_interval(norm_speed)
		else:
			$Pendulum._set_rotation_interval(slow_speed)
			
		$Pendulum._set_comp_vis(base_comp_on, pen_comp_on)
	
func _open_save(initiate):
	if initiate:
		$Save._init_load()
		current_profile = $Save._get_profile()
	else:
		$Save._load(current_profile)
	level_progresses = $Save._get_progress(num_levels)
	var options_array = $Save._get_settings() #Pendulum speed, base comp, pen comp, music, sound
	
	pend_speed = options_array[0]
	base_comp_on = options_array[1]
	pen_comp_on = options_array[2]
	music_on = options_array[3]
	sound_on = options_array[4]
	for i in options_array:
		print("Options array", i)
	_update_options(true)
	$Options._set_vals(pend_speed, base_comp_on, pen_comp_on, music_on, sound_on, current_profile)
	$Options._update_buttons()
	highest_level = 1
	for i in range(0, num_levels):
		if level_progresses[i] >= accuracy_c:
			highest_level = i + 2
		level_select._update_progress(i + 1, level_progresses[i])
	print(highest_level)
	
	level_select._level_to_page(highest_level) #Go to highest unlocked page
	level_select._update_locked(highest_level) #Unlock levels to highest unlocked
	
func _update_save(level, score):
	pass
	



func _on_Pendulum_done():
	_check_drawing(pendulum._get_image())
	
	#print("Drawing Checked")


func _on_Control_select():
	_load_level($LevelSelect._get_level())
	$LevelSelect.hide()
	$LevelSelect/CanvasLayer.hide()
	pass # Replace with function body.


func _on_Pendulum_menu():
	_unload_level()
	$CanvasLayer/Accuracy/AccuracyLabel.text = ""
	$LevelSelect.show()
	$LevelSelect/CanvasLayer.show()
	pass # Replace with function body.


func _on_Pendulum_reset():
	$CanvasLayer/Accuracy/AccuracyLabel.text = ""


func _on_LevelSelect_initialize():
	print("Make buttons")
	for i in range(0, num_levels):
		$LevelSelect._add_button()
		
	$LevelSelect._level_to_page(2)
	pass # Replace with function body.


func _on_MainMenu_options_pressed():
	$MainMenu/CanvasLayer.hide()
	$Options.show()
	$Options/CanvasLayer.show()


func _on_MainMenu_play_pressed():
	$MainMenu/CanvasLayer.hide()
	$LevelSelect.show()
	$LevelSelect/CanvasLayer.show()


func _on_LevelSelect_menu():
	$LevelSelect.hide()
	$LevelSelect/CanvasLayer.hide()
	$MainMenu/CanvasLayer.show()


func _on_Options_back():
	$Options.hide()
	$Options/CanvasLayer.hide()
	$MainMenu/CanvasLayer.show()


func _on_Options_setting():
	_update_options(false)


func _on_Options_profile():
	current_profile = $Options._get_profile()
	
	_open_save(false)


func _on_Options_delete():
	current_profile = $Options._get_profile()
	$Save._reset_profile(current_profile)
	_open_save(false)
	pass # Replace with function body.


func _on_CompleteMenu_display():
	$CompleteMenu._set_displaying(true)
	pass # Replace with function body.


func _on_CompleteMenu_next():
	_unload_level()
	current_level += 1
	_load_level(current_level)
	$CompleteMenu/CanvasLayer.hide()
	


func _on_CompleteMenu_retry():
	$CompleteMenu/CanvasLayer.hide()
	$Pendulum._reset()


func _on_CompleteMenu_select():
	_unload_level()
	$CompleteMenu/CanvasLayer.hide()
	$LevelSelect.show()
	$LevelSelect/CanvasLayer.show()
	pass # Replace with function body.


func _on_CompleteMenu_stop_displaying():
	$CompleteMenu._set_displaying(false)
