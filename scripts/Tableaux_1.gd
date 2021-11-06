extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _ready():
	set_process(false)
	animation_entre()

# Continuation de l'animation de l'intro
func animation_entre():
	$Au_dela/Ecran_blanc.visible = true
	$Joueur.visible = false
	$Au_dela/Ecran_blanc/AnimationPlayer.play_backwards("Fades")
	while $Au_dela/Ecran_blanc/AnimationPlayer.is_playing():
		$Joueur.set_physics_process(false)
		yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
	$Au_dela/Texture_joueur.visible = false
	$Joueur.visible = true
	$Musique.play()
	$Au_dela/Interface/AnimationPlayer.play("Entree")
	set_process(true)
	$Joueur.set_physics_process(true)

func config_camera():
	if $Joueur/Sprite_joueur.flip_h == true:
		$Joueur/Camera2D.offset_h = -0.5
	else:
		$Joueur/Camera2D.offset_h = 1

func _process(delta):
	config_camera()
