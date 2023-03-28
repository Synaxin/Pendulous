extends Node
signal reset
signal done
signal menu

export(PackedScene) var firstArm
export(PackedScene) var secondArm
export(PackedScene) var ink
export(PackedScene) var write_scene

var overlay_path = "res:///art/Levels/Overlays/"
var reference_path = "res:///art/Levels/References/"

var pendulumBase
var pendulumHinge
var pendulumPen
var inkHolder
var buttonRight
var buttonLeft
var button_reset
var button_menu
var compass
var compass_needle
var compass_base
var text_box

#Input

var button_right_on = false
var button_left_on = false
var button_last_pressed = 0
var button_currently_active = 0

var write_mode = true
export var write_level = 1
export var write_base_arm = 5
export var write_hinge_arm = 7
var ink_white_size = 0.0625
var ink_red_size = 0.0125
var ink_blue_size = 0.04
var ink_norm_size = 0.0125
var activeTimer = 0
var active = false
var complete = false
export var num_rotations = 1.0
var stop_rotation = 0
var stop_timer = 0
var changeInterval = 100
var changeIntervalTimer = 0

export var start_rotation_base = 180
export var start_rotation_hinge = 0
export var rotationDirection = 1
export var rotationInterval = 0.008
export var baseRotationPerInterval = 0.001
export var penRotationPerInterval = 0.003
export var penIntervalPerInk = 4
export var intervalMultiplier = 4
var base_rotation_degrees_segment = 22.5
var base_rotation_goal = 0
var hinge_rotation_degrees_segment = 45
var hinge_rotation_last_direction = 0
var hinge_rotation_current_goal = 0
var hinge_rotation_completed = false
var hinge_rotation_active = false
var hinge_rotation_buffered = false
var hinge_rotation_record = 0

#export var rotationInterval = 0.005
#export var baseRotationRate = 0.005 #How much it rotates over the interval
#export var penRotationSpeed = 0.03
#export var penInkRate = 2
var penInkTimer = 0
var rotationIntervalTimer = 0

export var baseToFirstSegmentDist = 114
export var firstArmSegmentDist = 56
export var firstArmToHingeDist = 82
export var hingeToSecondSegmentDist = 88
export var secondArmSegmentDist = 52
export var secondArmToPenDist = 56


var screenSize
var inputStack = []

var initialized = false
var before_start = true
var start_next = false
var start_next_recognized = false

onready var sub_viewport = $DetectionContainer/SubViewport
onready var view_draw_subport = $ViewDrawContainer/SubViewport
var ink_list: Array = []
var img_saved = false
var stopped = false
var menu_pressed = false

var final_img

export(NodePath) var viewport_path = null


onready var target_viewport = sub_viewport.get_viewport()

# Called when the node enters the scene tree for the first time.
func _ready():
	pendulumBase = $PendulumBase
	pendulumHinge = $PendulumBase/PendulumHinge
	pendulumPen = $PendulumBase/PendulumHinge/PendulumPen
	inkHolder = $InkHolder
	buttonLeft = $LeftButton
	buttonRight = $RightButton
	button_reset = $ResetButton
	button_menu = $MenuButton
	compass = $Compass
	compass_base = $BaseCompass
	compass_needle = $Compass/CompassNeedle
	text_box = $TextEdit
	buttonLeft.connect("pressed", self, "_on_pendulum_button_left")
	buttonLeft.connect("released", self, "_off_pendulum_button_left")
	buttonRight.connect("pressed", self, "_on_pendulum_button_right")
	buttonRight.connect("released", self, "_off_pendulum_button_right")
	button_reset.connect("released", self, "_reset")
	button_menu.connect("pressed", self, "_menu")
	if write_mode:
		_initialize_pendulum(Vector2(write_base_arm, write_hinge_arm))
	screenSize = get_viewport().size
	
	#pendulumBase.rotation = deg2rad(start_rotation_base)
	#pendulumHinge.rotation = deg2rad(start_rotation_hinge)
	#base_rotation_goal = pendulumBase.rotation + deg2rad(base_rotation_degrees_segment) * rotationDirection
	get_drawing()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#activeTimer += delta
	if stop_rotation <= 0 and stop_timer <= stop_rotation or stop_rotation >= 0 and stop_timer >= stop_rotation and !stopped:
		active = false
		complete = true
		_toggle_visibility(false, false)
		
		stopped = true
		#if !img_saved:
			#save_to("ReferenceOverlay.png", sub_viewport)
			#final_img = sub_viewport.get_texture().get_data()
			#final_img.flip_y()
			#emit_signal("done")
	elif !active and !stopped:
		if start_next:
			if menu_pressed:
				start_next = false
				start_next_recognized = false
			elif start_next_recognized:
				if hinge_rotation_buffered:
					hinge_rotation_buffered = false
					hinge_rotation_active = true
				active = true
			else:
				start_next_recognized = true
		
	if !menu_pressed:
		_rotation_input()
		_pendulum_rotation(delta)
		if initialized:
			_handle_compass()
	
func get_drawing():
	var img = view_draw_subport.get_texture().get_data()
	return img

