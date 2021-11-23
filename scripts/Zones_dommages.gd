extends Area2D

# Script pour les zones piquantes

var ca_pique = false
export (int) var degat = 5

func _process(_delta):
	if Global.joueur and ca_pique:
		Global.joueur.recevoir_degat(degat)

func _on_Zones_dommages_body_entered(body):
	if body == Global.joueur:
		ca_pique = true

func _on_Zones_dommages_body_exited(body):
	if body == Global.joueur:
		ca_pique = false
