class_name Player
extends CharacterBody2D

signal coin_collected()
signal died()
signal bossZoneTriggerPlayer()
signal bossZoneLeavePlayer()

const WALK_SPEED = 300.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
const RUN_MODIFIER = 1.5
const JUMP_VELOCITY = -725.0
## Maximum speed at which the player can fall.
const TERMINAL_VELOCITY = 700
## Climb settings
const CLIMB_HORIZONTAL_SPEED = 160

## The player listens for input actions appended with this suffix.[br]
## Used to separate controls for multiple players in splitscreen.
@export var action_suffix := ""

@export var gravity: int = ProjectSettings.get("physics/2d/default_gravity")
@onready var platform_detector := $PlatformDetector as RayCast2D
@onready var animation_player := $AnimationPlayer as AnimationPlayer
@onready var shoot_timer := $ShootAnimation as Timer
@onready var sprite := $Sprite2D as Sprite2D
@onready var jump_sound := $Jump as AudioStreamPlayer2D
@onready var ouch_sound := $Ouch as AudioStreamPlayer2D
@onready var spit: SpitNut = sprite.get_node(^"SpitNut")
@onready var melee: MeleeAttack = sprite.get_node(^"Melee")
#@onready var camera := $Camera as PlayerCamera

var _isFlying := false
var _isMelee := false


@onready var health_ui_amount = $UI/HealthLabel/HealthAmount
@onready var acorns_ui_amount = $UI/AcornLabel/AcornAmount
@onready var collision_shape = $CollisionShape2D

var _is_damage_state := false
const FRAME_FLICKER_AMOUNT = 4

@export var MAX_HEALTH := 100;
@export var CURRENT_HEALTH : int:
		set(value):
			CURRENT_HEALTH = max(value, 0)
			health_ui_amount.text = str(CURRENT_HEALTH)
			
@export var IFRAME_DURATION_IN_MS := 400.0

@export var ACORNS := 0 :
		set(value):
			ACORNS = value
			acorns_ui_amount.text = str(value)

var alive = true
			
func _ready() -> void:
	CURRENT_HEALTH = MAX_HEALTH
	_is_damage_state = false

func _physics_process(delta: float) -> void:
	if is_on_floor():
		_isFlying = false
	
	if Input.is_action_just_pressed("jump" + action_suffix):
		try_jump()
	elif Input.is_action_just_released("jump" + action_suffix) and velocity.y < 0.0:
		# The player let go of jump early, reduce vertical momentum.
		velocity.y *= 0.6
	
	# Fall if not flying	
	if !_isFlying || !Input.is_action_pressed("jump"):
		velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)
		_isFlying = false
	else:
		var yDirection := Input.get_axis("move_up" + action_suffix, "move_down" + action_suffix) * WALK_SPEED
		velocity.y = move_toward(velocity.y, yDirection, ACCELERATION_SPEED * delta)

	var xDirection := Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix)
	xDirection *= WALK_SPEED
	
	if Input.is_action_pressed("run") && is_on_floor():
		xDirection *= RUN_MODIFIER
	
	velocity.x = move_toward(velocity.x, xDirection, ACCELERATION_SPEED * delta)			

	if not is_zero_approx(velocity.x) and not _is_damage_state:
		if velocity.x > 0.0:
			sprite.scale.x = 1.0
		else:
			sprite.scale.x = -1.0

	floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()

	var is_shooting := false
	
	if Input.is_action_just_pressed("spit" + action_suffix) and ACORNS > 0:
		is_shooting = spit.shoot(sprite.scale.x)
		if is_shooting:
			ACORNS -= 1

	var is_attacking := false
	_isMelee = false
	if Input.is_action_just_pressed("melee" + action_suffix):
		is_shooting = melee.attack(sprite.scale.x)
		_isMelee = true

	var animation := get_new_animation(is_shooting)
	if animation != animation_player.current_animation and shoot_timer.is_stopped():
		if is_shooting:
			shoot_timer.start()
		animation_player.play(animation)


func get_new_animation(is_shooting := false) -> String:
	var animation_new: String
	if is_on_floor():
		if absf(velocity.x) > 0.1:
			animation_new = "run"
		else:
			animation_new = "idle"
	else:
		if velocity.y > 0.0:
			animation_new = "falling"
		else:
			animation_new = "jumping"
	if is_shooting:
		animation_new += "_weapon"
		
	if _isFlying:
		animation_new = "climb"	
		
	if _isMelee:
		animation_new = "melee"
		
	if _is_damage_state:
		animation_new = "damaged"
	
	return animation_new


func try_jump() -> void:
	if is_on_floor():
		jump_sound.pitch_scale = 1.0
		velocity.y = JUMP_VELOCITY
		jump_sound.play()
	elif _isFlying == true:
		_isFlying = false
	else:
		_isFlying = true
		velocity.y = JUMP_VELOCITY
	
func hit(damage, source: Node):
	if _is_damage_state == false:
		ouch_sound.play()
		CURRENT_HEALTH -= damage
		if (CURRENT_HEALTH <= 0 and alive):
			alive = false
			died.emit()
		else:
			_is_damage_state = true
				
			if (source is Hornet):
				velocity = source.velocity * 2
			else:
			# push the player back
				velocity = -velocity
			if (abs(velocity.x) > abs(velocity.y)):
				velocity.x *= 1.5 
		
			await trigger_invincible(IFRAME_DURATION_IN_MS)
		
		_is_damage_state = false
	pass
	
	
func trigger_invincible(duration_in_ms) -> void:
	var duration_per_flicker = duration_in_ms / FRAME_FLICKER_AMOUNT / 2
	for i in FRAME_FLICKER_AMOUNT:
		sprite.visible = false
		await get_tree().create_timer(duration_per_flicker / 1000).timeout
		sprite.visible = true
		await get_tree().create_timer(duration_per_flicker / 1000).timeout
	# Replace with function body.

func _on_boss_zone_trigger() -> void:
	bossZoneTriggerPlayer.emit()	

func acorn_collected() -> void:
	ACORNS = ACORNS + 1
	
func healberry_collected(heal_amount) -> void:
	var new_health_theoretical = min(CURRENT_HEALTH, MAX_HEALTH) + heal_amount
	var new_health_actual = CURRENT_HEALTH if CURRENT_HEALTH > MAX_HEALTH else min(MAX_HEALTH, new_health_theoretical)
		
	var healed_amount = max(new_health_actual - CURRENT_HEALTH, 0)
	var overheal = floor((heal_amount - healed_amount) / 2)

	CURRENT_HEALTH = new_health_actual + overheal

func _on_mini_boss_trigger_area_body_entered(body: Node2D) -> void:
#	const MINI_BOSS_CAMERA_LOWER_LIMIT = -2564
#	camera.setCameraLimits(MINI_BOSS_CAMERA_LOWER_LIMIT)
	pass
