extends Node2D

export var base_length = 5
export var hinge_length = 7
export var num_rotations = 1.002
export var rotation_direction = 1
export var base_rotation = 180
export var hinge_rotation = 0

export var overlay = "res:///art/Levels/Overlays/"
export var reference = "res:///art/Levels/References/"
export(StreamTexture) var overlay_img
export(StreamTexture) var ref_img
var over_test

var overlay_file = null
var ref_file = null

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.
	
	
func _get_arm_info():
	return Vector2(base_length, hinge_length)

func _get_rotation_info():
	return Vector2(num_rotations, rotation_direction)
	
func _get_start_info():
	return Vector2(base_rotation, hinge_rotation)
	
func _get_overlay():
	"""
	if overlay_file == null:
		var success = false
		while not success:
			overlay_file = load(overlay)
			if overlay_file != null:
				success = true
	"""
	return overlay_img
	
func _get_reference():
	"""
	if ref_file == null:
		var success = false
		while not success:
			print("Ref Heyo")
			ref_file = load(reference)
			if ref_file != null:
				success = true
	"""
	return ref_img.get_data()
	
func _set_scene(base_len, hinge_len, num_rot, rot_dir, base_rot, hinge_rot, over_path, ref_path):
	base_length = base_len
	hinge_length = hinge_len
	num_rotations = num_rot
	rotation_direction = rot_dir
	base_rotation = base_rot
	hinge_rotation = hinge_rot
	overlay = over_path
	reference = ref_path
	
func _set_images():
	overlay_img = null
	ref_img = null
	over_test = load(overlay)
	print("Over test", over_test.get_data())
	while overlay_img == null:
		overlay_img = load(overlay)
		
	while ref_img == null:
		ref_img = load(reference)
	print(ref_img)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
