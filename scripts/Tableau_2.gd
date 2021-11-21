extends Node2D

# ajuste la camera pour voir plus en avant du personnage
func config_camera():
	if $Joueur/Sprite_joueur.flip_h == true:
		$Joueur/Camera2D.offset_h = -0.5
	else:
		$Joueur/Camera2D.offset_h = 1

func _ready():
	Global.distance_obj_global -= 7300
	animation_entre()

func _process(delta):
	config_camera()

# Continuation de l'animation de l'intro
func animation_entre():
	$Au_dela/Ecran_blanc.visible = true
	$Au_dela/Ecran_blanc/AnimationPlayer.play_backwards("Fades")
	while $Au_dela/Ecran_blanc/AnimationPlayer.is_playing():
		yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
	$Au_dela/Interface/AnimationPlayer.play("Entree")
	$Musique.play()
	
func animation_sorti():
	$Musique.stop()
	$Au_dela/Interface/AnimationPlayer.play_backwards("Entree")
	$Au_dela/Ecran_blanc/AnimationPlayer.play("Fades")
	while $Au_dela/Ecran_blanc/AnimationPlayer.is_playing():
		yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
	get_tree().change_scene("res://scenes/Tableau_3.tscn")


func _on_Porte_body_entered(body):
	if body == Global.joueur and $Doduo.pv > 0 and $CameraBoss.current == false:
		$Objectif.visible = false
		$Au_dela/Ecran_blanc/AnimationPlayer.play("FadeIn")
		yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
		$CameraBoss.current = true
		$Au_dela/Ecran_blanc/AnimationPlayer.play_backwards("FadeIn")
		$Musique.stop()
		$SonBossApparait.play()
		yield($SonBossApparait, "finished")
		$MusCombatDoduo.play()
	elif body == Global.joueur and $Doduo.pv <= 0 and $Objectif.visible == false:
		if $Objectif/Porte/Arene:
			$Objectif/Porte/Arene.queue_free()
		$Objectif.visible = true
		$MusCombatDoduo.stop()
	elif body == Global.joueur and $Doduo.pv <= 0 and $Objectif.visible == true:
		animation_sorti()

