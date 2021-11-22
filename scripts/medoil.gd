extends KinematicBody2D
var particules = load("res://scenes/Particule_Ennemi.tscn")
# Variables en rapport au mouvement #
var velocity = Vector2.ZERO
var pv
export (int) var pv_max = 5
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

func _physics_process(_delta):
	collision_pieds_tilemap()
	infliger_degat()
	if(joueur_range && pv > 0 && attacking_behavior):
		attacking()
	if(pv>0 && !immovible && !is_attacking):
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
		
func infliger_degat():
	if bobo_joueur:
		Global.joueur.recevoir_degat(damage)

func emit_particule():
	var instance_particule = particules.instance()
	get_tree().current_scene.add_child(instance_particule)
	instance_particule.scale_to(self.scale.x)
	instance_particule.modulate = self.modulate
	instance_particule.global_position = $Centre.global_position
	instance_particule.rotation = global_position.angle_to_point(Global.joueur.global_position)

#Fonction qui enleve de la vie si frapper par balle et le tu si 0 pv
func hit():
	pv -= 1
	emit_particule()
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
			Global.joueur.recevoir_degat(damage)

func _on_Sprite_medoil_animation_finished():
	if $Sprite_medoil.animation == "mort":
		mort()
	elif $Sprite_medoil.animation == "attack":
		$Sprite_medoil.animation = "idle"
		is_attacking = false


func _on_Zone_attack_body_entered(body):
	if body == Global.joueur:
		joueur_range = true

		


func _on_Zone_attack_body_exited(body):
	if body == Global.joueur:
		joueur_range = false


func _on_Hit_box_body_entered(body):
	if body == Global.joueur:
		bobo_joueur = true
	elif body.has_method("gone"):
		body.gone()
		self.hit()


func _on_Hit_box_body_exited(body):
	if body == Global.joueur:
		bobo_joueur = false
