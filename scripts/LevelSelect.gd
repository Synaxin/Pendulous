extends Control
signal select
signal menu
#signal initialize

export(PackedScene) var level_button

var pages = 0
var levels = 0
var levels_this_page = 20
var levels_this_row = 0
var max_per_page = 20
var max_per_row = 4
var current_page_instance

var highest_available_level = 4

var start_pos_x = 26
var start_pos_y = 168
var pos_x = 26
var pos_y = 168

var increment_x = 180
var increment_y = 154

var button_array = []
var page_array = []

var current_page = 1

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var level = 0

onready var menu_button = $CanvasLayer/TopPanel/MenuButton
onready var back_button = $CanvasLayer/BottomPanel/Control/PageBack
onready var next_button = $CanvasLayer/BottomPanel/Control/PageNext


# Called when the node enters the scene tree for the first time.
func _ready():
	print("ready")
	menu_button.connect("pressed", self, "_back_to_menu")
	back_button.connect("pressed", self, "_page_back")
	next_button.connect("pressed", self, "_page_next")
	#print("ready")
	"""
	for i in range(0, 40):
		_add_button()
	_update_locked(4)
	_handle_page()
	"""
	#_add_button()
	#emit_signal("initialize")
	_update_pages()
	_handle_page()
	
func _init():
	print("init")
	#menu_button.connect("pressed", self, "_back_to_menu")
	#back_button.connect("pressed", self, "_page_back")
	#next_button.connect("pressed", self, "_page_next")
	#_add_button()
	#_update_locked(4)
	#_update_pages()
	#_handle_page()
	
func _add_button():
	if levels_this_page >= max_per_page:
		current_page_instance = Control.new()
		#current_page_instance.anchor_left = 0.5
		#current_page_instance.anchor_top = 0.5
		#current_page_instance.anchor_right = 0.5
		#current_page_instance.set_anchor(MARGIN_LEFT, 0.5, false, true)
		#current_page_instance.set_anchor(MARGIN_RIGHT, 0.5)
		#current_page_instance.set_anchor(MARGIN_TOP, 0.5)
		#current_page_instance.rect_position = Vector2(0, 0)
		#print(current_page_instance.margin_left, " Margin left")
		#print(current_page_instance.rect_position, " Rect position")
		current_page_instance.set_anchor_and_margin(MARGIN_LEFT, 0.5, -360, true)
		$CanvasLayer.add_child(current_page_instance)
		page_array.append(current_page_instance)
		current_page_instance.hide()
		levels_this_page = 0
		pages += 1
		levels_this_row = 0
		pos_x = start_pos_x
		pos_y = start_pos_y
		_update_pages()
		
	levels += 1
	levels_this_row += 1
	levels_this_page += 1
	var new_control = level_button.instance()
	#new_control.set_anchor(MARGIN_LEFT, 0.5, false, true)
	var new_button = new_control.get_node("LevelButton")
	var level_text = new_button.get_node("LevelText")
	new_button.position = Vector2(pos_x, pos_y)
	new_button.action = str(levels)
	level_text.text = str(levels)
	if levels_this_row < max_per_row:
		pos_x += increment_x
	else:
		levels_this_row = 0
		pos_x = start_pos_x
		pos_y += increment_y
	current_page_instance.add_child(new_control)
	button_array.append(new_control)
	return 0
	

	
func _update_progress(level, progress):
	if int(level) - 1 >= 0:
		var button = button_array[int(level) - 1].get_node("LevelButton")
		var text = button.get_node("ProgressText")
		text.text = str(progress)
	
func _update_locked(progress):
	highest_available_level = progress
	for i in range(0, button_array.size()):
		var button = button_array[i].get_node("LevelButton")
		var lock = button.get_node("LevelLocked")
		if i < highest_available_level:
			pass
			lock.hide()
		else:
			pass
			lock.show()
	pass
	

func _update_pages():
	print("Pageupdate")
	$CanvasLayer/BottomPanel/Control/PageText.text = "Page: " + str(current_page) + "/" + str(pages)

func _unhandled_input(event):
	if event is InputEventAction and event.is_pressed():
		level = event.get_action()
		if int(level) <= highest_available_level:
			emit_signal("select")
		
func _get_level():
	return level
	
func _page_back():
	if current_page > 1:
		current_page -= 1
	_handle_page()
	
func _page_next():
	print("next")
	if current_page < pages:
		current_page += 1
	_handle_page()
	
func _handle_page():
	print("Pages")
	for i in range(0, page_array.size()):
		print(i)
		if i == current_page - 1:
			page_array[i].show()
		else:
			page_array[i].hide()
	_update_pages()
	
func _level_to_page(level):
	var target_page = floor(level / max_per_page) + 1
	current_page = target_page
	_handle_page()
	print(target_page)
	
func _back_to_menu():
	emit_signal("menu")
	#Emit signal to hide level select and show menu
	#Signal needs responder
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_GameScreen_menu_button():
	_add_button()


func _on_GameScreen_level_to_page():
	pass # Replace with function body.
