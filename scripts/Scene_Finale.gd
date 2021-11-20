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

# Called when the node enters the scene tree for the first time.
func _ready():
	$PanelContainer/AnimationPlayer.play("Vibration")
	while $PanelContainer/AnimationPlayer.is_playing():
		yield($PanelContainer/AnimationPlayer, "animation_finished")
	$PanelContainer/Appel.visible = false
	charger_dialogues()

func _process(_delta):
	$PanelContainer/Panel/Indicateur.visible = terminee
	if Input.is_action_just_pressed("ui_accept") and terminee == true:
		charger_dialogues()
	elif Input.is_action_just_pressed("ui_accept") and $PanelContainer/Panel/Tween.is_active() :
		# Passe le défilement du dialogue
		$PanelContainer/Panel/Tween.seek((dialogues[index_dialogue-1].length()*secondes_par_lettres)-0.01)

func charger_dialogues():
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
		get_tree().change_scene("res://scenes/Menu_Principal.tscn")
		
	index_dialogue += 1

func _on_Tween_tween_completed(_object, _key):
	terminee = true

