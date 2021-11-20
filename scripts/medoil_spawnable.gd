extends KinematicBody2D
onready var joueur = get_node_or_null("../Joueur")
# Variables en rapport au mouvement #
var velocity = Vector2.ZERO
var pv
var pv_max = 5
var vitesse_max = 15
var deceleration = 0.88
var acceleration = 15
var damage = 5
var attacking_behavior = true
var est_au_sol = false
var pieds_au_sol = true
var gauche = false
const UP_DIRECTION = Vector2(0, -1)
var joueur_range = false 
var is_attacking = false 
var bobo_joueur = false


func start(orientation_depart,spawn_pos):
	pv = pv_max
	self.position = spawn_pos
	$Sprite_medoil.animation = "idle"
	if(orientation_depart):
		changer_zone()
		gauche = true
	pass

func _physics_process(delta):
	collision_pieds_tilemap()
	infliger_degat()
	if(joueur_range && pv > 0 && attacking_behavior):
		attacking()
	if(pv>0 && !is_attacking):
		recevoir_input()
		se_deplacer()
		gauche_droite()

#tourne le le slime si il frappe un mur un troue ou le joueur
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


#regarde si il est au sol
func collision_pieds_tilemap():
	if $Pieds.is_colliding():
		var collider = $Pieds.get_collider()
		if collider is TileMap:
			pieds_au_sol = true
		else:
			pieds_au_sol = false
	else:
		pieds_au_sol = false
#inflige des degat au joueur si il rentre en contanct avec le slime
func infliger_degat():
	if bobo_joueur:
		joueur.recevoir_degat(damage)

#Fonction qui enleve de la vie si frapper par balle et le tu si 0 pv
func hit():
	pv -= 1
	if(pv< 1):
		set_physics_process(false)
		$Sprite_medoil.animation = "mort"
		joueur_range = false
		
#fait disparaitre le mob
func mort():
	self.queue_free()
#change les hitbox de coter
func changer_zone():
	self.scale.x *=-1
#si le joueur est en porter d'attack fait attacker le slime
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
	elif body.has_method("gone"):
		body.gone()
		self.hit()


func _on_Hit_box_body_exited(body):
	if body == joueur:
		bobo_joueur = false
