extends KinematicBody2D

# Variables en rapport au mouvement #
var velocity:Vector2 = Vector2.ZERO
var gravite:Vector2 = Vector2.ZERO
var knockback:Vector2 = Vector2.ZERO
export (int) var vitesse_saut:int = -900
export (int) var vitesse_max:int = 250
export (float) var deceleration:float = 0.88
export (int) var acceleration:int = 40
export (int) var y_vide:int = 605

var est_au_sol:bool = false
var pieds_au_sol:bool = false
var accroupi:bool = false
var saute:bool = false
var est_mort:bool = false

const UP_DIRECTION:Vector2 = Vector2(0, -1)

# Variables vie
const ECRAN_MORT = preload("res://scenes/Message_mort.tscn")
export (int) var pv = 99
export (int) var pv_max = 99

# Variables saut genereux #
var minuteur_saut = null
export (float) var delai_saut = 0.1
var peut_sauter:bool = false

# Variables en rapport au tir #
const BALLE = preload("res://scenes/Balle.tscn")
var minuteur_tir = null
export (float) var delai_balle:float = 0.2
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

func _physics_process(_delta):
	collision_pieds_tilemap()
	if (!est_mort):
		verif_peut_sauter()
		recevoir_input()
		changer_animation()
		changer_collision()
		position_pieds()
		bouger_canon()
		if (gravite.y > 0):
			verif_tomber_vide()
	calc_gravite()
	se_deplacer()

func recevoir_input():
	"""
	Sert à recevoir les inputs du joueur et ne retourne rien
	"""
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

func calc_gravite():
	"""
	Fonction qui calcul la gravité infliger au joueur
	"""
	est_au_sol = is_on_floor()
	if ((est_au_sol || pieds_au_sol || peut_sauter) && saute): 
		peut_sauter = false
		accroupi = false
		gravite.y = vitesse_saut
		est_au_sol = false
		pieds_au_sol = false
	
	if (est_au_sol || pieds_au_sol): 
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
	"""
	Vérifie si le joueur peut sauter et change la valeur de la variable peut_sauter
	"""
	if ((est_au_sol || pieds_au_sol) && minuteur_saut.is_stopped()):
		peut_sauter = true
	elif (peut_sauter && minuteur_saut.is_stopped()):
		minuteur_saut.start()

func reset_saut():
	"""
	Reset le saut lorsque le minuteur est fini
	"""
	peut_sauter = false

func se_deplacer():
	"""
	Fonction qui calcule le mouvement du joueur et le deplace
	"""
# warning-ignore:return_value_discarded
	velocity.clamped(vitesse_max)
# warning-ignore:return_value_discarded
	gravite.clamped(vitesse_max)
# warning-ignore:return_value_discarded
	move_and_slide(velocity + gravite + knockback, UP_DIRECTION)
	if (is_on_wall()):
		velocity.x = 0
	velocity *= deceleration
	knockback *= deceleration
	if (velocity.length() <= 15):
		velocity = Vector2.ZERO

func changer_animation():
	"""
	Fonction qui change l'animation du joueur
	"""
	if (gravite.y == 0):
		if accroupi:
			if ($Sprite_joueur.animation != "crouch"):
				$Sprite_joueur.animation = "crouch"
		elif (velocity == Vector2.ZERO):
			$Sprite_joueur.animation = "idle"
		else:
			$Sprite_joueur.animation = "running"
			
	if (!est_au_sol && !pieds_au_sol): 
		$Sprite_joueur.animation = "jump"

func changer_collision():
	"""
	Fonction qui déplace et change la grandeur de la collision en fonction de l'animation du joueur
	"""
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

func bouger_canon():
	"""
	Fonction qui change la position du canon en fonction de la position/rotation du joueur
	"""
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

func on_timeout_complete():
	"""
	Fonction qui permet au joueur de tirer seulement lorsque le minuteur de tire est fini
	"""
	peut_tirer = true

func tirer():
	"""
	Fonction qui génère la balle lorsque le joueur tire
	"""
	if peut_tirer:
		peut_tirer = false
		$Canon/Tir.play()
		var balle = BALLE.instance()
		balle.start($Canon.global_position, $Sprite_joueur.flip_h, accroupi)
		get_parent().add_child(balle)
		minuteur_tir.start()

func collision_pieds_tilemap():
	"""
	Fonction qui détecte la collision des raycasts avec le tilemap
	"""
	var pied_droit = false
	var pied_gauche = false
	if $Pieds_droit.is_colliding():
		var collider = $Pieds_droit.get_collider()
		if collider is TileMap:
			pied_droit = true
	if $Pieds_gauche.is_colliding():
		var collider = $Pieds_gauche.get_collider()
		if collider is TileMap:
			pied_gauche = true
	pieds_au_sol = pied_droit || pied_gauche

func position_pieds():
	"""
	Fonction qui déplace les raycasts selon la rotation du sprite
	"""
	if ($Sprite_joueur.flip_h):
		$Pieds_droit.position.x = 17
		$Pieds_gauche.position.x = -11
	else:
		$Pieds_droit.position.x = 11
		$Pieds_gauche.position.x = -17

func recevoir_degat(degat:int, position_degat:Vector2 = Vector2.ZERO, force_knockback:float = 0):
	"""
	Fonction qui permet au joueur de recevoir des degats
	degat -- Le nombre de dégat à infliger au joueur
	position_degat -- La position de la source de degat (sert à savoir d'où provient le knockback)
	force_knockback -- La force du knockback (elle est multiplié par 500 dans la fonction)
	"""
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
	"""
	Vérifie si le joueur tombe dans le vide
	"""
	if (position.y >= y_vide):
		mourir()

func mourir():
	"""
	Gère la mort du joueur
	"""
	$Flash_canon.visible = false
	if (Global.auDela && !Global.auDela.has_node("Message_mort")):
		var ecran_mort = ECRAN_MORT.instance()
		ecran_mort.name = 'Message_mort'
		Global.auDela.add_child(ecran_mort, true)
	if ($Sprite_joueur.animation != "die"):
		est_mort = true
		$Sprite_joueur.play("die")

func _on_Joueur_tree_exited():
	Global.joueur = null
