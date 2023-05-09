extends Node
signal reset
signal done
signal menu

export(PackedScene) var first_arm
export(PackedScene) var second_arm
export(PackedScene) var ink

onready var pendulum_base = $PendControl/ZNode/ViewportContainer/Viewport/PendulumBase
onready var pendulum_hinge = $PendControl/ZNode/ViewportContainer/Viewport/PendulumBase/PendulumHinge
onready var pendulum_pen = $PendControl/ZNode/ViewportContainer/Viewport/PendulumBase/PendulumHinge/PendulumPen
onready var pendulum_base_arm = $PendControl/ZNode/ViewportContainer/Viewport/PendulumBase/BaseArm
onready var pendulum_hinge_arm = $PendControl/ZNode/ViewportContainer/Viewport/PendulumBase/PendulumHinge/HingeArm
onready var ink_holder = $PendControl/ZNode/ViewportContainer/Viewport/InkHolder 
onready var button_left = $LeftButtonControl/LeftButton 
onready var button_right = $RightButtonControl/RightButton
onready var button_reset = $ResetButtonControl/ResetButton
onready var button_menu = $MenuButtonControl/MenuButton
onready var compass = $PendControl/ZNode/ViewportContainer/Viewport/Compass
onready var compass_base = $PendControl/ZNode/ViewportContainer/Viewport/BaseCompass
onready var compass_base_sprite = $PendControl/ZNode/ViewportContainer/Viewport/BaseCompass/CompassSprite
onready var compass_needle = $PendControl/ZNode/ViewportContainer/Viewport/Compass/CompassNeedle
onready var compass_needle_2 = $PendControl/ZNode/ViewportContainer/Viewport/BaseCompass/CompassNeedle2
onready var level_overlay = $PendControl/ZNode/ViewportContainer/Viewport/LevelOverlay
onready var info_control = $CanvasLayer/InfoControl
onready var rotation_text = $CanvasLayer/InfoControl/RotationsText
onready var direction_text = $CanvasLayer/InfoControl/DirectionText
onready var level_text = $CanvasLayer/InfoControl/LevelText
onready var left_panel = $CanvasLayer/SideControl/LeftPanel
onready var right_panel = $CanvasLayer/SideControl/RightPanel
onready var panel_control = $CanvasLayer/SideControl

var compass_normal_sprite = load("res:///art/Pendulum/Compass.png")
var compass_expand_sprites = []



#Input

var button_right_on = false
var button_left_on = false
var button_right_locked = true
var button_left_locked = true
var button_last_pressed = 0
var button_currently_active = 0
var inputs_active = false



export var write_mode = false
export var write_level = 1
export var write_base_arm = 5
export var write_hinge_arm = 7
export var ink_white_size = 0.0625
export var ink_red_size = 0.0125
export var ink_blue_size = 0.04
export var ink_norm_size = 0.018
var active = false
export var num_rotations = 1.0
var stop_rotation = 0
var stop_timer = 0

export var start_rotation_base = 180
export var start_rotation_hinge = 0
export var rotation_direction = 1
export var rotation_interval = 0.008
export var base_rotation_per_interval = 0.001
export var pen_rotation_per_interval = 0.003 
export var pen_interval_per_ink = 4 
export var interval_multiplier = 4 
var base_rotation_degrees_segment = 22.5
var base_rotation_goal = 0
var hinge_rotation_degrees_segment = 45
var hinge_rotation_last_direction = 0
var hinge_rotation_current_goal = 0
var hinge_rotation_completed = false
var hinge_rotation_active = false
var hinge_rotation_buffered = false
var hinge_rotation_record = 0

#export var rotation_interval = 0.005
#export var baseRotationRate = 0.005 #How much it rotates over the interval
#export var penRotationSpeed = 0.03
#export var penInkRate = 2
var pen_ink_timer = 0 
var rotation_interval_timer = 0

