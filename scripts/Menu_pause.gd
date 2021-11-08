extends Control

var pause = false

func _process(_delta):
	touche_pause()
	if not pause:
		$VBoxContainer/Quitter.disabled = true
		$VBoxContainer/Reprendre.disabled = true
		visible = false
	else:
		$VBoxContainer/Quitter.disabled = false
		$VBoxContainer/Reprendre.disabled = false
		visible = true

func touche_pause():
	if Input.is_action_just_pressed("pause") and !pause:
		pause = true
		get_tree().paused = true
		$VBoxContainer/Reprendre.grab_focus()
	elif Input.is_action_just_pressed("pause") and pause:
		pause = false
		get_tree().paused = false
		

func _on_Quitter_pressed():
	get_tree().change_scene("res://scenes/Menu_Principal.tscn")

func _on_Reprendre_pressed():
	pause = false
	get_tree().paused = false
