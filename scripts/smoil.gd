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
const UP_DIRECTION = Vector2(0, -1)

func _ready():
	pass

func _physics_process(delta):
	collision_pieds_tilemap()
	recevoir_input()
	calc_gravite()
	se_deplacer()
	gauche_droite()

func gauche_droite():
	if(!pieds_au_sol):
		$Pieds.position.x -= $Pieds.position.x *2
		$Face.position.x -= $Face.position.x *2
		$Face.rotation_degrees += 180
		if(gauche):
			gauche =false
		else:
			gauche = true
	elif($Face.is_colliding()):
		print_debug($Face.get_collider().name.match("**Joueur****"))
		if (!$Face.get_collider().name.match("**Joueur****")):
			$Pieds.position.x -= $Pieds.position.x *2
			$Face.position.x -= $Face.position.x *2
			$Face.rotation_degrees += 180
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