export var base_to_first_segment_dist = 114 
export var first_arm_segment_dist = 56
export var first_arm_to_hinge_dist = 82
export var hinge_to_second_segment_dist = 88
export var second_arm_segment_dist = 52
export var second_arm_to_pen_dist = 56

var base_comp_vis = true
var pen_comp_vis = true
var panel_vis = true
var panel_max_size = 16
var panel_min_size = 2
var panel_size = 2
var panel_size_mod = 8
var panel_size_increasing = true
var panel_style

var initialized = false
var before_start = true
var start_next = false
var start_next_recognized = false
var start_buffer_side = 0

onready var sub_viewport = $PendControl/DetectionContainer/SubViewport
onready var view_draw_subport = $PendControl/ViewDrawContainer/SubViewport
var ink_list: Array = []
var img_saved = false
var stopped = false
var menu_pressed = false

var final_img

export(NodePath) var viewport_path = null


onready var target_viewport = sub_viewport.get_viewport()

var array_ink_index = 0
var array_ink = []
var array_underlay = []
var array_eof = false

var shape = RectangleShape2D.new()
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(16):
		var spr = load("res:///art/Pendulum/PendulumExpand/CompassExpand" + str(i) + ".png")
		compass_expand_sprites.append(spr)
	button_left.connect("pressed", self, "_on_pendulum_button_left")
	button_left.connect("released", self, "_off_pendulum_button_left")
	button_right.connect("pressed", self, "_on_pendulum_button_right")
	button_right.connect("released", self, "_off_pendulum_button_right")
	button_reset.connect("released", self, "_reset")
	button_menu.connect("pressed", self, "_menu")
	screen_size = get_viewport().size
	print(screen_size, "Screen_size")
	shape.extents = Vector2(screen_size.x / 4, screen_size.y / 1.25)
	button_left.shape = shape
	button_right.shape = shape
	button_left.position = Vector2(0, screen_size.y - (screen_size.y / 1.25))
	button_right.position = Vector2(screen_size.x / 2 , screen_size.y - (screen_size.y / 1.25))
	left_panel.rect_position = Vector2(0, screen_size.y - (screen_size.y / 1.25))
	right_panel.rect_position = Vector2(screen_size.x / 2 , screen_size.y - (screen_size.y / 1.25))
	left_panel.rect_size = Vector2(screen_size.x / 2, screen_size.y / 1.25)
	right_panel.rect_size = Vector2(screen_size.x / 2, screen_size.y / 1.25)
	panel_style = StyleBoxFlat.new()
	panel_style.draw_center = false
	panel_style.bg_color = Color(0.76, 0.76, 0.76, 0.4)
	panel_style.border_color = Color(0.76, 0.76, 0.76, 0.4)
	print("Panel color ", panel_style.border_color)
	panel_style.border_width_bottom = panel_min_size
	panel_style.border_width_left = panel_min_size
	panel_style.border_width_right = panel_min_size
	panel_style.border_width_top = panel_min_size
	panel_size = panel_min_size
	right_panel.add_stylebox_override("Style", panel_style)
	left_panel.set("custom_styles/panel", panel_style)
	right_panel.set("custom_styles/panel", panel_style)
	#if write_mode:
		#_initialize_pendulum(Vector2(write_base_arm, write_hinge_arm))
	
	#pendulum_base.rotation = deg2rad(start_rotation_base)
	#pendulum_hinge.rotation = deg2rad(start_rotation_hinge) 
	#base_rotation_goal = pendulum_base.rotation + deg2rad(base_rotation_degrees_segment) * rotation_direction
	get_drawing()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if stop_rotation < 0 and stop_timer <= stop_rotation or stop_rotation > 0 and stop_timer >= stop_rotation and !stopped:
		active = false
		_toggle_visibility(false, true)
		
		stopped = true
		if !img_saved:
			img_saved = true
			if write_mode:
				save_to("Level" + str(write_level) + "Reference.png", sub_viewport)
				#Set transparency to 100/255 with aseprite
				save_to("Level" + str(write_level) + "Overlay.png", view_draw_subport)
				final_img = sub_viewport.get_texture().get_data()
			else:
				#save_to("ReferenceOverlay.png", sub_viewport)
				final_img = sub_viewport.get_texture().get_data()
				final_img.flip_y()
				
				#pass
			emit_signal("done")
			
	elif !active and !stopped:
		if panel_vis:
			if panel_size_increasing:
				panel_size += delta * panel_size_mod
				if panel_size >= panel_max_size:
					panel_size_increasing = false
					panel_size = panel_max_size
			else:
				panel_size -= delta * panel_size_mod
				if panel_size <= panel_min_size:
					panel_size_increasing = true
					panel_size = panel_min_size
			panel_style.border_width_bottom = panel_size
			panel_style.border_width_left = panel_size
			panel_style.border_width_right = panel_size
			panel_style.border_width_top = panel_size
		if start_next:
			if menu_pressed:
				start_next = false
				start_next_recognized = false
			elif start_next_recognized: #Start rotation at next tick on compass
				if hinge_rotation_buffered:
					hinge_rotation_buffered = false
					hinge_rotation_active = true
					active = true
					if panel_vis:
						panel_control.hide()
				else:
					start_next = false
					start_next_recognized = false
				
			else:
				start_next_recognized = true
				hinge_rotation_last_direction = start_buffer_side
		
	if !menu_pressed:
		_rotation_input()
		_pendulum_rotation(delta)
		_handle_pendulum_expand()
		if initialized:
			#print("Compass1")
			_handle_compass()
			#print("Compass2")

