extends Control
signal back
signal setting
signal profile
signal delete

export(StreamTexture) var not_pressed
export(StreamTexture) var is_pressed

var pend_speed_val = 2
var base_comp_val = true
var pen_comp_val = true
var profile_val = 1
var music_val = true
var sound_val = true
var in_confirm = false


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var pend_speed_slow = $CanvasLayer/OptionsPanel/SlowButton
onready var pend_speed_med = $CanvasLayer/OptionsPanel/MediumButton
onready var pend_speed_fast = $CanvasLayer/OptionsPanel/FastButton
onready var base_comp_on = $CanvasLayer/OptionsPanel/BaseCompOn
onready var base_comp_off = $CanvasLayer/OptionsPanel/BaseCompOff
onready var pen_comp_on = $CanvasLayer/OptionsPanel/PenCompOn
onready var pen_comp_off = $CanvasLayer/OptionsPanel/PenCompOff
onready var profile_1 = $CanvasLayer/OptionsPanel/Profile1
onready var profile_2 = $CanvasLayer/OptionsPanel/Profile2
onready var profile_3 = $CanvasLayer/OptionsPanel/Profile3
onready var music_on = $CanvasLayer/OptionsPanel/MusicOn
onready var music_off = $CanvasLayer/OptionsPanel/MusicOff
onready var sound_on = $CanvasLayer/OptionsPanel/SoundOn
onready var sound_off = $CanvasLayer/OptionsPanel/SoundOff
onready var menu_button = $CanvasLayer/OptionsPanel/MenuButton
onready var del_prof = $CanvasLayer/OptionsPanel/DeleteProf
onready var confirm_layer = $ConfirmationLayer
onready var del_prof_no = $ConfirmationLayer/OptionsPanel2/OptionsPanel/DelProfNo
onready var del_prof_yes = $ConfirmationLayer/OptionsPanel2/OptionsPanel/DelProfYes
onready var del_prof_label = $ConfirmationLayer/OptionsPanel2/OptionsPanel/DelProfText
onready var confirm_layer_2 = $ConfirmationLayer2
onready var del_prof_no_2 = $ConfirmationLayer2/OptionsPanel2/OptionsPanel/DelProfNo
onready var del_prof_yes_2 = $ConfirmationLayer2/OptionsPanel2/OptionsPanel/DelProfYes
onready var del_prof_shown = $CanvasLayer/OptionsPanel/DelProfShown

var del_prof_text = "Delete Profile "


# Called when the node enters the scene tree for the first time.
func _ready():
	pend_speed_slow.connect("pressed", self, "_slow_pressed")
	pend_speed_med.connect("pressed", self, "_med_pressed")
	pend_speed_fast.connect("pressed", self, "_fast_pressed")
	base_comp_on.connect("pressed", self, "_base_on_pressed")
	base_comp_off.connect("pressed", self, "_base_off_pressed")
	pen_comp_on.connect("pressed", self, "_pen_on_pressed")
	pen_comp_off.connect("pressed", self, "_pen_off_pressed")
	profile_1.connect("pressed", self, "_profile_1_selected")
	profile_2.connect("pressed", self, "_profile_2_selected")
	profile_3.connect("pressed", self, "_profile_3_selected")
	music_on.connect("pressed", self, "_music_on_selected")
	music_off.connect("pressed", self, "_music_off_selected")
	sound_on.connect("pressed", self, "_sound_on_selected")
	sound_off.connect("pressed", self, "_sound_off_selected")
	menu_button.connect("pressed", self, "_menu_pressed")
	del_prof.connect("pressed", self, "_del_prof_selected")
	del_prof_no.connect("pressed", self, "_del_prof_no_selected")
	del_prof_yes.connect("pressed", self, "_del_prof_yes_selected")
	del_prof_no_2.connect("pressed", self, "_del_prof_no_2_selected")
	del_prof_yes_2.connect("pressed", self, "_del_prof_yes_2_selected")
	_update_buttons()
	
