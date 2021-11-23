extends Control

var dialogues = [
	'Agent, ne complétez pas la mission.',
	'Nous avons grandement sous-estimé les impacts du voyage dans le temps.',
	'Si vous posez le relais Astral, nos deux univers parallèles vont entrer en conflit.',
	'Immédiatement après votre téléportation, plusieurs fractures ont été signalées dans la toile de l\'espace-temps.',
	'Chaque seconde que nous ouvrons un pont entre deux univers, les conséquences sont incommensurables.',
	'Cet appel est donc limité, je dois faire bref. Ne posez pas la porte Astral.',
	'Aussi, agent, vous êtes présentement une anomalie dans cet univers.',
	'Vous devez donc "effacer" votre existence...'
]

var index_dialogue = 0
var terminee = false
export var secondes_par_lettres = 0.03

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	animation_entre()

func _process(_delta):
	$PanelContainer/Panel/Indicateur.visible = terminee
	if Input.is_action_just_pressed("ui_accept") and terminee == true:
		charger_dialogues()
	elif Input.is_action_just_pressed("ui_accept") and $PanelContainer/Panel/Tween.is_active() :
		# Passe le défilement du dialogue
		$PanelContainer/Panel/Tween.seek((dialogues[index_dialogue-1].length()*secondes_par_lettres)-0.01)

func _physics_process(_delta):
	# Gère le défilement des parallaxes
	$ParallaxBackground/ParallaxLayer.motion_offset.x += 0.1
	$ParallaxBackground/ParallaxLayer2.motion_offset.x -= 0.3

func charger_dialogues():
	"""
	Gère l'enchaînement des dialogues
	"""
	if index_dialogue < dialogues.size():
		terminee = false
		$PanelContainer/Panel/RichTextLabel.bbcode_text = dialogues[index_dialogue]
		$PanelContainer/Panel/RichTextLabel.percent_visible = 0
		# Animation de défilement du dialogue
		$PanelContainer/Panel/Tween.interpolate_property(
			$PanelContainer/Panel/RichTextLabel, "percent_visible", 0, 1, dialogues[index_dialogue].length()*secondes_par_lettres,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$PanelContainer/Panel/Tween.start()
	else:
		set_process(false)
		$PanelContainer/AnimationPlayer.play("Sorti")
		yield($PanelContainer/AnimationPlayer, "animation_finished")
		$Rideau/AnimationPlayer.play_backwards("Fades")
		yield($Rideau/AnimationPlayer, "animation_finished")
		$VBoxContainer/Abandonner.disabled = false
		$VBoxContainer/Poser_la_porte.disabled = false
		$VBoxContainer.visible = true
		$VBoxContainer/Poser_la_porte.grab_focus()
		
	index_dialogue += 1

func animation_entre():
	"""
	Gère l'enchaînement des animations lors de l'entrée dans la scène
	"""
	$Au_dela/Ecran_blanc.visible = true
	$Au_dela/Ecran_blanc/AnimationPlayer.play_backwards("Fades")
	yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
	$PanelContainer/AnimationPlayer.play("Vibration")
	yield($PanelContainer/AnimationPlayer, "animation_finished")
	$PanelContainer/Appel.visible = false
	charger_dialogues()
	$MusFinale.play()

func finale_destruction():
	"""
	Gère l'enchaînement des animations lors du choix de fin "destruction"
	"""
	$MusFinale.stop()
	$Teleportail/AnimationPlayer.play("Grandir")
	yield($Teleportail/AnimationPlayer, "animation_finished")
	$Rideau/AnimationPlayer.play("Destruction")
	yield($Rideau/AnimationPlayer, "animation_finished")
	$Sprite_joueur.visible = false
	$Au_dela/AnimationTextes.play("Destruction")
	yield($Au_dela/AnimationTextes, "animation_finished")
	$Au_dela/Ecran_blanc/AnimationPlayer.play("Fades")
	yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/Credits.tscn")

func finale_abandon():
	"""
	Gère l'enchaînement des animations lors du choix de fin "abandon"
	"""
	$MusFinale.stop()
	$Au_dela/Ecran_blanc/AnimationPlayer.play("FadeIn")
	yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
	$SonTir.play()
	$Au_dela/Ecran_blanc/AnimationPlayer.play_backwards("FadeIn")
	yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
	$Sprite_joueur.play("die")
	yield($Sprite_joueur, "animation_finished")
	$Au_dela/Ecran_blanc/AnimationPlayer.play("Fades")
	yield($Au_dela/Ecran_blanc/AnimationPlayer, "animation_finished")
	$Au_dela/AnimationTextes.play("Abandon")
	yield($Au_dela/AnimationTextes, "animation_finished")
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/Credits.tscn")

func _on_Tween_tween_completed(_object, _key):
	terminee = true

func _on_Poser_la_porte_pressed():
	$VBoxContainer/Abandonner.disabled = true
	$VBoxContainer/Poser_la_porte.disabled = true
	$VBoxContainer.visible = false
	finale_destruction()

func _on_Abandonner_pressed():
	$VBoxContainer/Abandonner.disabled = true
	$VBoxContainer/Poser_la_porte.disabled = true
	$VBoxContainer.visible = false
	finale_abandon()