func save_to(path, viewport):
	#print("save")
	var img = viewport.get_texture().get_data()
	img.flip_y()
	img_saved = true
	return img.save_png(path)
	
func get_drawing():
	var img = view_draw_subport.get_texture().get_data()
	return img

func _initialize_pendulum(arm_segments, rotation, start, level, overlay):
	#print("Initialize1")
	menu_pressed = false
	
	var currSpace = base_to_first_segment_dist
	for i in range(0, int(arm_segments.x)):
		if i > 0:
			currSpace += first_arm_segment_dist
		var arm = first_arm.instance()
		pendulum_base_arm.add_child(arm)
		arm.position = Vector2(0, currSpace)
	
	currSpace += first_arm_to_hinge_dist
	pendulum_hinge.position = Vector2(0, currSpace)
	currSpace = hinge_to_second_segment_dist
	for i in range(0, int(arm_segments.y)):
		if i > 0:
			currSpace += second_arm_segment_dist
		var arm = second_arm.instance()
		pendulum_hinge_arm.add_child(arm)
		arm.position = Vector2(0, currSpace)
	
	currSpace += second_arm_to_pen_dist
	pendulum_pen.position = Vector2(0, currSpace)
	initialized = true
	num_rotations = rotation.x
	rotation_direction = rotation.y
	var rounded_rotation = int(num_rotations)
	if abs(num_rotations) > 0.9 and abs(num_rotations) < 1.1:
		rounded_rotation = 1 * sign(num_rotations)
	elif abs(num_rotations) > 1.4 and abs(num_rotations) < 1.6:
		rounded_rotation = 1.5 * sign(num_rotations)
	elif abs(num_rotations) > 1.9 and abs(num_rotations) < 2.1:
		rounded_rotation = 2 * sign(num_rotations)
	rotation_text.text = "Rotations: " + str(rounded_rotation)
	if rotation_direction > 0:
		direction_text.text = "Direction: Right"
	else:
		direction_text.text = "Direction: Left"
	level_text.text = "Level: " + str(level)
	
	start_rotation_base = start.x
	start_rotation_hinge = start.y
	stop_rotation = num_rotations * 360 * rotation_direction
	#print("Initialize2")
	level_overlay.texture = overlay
	level_overlay.show()
	_reset()
	
	#_toggle_visibility(true, true)
	
	
	pass
	
