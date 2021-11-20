extends KinematicBody2D
onready var joueur = get_node_or_null("../Joueur")
# Variables en rapport au mouvement #
var velocity = Vector2.ZERO
var pv
export (int) var pv_max = 99
export (int) var damage = 13
export (int) var balle_degat = 20
export (bool) var changer_orientation_depart = false
var gauche = false
const UP_DIRECTION = Vector2(0, -1)
var joueur_range = false 
var is_attacking = false 
var bobo_joueur = false
var phase = 0

const Balle = preload("res://scenes/Balle_doduo.tscn")
const Medoil = preload("res://scenes/medoil_spawnable.tscn")
var minuteur_tir = null
var minuteur_medoil = null
export (float) var delai_balle = 2
export (float) var delai_medoil = 5
var peut_tirer = true
var peut_spawn = true
var innactif = true

func _ready():
	pv = pv_max
	$Sprite_Heart.animation = "idle"
	if changer_orientation_depart:
		changer_zone()
		gauche = true
		# minuteur_tir pour le delai de tir #
	minuteur_tir = Timer.new()
	minuteur_tir.set_one_shot(true)
	minuteur_tir.set_wait_time(delai_balle)
	minuteur_tir.connect("timeout", self, "on_timeout_complete")
	add_child(minuteur_tir)
	# minuteur_spawn medoil pour le delai de spawnage des medoil #
	minuteur_medoil = Timer.new()
	minuteur_medoil.set_one_shot(true)
	minuteur_medoil.set_wait_time(delai_medoil)
	minuteur_medoil.connect("timeout", self, "on_timeout_complete_spawn")
	add_child(minuteur_medoil)
	pass

func _physics_process(delta):
	if !innactif:
		infliger_degat()
		tirer()
		spawner()
		if(phase == 0):
			if pv <= pv_max /3 *2:
				phase = 1
				minuteur_tir.set_wait_time(delai_balle/2)
				minuteur_medoil.set_wait_time(delai_medoil/2)
		elif (phase == 1):
			if pv <= pv_max /3:
				phase = 2
				minuteur_tir.set_wait_time(delai_balle/4)
				minuteur_medoil.set_wait_time(delai_medoil/4)

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
		joueur_range = false
		mort()
		
	
#fait disparaitre le mob
func mort():
	self.queue_free()
	
#retourne le monstre si il es pas du bon coter
func changer_zone():
	self.scale.x *=-1

#Timer pour tirer
func on_timeout_complete():
	peut_tirer = true
#Timer pour spawner des slime
func on_timeout_complete_spawn():
	peut_spawn = true
	
#instancie une balle lorsqu'il peut tirer
func tirer():
	if peut_tirer:
		peut_tirer = false
		var balle = Balle.instance()
		balle.start(20, $Canon.global_position,  joueur.global_position)
		get_parent().add_child(balle)
		minuteur_tir.start()
#instancie un slime lorsqu'il peut en spawner 1
func spawner():
	if peut_spawn:
		peut_spawn = false
		var medoil = Medoil.instance()
		medoil.start(!gauche,$Slime.global_position)
		get_parent().add_child(medoil)
		minuteur_medoil.start()
		

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
