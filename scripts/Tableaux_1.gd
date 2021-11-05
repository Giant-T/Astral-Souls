extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Joueur.visible = false
	$Au_dela/Ecran_blanc/AnimationPlayer.play_backwards("Fades")
	while $Au_dela/Ecran_blanc/AnimationPlayer.is_playing():
		$Joueur.set_physics_process(false)
		yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
	$Au_dela/Texture_joueur.visible = false
	$Joueur.visible = true
	$Musique.play()
	$Joueur.set_physics_process(true)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