func _reset_pendulum():
	initialized = false
	for i in pendulum_base_arm.get_children():
		i.queue_free()
	for i in pendulum_hinge_arm.get_children():
		i.queue_free()
	pendulum_base.rotation = 0
	stop_timer = 0
	array_ink_index = 0
	array_eof = false
	active = false
	img_saved = false
	before_start = true
	start_next = false
	start_next_recognized = false
	hinge_rotation_active = false
	hinge_rotation_completed = false
	hinge_rotation_current_goal = 0
	pendulum_base.rotation = 0
	base_rotation_goal = 0
	pendulum_hinge.rotation = 0
	button_left_locked = true
	button_right_locked = true
	level_overlay.hide()
	_toggle_visibility(false, true)
	panel_control.hide()
	stopped = false
	"""
	for i in ink_holder.get_children():
		i.queue_free()
		
	for i in sub_viewport.get_children():
		i.queue_free()
		
	for i in view_draw_subport.get_children():
		i.queue_free()
	"""
	for i in array_ink:
		i.position = Vector2(-400, -400)
		
	for i in array_underlay:
		i.position = Vector2(-400, -400)
	
func _toggle_visibility(on, menu):
	if on:
		pendulum_base.show()
		pendulum_hinge.show()
		pendulum_pen.show()
		level_overlay.show()
		if pen_comp_vis:
			pass
			compass.show()
		if base_comp_vis:
			pass
			compass_base.show()
		if menu:
			$CanvasLayer.show()
			button_left.show()
			button_right.show()
			button_menu.show()
			button_reset.show()
	else:
		pendulum_base.hide()
		pendulum_hinge.hide()
		pendulum_pen.hide()
		level_overlay.hide()
		if pen_comp_vis:
			compass.hide()
		if base_comp_vis:
			compass_base.hide()
		if menu:
			$CanvasLayer.hide()
			button_left.hide()
			button_right.hide()
			button_menu.hide()
			button_reset.hide()
			

func _place_ink():
	var ink_pos = pendulum_pen.to_global(Vector2(0, 0))
	#inkPos = pendulum_base.to_local(inkPos)
	
	
	if array_ink_index < len(array_ink) and len(array_ink) != 0 and not array_eof:
		#print("Moved")
		array_ink[array_ink_index].position = ink_pos
		array_underlay[array_ink_index].position = ink_pos
		array_ink_index += 1
	else:
		#print("Created")
		array_eof = true
		var ink_blue = ink.instance()
		ink_blue._start("blue", Vector2(ink_blue_size, ink_blue_size))
		ink_blue.position = ink_pos #- Vector2(0, $PendControl/DetectionContainer.margin_top - 40)
		sub_viewport.add_child(ink_blue)
		ink_blue.z_index = -4
		var ink_instance = ink.instance()
		ink_instance._start("grey", Vector2(ink_norm_size, ink_norm_size))
		ink_instance.position = ink_pos #- Vector2(0, $PendControl/ViewDrawContainer.margin_top)
		ink_holder.add_child(ink_instance)
		array_ink.append(ink_instance)
		array_underlay.append(ink_blue)
	#ink_list.append(pendulum_pen.to_global(Vector2(0, 0)))
	
	
func _on_pendulum_button_left():
	#print("Left Pressed")
	if before_start and initialized and not button_left_locked:
		#print("OnLeft1")
		start_next = true
		start_buffer_side = -1
		button_left_on = true
		button_last_pressed = -1
		_handle_button_input()
		#print("OnLeft2")

func _off_pendulum_button_left():
	#print("Left Released")
	if initialized:
		#print("OffButtonLeft1")
		if not button_left_locked:
			button_left_on = false
			_handle_button_input()
		#print("OffButtonLeft2")
		#button_left_locked = false
		#button_right_locked = false
	
