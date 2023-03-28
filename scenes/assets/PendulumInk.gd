extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(StreamTexture) var red_path
export(StreamTexture) var white_path
export(StreamTexture) var blue_path
export(StreamTexture) var grey_path
var sprite_path

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _start(color, size):
	if color == "red":
		sprite_path = red_path
	elif color == "white":
		sprite_path = white_path
	elif color == "blue":
		sprite_path = blue_path
	else:
		sprite_path = grey_path
		
	$PendulumInkSprite.texture = sprite_path
	$PendulumInkSprite.scale = size

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
