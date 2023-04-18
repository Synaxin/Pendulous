extends Control
signal play_pressed
signal options_pressed

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var play_button = $CanvasLayer/Control/PlayButton
onready var options_button = $CanvasLayer/Control/OptionsButton

# Called when the node enters the scene tree for the first time.
func _ready():
	play_button.connect("pressed", self, "_play_pressed")
	options_button.connect("pressed", self, "_options_pressed")
	pass # Replace with function body.


func _play_pressed():
	emit_signal("play_pressed")
	
func _options_pressed():
	emit_signal("options_pressed")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
