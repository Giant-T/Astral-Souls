extends Node2D

onready var joueur = get_node_or_null("Joueur")

# ajuste la camera pour voir plus en avant du personnage
func config_camera():
	if $Joueur/Sprite_joueur.flip_h == true:
		$Joueur/Camera2D.offset_h = -0.5
	else:
		$Joueur/Camera2D.offset_h = 1

func _ready():
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

func _on_Porte_body_entered(body):
	if body == joueur:
		get_tree().change_scene("res://scenes/Menu_Principal.tscn")
