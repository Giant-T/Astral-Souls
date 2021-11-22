extends Area2D


onready var joueur = get_node_or_null("../../Joueur")
var ca_pique = false
export (int) var degat = 5


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if joueur and ca_pique:
		joueur.recevoir_degat(degat)

func _on_Zones_dommages_body_entered(body):
	if body == joueur:
		ca_pique = true

func _on_Zones_dommages_body_exited(body):
	if body == joueur:
		ca_pique = false
