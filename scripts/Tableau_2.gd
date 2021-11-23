extends Node2D

func _ready():
	Global.auDela = $Au_dela
	Global.distance_obj_global = 4900
	animation_entre()

func _process(_delta):
	config_camera()

func config_camera():
	"""
	Ajuste la caméra pour voir plus en avant du personnage
	"""
	if $Joueur/Sprite_joueur.flip_h == true:
		$Joueur/Camera2D.offset_h = -0.5
	else:
		$Joueur/Camera2D.offset_h = 1

func animation_entre():
	"""
	Gère l'enchaînement des animations lors de l'entrée dans la scène
	"""
	$Au_dela/Ecran_blanc.visible = true
	$Au_dela/Ecran_blanc/AnimationPlayer.play_backwards("Fades")
	while $Au_dela/Ecran_blanc/AnimationPlayer.is_playing():
		yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
	$Au_dela/Interface/AnimationPlayer.play("Entree")
	$Musique.play()
	
func animation_sorti():
	"""
	Gère l'enchaînement des animations lors de la sorti de la scène
	"""
	$Musique.stop()
	$Au_dela/Interface/AnimationPlayer.play_backwards("Entree")
	$Au_dela/Ecran_blanc/AnimationPlayer.play("Fades")
	while $Au_dela/Ecran_blanc/AnimationPlayer.is_playing():
		yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/Tableau_3.tscn")

func boss_apparait():
	"""
	Gère l'enchaînement des animations lors de l'apparition du boss Doduo
	"""
	$Au_dela/Ecran_blanc/AnimationPlayer.play("FadeIn")
	yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
	$CameraBoss.current = true
	$Au_dela/Ecran_blanc/AnimationPlayer.play_backwards("FadeIn")
	$Musique.stop()
	$SonBossApparait.play()
	yield($SonBossApparait, "finished")
	$MusCombatDoduo.play()

func _on_Porte_body_entered(body):
	if body == Global.joueur and $Doduo.pv > 0 and $CameraBoss.current == false:
		$Objectif.visible = false
		boss_apparait()
		if $Objectif/Porte/Arene:
			$Objectif/Porte/Arene.queue_free()
	elif body == Global.joueur and $Doduo.pv <= 0 and $Objectif.visible == true:
		if $Objectif/Porte:
			$Objectif/Porte.queue_free()
		animation_sorti()

func _on_Doduo_doduomort():
		$Objectif.visible = true
		$MusCombatDoduo.stop()
