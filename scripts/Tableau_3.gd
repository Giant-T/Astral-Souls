extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.auDela = $Au_dela
	Global.distance_obj_global = 0
	animation_entre()

func _process(_delta):
	config_camera()

func animation_entre():
	"""
	Gère l'enchaînement des animations lors de l'entrée dans la scène
	"""
	$Au_dela/Ecran_blanc.visible = true
	$Au_dela/Ecran_blanc/AnimationPlayer.play_backwards("Fades")
	yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
	$Au_dela/Interface/AnimationPlayer.play("Entree")
	$Musique.play()

func animation_sorti():
	"""
	Gère l'enchaînement des animations lors de la sorti de la scène
	"""
	$Au_dela/Interface/AnimationPlayer.play_backwards("Entree")
	$Au_dela/Ecran_blanc/AnimationPlayer.play("Fades")
	yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/Scene_Finale.tscn")

func config_camera():
	"""
	Ajuste la caméra pour voir plus en avant du personnage
	"""
	if $Joueur/Sprite_joueur.flip_h == true:
		$Joueur/Camera2D.offset_h = -0.5
	else:
		$Joueur/Camera2D.offset_h = 1

func boss_apparait():
	"""
	Gère l'enchaînement des animations lors de l'apparition du boss Doduo
	"""
	$Au_dela/Ecran_blanc/AnimationPlayer.play("FadeIn")
	yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
	$CameraBoss.current = true
	$Au_dela/Ecran_blanc/AnimationPlayer.play_backwards("FadeIn")
	$Musique.stop()
	$MusBossFinal.play()


func _on_Porte_body_entered(body):
	if body == Global.joueur and $Objectif.visible == false:
		boss_apparait()
	elif body == Global.joueur and $Objectif.visible == true:
		if $Objectif/Porte:
			$Objectif/Porte.queue_free()
		animation_sorti()


func _on_Heart_tree_exited():
	"""
	Gère l'enchaînement des animations lors de la mort du boss
	"""
	$Au_dela/Ecran_blanc/AnimationPlayer.play("FadeIn")
	yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
	$Joueur/Camera2D.current = true
	$Objectif.visible = true
	$Au_dela/Ecran_blanc/AnimationPlayer.play_backwards("FadeIn")
	$MusBossFinal.stop()