func _on_pendulum_button_right():
	#print("Right Pressed")
	if before_start and initialized and not button_right_locked:
		#print("OnRight1")
		start_next = true
		start_buffer_side = 1
		button_right_on = true
		button_last_pressed = 1
		_handle_button_input()
		#print("OnRight2")
	
func _off_pendulum_button_right():
	#print("Right Released")
	if initialized:
		#print("OffButtonRight1")
		if not button_right_locked:
			button_right_on = false
			_handle_button_input()
		#print("OffButtonRight2")
	#button_right_locked = false
	#button_left_locked = false
	
func _menu():
	print("menu")
	menu_pressed = true
	emit_signal("menu")
	_reset_pendulum()
	_toggle_visibility(false, true)
	
func _handle_button_input():
	if button_left_on and button_right_on:
		button_currently_active = button_last_pressed
		#print("Both pressed")
	elif button_left_on and !button_right_on:
		button_currently_active = -1
		#print("Left Held")
	elif !button_left_on and button_right_on:
		button_currently_active = 1
		#print("Right Held")
	else:
		button_currently_active = 0
		#print("None Held")
	
	
#Add functionality that makes pendulum resting point locked to 16 directions
func _pendulum_rotation(delta):
	if active:
		rotation_interval_timer += delta
		if rotation_interval_timer >= rotation_interval:
			var div = floor(rotation_interval_timer / rotation_interval)
			rotation_interval_timer = fmod(rotation_interval_timer, rotation_interval)
			
			for i in range(div * interval_multiplier):
				stop_timer += rad2deg(base_rotation_per_interval * rotation_direction)
				pendulum_base.rotation += base_rotation_per_interval * rotation_direction
				if pendulum_base.rotation >= base_rotation_goal && rotation_direction > 0 or pendulum_base.rotation <= base_rotation_goal and rotation_direction < 0:
					pendulum_base.rotation = base_rotation_goal
					base_rotation_goal += deg2rad(base_rotation_degrees_segment) * rotation_direction
					if hinge_rotation_buffered:
						hinge_rotation_buffered = false
						hinge_rotation_active = true
				if hinge_rotation_active:
					pendulum_hinge.rotation += pen_rotation_per_interval * hinge_rotation_last_direction
					hinge_rotation_record += pen_rotation_per_interval * hinge_rotation_last_direction
					if (hinge_rotation_record >= deg2rad(hinge_rotation_degrees_segment) and hinge_rotation_last_direction > 0 or hinge_rotation_record <= deg2rad(-hinge_rotation_degrees_segment) and hinge_rotation_last_direction < 0) and button_currently_active != hinge_rotation_last_direction:
						hinge_rotation_completed = true
						pendulum_hinge.rotation = hinge_rotation_current_goal
						_rotation_input()
					elif (hinge_rotation_record >= deg2rad(hinge_rotation_degrees_segment) and hinge_rotation_last_direction > 0 or hinge_rotation_record <= deg2rad(-hinge_rotation_degrees_segment) and hinge_rotation_last_direction < 0) and button_currently_active == hinge_rotation_last_direction:
						hinge_rotation_record = 0
						pendulum_hinge.rotation = hinge_rotation_current_goal
						hinge_rotation_current_goal = pendulum_hinge.rotation + deg2rad(hinge_rotation_degrees_segment * hinge_rotation_last_direction)
				if pen_ink_timer >= pen_interval_per_ink:
					#if button_currently_active != 0:
					_place_ink()
					pen_ink_timer = 0
				pen_ink_timer += 1

