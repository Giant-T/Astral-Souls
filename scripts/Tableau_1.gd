extends Node2D

var textesTutoriel = [
	"Utilisez les flèches ou A et D pour vous déplacer.",
	"Sautez avec flèche vers le haut ou W.",
	"Attention aux piques, surveillez vos PV.",
	"Sautez plus haut en maintenant le bouton.",
	"Tirer avec J pour éliminer les ennemis.",
	"Accroupissez-vous avec S ou flèche vers le bas pour stabiliser vos tirs.",
	"Suivez les créatures de pétrole pour trouver la source."
]

var imagesTutoriel = [
	'res://ressources/UI/gauche_droite.png',
	'res://ressources/UI/saut.png',
	'res://ressources/UI/piques.png',
	'res://ressources/UI/saut.png',
	'res://ressources/UI/tirs.png',
	'res://ressources/UI/accroupi.png',
	'res://ressources/UI/tuto_objectif.png'
]

func _ready():
	Global.distance_obj_global = 12200
	Global.auDela = $Au_dela
	init_tutos()
	set_process(false)
	animation_entre()

func animation_entre():
	"""
	Gère l'enchaînement des animations lors de l'entrée dans la scène
	"""
	$Panneaux_tuto/Tutoriel_gauche_droite/Area2D/CollisionShape2D.disabled = true
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
	$Panneaux_tuto/Tutoriel_gauche_droite/Area2D/CollisionShape2D.disabled = false

func init_tutos():
	"""
	Configure les tutoriels en leur assignant leur texte et image correspondant.
	"""
	for n in range(0, len(textesTutoriel)):
		$Panneaux_tuto.get_child(n).init(textesTutoriel[n], imagesTutoriel[n])

func config_camera():
	"""
	Ajuste la caméra pour voir plus en avant du personnage
	"""
	if $Joueur/Sprite_joueur.flip_h == true:
		$Joueur/Camera2D.offset_h = -0.5
	else:
		$Joueur/Camera2D.offset_h = 1

func _process(_delta):
	config_camera()
	
func _on_Porte_body_entered(body):
	if body == Global.joueur:
		# Empèche le joueur d'entrer plusieurs fois
		if $Objectif/Porte:
			$Objectif/Porte.queue_free()
			# Animation de sorti
		$Au_dela/Interface/AnimationPlayer.play_backwards("Entree")
		$Au_dela/Ecran_blanc/AnimationPlayer.play("FadeIn")
		while $Au_dela/Ecran_blanc/AnimationPlayer.is_playing():
			yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/Tableau_2.tscn")
