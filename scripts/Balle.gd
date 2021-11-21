extends KinematicBody2D

# Variables #
var vitesse = 800
var velocity = Vector2.ZERO
var rng = RandomNumberGenerator.new()

func start(pos:Vector2, est_tourne:bool, est_accroupi:bool):
	"""
	Fonction qui sert a instancier une balle
	pos -- Vector2 qui represente la position initial de la balle
	est_tourne -- Represente si le joueur est tourne ainsi que la rotation de la balle
	est_accroupri --- Indique si la balle doit avoir une rotation aléatoire ou non
	"""
	position = pos
	var rotation_rand = 0
	if !est_accroupi:
		rng.randomize()
		rotation_rand = rng.randf_range(-3.0, 3.0)
	
	if est_tourne:
		velocity = Vector2(vitesse, 0).rotated(PI + deg2rad(rotation_rand))
		$Sprite_balle.flip_h = true
		$Particule_tir.position.x *= -1
		$Particule_tir.rotate(PI)
	else:
		velocity = Vector2(vitesse, 0).rotated(rotation + deg2rad(rotation_rand))

func _physics_process(delta):
	mouvement(delta)
	if ($Collision_balle.disabled && !$Particule_tir.emitting):
		queue_free()

func mouvement(delta:float):
	"""
	Fonction qui deplace la balle en direction de sa rotation
	"""
	var collision = move_and_collide(velocity * delta)
	if collision:
		if (collision.collider.has_method("hit")):
			collision.collider.hit()
		gone()

func gone():
	"""
	Fonction qui arrete le deplacement de la balle et commence les particules
	"""
	velocity = Vector2.ZERO
	$Collision_balle.disabled = true
	$Sprite_balle.visible = false
	$Particule_tir.emitting = true

func _on_VisibilityNotifier2D_screen_exited():
	"""
	Lorse la balle sort de l'ecran elle se fait detruire
	"""
	queue_free()
