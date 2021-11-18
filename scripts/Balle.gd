extends KinematicBody2D

# Variables #
var vitesse = 800
var velocity = Vector2.ZERO
var rng = RandomNumberGenerator.new()

func start(pos, est_tourne, est_accroupi):
	position = pos
	var rotation_rand = 0
	if !est_accroupi:
		rng.randomize()
		rotation_rand = rng.randf_range(-3.0, 3.0)
	
	if est_tourne:
		velocity = Vector2(vitesse, 0).rotated(PI + deg2rad(rotation_rand))
		$Sprite_balle.flip_h = true
	else:
		velocity = Vector2(vitesse, 0).rotated(rotation + deg2rad(rotation_rand))

func _physics_process(delta):
	mouvement(delta)

# S'occupe du mouvement de la balle #
func mouvement(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		if (collision.collider.has_method("hit")):
			collision.collider.hit()
		queue_free()

func gone():
	queue_free()

# Lorsque la balle sort de l'ecran elle est detruite #
func _on_VisibilityNotifier2D_screen_exited():
	gone()
