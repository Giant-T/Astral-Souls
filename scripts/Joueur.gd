extends KinematicBody2D

# Variables en rapport au mouvement #
var velocity:Vector2 = Vector2.ZERO
var gravite:Vector2 = Vector2.ZERO
var knockback:Vector2 = Vector2.ZERO
export (int) var vitesse_saut = -900
export (int) var vitesse_max = 250
export (float) var deceleration = 0.88
export (int) var acceleration = 40
export (int) var y_vide = 605

var est_au_sol:bool = false
var pieds_au_sol:bool = false
var accroupi:bool = false
var saute:bool = false
var est_mort:bool = false

const UP_DIRECTION:Vector2 = Vector2(0, -1)

export (int) var pv = 99
export (int) var pv_max = 99

# Variables saut genereux #
var minuteur_saut = null
export (float) var delai_saut = 0.1
var peut_sauter:bool = false

# Variables en rapport au tir #
const Balle = preload("res://scenes/Balle.tscn")
var minuteur_tir = null
export (float) var delai_balle = 0.2
var peut_tirer:bool = true

func _ready():
	Global.joueur = self
	
	# minuteur_tir pour le delai de tir #
	minuteur_tir = Timer.new()
	minuteur_tir.set_one_shot(true)
	minuteur_tir.set_wait_time(delai_balle)
	minuteur_tir.connect("timeout", self, "on_timeout_complete")
	add_child(minuteur_tir)
	
	# minuteur saut genereux #
	minuteur_saut = Timer.new()
	minuteur_saut.set_one_shot(true)
	minuteur_saut.set_wait_time(delai_saut)
	minuteur_saut.connect("timeout", self, "reset_saut")
	add_child(minuteur_saut)

func _physics_process(delta):
	collision_pieds_tilemap()
	if (!est_mort):
		verif_peut_sauter()
		recevoir_input()
		changer_animation()
		changer_collision()
		bouger_canon()
		verif_tomber_vide()
	calc_gravite()
	se_deplacer()

# Reçoit les inputs du joueur #
func recevoir_input():
	if (Input.is_action_pressed("bas")):
		accroupi = true

	if (Input.is_action_just_released("bas")):
		accroupi = false
	
	if (Input.is_action_just_pressed("haut") && peut_sauter):
		saute = true

	if (Input.is_action_pressed("droite")):
		$Sprite_joueur.flip_h = false
		$Flash_canon.flip_h = false
		if !accroupi:
			velocity.x += acceleration
	elif (Input.is_action_pressed("gauche")):
		$Sprite_joueur.flip_h = true
		$Flash_canon.flip_h = true
		if !accroupi:
			velocity.x -= acceleration
	
	if (Input.is_action_pressed("tirer")):
		$Flash_canon.visible = true
		tirer()
	else:
		$Flash_canon.visible = false

# Fonction qui calcul la gravité infliger au joueur #
func calc_gravite():
	est_au_sol = is_on_floor()
	if ((est_au_sol || pieds_au_sol || peut_sauter) && saute):
		peut_sauter = false
		accroupi = false
		gravite.y = vitesse_saut
		est_au_sol = false
		pieds_au_sol = false
	
	if (pieds_au_sol || est_au_sol):
		gravite.y = 0
	elif (Input.is_action_just_released("haut") && saute):
		saute = false
		gravite.y /= 2
	elif (is_on_ceiling()):
		gravite.y = acceleration
	else:
		gravite.y += acceleration
	
	if (gravite.y > 0 && saute):
		saute = false

func verif_peut_sauter():
	if (est_au_sol || pieds_au_sol):
		peut_sauter = true
	elif (peut_sauter && minuteur_saut.is_stopped()):
		minuteur_saut.start()

func reset_saut():
	peut_sauter = false

# Fonction qui gere les deplacements du joueur #
func se_deplacer():
	if (velocity != Vector2.ZERO || gravite != Vector2.ZERO):
		velocity.clamped(vitesse_max)
		gravite.clamped(vitesse_max)
		move_and_slide(velocity + gravite + knockback, UP_DIRECTION)
		velocity *= deceleration
		knockback *= deceleration
		if (velocity.length() <= 15):
			velocity = Vector2.ZERO

# Fonction qui s'occupe de changer les animations du joueur #
func changer_animation():
	if (gravite.y == 0):
		if accroupi:
			if ($Sprite_joueur.animation != "crouch"):
				$Sprite_joueur.animation = "crouch"
		elif (velocity == Vector2.ZERO):
			$Sprite_joueur.animation = "idle"
		else:
			$Sprite_joueur.animation = "running"
			
	if (!pieds_au_sol && !est_au_sol):
		$Sprite_joueur.animation = "jump"

# Fonction qui change la collision du joueur selon sa rotation/accroupi #
func changer_collision():
	if ($Sprite_joueur.flip_h):
		$Collision_joueur.position.x = 3
	else:
		$Collision_joueur.position.x = -3
	if accroupi:
		$Collision_joueur.shape.extents.y = 28
		$Collision_joueur.position.y = 1
	elif (Input.is_action_just_released("bas") && gravite.y == 0):
		$Collision_joueur.shape.extents.y = 30.5
		$Collision_joueur.position.y = -1

# Fonction qui bouge le canon du joueur selon sa rotaion/accroupi #
func bouger_canon():
	if (!$Sprite_joueur.flip_h):
		$Canon.position.x = 48
		$Flash_canon.position.x = 44
	else:
		$Canon.position.x = -48
		$Flash_canon.position.x = -44
	
	if ($Sprite_joueur.animation == "crouch" && $Sprite_joueur.frame == 2):
		$Canon.position.y = 5
		$Flash_canon.position.y = 5
	elif ($Sprite_joueur.animation == "running" && ($Sprite_joueur.frame == 1 || $Sprite_joueur.frame == 3)):
		$Canon.position.y = -10
		$Flash_canon.position.y = -10
	else:
		$Canon.position.y = -4
		$Flash_canon.position.y = -4

# S'execute lorsque le timer arrive a zero #
func on_timeout_complete():
	peut_tirer = true

# Lorsque le joueur tire #
func tirer():
	if peut_tirer:
		peut_tirer = false
		var balle = Balle.instance()
		balle.start($Canon.global_position, $Sprite_joueur.flip_h, accroupi)
		get_parent().add_child(balle)
		minuteur_tir.start()

func collision_pieds_tilemap():
	if $Pieds.is_colliding():
		var collider = $Pieds.get_collider()
		if collider is TileMap:
			pieds_au_sol = true
		else:
			pieds_au_sol = false
	else:
		pieds_au_sol = false

func recevoir_degat(degat:int, position_degat:Vector2 = Vector2.ZERO, force_knockback = 0):
	if !$Sprite_joueur/AnimationPlayer.is_playing():
		var pv_temp = pv - degat
		if (pv_temp <= 0):
			pv = 0
			mourir()
		else:
			pv = pv_temp
			$Sprite_joueur/AnimationPlayer.play("degat")
			force_knockback *= 500
			knockback =  Vector2(force_knockback, 0).rotated(position.angle_to(position_degat) + PI)

func verif_tomber_vide():
	if (position.y >= y_vide):
		mourir()

func mourir():
	if ($Sprite_joueur.animation != "die"):
		est_mort = true
		$Sprite_joueur.play("die")


func _on_Joueur_tree_exited():
	Global.joueur = null
