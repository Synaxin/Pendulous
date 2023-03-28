extends Control
signal select

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _unhandled_input(event):
	if event is InputEventAction and event.is_pressed():
		level = event.get_action()
		emit_signal("select")
		
func _get_level():
	return level

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
