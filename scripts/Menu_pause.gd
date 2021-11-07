extends Control

var pause = false

func _process(_delta):
	if not pause:
		$VBoxContainer/Quitter.disabled = true
		$VBoxContainer/Reprendre.disabled = true
		visible = false
	else:
		$VBoxContainer/Quitter.disabled = false
		$VBoxContainer/Reprendre.disabled = false
		visible = true

func _on_Reprendre_pressed():
	var pause = false

func _on_Quitter_pressed():
	get_tree().change_scene("res://scenes/Menu_Principal.tscn")