func _update_buttons():
	if pend_speed_val == 1:
		pend_speed_slow.normal = is_pressed
		pend_speed_med.normal = not_pressed
		pend_speed_fast.normal = not_pressed
	elif pend_speed_val == 2:
		pend_speed_slow.normal = not_pressed
		pend_speed_med.normal = is_pressed
		pend_speed_fast.normal = not_pressed
	else:
		pend_speed_slow.normal = not_pressed
		pend_speed_med.normal = not_pressed
		pend_speed_fast.normal = is_pressed
		
	if base_comp_val:
		base_comp_on.normal = is_pressed
		base_comp_off.normal = not_pressed
	else:
		base_comp_on.normal = not_pressed
		base_comp_off.normal = is_pressed
		
	if pen_comp_val:
		pen_comp_on.normal = is_pressed
		pen_comp_off.normal = not_pressed
	else:
		pen_comp_on.normal = not_pressed
		pen_comp_off.normal = is_pressed
		
	if music_val:
		music_on.normal = is_pressed
		music_off.normal = not_pressed
	else:
		music_on.normal = not_pressed
		music_off.normal = is_pressed
		
	if sound_val:
		sound_on.normal = is_pressed
		sound_off.normal = not_pressed
	else:
		sound_on.normal = not_pressed
		sound_off.normal = is_pressed
		
	if profile_val == 1:
		profile_1.normal = is_pressed
		profile_2.normal = not_pressed
		profile_3.normal = not_pressed
	elif profile_val == 2:
		profile_1.normal = not_pressed
		profile_2.normal = is_pressed
		profile_3.normal = not_pressed
	else:
		profile_1.normal = not_pressed
		profile_2.normal = not_pressed
		profile_3.normal = is_pressed

func _slow_pressed():
	pend_speed_val = 1
	print("Pend speed val ", pend_speed_val)
	emit_signal("setting")
	_update_buttons()
	
func _med_pressed():
	pend_speed_val = 2
	print("Pend speed val ", pend_speed_val)
	emit_signal("setting")
	_update_buttons()
	
func _fast_pressed():
	pend_speed_val = 3
	print("Pend speed val ", pend_speed_val)
	emit_signal("setting")
	_update_buttons()

func _base_on_pressed():
	print("Base on")
	base_comp_val = true
	emit_signal("setting")
	_update_buttons()
	
func _base_off_pressed():
	print("Base off")
	base_comp_val = false
	emit_signal("setting")
	_update_buttons()
	
func _pen_on_pressed():
	print("Pen on")
	pen_comp_val = true
	emit_signal("setting")
	_update_buttons()

func _pen_off_pressed():
	print("Pen off")
	pen_comp_val = false
	emit_signal("setting")
	_update_buttons()
	
func _music_on_selected():
	music_val = true
	emit_signal("setting")
	_update_buttons()
	
func _music_off_selected():
	music_val = false
	emit_signal("setting")
	_update_buttons()
	
func _sound_on_selected():
	sound_val = true
	emit_signal("setting")
	_update_buttons()
	
func _sound_off_selected():
	sound_val = false
	emit_signal("setting")
	_update_buttons()
	
func _profile_1_selected():
	profile_val = 1
	emit_signal("profile")
	_update_buttons()
	
func _profile_2_selected():
	profile_val = 2
	emit_signal("profile")
	_update_buttons()
	
func _profile_3_selected():
	profile_val = 3
	emit_signal("profile")
	_update_buttons()

func _menu_pressed():
	del_prof_shown.text = ""
	emit_signal("back")
	


func _get_vals():
	print("Get ", pend_speed_val)
	return [pend_speed_val, base_comp_val, pen_comp_val, music_val, sound_val]
	
func _get_profile():
	return profile_val
	
func _set_vals(pend, base, pen, music, sound, profile):
	pend_speed_val = pend
	base_comp_val = base
	pen_comp_val = pen
	music_val = music
	sound_val = sound
	profile_val = profile
	
func _del_prof_selected():
	del_prof_label.text = del_prof_text + str(profile_val) + "?"
	confirm_layer.show()
	
func _del_prof_no_selected():
	confirm_layer.hide()
	
func _del_prof_yes_selected():
	confirm_layer_2.show()
	
func _del_prof_no_2_selected():
	confirm_layer.hide()
	confirm_layer_2.hide()
	
func _del_prof_yes_2_selected():
	confirm_layer.hide()
	confirm_layer_2.hide()
	del_prof_shown.text = "Profile " + str(profile_val) + " Deleted"
	emit_signal("delete")
