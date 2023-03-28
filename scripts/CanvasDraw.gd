extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var ink_list: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _add_point(point):
	ink_list.append(point)
	update()
	
func _reset():
	for point in range(ink_list.size() - 1, 0, -1):
		ink_list.remove(point)

func _draw():
	for point in ink_list:
		draw_circle(point, 10, Color.gray)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
