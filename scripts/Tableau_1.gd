extends Node2D

onready var joueur = get_node_or_null("Joueur")


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
	Global.auDela = $Au_dela
	init_tutos()
	set_process(false)
	animation_entre()

# Continuation de l'animation de l'intro
func animation_entre():
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

# Configuration des tutoriels
func init_tutos():
	for n in range(0, len(textesTutoriel)):
		$Panneaux_tuto.get_child(n).init(textesTutoriel[n], imagesTutoriel[n])

# ajuste la camera pour voir plus en avant du personnage
func config_camera():
	if $Joueur/Sprite_joueur.flip_h == true:
		$Joueur/Camera2D.offset_h = -0.5
	else:
		$Joueur/Camera2D.offset_h = 1

func _process(_delta):
	config_camera()

func _on_Porte_body_entered(body):
	if body == joueur:
		$Au_dela/Interface/AnimationPlayer.play_backwards("Entree")
		$Au_dela/Ecran_blanc/AnimationPlayer.play("FadeIn")
		while $Au_dela/Ecran_blanc/AnimationPlayer.is_playing():
			yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
		get_tree().change_scene("res://scenes/Tableau_2.tscn")
