extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = false
	$VBoxContainer/Commencer.grab_focus()

# Gère le défilement des parallaxes
func _physics_process(_delta):
	$ParallaxBackground/ParallaxLayer.motion_offset.x += 0.1
	$ParallaxBackground/ParallaxLayer2.motion_offset.x -= 0.3

func _on_Commencer_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/Intro.tscn")

func _on_Quitter_pressed():
	get_tree().quit()

func _on_Credits_pressed():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/Credits.tscn")
