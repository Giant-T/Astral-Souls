extends KinematicBody2D

# Variables #
var vitesse = 500
var velocity = Vector2.ZERO
var rng = RandomNumberGenerator.new()
var degat

func start( damage, pos,joueur_position):
	degat = damage
	self.position = pos
	self.look_at(joueur_position)
	velocity = Vector2(vitesse, 0).rotated(self.rotation)

func _physics_process(delta):
	mouvement(delta)

# S'occupe du mouvement de la balle #
func mouvement(delta):
	var collision = move_and_collide(velocity * delta)
	if collision:
		if (collision.collider.has_method("recevoir_degat")):
			collision.collider.recevoir_degat(degat)
		queue_free()

# Lorsque la balle sort de l'ecran elle est detruite #
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
