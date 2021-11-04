extends KinematicBody2D

# Variables #
var velocity = Vector2.ZERO
var gravite = Vector2.ZERO
export (int) var vitesse_saut = -900
export (int) var vitesse_max = 250
export (float) var deceleration = 0.88
export (int) var acceleration = 40
var est_au_sol = false
var accroupi = false
var saute = false
const UP_DIRECTION = Vector2(0, -1)

func _physics_process(delta):
	recevoir_input()
	changer_animation()
	changer_collision()
	calc_gravite()
	se_deplacer()

# Reçoit les inputs du joueur "
func recevoir_input():
	if (Input.is_action_pressed("bas")):
		accroupi = true

	if (Input.is_action_just_released("bas")):
		accroupi = false
	
	if (Input.is_action_just_pressed("haut") && ($Pieds.is_colliding() || est_au_sol)):
		saute = true

	if (Input.is_action_pressed("droite")):
		$Sprite_joueur.flip_h = false
		if !accroupi:
			velocity.x += acceleration
	elif (Input.is_action_pressed("gauche")):
		$Sprite_joueur.flip_h = true
		if !accroupi:
			velocity.x -= acceleration

# Fonction qui calcul la gravité infliger au joueur "
func calc_gravite():
	if ($Pieds.is_colliding() || est_au_sol):
		gravite.y = 0
		if saute:
			gravite.y = vitesse_saut
			saute = false
	elif (is_on_ceiling()):
		gravite.y = acceleration
	else:
		gravite.y += acceleration

# Fonction qui gere les deplacements du joueur #
func se_deplacer():
	if (velocity != Vector2.ZERO || gravite != Vector2.ZERO):
		velocity.clamped(vitesse_max)
		gravite.clamped(vitesse_max)
		move_and_slide(velocity + gravite, UP_DIRECTION)
		est_au_sol = is_on_floor()
		velocity *= deceleration
		if (velocity.length() <= 15):
			velocity = Vector2.ZERO

# Fonction qui s'occupe de changer les animations du joueur "
func changer_animation():
	if (gravite.y == 0):
		if accroupi:
			if ($Sprite_joueur.animation != "crouch"):
				$Sprite_joueur.animation = "crouch"
		elif (velocity == Vector2.ZERO):
			$Sprite_joueur.animation = "idle"
		else:
			$Sprite_joueur.animation = "running"
			
	if (!$Pieds.is_colliding() && !est_au_sol):
		$Sprite_joueur.animation = "jump"

# Fonction qui change la collision du joueur selon sa rotation/accroupi #
func changer_collision():
	if ($Sprite_joueur.flip_h):
		$Collision_joueur.position.x = 2.668
	else:
		$Collision_joueur.position.x = -2.668
	if accroupi:
		$Collision_joueur.shape.extents.y = 28.569
		$Collision_joueur.position.y = 1.073
	elif (Input.is_action_just_released("bas") && gravite.y == 0):
		$Collision_joueur.shape.extents.y = 30.533
		$Collision_joueur.position.y = -0.946
