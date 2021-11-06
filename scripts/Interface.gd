extends Control

onready var joueur = get_node_or_null("../../Joueur")
onready var objectif = get_node_or_null("../../Objectif")
var distance_objectif
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if joueur:
		$Interface_PV.visible = true
		$Interface_PV/Etiquette_PV.text = str(joueur.pv)
		$Interface_PV/Barre_PV.value = joueur.pv
		if objectif:
			$Interface_Objectif.visible = true
			distance_objectif = int(sqrt(pow((objectif.position.x - joueur.position.x), 2) + pow((objectif.position.y - joueur.position.y), 2)))
			$Interface_Objectif/VBoxContainer/HBoxContainer2/Distance_Objectif.text = " | "+str(distance_objectif/100)+" m"
		else:
			$Interface_Objectif.visible = false
	else:
		$Interface_PV.visible = false
		$Interface_Objectif.visible = false
