extends KinematicBody2D

# Variables en rapport au mouvement #
var velocity = Vector2.ZERO
var gravite = Vector2.ZERO
export (int) var pv = 99
export (int) var pv_max = 99
export (int) var vitesse_saut = -900
export (int) var vitesse_max = 15
export (float) var deceleration = 0.88
export (int) var acceleration = 15
export (int) var damage = 13
var est_au_sol = false
var pieds_au_sol = true
var accroupi = false
var saute = false
var gauche = false
var vielle_pos
const UP_DIRECTION = Vector2(0, -1)

# Variables en rapport au tir #
const Balle = preload("res://scenes/Balle.tscn")
var minuteur = null
export (float) var delai_balle = 0.2
var peut_tirer = true

func _ready():
	# Minuteur pour le delai de tir #
	minuteur = Timer.new()
	minuteur.set_one_shot(true)
	minuteur.set_wait_time(delai_balle)
	minuteur.connect("timeout", self, "on_timeout_complete")
	add_child(minuteur)
	vielle_pos = self.position

func _physics_process(delta):
	collision_pieds_tilemap()
	recevoir_input()
	changer_collision()
	calc_gravite()
	se_deplacer()
	gauche_droite()

func gauche_droite():
	if(!pieds_au_sol||vielle_pos == self.position):
		$Pieds.position.x -= $Pieds.position.x *2
		if(gauche):
			gauche =false
		else:
			gauche = true


# Reçoit les inputs du smoil #
func recevoir_input():
	if (!gauche):
		$Sprite_smoil.flip_h = false
		velocity.x += acceleration
	elif (gauche):
		$Sprite_smoil.flip_h = true
		velocity.x -= acceleration
	
	
# Fonction qui calcul la gravité infliger au smoil #
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

# Fonction qui gere les deplacements du smoil #
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


# Fonction qui change la collision du smoil selon sa rotation/accroupi #
func changer_collision():
	if ($Sprite_smoil.flip_h):
		$Collision_smoil.position.x = 3
	else:
		$Collision_smoil.position.x = -3
	
# S'execute lorsque le timer arrive a zero #
func on_timeout_complete():
	peut_tirer = true
	
# Lorsque le smoil tire #
func tirer():
	if peut_tirer:
		peut_tirer = false
		var balle = Balle.instance()
		balle.start($Canon.global_position, $Sprite_smoil.flip_h)
		get_parent().add_child(balle)
		minuteur.start()

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
	$Sprite_smoil.animation = "mort"
	
func mort():
	self.queue_free()


func _on_Sprite_smoil_animation_finished():
	if $Sprite_smoil.animation == "mort":
		mort()
