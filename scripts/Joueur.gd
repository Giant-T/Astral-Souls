extends KinematicBody2D

# Variables #
var velocity = Vector2.ZERO
var gravite = Vector2.ZERO
export (int) var vitesse_saut = -900
export (int) var vitesse_max = 250
export (float) var deceleration = 0.88
export (int) var acceleration = 50
var accroupi = false
var saute = false

func _ready():
	pass

func _physics_process(delta):
	recevoir_input()
	changer_animation()
	calc_gravite()
	se_deplacer()

func recevoir_input():
	if (Input.is_action_pressed("ui_down")):
		accroupi = true

	if (Input.is_action_just_released("ui_down")):
		accroupi = false
	
	if (Input.is_action_just_pressed("ui_up") && $Gravity.is_colliding()):
		saute = true

	if (Input.is_action_pressed("ui_right")):
		$Sprite_joueur.flip_h = false
		if !accroupi:
			velocity.x += acceleration
	elif (Input.is_action_pressed("ui_left")):
		$Sprite_joueur.flip_h = true
		if !accroupi:
			velocity.x -= acceleration

func calc_gravite():
	if ($Gravity.is_colliding()):
		gravite.y = 0
		if saute:
			gravite.y = vitesse_saut
			saute = false
	else:
		gravite.y += acceleration

func se_deplacer():
	if (velocity != Vector2.ZERO || gravite != Vector2.ZERO):
		velocity.clamped(vitesse_max)
		gravite.clamped(vitesse_max)
		move_and_slide(velocity + gravite)
		velocity *= deceleration
		if (velocity.length() <= 15):
			velocity = Vector2.ZERO

func changer_animation():
	if (gravite.y == 0):
		if accroupi:
			if ($Sprite_joueur.animation != "crouch"):
				$Sprite_joueur.animation = "crouch"
		elif (velocity == Vector2.ZERO):
			$Sprite_joueur.animation = "idle"
		else:
			$Sprite_joueur.animation = "running"
			
	if (!$Gravity.is_colliding()):
		$Sprite_joueur.animation = "jump"
