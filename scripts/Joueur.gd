extends KinematicBody2D

# Variables #
var velocity = Vector2.ZERO
export (int) var vitesse_max = 250
export (float) var deceleration = 0.88
export (int) var acceleration = 50
var accroupi = false

func _ready():
	pass

func _physics_process(delta):
	recevoir_input()
	se_deplacer()
	changer_animation()

func recevoir_input():
	if (Input.is_action_pressed("ui_down")):
		accroupi = true

	if (Input.is_action_just_released("ui_down")):
		accroupi = false

	if (Input.is_action_pressed("ui_right")):
		$Sprite_joueur.flip_h = false
		if !accroupi:
			velocity.x += acceleration
	elif (Input.is_action_pressed("ui_left")):
		$Sprite_joueur.flip_h = true
		if !accroupi:
			velocity.x -= acceleration

func se_deplacer():
	if (velocity != Vector2.ZERO):
		velocity.clamped(vitesse_max)
		move_and_slide(velocity)
		velocity *= deceleration
		if (velocity.length() <= 15):
			velocity = Vector2.ZERO

func changer_animation():
	if (velocity.y <= 15):
		if accroupi:
			if ($Sprite_joueur.animation != "crouch"):
				$Sprite_joueur.animation = "crouch"
		elif (velocity == Vector2.ZERO):
			$Sprite_joueur.animation = "idle"
		else:
			$Sprite_joueur.animation = "running"