func _handle_pendulum_expand():
	var rotation_count = floor(pendulum_base.rotation_degrees / 360)
	if rotation_direction > 0:
		if pendulum_base.rotation_degrees > 157.5 + (rotation_count * 360) and pendulum_base.rotation_degrees <= 180 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[0]
		elif pendulum_base.rotation_degrees > 180 + (rotation_count * 360) and pendulum_base.rotation_degrees <= 202.5 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[1]
		elif pendulum_base.rotation_degrees > 202.5 + (rotation_count * 360) and pendulum_base.rotation_degrees <= 225 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[2]
		elif pendulum_base.rotation_degrees > 225 + (rotation_count * 360) and pendulum_base.rotation_degrees <= 247.5 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[3]
		elif pendulum_base.rotation_degrees > 247.5 + (rotation_count * 360) and pendulum_base.rotation_degrees <= 270 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[4]
		elif pendulum_base.rotation_degrees > 270 + (rotation_count * 360) and pendulum_base.rotation_degrees <= 292.5 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[5]
		elif pendulum_base.rotation_degrees > 292.5 + (rotation_count * 360) and pendulum_base.rotation_degrees <= 315 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[6]
		elif pendulum_base.rotation_degrees > 315 + (rotation_count * 360) and pendulum_base.rotation_degrees <= 337.5 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[7]
		elif pendulum_base.rotation_degrees > 337.5 + (rotation_count * 360) and pendulum_base.rotation_degrees <= 360 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[8]
		elif pendulum_base.rotation_degrees > 0 + (rotation_count * 360) and pendulum_base.rotation_degrees <= 22.5 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[9]
		elif pendulum_base.rotation_degrees > 22.5 + (rotation_count * 360) and pendulum_base.rotation_degrees <= 45 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[10]
		elif pendulum_base.rotation_degrees > 45 + (rotation_count * 360) and pendulum_base.rotation_degrees <= 67.5 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[11]
		elif pendulum_base.rotation_degrees > 67.5 + (rotation_count * 360) and pendulum_base.rotation_degrees <= 90 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[12]
		elif pendulum_base.rotation_degrees > 90 + (rotation_count * 360) and pendulum_base.rotation_degrees <= 112.5 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[13]
		elif pendulum_base.rotation_degrees > 112.5 + (rotation_count * 360) and pendulum_base.rotation_degrees <= 135 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[14]
		elif pendulum_base.rotation_degrees > 135 + (rotation_count * 360) and pendulum_base.rotation_degrees <= 157.5 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[15]
	elif rotation_direction < 0:
		if pendulum_base.rotation_degrees < 202.5 + (rotation_count * 360) and pendulum_base.rotation_degrees >= 180 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[0]
		elif pendulum_base.rotation_degrees < 180 + (rotation_count * 360) and pendulum_base.rotation_degrees >= 157.5 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[15]
		elif pendulum_base.rotation_degrees < 157.5 + (rotation_count * 360) and pendulum_base.rotation_degrees >= 135 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[14]
		elif pendulum_base.rotation_degrees < 135 + (rotation_count * 360) and pendulum_base.rotation_degrees >= 112.5 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[13]
		elif pendulum_base.rotation_degrees < 112.5 + (rotation_count * 360) and pendulum_base.rotation_degrees >= 90 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[12]
		elif pendulum_base.rotation_degrees < 90+ (rotation_count * 360) and pendulum_base.rotation_degrees >= 67.5 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[11]
		elif pendulum_base.rotation_degrees < 67.5 + (rotation_count * 360) and pendulum_base.rotation_degrees >= 45 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[10]
		elif pendulum_base.rotation_degrees < 45 + (rotation_count * 360) and pendulum_base.rotation_degrees >= 22.5 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[9]
		elif pendulum_base.rotation_degrees < 22.5 + (rotation_count * 360) and pendulum_base.rotation_degrees >= 0 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[8]
		elif pendulum_base.rotation_degrees < 360 + (rotation_count * 360) and pendulum_base.rotation_degrees >= 337.5 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[7]
		elif pendulum_base.rotation_degrees < 337.5 + (rotation_count * 360) and pendulum_base.rotation_degrees >= 315 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[6]
		elif pendulum_base.rotation_degrees < 315 + (rotation_count * 360) and pendulum_base.rotation_degrees >= 292.5 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[5]
		elif pendulum_base.rotation_degrees < 292.5 + (rotation_count * 360) and pendulum_base.rotation_degrees >= 270 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[4]
		elif pendulum_base.rotation_degrees < 270 + (rotation_count * 360) and pendulum_base.rotation_degrees >= 247.5 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[3]
		elif pendulum_base.rotation_degrees < 247.5 + (rotation_count * 360) and pendulum_base.rotation_degrees >= 225 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[2]
		elif pendulum_base.rotation_degrees < 225 + (rotation_count * 360) and pendulum_base.rotation_degrees >= 202.5 + (rotation_count * 360):
			compass_base_sprite.texture = compass_expand_sprites[1]
		
			