func _initialize_pendulum(arm_segments):
	menu_pressed = false
	stop_rotation = num_rotations * 360 * rotationDirection
	var currSpace = baseToFirstSegmentDist
	for i in range(0, int(arm_segments.x)):
		if i > 0:
			currSpace += firstArmSegmentDist
		var arm = firstArm.instance()
		$PendulumBase/BaseArm.add_child(arm)
		arm.position = Vector2(0, currSpace)
		
	currSpace += firstArmToHingeDist
	pendulumHinge.position = Vector2(0, currSpace)
	currSpace = hingeToSecondSegmentDist
	for i in range(0, int(arm_segments.y)):
		if i > 0:
			currSpace += secondArmSegmentDist
		var arm = secondArm.instance()
		$PendulumBase/PendulumHinge/HingeArm.add_child(arm)
		arm.position = Vector2(0, currSpace)
		
	currSpace += secondArmToPenDist
	pendulumPen.position = Vector2(0, currSpace)
	initialized = true
	_reset()
	_toggle_visibility(true, true)
	
func _reset_pendulum():
	initialized = false
	for i in $PendulumBase/BaseArm.get_children():
		i.queue_free()
	for i in $PendulumBase/PendulumHinge/HingeArm.get_children():
		i.queue_free()
	pendulumBase.rotation = 0
	stop_timer = 0
	activeTimer = 0
	active = false
	complete = false
	img_saved = false
	before_start = true
	start_next = false
	start_next_recognized = false
	hinge_rotation_active = false
	hinge_rotation_completed = false
	hinge_rotation_current_goal = 0
	pendulumBase.rotation = 0
	base_rotation_goal = 0
	pendulumHinge.rotation = 0
	_toggle_visibility(true, false)
	stopped = false
	for i in inkHolder.get_children():
		i.queue_free()
		
	for i in sub_viewport.get_children():
		i.queue_free()
		
	for i in view_draw_subport.get_children():
		i.queue_free()
	
func _toggle_visibility(on, menu):
	if on:
		pendulumBase.show()
		pendulumHinge.show()
		pendulumPen.show()
		compass.show()
		compass_base.show()
		if menu:
			buttonLeft.show()
			buttonRight.show()
			button_menu.show()
			button_reset.show()
	else:
		pendulumBase.hide()
		pendulumHinge.hide()
		pendulumPen.hide()
		compass.hide()
		compass_base.hide()
		if menu:
			buttonLeft.hide()
			buttonRight.hide()
			button_menu.hide()
			button_reset.hide()

func _place_ink():
	var inkPos = pendulumPen.to_global(Vector2(0, 0))
	if write_mode:
		var ink_red = ink.instance()
		ink_red._start("red", Vector2(ink_red_size, ink_red_size))
		ink_red.position = inkPos - Vector2(0, $DetectionContainer.margin_top)
		
		sub_viewport.add_child(ink_red)
		ink_red.z_index = -4
		var ink_white = ink.instance()
		ink_white._start("white", Vector2(ink_white_size, ink_white_size))
		ink_white.position = inkPos - Vector2(0, $DetectionContainer.margin_top)
		
		sub_viewport.add_child(ink_white)
		ink_white.z_index = -5
		
		var ink_view = ink.instance()
		ink_view._start("white", Vector2(ink_white_size, ink_white_size))
		ink_view.position = inkPos - Vector2(0, $ViewDrawContainer.margin_top)
		
		view_draw_subport.add_child(ink_view)
		ink_view.z_index = -3
	else:
		var ink_blue = ink.instance()
		ink_blue._start("blue", Vector2(ink_blue_size, ink_blue_size))
		ink_blue.position = inkPos - Vector2(0, $DetectionContainer.margin_top)
		sub_viewport.add_child(ink_blue)
		ink_blue.z_index = -4
	var inkInstance = ink.instance() 
	inkInstance.position = pendulumPen.to_global(Vector2(0, 0))
	$InkHolder.add_child(inkInstance)
	
	#ink_list.append(pendulumPen.to_global(Vector2(0, 0)))
	
	
func _on_pendulum_button_left():
	#print("Left Pressed")
	if before_start and initialized:
			start_next = true
	button_left_on = true
	button_last_pressed = -1
	_handle_button_input()

func _off_pendulum_button_left():
	#print("Left Released")
	button_left_on = false
	_handle_button_input()
	
func _on_pendulum_button_right():
	#print("Right Pressed")
	if before_start and initialized:
			start_next = true
	button_right_on = true
	button_last_pressed = 1
	_handle_button_input()
	
