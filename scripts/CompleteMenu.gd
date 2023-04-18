extends Control

signal display
signal next
signal retry
signal select
signal stop_displaying


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var accuracy_text = "Accuracy: "
var praise_new_record = "New Best!"
var praise_perfect = "Perfect!"
var next_locked = false
var displaying = false

var display_delay = 0.1
var display_time = 0

onready var accuracy = $CanvasLayer/Panel/AccuracyText
onready var praise = $CanvasLayer/Panel/PraiseText
onready var display_button = $CanvasLayer/Panel/DisplayButton
onready var next_button = $CanvasLayer/Panel/NextLevelButton
onready var retry_button = $CanvasLayer/Panel/RetryButton
onready var select_button = $CanvasLayer/Panel/LevelSelectButton
onready var next_lock = $CanvasLayer/Panel/NextLevelButton/Lock
onready var next_text = $CanvasLayer/Panel/NextLevelText
onready var no_next_text = $CanvasLayer/Panel/NoNextLevelText

# Called when the node enters the scene tree for the first time.
func _ready():
	display_button.connect("pressed", self, "_display_pressed")
	next_button.connect("pressed", self, "_next_pressed")
	retry_button.connect("pressed", self, "_retry_pressed")
	select_button.connect("pressed", self, "_select_pressed")
	
func _display_pressed():
	if !displaying:
		emit_signal("display")
	
func _next_pressed():
	if !next_locked and !displaying:
		emit_signal("next")
	
func _retry_pressed():
	if !displaying:
		emit_signal("retry")
	
func _select_pressed():
	if !displaying:
		emit_signal("select")

func _set_next_lock(on):
	no_next_text.hide()
	if on:
		next_locked = true
		next_lock.show()
		next_text.show()
	else:
		next_locked = false
		next_lock.hide()
		next_text.hide()
		
func _set_no_next():
	next_locked = true
	next_lock.show()
	next_text.hide()
	no_next_text.show()
		
func _set_accuracy(val):
	accuracy.text = accuracy_text + str(val)
	

func _set_praise(val):
	if val == 0:
		praise.text = ""
	elif val == 1:
		praise.text = praise_new_record
	elif val == 2:
		praise.text = praise_perfect
		
func _set_displaying(val):
	if val:
		display_time = Time.get_unix_time_from_system()
		displaying = true
		$CanvasLayer.hide()
	else:
		displaying = false
		$CanvasLayer.show()
		
func _input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		if displaying and Time.get_unix_time_from_system() >= display_time + display_delay:
			emit_signal("stop_displaying")
