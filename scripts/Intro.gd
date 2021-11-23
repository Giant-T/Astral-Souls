extends Control

var dialogues = [
	'Année [color=#FFD700]2048[/color] du calendrier grégorien, la planète Terre subit un [shake rate=10 level=10]déficit sévère[/shake] en [color=red]hydrocarbures[/color]...',
	'Les scientifiques américains ont soulevé la possibilité de voyager dans le temps à l\'aide de [color=#1CC4D4][tornado radius=3 freq=2]Astral Souls[/tornado][/color] afin d\'exploiter le pétrole qui n\'a pas été utiliser dans le passé.',
	'[color=#1CC4D4][tornado radius=3 freq=2]Astral Souls[/tornado][/color] est le premier prototype de machine à voyager dans le temps. Son nom référence les âmes et les étoiles, puisqu\'il permettra de faire voyager les âmes au-delà des étoiles.',
	'En théorie, ce voyage dans le temps fractionnerait le cours du temps en deux univers parallèles sans créer de paradoxes dans le présent.',
	'Les scientifiques ont toutefois souligné que les répercussions et les dangers des voyages dans le temps sont encore trop incertains pour recourir à cette méthode.',
	'Mais le temps presse et le président des États-Unis doit remédier à la situation, les forces spéciales se sont emparées de [color=#1CC4D4][tornado radius=3 freq=2]Astral Souls[/tornado][/color] durant la nuit, et vous...',
	'[shake rate=10 level=10]Vous serez le premier à voyager dans le temps.[/shake]',
	'Votre mission est simple : placer une porte [color=#1CC4D4][tornado radius=3 freq=2]Astral[/tornado][/color] directement à la source de pétrole pour permettre l\'importation des [color=red]hydrocarbures[/color] de [color=#FFD700]1405[/color].'
]
var images = [
	'res://ressources/Images_intro/Hydrocarbures_Deficit.png',
	'res://ressources/Images_intro/reunion_scientifique.png',
	'res://ressources/Images_intro/Astral_Souls.png',
	'res://ressources/Images_intro/TimeSplit.png',
	'res://ressources/Images_intro/Danger.png',
	'res://ressources/Images_intro/Infiltration.png',
	'res://ressources/Images_intro/MysteryMan.png',
	'res://ressources/Images_intro/noir.png'
]

var index_dialogue = 0
var terminee = false
export var secondes_par_lettres = 0.03

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$Musique.play()
	charger_dialogues()

func charger_dialogues():
	"""
	Gère l'enchaînement des dialogues et des images
	"""
	if index_dialogue < dialogues.size():
		terminee = false
		$Panneau.visible = false
		# Transition Fade out pour changer l'image
		$Image/AnimationPlayer.play("Fades")
		yield($Image/AnimationPlayer, "animation_finished")
		$Image.texture = load(images[index_dialogue])
		# Si c'est la dernière image, fait apparaître la sprite du joueur.
		if index_dialogue == dialogues.size()-1:
			$Texture_joueur.visible = true
		# Transition Fade in pour afficher la nouvelle image
		$Image/AnimationPlayer.play_backwards("Fades")
		yield($Image/AnimationPlayer, "animation_finished")
		$Panneau.visible = true
		$Panneau/Texte.bbcode_text = dialogues[index_dialogue]
		$Panneau/Texte.percent_visible = 0
		# Animation de défilement du dialogue
		$Panneau/Tween.interpolate_property(
			$Panneau/Texte, "percent_visible", 0, 1, dialogues[index_dialogue].length()*secondes_par_lettres,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Panneau/Tween.start()
	else:
		# Transition vers Tableau 1
		set_process(false)
		$Musique.stop()
		$Panneau.visible = false
		$Teleportail.visible = true
		$Ecran_blanc/AnimationPlayer.play("Fades")
		$Teleportail/AnimationPlayer.play("Grandir")
		$Teleportail2.play()
		yield($Teleportail2, "finished")
		$Teleportail1.play()
		yield($Teleportail1, "finished")
		yield($Teleportail/AnimationPlayer, "animation_finished")
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/Tableau_1.tscn")
		
	index_dialogue += 1

func _process(_delta):
	$Panneau/Indicateur.visible = terminee
	if Input.is_action_just_pressed("ui_accept") and terminee == true:
		charger_dialogues()
	elif Input.is_action_just_pressed("ui_accept") and $Panneau/Tween.is_active() :
		# Passe le défilement du dialogue
		$Panneau/Tween.seek((dialogues[index_dialogue-1].length()*secondes_par_lettres)-0.01)

func _on_Tween_tween_completed(_object, _key):
	terminee = true

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://scenes/Tableau_1.tscn")
