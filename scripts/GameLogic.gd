extends Node2D

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

export var accuracy_f = 0.5
export var accuracy_d = 0.6
export var accuracy_c = 0.7
export var accuracy_b = 0.8
export var accuracy_a = 0.9
export var accuracy_s = 1

onready var pendulum = $Pendulum

# Called when the node enters the scene tree for the first time.
func _ready():
	#_load_level(1)
	pass
	#_check_drawing()

func _initiate(over, ref):
	overlay = over
	$LevelOverlay.texture = overlay
	
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
	print(active_scene)
	add_child(active_scene)
	#var level_info = active_scene.get_node("Level")
	#print(level_info)
	pendulum._initialize_pendulum(active_scene._get_arm_info(), active_scene._get_rotation_info(), active_scene._get_start_info())
	pendulum._reset()
	_initiate(active_scene._get_overlay(), active_scene._get_reference())
	
	
func _unload_level():
	active_scene.queue_free()
	$LevelOverlay.texture = Image.new()
	pendulum._reset_pendulum()

func _check_drawing(image):
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
	
	$AccuracyContainer/Accuracy/AccuracyLabel.text = "Accuracy Points: " + str(int(accuracy * 100))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Pendulum_done():
	_check_drawing(pendulum._get_image())
	
	#print("Drawing Checked")


func _on_Control_select():
	_load_level($LevelSelect._get_level())
	$LevelSelect.hide()
	pass # Replace with function body.


func _on_Pendulum_menu():
	_unload_level()
	$AccuracyContainer/Accuracy/AccuracyLabel.text = ""
	$LevelSelect.show()
	pass # Replace with function body.


func _on_Pendulum_reset():
	$AccuracyContainer/Accuracy/AccuracyLabel.text = ""
