extends KinematicBody2D
onready var joueur = get_node_or_null("../Joueur")
# Variables en rapport au mouvement #
var velocity = Vector2.ZERO
var pv
export (int) var pv_max = 99
export (int) var vitesse_max = 15
export (float) var deceleration = 0.88
export (int) var acceleration = 15
export (int) var damage = 13
export (bool) var changer_orientation_depart = false
export (bool) var immovible = false
export (bool) var attacking_behavior = false
var est_au_sol = false
var pieds_au_sol = true
var gauche = false
const UP_DIRECTION = Vector2(0, -1)
var joueur_range = false 
var is_attacking = false 
var bobo_joueur = false

func _ready():
	pv = pv_max
	$Sprite_medoil.animation = "idle"
	if(changer_orientation_depart):
		changer_zone()
		gauche = true
	pass

func _physics_process(delta):
	collision_pieds_tilemap()
	if(joueur_range && pv > 0 && attacking_behavior):
		attacking()
	if(pv>0 && !immovible && !is_attacking):
		infliger_degat()
		recevoir_input()
		se_deplacer()
		gauche_droite()

func gauche_droite():
	if(!pieds_au_sol):
		changer_zone()
		if(gauche):
			gauche =false
		else:
			gauche = true
	elif($Face.is_colliding()):
		if (!$Face.get_collider().name.match("**Joueur****")):
			changer_zone()
			if(gauche):
				gauche =false
			else:
				gauche = true
		


# Reçoit les inputs du medoil #
func recevoir_input():
	if (!gauche):
		velocity.x += acceleration
	elif (gauche):
		velocity.x -= acceleration
	


# Fonction qui gere les deplacements du medoil #
func se_deplacer():
	if (velocity != Vector2.ZERO ):
		velocity.clamped(vitesse_max)
		move_and_slide(velocity , UP_DIRECTION)
		for i in get_slide_count():
			var collision = get_slide_collision(i)
		est_au_sol = is_on_floor()
		velocity *= deceleration
		if (velocity.length() <= 15):
			velocity = Vector2.ZERO



func collision_pieds_tilemap():
	if $Pieds.is_colliding():
		var collider = $Pieds.get_collider()
		if collider is TileMap:
			pieds_au_sol = true
		else:
			pieds_au_sol = false
	else:
		pieds_au_sol = false
		
func infliger_degat():
	if bobo_joueur:
		joueur.recevoir_degat(damage)



func hit():
	pv -= 1
	if(pv< 1):
		$Sprite_medoil.animation = "mort"
		joueur_range = false
		
	
func mort():
	self.queue_free()
	
func changer_zone():
	self.scale.x *=-1
	
func attacking():
		$Sprite_medoil.animation = "attack"
		is_attacking=true
		infliger_degat()
		if(joueur_range && ($Sprite_medoil.frame == 9 || $Sprite_medoil.frame == 10)):
			joueur.recevoir_degat(damage)

func _on_Sprite_medoil_animation_finished():
	if $Sprite_medoil.animation == "mort":
		mort()
	elif $Sprite_medoil.animation == "attack":
		$Sprite_medoil.animation = "idle"
		is_attacking = false


func _on_Zone_attack_body_entered(body):
	if body == joueur:
		joueur_range = true
		


func _on_Zone_attack_body_exited(body):
	if body == joueur:
		joueur_range = false


func _on_Hit_box_body_entered(body):
	if body == joueur:
		bobo_joueur = true


func _on_Hit_box_body_exited(body):
	if body == joueur:
		bobo_joueur = false
