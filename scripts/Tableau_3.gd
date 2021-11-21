extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.distance_obj_global -= 4900
	animation_entre()

func _process(delta):
	config_camera()

func animation_entre():
	$Au_dela/Ecran_blanc.visible = true
	$Au_dela/Ecran_blanc/AnimationPlayer.play_backwards("Fades")
	yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
	$Au_dela/Interface/AnimationPlayer.play("Entree")
	$Musique.play()

func animation_sorti():
	$Au_dela/Interface/AnimationPlayer.play_backwards("Entree")
	$Au_dela/Ecran_blanc/AnimationPlayer.play("Fades")
	yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
	get_tree().change_scene("res://scenes/Scene_Finale.tscn")

# ajuste la camera pour voir plus en avant du personnage
func config_camera():
	if $Joueur/Sprite_joueur.flip_h == true:
		$Joueur/Camera2D.offset_h = -0.5
	else:
		$Joueur/Camera2D.offset_h = 1


func _on_Porte_body_entered(body):
	if body == Global.joueur and $Objectif.visible == false:
		$Au_dela/Ecran_blanc/AnimationPlayer.play("FadeIn")
		yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
		$CameraBoss.current = true
		$Au_dela/Ecran_blanc/AnimationPlayer.play_backwards("FadeIn")
		$Musique.stop()
		$MusBossFinal.play()
	elif body == Global.joueur and $Objectif.visible == true:
		animation_sorti()


func _on_Heart_tree_exited():
	$Au_dela/Ecran_blanc/AnimationPlayer.play("FadeIn")
	yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
	$Joueur/Camera2D.current = true
	$Objectif.visible = true
	$Au_dela/Ecran_blanc/AnimationPlayer.play_backwards("FadeIn")
	$MusBossFinal.stop()
