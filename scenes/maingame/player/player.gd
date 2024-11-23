class_name Player
extends CharacterBody2D

signal coin_collected()
signal died()

const WALK_SPEED = 300.0
const ACCELERATION_SPEED = WALK_SPEED * 6.0
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
@onready var spit: SpitNut = sprite.get_node(^"SpitNut")
@onready var melee: MeleeAttack = sprite.get_node(^"MeleeAttack")
@onready var camera := $Camera as Camera2D

var _isClimbing := false

@onready var health_ui_amount = $UI/HealthLabel/HealthAmount
@onready var collision_shape = $CollisionShape2D
var _double_jump_charged := false

var _is_damage_state := false
const FRAME_FLICKER_AMOUNT = 4

@export var MAX_HEALTH := 100;
@export var CURRENT_HEALTH : int:
		set(value):
			CURRENT_HEALTH = value
			health_ui_amount.text = str(value)
			
@export var IFRAME_DURATION_IN_MS := 400.0
			
func _ready() -> void:
	CURRENT_HEALTH = MAX_HEALTH
	_is_damage_state = false

func _physics_process(delta: float) -> void:
	if is_on_floor():
		_isClimbing = false
		
	if Input.is_action_just_pressed("toggle_climb"):
		_isClimbing = !_isClimbing
		velocity.y = 0
		velocity.x = 0
	
	if Input.is_action_just_pressed("jump" + action_suffix):
		try_jump()
	elif Input.is_action_just_released("jump" + action_suffix) and velocity.y < 0.0:
		# The player let go of jump early, reduce vertical momentum.
		velocity.y *= 0.6
	
	# Fall if not climbing	
	if !_isClimbing:
		velocity.y = minf(TERMINAL_VELOCITY, velocity.y + gravity * delta)	

	var xDirection := Input.get_axis("move_left" + action_suffix, "move_right" + action_suffix)
	
	if _isClimbing:
		var yDirection := Input.get_axis("move_up" + action_suffix, "move_down" + action_suffix) * WALK_SPEED
		velocity.y = move_toward(velocity.y, yDirection, ACCELERATION_SPEED * delta)
		
		xDirection *= CLIMB_HORIZONTAL_SPEED
		velocity.x = move_toward(velocity.x, xDirection, ACCELERATION_SPEED * delta)
	else:		
		xDirection *= WALK_SPEED
		velocity.x = move_toward(velocity.x, xDirection, ACCELERATION_SPEED * delta)

	if not is_zero_approx(velocity.x) and not _is_damage_state:
		if velocity.x > 0.0:
			sprite.scale.x = 1.0
		else:
			sprite.scale.x = -1.0

	floor_stop_on_slope = not platform_detector.is_colliding()
	move_and_slide()

	var is_shooting := false
	if Input.is_action_just_pressed("spit" + action_suffix):
		is_shooting = spit.shoot(sprite.scale.x)

	var is_attacking := false
	if Input.is_action_just_pressed("melee" + action_suffix):
		is_shooting = melee.attack(sprite.scale.x)

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
	return animation_new


func try_jump() -> void:	
	if is_on_floor():
		jump_sound.pitch_scale = 1.0
		velocity.y = JUMP_VELOCITY
		jump_sound.play()	
	else:
		return
	
func hit(damage, source: Node):
	if _is_damage_state == false:
		CURRENT_HEALTH -= damage
		if (CURRENT_HEALTH <= 0):
			died.emit()
		else:
			_is_damage_state = true
			if (source is Enemy):
				var enemy = source
				
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
	
