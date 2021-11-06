extends KinematicBody2D

# Variables #
var vitesse = 800
var velocity = Vector2.ZERO

func start(pos, est_tourne):
	position = pos
	if est_tourne:
		velocity = Vector2(vitesse, 0).rotated(PI)
	else:
		velocity = Vector2(vitesse, 0)

func _physics_process(delta):
	mouvement(delta)

# S'occupe du mouvement de la balle #
func mouvement(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		if (collision.collider.has_method("hit")):
			collision.collider.hit()
		queue_free()

# Lorsque la balle sort de l'ecran elle est detruite #
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