func _off_pendulum_button_right():
	#print("Right Released")
	button_right_on = false
	_handle_button_input()
	
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
		rotationIntervalTimer += delta
		if rotationIntervalTimer >= rotationInterval:
			var div = floor(rotationIntervalTimer / rotationInterval)
			rotationIntervalTimer = fmod(rotationIntervalTimer, rotationInterval)
			
			for i in range(div * intervalMultiplier):
				stop_timer += rad2deg(baseRotationPerInterval * rotationDirection)
				pendulumBase.rotation += baseRotationPerInterval * rotationDirection
				if pendulumBase.rotation >= base_rotation_goal && rotationDirection > 0 or pendulumBase.rotation <= base_rotation_goal and rotationDirection < 0:
					pendulumBase.rotation = base_rotation_goal
					base_rotation_goal += deg2rad(base_rotation_degrees_segment) * rotationDirection
					if hinge_rotation_buffered:
						hinge_rotation_buffered = false
						hinge_rotation_active = true
				if hinge_rotation_active:
					pendulumHinge.rotation += penRotationPerInterval * hinge_rotation_last_direction
					hinge_rotation_record += penRotationPerInterval * hinge_rotation_last_direction
					if (hinge_rotation_record >= deg2rad(hinge_rotation_degrees_segment) and hinge_rotation_last_direction > 0 or hinge_rotation_record <= deg2rad(-hinge_rotation_degrees_segment) and hinge_rotation_last_direction < 0) and button_currently_active != hinge_rotation_last_direction:
						hinge_rotation_completed = true
						pendulumHinge.rotation = hinge_rotation_current_goal
						_rotation_input()
					elif (hinge_rotation_record >= deg2rad(hinge_rotation_degrees_segment) and hinge_rotation_last_direction > 0 or hinge_rotation_record <= deg2rad(-hinge_rotation_degrees_segment) and hinge_rotation_last_direction < 0) and button_currently_active == hinge_rotation_last_direction:
						hinge_rotation_record = 0
						pendulumHinge.rotation = hinge_rotation_current_goal
						hinge_rotation_current_goal = pendulumHinge.rotation + deg2rad(hinge_rotation_degrees_segment * hinge_rotation_last_direction)
				if penInkTimer >= penIntervalPerInk:
					#if button_currently_active != 0:
					_place_ink()
					penInkTimer = 0
				penInkTimer += 1
				
func _rotation_input():
	if !hinge_rotation_active and !hinge_rotation_completed and button_currently_active != 0:
		hinge_rotation_record = 0
		hinge_rotation_buffered = true
		hinge_rotation_last_direction = button_currently_active
		hinge_rotation_current_goal = pendulumHinge.rotation + deg2rad(hinge_rotation_degrees_segment * hinge_rotation_last_direction)
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
			start_next = true
	
	if Input.is_action_just_pressed("reset"):
		_reset()
	if Input.is_action_just_pressed("Write") and not active:
		_write()

func _write():
	var ref_path = save_to("Level" + str(text_box.text) + "Reference.png", sub_viewport, false, 0)
	print(ref_path)
	#Set transparency to 100/255 with aseprite
	var over_path = save_to("Level" + str(text_box.text) + "Overlay.png", view_draw_subport, true, 1)
	#final_img = sub_viewport.get_texture().get_data()
	var level_scene = write_scene.instance()
	level_scene._set_scene(write_base_arm, write_hinge_arm, num_rotations, rotationDirection, start_rotation_base, start_rotation_hinge, over_path, ref_path)
	add_child(level_scene)
	var packed_scene = PackedScene.new()
	packed_scene.pack(level_scene)
	ResourceSaver.save("res:///scenes/assets/Levels/Level" + str(text_box.text) + ".tscn", packed_scene)
	print("Write Finished!")
	
func save_to(path, viewport, transparent, type):
	#print("save")
	var img = viewport.get_texture().get_data()
	img.flip_y()
	#img_saved = true
	if transparent:
		img.lock()
		for i in img.get_size().y:
			for j in img.get_size().x:
				var pixel = img.get_pixel(j, i)
				if pixel.a > 0.5:
					var new_pixel = Color(pixel.r, pixel.g, pixel.b, 0.45)
					img.set_pixel(j, i, new_pixel)
		img.unlock()
	if type == 0:
		img.save_png(reference_path + path)
		return reference_path + path
	else:
		img.save_png(overlay_path + path)
		return overlay_path + path
	#return img.save_png(path)

func _reset():
	stop_timer = 0
	activeTimer = 0
	active = false
	complete = false
	img_saved = false
	before_start = true
	start_next = false
	start_next_recognized = false
	hinge_rotation_active = false
	hinge_rotation_completed = false
	hinge_rotation_current_goal = 0
	pendulumBase.rotation = deg2rad(start_rotation_base)
	base_rotation_goal = pendulumBase.rotation + deg2rad(base_rotation_degrees_segment) * rotationDirection
	pendulumHinge.rotation = deg2rad(start_rotation_hinge)
	_toggle_visibility(true, false)
	stopped = false
	for i in inkHolder.get_children():
		i.queue_free()
		
	for i in sub_viewport.get_children():
		i.queue_free()
		
	for i in view_draw_subport.get_children():
		i.queue_free()
		
	emit_signal("reset")
		
func _handle_compass():
	#compass.position = pendulumBase.global_position
	compass.position = pendulumPen.global_position
	compass_needle.rotation = pendulumHinge.rotation
	compass_base.position = pendulumBase.global_position
	$BaseCompass/CompassNeedle2.rotation = pendulumBase.rotation + deg2rad(180)
	
func _get_image():
	return final_img


func _unhandled_input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		print("FromPendulum")
		
