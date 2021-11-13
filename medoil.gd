extends KinematicBody2D
onready var joueur = get_node_or_null("../Joueur")
# Variables en rapport au mouvement #
var velocity = Vector2.ZERO
var temp_velo = velocity
var gravite = Vector2.ZERO
var temp_grav= gravite
export (int) var pv = 99
export (int) var pv_max = 99
export (int) var vitesse_saut = -900
export (int) var vitesse_max = 15
export (float) var deceleration = 0.88
export (int) var acceleration = 15
export (int) var damage = 13
export (bool) var changer_orientation_depart = false
export (bool) var immovible = false
var est_au_sol = false
var pieds_au_sol = true
var accroupi = false
var saute = false
var gauche = false
const UP_DIRECTION = Vector2(0, -1)
var joueur_range = false 
var is_attacking = false 

func _ready():
	$Sprite_medoil.animation = "idle"
	if(changer_orientation_depart):
		changer_zone()
		gauche = true
	pass

func _physics_process(delta):
	collision_pieds_tilemap()
	calc_gravite()
	if(joueur_range && pv > 0):
		attacking()
	if(pv>0 && !immovible && !is_attacking):
		
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
	
	
# Fonction qui calcul la gravité infliger au medoil #
func calc_gravite():
	if (pieds_au_sol || est_au_sol):
		gravite.y = 0
		if saute:
			accroupi = false
			gravite.y = vitesse_saut
	elif (is_on_ceiling()):
		gravite.y = acceleration
	else:
		gravite.y += acceleration
	if (gravite.y >= 0 && saute):
		saute = false

# Fonction qui gere les deplacements du medoil #
func se_deplacer():
	if (velocity != Vector2.ZERO || gravite != Vector2.ZERO):
		velocity.clamped(vitesse_max)
		gravite.clamped(vitesse_max)
		move_and_slide(velocity + gravite, UP_DIRECTION)
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			infliger_degat(collision)
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
		
func infliger_degat(collider):
	if collider.get_collider().name.match("**Joueur****"):
		collider.get_collider().recevoir_degat(damage)



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
