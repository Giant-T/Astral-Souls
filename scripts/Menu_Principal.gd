extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false
	$VBoxContainer/Commencer.grab_focus()

# Gère le défilement des parallaxes
func _process(_delta):
	$ParallaxBackground/ParallaxLayer.motion_offset.x += 0.2
	$ParallaxBackground/ParallaxLayer2.motion_offset.x -= 0.5

func _on_Commencer_pressed():
	get_tree().change_scene("res://scenes/Intro.tscn")

func _on_Quitter_pressed():
	get_tree().quit()
