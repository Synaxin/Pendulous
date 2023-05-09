extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var button = $LevelButton
onready var overlay = $LevelButton/LevelOverlay
onready var text = $LevelButton/LevelText

var number = 0

func _ready():
	button.action = str(number)
	text.text = " " + str(number)
	var img = load("res:///art/Levels/Overlays/Level" + str(number) + "Overlay.png")
	overlay.texture = img
# Called when the node enters the scene tree for the first time.
func _button_init(num):
	number = num

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
