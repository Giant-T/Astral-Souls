extends Control

var section = 0

var credits = [
	'[center][color=#1CC4D4][tornado radius=3 freq=2]Astral Souls[/tornado][/color][/center]\nProjet étudiant - Cégep de Victoriaville',
	'[color=red]Programmeurs[/color]\nRaphaël Boisvert\nWilliam Boudreault\nWilliam Daigle-Beaudoin',
	'[color=red]Ressources artistiques[/color]\nCoordinateur : Raphaël Boisvert\nDécor&Tileset : TAIGA ASSETS PACK v2 par @vnitti\nInspiration ennemis : Slime Animations crée par @Reff_SQ\nSprite joueur : TeamGunner_by_SecretHideous_060519',
	'[color=red]Musiques[/color]\nAM2R - Milton Guasti',
	'[color=red]Outils[/color]\nDeveloppé avec Godot Engine [color=#1CC4D4]https://godotengine.org/license[/color]\nArt crée ou modifié avec GraphicsGale [color=#1CC4D4]https://graphicsgale.com[/color]',
	'Un gros merci à toi, pour avoir joué !'
]

func _ready():
	$RichTextLabel.bbcode_text = credits[section]
	$RichTextLabel/AnimationPlayer.play("haut-milieu")
	yield($RichTextLabel/AnimationPlayer, "animation_finished")

func terminer():
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://scenes/Menu_Principal.tscn")

func montrer_section():
	$RichTextLabel/AnimationPlayer.play("milieu-bas")
	yield($RichTextLabel/AnimationPlayer, "animation_finished")
	$RichTextLabel.bbcode_text = credits[section]
	$RichTextLabel/AnimationPlayer.play("haut-milieu")
	yield($RichTextLabel/AnimationPlayer, "animation_finished")

func _on_Minuteur_timeout():
	section += 1
	if section < len(credits):
		montrer_section()
	else:
		terminer()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		terminer()
