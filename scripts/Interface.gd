extends Control

onready var objectif = get_node_or_null("../../Objectif")
var distance_objectif

func _process(_delta):
	if Global.joueur:
		$Interface_PV.visible = true
		$Interface_PV/Etiquette_PV.text = str(Global.joueur.pv)
		$Interface_PV/Barre_PV.value = Global.joueur.pv
		if objectif:
			$Interface_Objectif.visible = true
			distance_objectif = Global.distance_obj_global + int(sqrt(pow((objectif.position.x - Global.joueur.position.x), 2) + pow((objectif.position.y - Global.joueur.position.y), 2)))
			$Interface_Objectif/VBoxContainer/HBoxContainer2/Distance_Objectif.text = " | "+str(distance_objectif/100)+" m"
		else:
			$Interface_Objectif.visible = false
	else:
		$Interface_PV.visible = false
		$Interface_Objectif.visible = false
