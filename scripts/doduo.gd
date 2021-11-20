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
export (int) var balle_degat = 20
export (bool) var changer_orientation_depart = false
var immovible = false
var est_au_sol = false
var pieds_au_sol = true
var gauche = false
const UP_DIRECTION = Vector2(0, -1)
var joueur_range = false 
var is_attacking = false 
var bobo_joueur = false
var phase = 0

const Balle = preload("res://scenes/Balle_doduo.tscn")
var minuteur_tir = null
export (float) var delai_balle = 2
var peut_tirer = true
var innactif = true

func _ready():
	pv = pv_max
	$Sprite_doduo.animation = "idle"
	changer_zone()
	gauche = true
	immovible = false
		# minuteur_tir pour le delai de tir #
	minuteur_tir = Timer.new()
	minuteur_tir.set_one_shot(true)
	minuteur_tir.set_wait_time(delai_balle)
	minuteur_tir.connect("timeout", self, "on_timeout_complete")
	add_child(minuteur_tir)
	pass

func _physics_process(delta):
	if !innactif:
		infliger_degat()
		collision_pieds_tilemap()
		if(phase == 0):
			tirer()
			if pv < pv_max /3 *2:
				phase = 1
		elif (phase == 1):
			if $Sprite_doduo.animation != "marche":
				$Sprite_doduo.animation = "marche"
			recevoir_input()
			se_deplacer()
			gauche_droite()
			if pv < pv_max /3:
				phase = 2
				vitesse_max *= 2
				acceleration *=2
				minuteur_tir.set_wait_time(delai_balle/2)
		else:
			tirer()
			recevoir_input()
			se_deplacer()
			gauche_droite()

#tourne le le doduo si il frappe un mur un troue ou le joueur
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
		


# Reçoit les inputs du doduo #
func recevoir_input():
	if (!gauche):
		velocity.x += acceleration
	elif (gauche):
		velocity.x -= acceleration
	


# Fonction qui gere les deplacements du doduo #
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
#Inflige des deget au joueur si il passe dans le monstre
func infliger_degat():
	if bobo_joueur:
		joueur.recevoir_degat(damage)



#quand l'enemy prend une balle devien de plus en plus rouge et meurt a 0 pv
func hit():
	pv -= 1
	self.set_modulate(Color(1,float(pv)/float(pv_max),float(pv)/float(pv_max)))
	if(pv< 1):
		set_physics_process(false)
		$Sprite_doduo.animation = "mort"
		joueur_range = false
		
#fait disparaitre le mob
func mort():
	self.queue_free()
#retourne le monstre si il es pas du bon coter
func changer_zone():
	self.scale.x *=-1
#Timer pour tirer
func on_timeout_complete():
	peut_tirer = true
	
#instancie une balle lorsqu'il peut tirer
func tirer():
	if peut_tirer:
		peut_tirer = false
		var balle = Balle.instance()
		balle.start(20, $Canon.global_position,  joueur.global_position)
		get_parent().add_child(balle)
		minuteur_tir.start()
			
func _on_Sprite_doduo_animation_finished():
	if $Sprite_doduo.animation == "mort":
		mort()
	elif $Sprite_doduo.animation == "attack":
		$Sprite_doduo.animation = "idle"
		is_attacking = false


func _on_Hit_box_body_entered(body):
	if body == joueur:
		bobo_joueur = true
	elif body.has_method("gone"):
		body.gone()
		self.hit()

func _on_Hit_box_body_exited(body):
	if body == joueur:
		bobo_joueur = false


func _on_Detection_body_entered(body):
	
	if body == joueur:
		innactif = false


func _on_Detection_body_exited(body):
	if body == joueur:
		innactif = true