func _rotation_input():
	if !hinge_rotation_active and !hinge_rotation_completed and button_currently_active != 0:
		hinge_rotation_record = 0
		hinge_rotation_buffered = true
		hinge_rotation_last_direction = button_currently_active
		hinge_rotation_current_goal = pendulum_hinge.rotation + deg2rad(hinge_rotation_degrees_segment * hinge_rotation_last_direction)
		#print(hinge_rotation_current_goal)
	elif hinge_rotation_buffered and button_currently_active == 0:
		hinge_rotation_buffered = false
	elif hinge_rotation_completed:
		hinge_rotation_active = false
		hinge_rotation_completed = false

func _input(event):
	var side = 0
	if Input.is_action_pressed("rotate_left"):
		side -= 1
	elif Input.is_action_pressed("rotate_right"):
		side += 1
	if !button_left_on and !button_right_on:
		button_currently_active = side
		
	if side != 0 and before_start and initialized:
		#print("StartNext1")
		start_next = true
		#print("StartNext2")
	
	if Input.is_action_just_pressed("reset"):
		_reset()
		
	if event is InputEventScreenTouch and not event.is_pressed():
		#print("InputEventScreenTouch")
		if initialized:
			#print("ButtonUnlock1")
			button_left_locked = false
			button_right_locked = false
			#print("ButtonUnlock2")
	

func _reset():
	stop_timer = 0
	active = false
	img_saved = false
	before_start = true
	start_next = false
	button_left_on = false
	button_right_on = false
	start_next_recognized = false
	hinge_rotation_active = false
	hinge_rotation_completed = false
	hinge_rotation_current_goal = 0
	array_ink_index = 0
	array_eof = false
	pendulum_base.rotation = deg2rad(start_rotation_base)
	base_rotation_goal = pendulum_base.rotation + deg2rad(base_rotation_degrees_segment) * rotation_direction
	pendulum_hinge.rotation = deg2rad(start_rotation_hinge)
	_toggle_visibility(true, true)
	if panel_vis:
		panel_control.show()
	stopped = false
	"""
	for i in ink_holder.get_children():
		i.queue_free()
		
	for i in sub_viewport.get_children():
		i.queue_free()
		
	for i in view_draw_subport.get_children():
		i.queue_free()
	"""
	for i in array_ink:
		i.position = Vector2(-400, -400)
		
	for i in array_underlay:
		i.position = Vector2(-400, -400)
		
	emit_signal("reset")
		
func _handle_compass():
	#compass.position = pendulum_base.global_position
	compass.position = pendulum_pen.global_position
	compass_needle.rotation = pendulum_hinge.rotation
	compass_base.position = pendulum_base.global_position
	compass_needle_2.rotation = pendulum_base.rotation + deg2rad(180)
	
func _get_image():
	return final_img

func _set_rotation_interval(interval):
	rotation_interval = interval
	
func _set_comp_vis(base, pen):
	base_comp_vis = base
	pen_comp_vis = pen
	
	if initialized:
		#print("CompVis1")
		if base_comp_vis:
			compass_base.show()
		else:
			compass_base.hide()
			
		if pen_comp_vis:
			compass.show()
		else:
			compass.hide()
		#print("CompVis2")
func _set_panel_vis(val):
	panel_vis = val
